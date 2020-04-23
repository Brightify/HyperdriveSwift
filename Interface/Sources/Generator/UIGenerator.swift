//
//  UIGenerator.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 26/02/2018.
//

import Tokenizer
import SwiftCodeGen

enum SortDirection {
    case ascending
    case descending
}

extension Sequence {
    func sorted<C: Comparable>(using keyPath: KeyPath<Self.Element, C>, direction: SortDirection = .ascending) -> [Self.Element] {
        self.sorted(by: { lhs, rhs in
            switch direction {
            case .ascending:
                return lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
            case .descending:
                return lhs[keyPath: keyPath] > rhs[keyPath: keyPath]
            }
        })
    }
}

extension Dictionary {
    func sorted<C: Comparable>(using keyPath: KeyPath<Self.Element, C>, direction: SortDirection = .ascending) -> [Self.Element] {
        self.sorted(by: { lhs, rhs in
            switch direction {
            case .ascending:
                return lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
            case .descending:
                return lhs[keyPath: keyPath] > rhs[keyPath: keyPath]
            }
        })
    }
}

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
        let viewAccessibility: Accessibility
        if componentContext.component.modifier == .open || configuration.defaultModifier == .open {
            viewAccessibility = .open
        } else if componentContext.component.modifier == .public || configuration.defaultModifier == .public {
            viewAccessibility = .public
        } else {
            viewAccessibility = .internal
        }
        let isViewClassFinal = root.isFinal && viewAccessibility != .open

        let triggerReloadPaths = Expression.arrayLiteral(items:
            [configuration.localXmlPath].map { Expression.constant(#""\#($0)""#) }
        )

        let viewProperties: [SwiftCodeGen.Property] = [
            .constant(accessibility: viewAccessibility, modifiers: .static, name: "triggerReloadPaths", type: "Set<String>", value: triggerReloadPaths),
            .constant(accessibility: viewAccessibility, name: "layout", value: .constant("Constraints()")),
            .variable(accessibility: viewAccessibility, name: "state", type: "State", block: [
                .expression(.constant("willSet { state.owner = nil }")),
                .expression(.constant("didSet { state.owner = self }")),
            ]),
            .constant(accessibility: root.providedActions.isEmpty ? .private : viewAccessibility, name: "actionPublisher", type: "ActionPublisher<Action>"),
        ]

        let viewDeclarations = try root.allChildren.sorted(using: \.id).map { child in
            SwiftCodeGen.Property.constant(
                accessibility: child.isExported ? viewAccessibility : .private,
                name: child.id.description,
                type: child.injectionOptions.contains(.generic) ? child.id.description.uppercased() : try child.runtimeType(for: componentContext.platform).name)
        }

        let injectedChildren = root.allInjectedChildren

        let genericParameters = try injectedChildren.compactMap { child -> GenericParameter? in
            guard child.injectionOptions.contains(.generic) else { return nil }
            return GenericParameter(
                name: child.id.description.uppercased(),
                inheritance: try child.runtimeType(for: componentContext.platform).name)
        }

        tempCounter = 1
        let viewInitializations = try root.allChildren.map { child -> Statement in
            guard !child.injectionOptions.contains(.initializer) else {
                return .assignment(target: .member(target: .constant("self"), name: child.id.description), expression: .constant(child.id.description))
            }

            guard let providesInitialization = child as? ProvidesCodeInitialization else {
                #warning("FIXME Replace with throwing an error")
                fatalError("\(child) doesn't provide initialization!")
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

        var navigationItemProperties: [SwiftCodeGen.Property] = []
        if let navigationItem = root.navigationItem {
            viewInheritances.append("HasNavigationItem")

            func instantiateItem(kind: NavigationItem.BarButtonItem.Kind) throws -> Expression {
                let invokeArguments: [MethodArgument]
                switch kind {
                case .image(let image, landscapeImagePhone: let landscapeImagePhone, let style):
                    let imageContext = SupportedPropertyTypeContext(parentContext: componentContext, value: AnyPropertyValue.value(image))
                    invokeArguments = [
                        MethodArgument(name: "image", value: image.generate(context: imageContext)),
                        MethodArgument(name: "landscapeImagePhone", value: landscapeImagePhone?.generate(context: imageContext) ?? .constant("nil")),
                        MethodArgument(name: "style", value: .constant(".\(style.rawValue)")),
                    ]
                case .system(let systemItem):
                    invokeArguments = [
                        MethodArgument(name: "barButtonSystemItem", value: .constant(".\(systemItem.rawValue)")),
                    ]
                case .title(let title, let style):
                    invokeArguments = [
                        MethodArgument(name: "title", value: .constant("\"\(title)\"")),
                        MethodArgument(name: "style", value: .constant(".\(style.rawValue)")),
                    ]
                case .view(let view):
                    return .invoke(target: .constant("UIBarButtonItem"), arguments: [
                        MethodArgument(name: "customView", value: try view.initialization(for: componentContext.platform, context: componentContext)),
                    ])
                }
                return .invoke(target: .constant("UIBarButtonItem"), arguments: invokeArguments + [
                    MethodArgument(name: "target", value: .constant("nil")),
                    MethodArgument(name: "action", value: .constant("nil")),
                ])
            }

            navigationItemProperties = try navigationItem.allItems.map { item in
                .constant(
                    accessibility: item.isExported ? viewAccessibility : .private,
                    name: item.id,
                    type: "UIBarButtonItem",
                    value: try instantiateItem(kind: item.kind))
            }

            if let leftBarButtonItems = navigationItem.leftBarButtonItems {
                navigationItemProperties.append(
                    .variable(accessibility: viewAccessibility, name: "leftBarButtonItems", type: "[UIBarButtonItem]?", block: [
                        .return(expression: .arrayLiteral(items: leftBarButtonItems.items.map {
                            .constant("\($0.id)")
                        }))
                    ])
                )
            }

            if let rightBarButtonItems = navigationItem.rightBarButtonItems {
                navigationItemProperties.append(
                    .variable(accessibility: viewAccessibility, name: "rightBarButtonItems", type: "[UIBarButtonItem]?", block: [
                        .return(expression: .arrayLiteral(items: rightBarButtonItems.items.map {
                            .constant("\($0.id)")
                        }))
                    ])
                )
            }
        }

        let rxDisposeBagProperties: [SwiftCodeGen.Property] = root.rxDisposeBags.items.map { bag in
            if bag.resetable {
                return .variable(attributes: ["private(set)"], accessibility: viewAccessibility, name: bag.name, value: .constant("DisposeBag()"))
            } else {
                return .constant(accessibility: viewAccessibility, name: bag.name, value: .constant("DisposeBag()"))
            }
        }

        let rxDisposeBagResetMethods: [SwiftCodeGen.Function] = root.rxDisposeBags.items.compactMap { bag in
            guard bag.resetable else { return nil }
            return .init(accessibility: viewAccessibility, name: "reset\(bag.name.capitalizingFirstLetter())", block: [
                .assignment(target: .constant(bag.name), expression: .constant("DisposeBag()"))
            ])
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
            modifiers: isViewClassFinal ? [] : [.required],
            parameters: [
                .init(name: "initialState", type: "State", defaultValue: "State()"),
                .init(name: "actionPublisher", type: "ActionPublisher<Action>", defaultValue: "ActionPublisher()"),
            ] + injectedChildren.map { child in
                try MethodParameter(
                    name: child.id.description,
                    type: child.injectionOptions.contains(.generic) ? child.id.description.uppercased() : child.runtimeType(for: componentContext.platform).name)
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
                ] + root.overrides.filter({ $0.message == .willInit }).map { override in
                    Statement.expression(.invoke(target: .constant(override.receiver), arguments: []))
                } + [
                    .emptyLine,
                    .expression(.constant("loadView()")),
                    .expression(.constant("setupConstraints()")),
                    .expression(.constant("initialState.owner = self")),
                    .expression(.constant("observeActions(actionPublisher: actionPublisher)")),
                    .emptyLine,
                ]  + root.overrides.filter({ $0.message == .didInit }).map { override in
                    Statement.expression(.invoke(target: .constant(override.receiver), arguments: []))
                }))

        let stateProperties: [SwiftCodeGen.Property] = [
            .variable(accessibility: .fileprivate, modifiers: .weak, name: "owner", type: "\(root.type)?", block: [
                .expression(.constant("didSet { resynchronize() }"))
            ]),
        ]

        let stateItems = try componentContext.globalContext.resolve(state: root).sorted(using: \.key)

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
        if configuration.isLiveEnabled && !constraintFields.isEmpty {
            liveAccessors.append(.init(
                accessibility: viewAccessibility,
                modifiers: .override,
                name: "setConstraint",
                parameters: [
                    MethodParameter(label: "named", name: "name", type: "String"),
                    MethodParameter(name: "constraint", type: "SnapKit.Constraint"),
                ],
                returnType: "Bool",
                block: [.switch(
                    expression: .constant("name"),
                    cases: constraintFields.map { property -> (Expression, Block) in
                        (.constant("\"\(property.name)\""), [
                            .assignment(target: .constant("layout.\(property.name)"), expression: .constant("constraint")),
                            .return(expression: .constant("true")),
                        ])
                    },
                    default: [.return(expression: .constant("false"))]
                )]
            ))
        }

        let elementContainerDeclarations = root.allChildren.flatMap {
            ($0 as? ProvidesCodeInitialization)?.extraDeclarations ?? []
        }

        let overridenMethods = Dictionary(grouping: root.overrides.filter { !$0.message.isAbstract }) { $0.message.methodId }
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
            isFinal: isViewClassFinal,
            name: root.type,
            genericParameters: genericParameters,
            inheritances: viewInheritances,
            containers: [stateClass, actionEnum, constraintsClass] + elementContainerDeclarations,
            properties: viewProperties + viewDeclarations + navigationItemProperties + rxDisposeBagProperties,
            functions: [
                viewInit,
                observeActions(resolvedActions: resolvedActions),
                loadView(),
                setupConstraints(),
                updateConstraints(viewAccessibility: viewAccessibility),
            ] + liveAccessors + overrides + rxDisposeBagResetMethods)

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

        for override in root.overrides.filter({ $0.message == .willLoadView }) {
            block += Statement.expression(.invoke(target: .constant(override.receiver), arguments: []))
        }

        var themeApplicationBlock = Block()
        for property in root.properties {
            if case .state = property.anyValue { continue }
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)

            guard !property.anyValue.requiresTheme(context: componentContext) else {
                themeApplicationBlock += property.application(on: "self", context: propertyContext)
                continue
            }

            block += property.application(on: "self", context: propertyContext)
        }

        for child in root.children {
            block += try propertyApplications(
                element: child,
                superName: "self",
                containedIn: root,
                themeApplicationBlock: &themeApplicationBlock)
        }

        if !themeApplicationBlock.statements.isEmpty {
            let selfGuard = Statement.guard(conditions: [.conditionalUnwrap(isConstant: true, name: "self", expression: .constant("self"))], else: [.return(expression: nil)])

            block += Statement.expression(
                .invoke(target: .constant("ApplicationTheme.selector.register"), arguments: [
                    MethodArgument(name: "target", value: .constant("self")),
                    MethodArgument(name: "listener", value: .closure(
                        Closure(captures: [.weak(.constant("self"))], parameters: [(name: "theme", type: nil)],
                                block: [selfGuard] + themeApplicationBlock))),
                    ])
            )
        }

        for override in root.overrides.filter({ $0.message == .didLoadView }) {
            block += Statement.expression(.invoke(target: .constant(override.receiver), arguments: []))
        }

        return Function(
            accessibility: .private,
            name: "loadView",
            block: configuration.isLiveEnabled ? [] : block)
    }

    private func propertyApplications(element: UIElement, superName: String, containedIn: UIContainer, themeApplicationBlock: inout Block) throws -> Block {

        var block = Block()

        let name = element.id.description

        for styleName in element.styles {
            let styleExpression: Expression
            switch styleName {
            case .local(let codeStyleName):
                styleExpression = .constant("\(root.stylesName).\(codeStyleName)")
            case .global(let group, let codeStyleName):
                let stylesGroupName = group.capitalizingFirstLetter() + "Styles"
                styleExpression = .constant("\(stylesGroupName).\(codeStyleName)")
            }

            guard let style = componentContext.style(named: styleName) else {
                throw TokenizationError.invalidStyleName(text: styleName.name)
            }

            if try style.requiresTheme(context: componentContext) ||
                componentContext.globalContext.stateProperties(for: style, factory: element.factory).contains(where: { $0.anyValue.requiresTheme(context: componentContext) }) {

                themeApplicationBlock += .expression(.invoke(target:
                        .invoke(target: styleExpression, arguments: [
                            MethodArgument(name: "theme", value: .constant("theme")),
                        ]), arguments: [
                            MethodArgument(value: .constant("self.\(name)")),
                        ]))
            } else {
                block += .expression(
                    .invoke(target: styleExpression, arguments: [
                        MethodArgument(value: .constant(name))
                    ]))
            }
        }

        for property in try element.properties + componentContext.globalContext.stateProperties(of: element) {
            if case .state = property.anyValue { continue }

            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            guard !property.anyValue.requiresTheme(context: componentContext) else {
                themeApplicationBlock += property.application(on: "self.\(name)", context: propertyContext)
                continue
            }

            block += property.application(on: name, context: propertyContext)
        }

        block += .expression(
            .invoke(target: .member(target: .constant(superName), name: containedIn.addSubviewMethod), arguments: [
                MethodArgument(value: .constant(name)),
            ])
        )

        if let container = element as? UIContainer {
            for child in container.children {
                block += try propertyApplications(element: child, superName: name, containedIn: container, themeApplicationBlock: &themeApplicationBlock)
            }
        }

        return block
    }

    private func setupConstraints() -> Function {
        var block = Block()

        for override in root.overrides.filter({ $0.message == .willSetupConstraints }) {
            block += Statement.expression(.invoke(target: .constant(override.receiver), arguments: []))
        }

        for child in root.children {
            block += viewConstraints(element: child, superName: "self", forUpdate: false)
        }

        for override in root.overrides.filter({ $0.message == .didSetupConstraints }) {
            block += Statement.expression(.invoke(target: .constant(override.receiver), arguments: []))
        }

        return Function(
            accessibility: .private,
            name: "setupConstraints",
            block: configuration.isLiveEnabled ? [] : block)
    }

    private func updateConstraints(viewAccessibility: Accessibility) -> Function {
        var block = Block()

        for child in root.children {
            block += viewConstraints(element: child, superName: "self", forUpdate: true)
        }

        block += Statement.expression(.constant("super.updateConstraints()"))

        return Function(
            accessibility: viewAccessibility,
            modifiers: .override,
            name: "updateConstraints",
            block: configuration.isLiveEnabled ? [] : block)
    }

    private func viewConstraints(element: UIElement, superName: String, forUpdate: Bool) -> Block {
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

            if template.requiresTheme(context: propertyContext) || property.anyValue.requiresTheme(context: propertyContext) {
                return Function(
                    accessibility: accessibility,
                    modifiers: .static,
                    name: template.name.name,
                    parameters: attributedTextTemplate.arguments.map {
                        MethodParameter(name: $0, type: "String")
                    },
                    returnType: "(ApplicationTheme) -> NSMutableAttributedString",
                    block: [
                        .return(expression: .closure(Closure(parameters: [(name: "theme", type: nil)], block: [
                            .return(expression: property.application(context: propertyContext))
                        ]))),
                    ])
            } else {
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
}
