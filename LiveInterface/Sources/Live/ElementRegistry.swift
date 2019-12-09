//
//  ElementRegistry.swift
//  tuistLiveInterface
//
//  Created by Tadeas Kriz on 07/12/2019.
//

import Foundation

public class ElementRegistry {
    public enum InitializationError: Error {
        case missingFactory(element: UIElement, viewType: Any.Type)
        case invalidViewType(expected: Any.Type, actual: Any)
        case invalidElementType(expected: UIElement.Type, actual: UIElement)
    }
    public enum InsertionError: Error {
        case missingInserter(element: UIContainer, container: Any, subview: Any)
        case invalidContainerViewType(expected: Any.Type, actual: Any)
        case invalidContainerElementType(expected: UIContainer.Type, actual: UIContainer)
        case invalidSubviewType(expected: Any.Type, actual: Any)
    }

    private var factories: [ObjectIdentifier: (UIElement, ReactantLiveUIWorker.Context) throws -> Any] = [:]
    private var containerInserters: [ObjectIdentifier: (Any, Any, UIContainer) throws -> Void] = [:]
    private var fallbackContainerInserters: [(Any, Any, UIContainer) throws -> Bool] = []

    public func register<E: UIElement, VIEW>(factory: @escaping (E, ReactantLiveUIWorker.Context) throws -> VIEW) {
        factories[ObjectIdentifier(E.self)] = { element, context in
            guard let castElement = element as? E else {
                throw InitializationError.invalidElementType(expected: E.self, actual: element)
            }

            return try factory(castElement, context)
        }
    }

    public func register<CONTAINER, ELEMENT: UIContainer, SUBVIEW>(inserter: @escaping (_ subview: SUBVIEW, _ container: CONTAINER, _ containerElement: ELEMENT) throws -> Void) {
        containerInserters[ObjectIdentifier(ELEMENT.self)] = { subview, container, containerElement in
            guard let castContainerElement = containerElement as? ELEMENT else {
                throw InsertionError.invalidContainerElementType(expected: ELEMENT.self, actual: containerElement)
            }
            guard let castContainer = container as? CONTAINER else {
                throw InsertionError.invalidContainerViewType(expected: CONTAINER.self, actual: container)
            }
            guard let castSubview = subview as? SUBVIEW else {
                throw InsertionError.invalidSubviewType(expected: SUBVIEW.self, actual: subview)
            }

            try inserter(castSubview, castContainer, castContainerElement)
        }
    }

    public func register<CONTAINER, SUBVIEW>(fallbackInserter: @escaping (_ subview: SUBVIEW, _ container: CONTAINER, _ containerElement: UIContainer) throws -> Bool) {

        fallbackContainerInserters.insert({ subview, container, containerElement in
            guard let castContainer = container as? CONTAINER else {
                return false
            }
            guard let castSubview = subview as? SUBVIEW else {
                return false
            }

            return try fallbackInserter(castSubview, castContainer, containerElement)
        }, at: 0)
    }

    public func initialize<VIEW>(from element: UIElement, context: ReactantLiveUIWorker.Context, viewType: VIEW.Type = VIEW.self) throws -> VIEW {
        guard let factory = factories[ObjectIdentifier(type(of: element))] else {
            throw InitializationError.missingFactory(element: element, viewType: viewType)
        }

        let view = try factory(element, context)

        if let castView = view as? VIEW {
            return castView
        } else {
            throw InitializationError.invalidViewType(expected: viewType, actual: view)
        }
    }

    public func add(subview: Any, toInstanceOfSelf container: Any, containerElement: UIContainer) throws {
        if let inserter = containerInserters[ObjectIdentifier(type(of: containerElement))] {
            try inserter(subview, container, containerElement)
        } else {
            for fallbackInserter in fallbackContainerInserters {
                if try fallbackInserter(subview, container, containerElement) {
                    return
                }
            }

            throw InsertionError.missingInserter(element: containerElement, container: container, subview: subview)
        }
    }
}

extension ElementRegistry.InitializationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingFactory(let element, let viewType):
            return "Missing factory for view type \(viewType) requested by element \(element)."
        case .invalidViewType(let expected, let actual):
            return "Invalid view type returned from factory. Expected <\(expected)>, but got <\(actual)>."
        case .invalidElementType(let expected, let actual):
            return "Invalid element type for factory. Expected \(expected), but got <\(actual)>."
        }
    }
}

extension ElementRegistry.InsertionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingInserter(let element, let container, let subview):
            return "Missing view inserter to insert \(subview) into \(container) as requested by \(element)."
        case .invalidContainerViewType(let expected, let actual):
            return "Invalid type of container view. Expected <\(expected)>, but got <\(actual)>."
        case .invalidContainerElementType(let expected, let actual):
            return "Invalid type of container element. Expected <\(expected)>, but got <\(actual)>."
        case .invalidSubviewType(let expected, let actual):
            return "Invalid type of subview to be inserted. Expected <\(expected)>, but got <\(actual)>."
        }
    }
}
