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

    private var factories: [ObjectIdentifier: (UIElement, ReactantLiveUIWorker.Context) throws -> Any] = [:]
    private var containerInserters: [ObjectIdentifier: (Any, Any, UIContainer) throws -> Void] = [:]

    public func register<E: UIElement, VIEW>(factory: @escaping (E, ReactantLiveUIWorker.Context) throws -> VIEW) {
        factories[ObjectIdentifier(E.self)] = { element, context in
            guard let castElement = element as? E else {
                throw InitializationError.invalidElementType(expected: E.self, actual: element)
            }

            return try factory(castElement, context)
        }
    }

    public func register<CONTAINER: UIContainer, SUBVIEW>(inserter: @escaping (_ subview: SUBVIEW, _ container: CONTAINER) -> Void) {


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

    public func add(subview: Any, toInstanceOfSelf: Any, containerElement: UIContainer) throws {

        throw NSError(domain: "aaa", code: 11, userInfo: [:])
    }
}


