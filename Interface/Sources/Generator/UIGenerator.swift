//
//  UIGenerator.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 26/02/2018.
//

import Tokenizer
import SwiftCodeGen

public class UIGenerator: Generator {
    public let root: ComponentDefinition
    public let componentContext: ComponentContext

    private let styleGroupGenerator: StyleGroupGenerator

    private var tempCounter: Int = 1

    public init(componentContext: ComponentContext, configuration: GeneratorConfiguration) {
        self.root = componentContext.component
        self.componentContext = componentContext
        self.styleGroupGenerator = StyleGroupGenerator(
            context: componentContext,
            styleGroup: StyleGroup(name: root.stylesName, accessModifier: root.modifier, styles: root.styles))
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> Describable {
        let viewAccessibility: Accessibility = componentContext.component.modifier == .public || configuration.defaultModifier == .public ? .public : .internal

        let triggerReloadPaths = Expression.arrayLiteral(items:
            [configuration.localXmlPath].map { Expression.constant(#""\#($0)""#) }
        )

        let viewProperties: [SwiftCodeGen.Property] = [
            .constant(accessibility: viewAccessibility, modifiers: .static, name: "triggerReloadPaths", type: "Set<String>", value: triggerReloadPaths),
            .constant(accessibility: viewAccessibility, name: "layout", value: .constant("Constraints()")),
            .constant(accessibility: viewAccessibility, name: "state", type: "State"),
            .constant(accessibility: root.providedActions.isEmpty ? .private : viewAccessibility, name: "actionPublisher", type: "ActionPublisher<Action>"),
        ]

        let viewDeclarations = try root.allChildren.map { child in
            SwiftCodeGen.Property.constant(
                accessibility: child.isExported ? viewAccessibility : .private,
                name: child.id.description,
                type: try child.runtimeType(for: componentContext.platform).name)
        }

        let injectedChildren = root.allInjectedChildren

        tempCounter = 1
        let viewInitializations = try root.allChildren.map { child -> Statement in
            guard !child.isInjected else {
                return .assignment(target: .member(target: .constant("self"), name: child.id.description), expression: .constant(child.id.description))
            }

            guard let providesInitialization = child as? ProvidesCodeInitialization else {
                #warning("FIXME Replace with throwing an error")
                fatalError()
            }

            return .assignment(target: .constant(child.id.description), expression: try providesInitialization.initialization(for: componentContext.platform, context: componentContext))
        }

        var viewInheritances: [String] = []
        if configuration.isLiveEnabled {
            viewInheritances.append("LiveHyperViewBase")
        } else {
            viewInheritances.append("HyperViewBase")
        }
        if injectedChildren.isEmpty {
            viewInheritances.append("HyperView")
        } else {
            viewInheritances.append("ComposableHyperView")
        }

        let viewSuperCall: Block
        if configuration.isLiveEnabled {
            viewSuperCall = [
                .expression(
                    .invoke(target: .member(target: .constant("super"), name: "init"), arguments: [
                        MethodArgument(name: "worker", value: .constant("bundleWorker")),
                        MethodArgument(name: "typeName", value: .constant("\"\(root.type)\"")),
                        MethodArgument(name: "xmlPath", value: .constant("\"\(configuration.localXmlPath)\""))
                    ]))
            ]
        } else {
            viewSuperCall = [
                .expression(.constant("super.init()"))
            ]
        }

        let viewInit = try Function.initializer(
            accessibility: viewAccessibility,
            parameters: [
                .init(name: "initialState", type: "State", defaultValue: "State()"),
                .init(name: "actionPublisher", type: "ActionPublisher<Action>", defaultValue: "ActionPublisher()"),
            ] + injectedChildren.map { child in
                try MethodParameter(name: child.id.description, type: child.runtimeType(for: componentContext.platform).name)
            },
            block:
                Block(statements: viewInitializations) +
                Block(statements: [
                    .emptyLine,
                    .expression(.constant("state = initialState")),
                    .expression(.constant("self.actionPublisher = actionPublisher")),
                    .emptyLine,
                ]) +
                viewSuperCall +
                Block(statements: [
                    .emptyLine,
                    .expression(.constant("loadView()")),
                    .expression(.constant("setupConstraints()")),
                    .expression(.constant("initialState.owner = self")),
                    .expression(.constant("observeActions(actionPublisher: actionPublisher)")),
                ]))

        let stateProperties: [SwiftCodeGen.Property] = [
            .variable(accessibility: .fileprivate, modifiers: .weak, name: "owner", type: "\(root.type)?", block: [
                .expression(.constant("didSet { resynchronize() }"))
            ]),
        ]

        let stateItems = try componentContext.resolve(state: root)

        let stateVariables = stateItems.map { _, item -> SwiftCodeGen.Property in
//            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
//            let defaultValue = property.anyDescription.anyDefaultValue
            return SwiftCodeGen.Property.variable(
                name: item.name,
                type: item.typeFactory.runtimeType(for: componentContext.platform).name,
                value: item.defaultValue.generate(context: SupportedPropertyTypeContext(parentContext: componentContext, value: .value(item.defaultValue))),
                block: [
                    .expression(.constant("didSet { notify\(item.name.capitalizingFirstLetter())Changed() }"))
                ])
        }

        let stateNotifyFunctions = stateItems.map { _, item -> Function in
            let handlerInvoke: [Statement]
            if let handler = item.description?.item.handler {
                handlerInvoke = [
                    .expression(.invoke(target: .member(target: .constant("owner"), name: handler), arguments: [
                        MethodArgument(name: item.name, value: .constant(item.name))
                    ]))
                ]
            } else {
                handlerInvoke = []
            }

            return Function(
                accessibility: .private,
                modifiers: .final,
                name: "notify\(item.name.capitalizingFirstLetter())Changed",
                block: Block(statements:
                    [.guard(conditions: [ConditionExpression.conditionalUnwrap(isConstant: true, name: "owner", expression: .constant("owner"))], else: [.return(expression: nil)])] +
                    item.applications.map { application in
                        let propertyContext = PropertyContext(parentContext: componentContext, property: application.property.property)
                        let view = (application.element as? UIElement).map { "owner.\($0.id.description)" } ?? "owner"
                        return application.property.property.application(on: view, context: propertyContext)
                    } +
                    handlerInvoke))
        }

        let stateFunctions: [Function] = [
            .initializer(accessibility: viewAccessibility),
            .init(
                accessibility: viewAccessibility,
                name: "apply",
                parameters: [.init(label: "from", name: "otherState", type: "State")],
                block: Block(statements: stateItems.map { _, item in
                    Statement.assignment(target: .constant(item.name), expression: .constant("otherState.\(item.name)"))
                })),
            .init(
                accessibility: viewAccessibility,
                name: "resynchronize",
                block: Block(statements: stateNotifyFunctions.map {
                    Statement.expression(.invoke(target: .constant($0.name), arguments: []))
                })),
        ]

        let resolvedActions = try componentContext.resolve(actions: root.providedActions)

        let stateClass = Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: "State",
            inheritances: ["HyperViewState"],
            properties: stateProperties + stateVariables,
            functions: stateFunctions + stateNotifyFunctions)

        let actionEnum = Structure.enum(
            accessibility: viewAccessibility,
            name: "Action",
            cases: resolvedActions.map { action in
                Structure.EnumCase(name: action.name, arguments: action.parameters.map { parameter -> (name: String?, type: String) in
                    (name: parameter.label, type: parameter.type.runtimeType(for: componentContext.platform).name)
                })
            })

        let constraintFields = root.children.flatMap(self.constraintFields)

        let constraintsClass = Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: "Constraints",
            properties: constraintFields)

        var liveAccessors: [Function] = []
        if configuration.isLiveEnabled && !stateItems.isEmpty {
            liveAccessors.append(.init(
                accessibility: viewAccessibility,
                modifiers: .override,
                name: "stateProperty",
                parameters: [
                    MethodParameter(label: "named", name: "name", type: "String"),
                ],
                returnType: "LiveKeyPath?",
                block: [.switch(
                    expression: .constant("name"),
                    cases: stateItems.map { key, value -> (Expression, Block) in
                        (.constant("\"\(key)\""), [.return(expression: .constant("live(keyPath: \\.\(key))"))])
                    },
                    default: [.return(expression: .constant("nil"))])
                ]))
        }

        let elementContainerDeclarations = root.allChildren.flatMap {
            ($0 as? ProvidesCodeInitialization)?.extraDeclarations ?? []
        }

        let overridenMethods = Dictionary(grouping: root.overrides) { $0.message.methodId }
        let overrides = overridenMethods.map { _, overrides -> Function in
            func invoke(override: ComponentDefinition.Override) -> Statement {
                if override.message.parameters.isEmpty && override.receiver.hasSuffix("()") {
                    return Statement.expression(.constant(override.receiver))
                } else {
                    return Statement.expression(.constant(override.receiver + "(\(override.message.parameters.map { $0.name }.joined(separator: ", ")))"))
                }
            }

            let message = overrides.first!.message

            let beforeSuper = overrides.filter { $0.message.beforeSuper }.map(invoke(override:))
            let invokeSuper = Expression.invoke(target: .member(target: .constant("super"), name: message.methodName), arguments: message.parameters.map {
                MethodArgument(name: $0.label != "_" ? $0.label ?? $0.name : nil, value: .constant($0.name))
            })
            let afterSuper = overrides.filter { !$0.message.beforeSuper }.map(invoke(override:))

            return Function(
                accessibility: viewAccessibility,
                modifiers: .override,
                name: message.methodName,
                parameters: message.parameters,
                block: Block(statements: beforeSuper + [
                    Statement.expression(invokeSuper)
                ] + afterSuper))
        }

        let viewClass = try Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: root.type,
            inheritances: viewInheritances,
            containers: [stateClass, actionEnum, constraintsClass] + elementContainerDeclarations,
            properties: viewProperties + viewDeclarations,
            functions: [viewInit, observeActions(resolvedActions: resolvedActions), loadView(), setupConstraints()] + liveAccessors + overrides)

        let styleExtension = Structure.extension(
            accessibility: viewAccessibility,
            extendedType: root.type,
            containers: [
                try styleGroupGenerator.generateStyles(accessibility: viewAccessibility),
                try generateTemplates(accessibility: viewAccessibility),
            ])

        return [viewClass, styleExtension]
    }

    private func observeActions(resolvedActions: [ResolvedHyperViewAction]) throws -> Function {
        return try Function(
            accessibility: .private,
            name: "observeActions",
            parameters: [MethodParameter(name: "actionPublisher", type: "ActionPublisher<Action>")],
            block: resolvedActions.reduce(Block()) { accumulator, action in
                try accumulator + action.observeSources(context: componentContext, actionPublisher: .constant("actionPublisher"))
            })
    }

    private func loadView() throws -> Function {
        var block = Block()
        var themedProperties = [:] as [String: [Tokenizer.Property]]
        for property in root.properties {
            guard !property.anyValue.requiresTheme else {
                themedProperties["self", default: []].append(property)
                continue
            }
            if case .state = property.anyValue { continue }
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)

            block += property.application(on: "self", context: propertyContext)
        }

        for child in root.children {
            block += try propertyApplications(element: child, superName: "self", containedIn: root, themedProperties: &themedProperties)
        }

        if !themedProperties.isEmpty {
            var themeApplicationBlock = Block()

            themeApplicationBlock += .guard(conditions: [.conditionalUnwrap(isConstant: true, name: "self", expression: .constant("self"))], else: [.return(expression: nil)])

            for (name, properties) in themedProperties {
                for property in properties {
                    let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                    themeApplicationBlock += property.application(on: "self." + name, context: propertyContext)
                }
            }

            block += Statement.expression(
                .invoke(target: .constant("ApplicationTheme.selector.register"), arguments: [
                    MethodArgument(name: "target", value: .constant("self")),
                    MethodArgument(name: "listener", value: .closure(
                        Closure(captures: [.weak(.constant("self"))], parameters: [(name: "theme", type: nil)], block: themeApplicationBlock))),
                    ])
            )
        }

        return Function(
            accessibility: .private,
            name: "loadView",
            block: configuration.isLiveEnabled ? [] : block)
    }

    private func propertyApplications(element: UIElement, superName: String, containedIn: UIContainer, themedProperties: inout [String: [Tokenizer.Property]]) throws -> Block {

        var block = Block()

        let name = element.id.description

        let applyStyle = Expression.member(target: .constant(name), name: "apply")
        for style in element.styles {
            let styleExpression: Expression
            switch style {
            case .local(let styleName):
                styleExpression = .constant("\(root.stylesName).\(styleName)")
            case .global(let group, let styleName):
                let stylesGroupName = group.capitalizingFirstLetter() + "Styles"
                styleExpression = .constant("\(stylesGroupName).\(styleName)")
            }

            block += .expression(
                .invoke(target: applyStyle, arguments: [
                    MethodArgument(name: "style", value: styleExpression)
                ]))
        }

        for property in try element.properties + componentContext.stateProperties(of: element) {
            guard !property.anyValue.requiresTheme else {
                themedProperties[name, default: []].append(property)
                continue
            }
            if case .state = property.anyValue { continue }

            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            block += property.application(on: name, context: propertyContext)
        }

        block += .expression(
            .invoke(target: .member(target: .constant(superName), name: containedIn.addSubviewMethod), arguments: [
                MethodArgument(value: .constant(name)),
            ])
        )

        if let container = element as? UIContainer {
            for child in container.children {
                block += try propertyApplications(element: child, superName: name, containedIn: container, themedProperties: &themedProperties)
            }
        }

        return block
    }

    private func setupConstraints() -> Function {
        var block = Block()

        for child in root.children {
            block += viewConstraints(element: child, superName: "self", forUpdate: false)
        }

        return Function(
            accessibility: .private,
            name: "setupConstraints",
            block: configuration.isLiveEnabled ? [] : block)
    }

    private func viewConstraints(element: UIElement, superName: String, forUpdate: Bool) -> Block{
        var block = Block()

        let name = element.id.description

        let children: Block = (element as? UIContainer)?.children.reduce(Block()) { accumulator, child in
            accumulator + viewConstraints(element: child, superName: name, forUpdate: forUpdate)
        } ?? []

        // we want to continue only if we are generating constraints for update AND the layout has conditions
        // on the other hand, if it's the first time this method is called (not from update), we don't want to
        // generate the constraints if the layout has any conditions in it (they will be handled in update later)
        guard forUpdate == element.layout.hasConditions else {
            return children
        }

        let elementExpression = Expression.constant(name)
        let setContentCompressionResistancePriority = Expression.member(target: elementExpression, name: "setContentCompressionResistancePriority")
        let setContentHuggingPriority = Expression.member(target: elementExpression, name: "setContentHuggingPriority")

        if let horizontalCompressionPriority = element.layout.contentCompressionPriorityHorizontal {
            block += .expression(.invoke(target: setContentCompressionResistancePriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(horizontalCompressionPriority.numeric))")),
                .init(name: "for", value: .constant(".horizontal")),
            ]))
        }

        if let verticalCompressionPriority = element.layout.contentCompressionPriorityVertical {
            block += .expression(.invoke(target: setContentCompressionResistancePriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(verticalCompressionPriority.numeric))")),
                .init(name: "for", value: .constant(".vertical")),
            ]))
        }

        if let horizontalHuggingPriority = element.layout.contentHuggingPriorityHorizontal {
            block += .expression(.invoke(target: setContentHuggingPriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(horizontalHuggingPriority.numeric))")),
                .init(name: "for", value: .constant(".horizontal")),
            ]))
        }

        if let verticalHuggingPriority = element.layout.contentHuggingPriorityVertical {
            block += .expression(.invoke(target: setContentHuggingPriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(verticalHuggingPriority.numeric))")),
                .init(name: "for", value: .constant(".vertical")),
            ]))
        }

        let makeConstraints = Expression.member(target: elementExpression, name: "snp.makeConstraints")
        let remakeConstraints = Expression.member(target: elementExpression, name: "snp.remakeConstraints")

        let createConstraintsClosure = Closure(
            parameters: [(name: "make", type: nil)],
            block: element.layout.constraints.reduce(into: Block()) { accumulator, constraint in
                accumulator += viewConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false)
            })

        block += .expression(
            .invoke(target: forUpdate ? remakeConstraints : makeConstraints, arguments: [
                .init(value: .closure(createConstraintsClosure)),
            ])
        )

        return block + children
    }

    private func viewConstraintLine(constraint: Constraint, superName: String, name: String, fallback: Bool) -> Statement {
        var constraintLine = "make.\(constraint.anchor).\(constraint.relation)("

        switch constraint.type {
        case .targeted(let targetDefinition):
            let target: String
            switch targetDefinition.target {
            case .identifier(let id):
                target = id
            case .parent:
                target = superName
            case .this:
                target = name
            case .safeAreaLayoutGuide:
                if fallback {
                    target = "\(superName).fallback_safeAreaLayoutGuide"
                } else {
                    target = "\(superName).safeAreaLayoutGuide"
                }
            case .readableContentGuide:
                target="\(superName).readableContentGuide"
            }
            constraintLine += target
            if targetDefinition.targetAnchor != constraint.anchor {
                constraintLine += ".snp.\(targetDefinition.targetAnchor)"
            }

        case .constant(let constant):
            constraintLine += "\(constant)"
        }
        constraintLine += ")"

        if case .targeted(let targetDefinition) = constraint.type {
            if targetDefinition.constant != 0 {
                constraintLine += ".offset(\(targetDefinition.constant))"
            }
            if targetDefinition.multiplier != 1 {
                constraintLine += ".multipliedBy(\(targetDefinition.multiplier))"
            }
        }

        if constraint.priority.numeric != 1000 {
            constraintLine += ".priority(\(constraint.priority.numeric))"
        }

        if let field = constraint.field {
            constraintLine = "layout.\(field) = \(constraintLine).constraint"
        }

        if let condition = constraint.condition {
            return .if(
                condition: [.expression(condition.generateSwift(viewName: name))],
                then: [
                    .expression(.constant(constraintLine))
                ],
                else: nil)
        } else {
            return .expression(.constant(constraintLine))
        }
    }

    private func constraintFields(element: UIElement) -> [SwiftCodeGen.Property] {
        var fields = Set<String>()
        for constraint in element.layout.constraints {
            guard let field = constraint.field else { continue }

            fields.insert(field)
        }

        let properties = fields.map { field in
            SwiftCodeGen.Property.variable(name: field, type: "SnapKit.Constraint?")
        }

        if let container = element as? UIContainer {
            return properties + container.children.flatMap(constraintFields)
        } else {
            return properties
        }
    }

    private func generateTemplates(accessibility: Accessibility) throws -> Structure {
        return try Structure.struct(
            accessibility: accessibility,
            name: root.templatesName,
            functions: root.templates.map { template in
                try generate(accessibility: accessibility, template: template)
            })
    }

    private func generate(accessibility: Accessibility, template: Template) throws -> Function {
        switch template.type {
        case .attributedText(let attributedTextTemplate):
            let property = attributedTextTemplate.attributedText
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)

            return Function(
                accessibility: accessibility,
                modifiers: .static,
                name: template.name.name,
                parameters: attributedTextTemplate.arguments.map {
                    MethodParameter(name: $0, type: "String")
                },
                returnType: "NSMutableAttributedString",
                block: [
                    .return(expression: property.application(context: propertyContext))
                ])
        }
    }
}
