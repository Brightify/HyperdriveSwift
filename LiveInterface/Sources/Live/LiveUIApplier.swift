//
//  LiveUIApplier.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import SnapKit
import HyperdriveInterface

private func findView(named name: String, in array: [ReactantLiveUIViewApplier.ViewTuple]) -> UIView? {
    return array.first(where: { $0.name == name })?.view
}

public class ReactantLiveUIViewApplier {
    private let workerContext: ReactantLiveUIWorker.Context
    private let parentContext: DataContext
    private let findViewByFieldName: (String, UIElement) throws -> UIView
    private let resolveStyle: (UIElement) throws -> [Property]
    private let setConstraint: (String, SnapKit.Constraint) -> Bool

    public typealias ViewTuple = (name: String, element: UIElement, view: UIView)

    public init(workerContext: ReactantLiveUIWorker.Context,
                parentContext: DataContext,
                findViewByFieldName: @escaping (String, UIElement) throws -> UIView,
                resolveStyle: @escaping (UIElement) throws -> [Property],
                setConstraint: @escaping (String, SnapKit.Constraint) -> Bool) {
        self.workerContext = workerContext
        self.parentContext = parentContext
        self.findViewByFieldName = findViewByFieldName
        self.resolveStyle = resolveStyle
        self.setConstraint = setConstraint
    }

    public func apply(element: UIElement, superview: UIView?, containedIn: UIContainer?) throws -> [ViewTuple] {
        #warning("FIXME In LiveUI mode, we shouldn't generate views that aren't `export=true`")
        let name = element.id.description
        let view: UIView
        if let foundView = try? findViewByFieldName(name, element) {
            view = foundView
        } else {
            view = try workerContext.elementRegistry.initialize(from: element, context: workerContext)
//            guard let initializer = element as? CanInitializeUIKitView else {
//                fatalError("Not Implemented")
//            }
//            view = try initializer.initialize(context: workerContext)
            // tag views that are initialized without a field automatically
            view.applierTag = "applier-generated-view"
        }

        for property in try resolveStyle(element) {
            let propertyContext = PropertyContext(parentContext: parentContext, property: property)
            try property.apply(on: view, context: propertyContext)
        }

        if let superview = superview, let containedIn = containedIn {
            try workerContext.elementRegistry.add(subview: view, toInstanceOfSelf: superview, containerElement: containedIn)
//            containedIn.add(subview: view, toInstanceOfSelf: superview)
        }

        if let container = element as? UIContainer {
            // remove views that were previously created by applier
            for subview in view.subviews {
                if subview.applierTag == "applier-generated-view" {
                    subview.removeFromSuperview()
                }
            }

            let children = try container.children.flatMap {
                try apply(element: $0, superview: view, containedIn: container)
            }

            return [(name, element, view)] + children
        } else {
            return [(name, element, view)]
        }
    }

    func applyConstraints(views: [ViewTuple], element: UIElement, superview: UIView) throws -> [SnapKit.Constraint] {
        let elementType = type(of: element)
        guard let viewTuple = views.first(where: { $0.element === element }) else {
            fatalError("Inconsistency of name-element-view triples occured")
        }
        let name = viewTuple.name

        guard let view = findView(named: name, in: views) else {
            throw LiveUIError(message: "Couldn't find view with name \(name) in view hierarchy")
        }

        view.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: Float((element.layout.contentCompressionPriorityHorizontal ?? elementType.defaultContentCompression.horizontal).numeric)
        ), for: .horizontal)

        view.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: Float((element.layout.contentCompressionPriorityVertical ?? elementType.defaultContentCompression.vertical).numeric)
        ), for: .vertical)

        view.setContentHuggingPriority(
            UILayoutPriority(rawValue: Float((element.layout.contentHuggingPriorityHorizontal ?? elementType.defaultContentHugging.horizontal).numeric)
        ), for: .horizontal)

        view.setContentHuggingPriority(
            UILayoutPriority(rawValue: Float((element.layout.contentHuggingPriorityVertical ?? elementType.defaultContentHugging.vertical).numeric)
        ), for: .vertical)

        var error: LiveUIError?

        var appliedConstraints = [] as [SnapKit.Constraint]
        view.snp.makeConstraints { make in
            let traits = UITraitHelper(for: view)

            for constraint in element.layout.constraints {
                // FIXME: that `try!` is not looking good
                if let condition = constraint.condition, try! !condition.evaluate(from: traits, in: view) { continue }

                func constraintMakerExtendable(from anchor: LayoutAnchor) -> ConstraintMakerExtendable {
                    switch anchor {
                    case .top:
                        return make.top
                    case .bottom:
                        return make.bottom
                    case .leading:
                        return make.leading
                    case .trailing:
                        return make.trailing
                    case .left:
                        return make.left
                    case .right:
                        return make.right
                    case .width:
                        return make.width
                    case .height:
                        return make.height
                    case .centerX:
                        return make.centerX
                    case .centerY:
                        return make.centerY
                    case .firstBaseline:
                        return make.firstBaseline
                    case .lastBaseline:
                        return make.lastBaseline
                    case .size:
                        return make.size
                    case .margin(.top):
                        return make.topMargin
                    case .margin(.bottom):
                        return make.bottomMargin
                    case .margin(.leading):
                        return make.leadingMargin
                    case .margin(.trailing):
                        return make.trailingMargin
                    case .margin(.left):
                        return make.leftMargin
                    case .margin(.right):
                        return make.rightMargin
                    case .margin(.centerX):
                        return make.centerXWithinMargins
                    case .margin(.centerY):
                        return make.centerYWithinMargins
                    case .margin(let innerAnchor):
                        return constraintMakerExtendable(from: innerAnchor)
                    }
                }

                let maker = constraintMakerExtendable(from: constraint.anchor)


                let target: ConstraintRelatableTarget

                switch constraint.type {
                case .targeted(let targetDefinition):
                    let targetView: ConstraintAttributesDSL
                    switch targetDefinition.target {
                    case .identifier(let id):
                        guard let fieldView = findView(named: id, in: views) else {
                            error = LiveUIError(message: "Couldn't find view with identifer `\(id)` in view hierarchy")
                            return
                        }
                        targetView = fieldView.snp
                    case .parent:
                        targetView = superview.snp
                    case .this:
                        targetView = view.snp
                    case .safeAreaLayoutGuide:
                        targetView = superview.safeAreaLayoutGuide.snp
                    case .readableContentGuide:
                        targetView = superview.readableContentGuide.snp
                    }

                    if targetDefinition.targetAnchor != constraint.anchor {
                        func constraintRelatableTarget(from targetAnchor: LayoutAnchor) -> ConstraintRelatableTarget {
                            switch targetAnchor {
                            case .top:
                                return targetView.top
                            case .bottom:
                                return targetView.bottom
                            case .leading:
                                return targetView.leading
                            case .trailing:
                                return targetView.trailing
                            case .left:
                                return targetView.left
                            case .right:
                                return targetView.right
                            case .width:
                                return targetView.width
                            case .height:
                                return targetView.height
                            case .centerX:
                                return targetView.centerX
                            case .centerY:
                                return targetView.centerY
                            case .firstBaseline:
                                return targetView.firstBaseline
                            case .lastBaseline:
                                return targetView.lastBaseline
                            case .size:
                                return targetView.size
                            case .margin(.top):
                                return targetView.topMargin
                            case .margin(.bottom):
                                return targetView.bottomMargin
                            case .margin(.leading):
                                return targetView.leadingMargin
                            case .margin(.trailing):
                                return targetView.trailingMargin
                            case .margin(.left):
                                return targetView.leftMargin
                            case .margin(.right):
                                return targetView.rightMargin
                            case .margin(.centerX):
                                return targetView.centerXWithinMargins
                            case .margin(.centerY):
                                return targetView.centerYWithinMargins
                            case .margin(let innerAnchor):
                                return constraintRelatableTarget(from: innerAnchor)
                            }
                        }

                        target = constraintRelatableTarget(from: targetDefinition.targetAnchor)

                    } else {
                        guard let constraintTarget = targetView.target as? ConstraintRelatableTarget else {
                            fatalError("Target view was not what was expected, please report this crash to Issues on GitHub.")
                        }
                        target = constraintTarget
                    }

                case .constant(let constant):
                    target = constant
                }

                var editable: ConstraintMakerEditable
                switch constraint.relation {
                case .equal:
                    editable = maker.equalTo(target)
                case .greaterThanOrEqual:
                    editable = maker.greaterThanOrEqualTo(target)
                case .lessThanOrEqual:
                    editable = maker.lessThanOrEqualTo(target)
                }

                if case .targeted(let targetDefinition) = constraint.type {
                    if targetDefinition.constant != 0 {
                        editable = editable.offset(targetDefinition.constant)
                    }
                    if targetDefinition.multiplier != 1 {
                        editable = editable.multipliedBy(targetDefinition.multiplier)
                    }
                }

                let finalizable: ConstraintMakerFinalizable
                if constraint.priority.numeric != 1000 {
                    finalizable = editable.priority(constraint.priority.numeric)
                } else {
                    finalizable = editable
                }

                appliedConstraints.append(finalizable.constraint)

                if let field = constraint.field {
                    guard setConstraint(field, finalizable.constraint) else {
                        error = LiveUIError(message: "Constraint cannot be set to field `\(field)`!")
                        return
                    }
                }
            }
        }

        if let error = error {
            throw error
        }

        if let container = element as? UIContainer {
            appliedConstraints.append(contentsOf: try container.children.flatMap { try applyConstraints(views: views, element: $0, superview: view) })
        }

        return appliedConstraints
    }
}

public class ReactantLiveUIApplier {
    private let workerContext: ReactantLiveUIWorker.Context

    private var appliedConstraints: [SnapKit.Constraint] = []

    public init(workerContext: ReactantLiveUIWorker.Context) {
        self.workerContext = workerContext
    }

    public func apply(context: ComponentContext, commonStyles: [Style], view instance: LiveHyperViewBase, setConstraint: @escaping (String, SnapKit.Constraint) -> Bool) throws {
        let definition = context.component
        func findViewByFieldName(field: String, element: UIElement) throws -> UIView {
            let view: UIView
            if let anonymousLiveInstance = instance as? AnonymousLiveComponent {
//                anonymousLiveInstance.
//                fatalError()
//                try (element as? CanInitializeUIKitView)?.initialize(context: workerContext)
                view = (try? (element as? CanInitializeUIKitView)?.initialize(context: workerContext) ?? UIView()) ?? UIView()
                instance.setValue(view, forUndefinedKey: field)
            } else if instance.responds(to: Selector("\(field)")) {
                guard let targetView = instance.value(forKey: field) as? UIView else {
                    throw LiveUIError(message: "Undefined field \(field)")
                }
                view = targetView
            } else if let mirrorView = Mirror(reflecting: instance).children.first(where: { $0.label == field })?.value as? UIView {
                view = mirrorView
            } else {
                throw LiveUIError(message: "Undefined field \(field)")
            }
            return view
        }

        func resolveStyle(element: UIElement) throws -> [Property] {
            return try context.resolveStyle(for: element, stateProperties: context.stateProperties(of: element), from: commonStyles + context.component.styles)
        }

        class ComponentInstanceContext: DataContext, HasParentContext {
            let parentContext: ComponentContext
            let instance: LiveHyperViewBase

            init(parentContext: ComponentContext, instance: LiveHyperViewBase) {
                self.parentContext = parentContext
                self.instance = instance
            }

            func resolveStateProperty(named name: String) throws -> Any? {
                return instance.stateProperty(named: name)?.get()
            }
        }

        let instanceContext = ComponentInstanceContext(parentContext: context, instance: instance)

        let viewApplier = ReactantLiveUIViewApplier(
            workerContext: workerContext,
            parentContext: instanceContext,
            findViewByFieldName: findViewByFieldName,
            resolveStyle: resolveStyle,
            setConstraint: setConstraint
        )

        instance.subviews.forEach { $0.removeFromSuperview() }
        for constraint in appliedConstraints {
            constraint.deactivate()
        }
        appliedConstraints = []

        for property in definition.properties {
            let propertyContext = PropertyContext(parentContext: instanceContext, property: property)
            try property.apply(on: instance, context: propertyContext)
        }

        let views = try definition.children.flatMap {
            try viewApplier.apply(element: $0, superview: instance, containedIn: definition)
        }

        appliedConstraints = try definition.children.flatMap { element in
            try viewApplier.applyConstraints(views: views, element: element, superview: instance)
        }
    }
}

extension UIView {
    private static var applierTagKey: UInt8 = 0

    var applierTag: String? {
        get {
            return objc_getAssociatedObject(self, &UIView.applierTagKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIView.applierTagKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension InterfaceIdiom {
    init(uiIdiom: UIUserInterfaceIdiom) {
        switch uiIdiom {
        case .carPlay:
            self = .carPlay
        case .pad:
            self = .pad
        case .phone:
            self = .phone
        case .tv:
            self = .tv
        case .unspecified:
            self = .unspecified
        }
    }
}

extension InterfaceSizeClass {
    init(uiSizeClass: UIUserInterfaceSizeClass) {
        switch uiSizeClass {
        case .compact:
            self = .compact
        case .regular:
            self = .regular
        case .unspecified:
            self = .unspecified
        }
    }
}
