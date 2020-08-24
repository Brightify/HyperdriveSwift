//
//  NavigationItem.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct NavigationItem {
    public var leftBarButtonItems: BarButtonItemContainer?
    public var rightBarButtonItems: BarButtonItemContainer?

    public var allItems: [BarButtonItem] {
        return (leftBarButtonItems?.items ?? []) + (rightBarButtonItems?.items ?? [])
    }

    public init(element: XMLElement) throws {
        leftBarButtonItems = try element.singleOrNoElement(named: "leftBarButtonItems").map(BarButtonItemContainer.init)
        rightBarButtonItems = try element.singleOrNoElement(named: "rightBarButtonItems").map(BarButtonItemContainer.init)
    }

    public struct BarButtonItemContainer {
        public var items: [BarButtonItem]

        public init(element: XMLElement) throws {
            items = try element.xmlChildren.map(BarButtonItem.init)
        }
    }

    public struct BarButtonItem {
        public var id: String
        public var isExported: Bool
        public var kind: Kind

        public init(element: XMLElement) throws {
            id = element.name
            isExported = element.value(ofAttribute: "export") ?? false

            let style = try element.singleOrNoElement(named: "style").map { try Kind.Style(from: $0.nonEmptyTextOrThrow()) }
            if let systemElement = try element.singleOrNoElement(named: "system") {
                guard let systemItem = try Kind.SystemItem(rawValue: systemElement.nonEmptyTextOrThrow()) else {
                    throw TokenizationError(message: "Unsupported system item '\(systemElement.text ?? "")'.")
                }
                kind = .system(systemItem)

            } else if let title = try element.singleOrNoElement(named: "title") {
                kind = .title(try TransformedText.typeFactory.typedMaterialize(from: title.text ?? ""), style: style ?? .plain)
            } else if let imageElement = try element.singleOrNoElement(named: "image") {
                let landscapeImagePhone = try element.singleOrNoElement(named: "landscapeImagePhone").map {
                    try Image.typeFactory.typedMaterialize(from: $0.nonEmptyTextOrThrow())
                }

                let image = try Image.typeFactory.typedMaterialize(from: imageElement.nonEmptyTextOrThrow())
                kind = .image(image, landscapeImagePhone: landscapeImagePhone, style: style ?? .plain)
            } else {
                throw TokenizationError(message: "Unknown barButtonItem type!")
            }
        }

        public enum Kind {
            case system(SystemItem)
            case title(TransformedText, style: Style)
            case image(Image, landscapeImagePhone: Image?, style: Style)
            case view(Module.UIKit.View)

            public enum Style: String {
                case plain
                case done

                init(from name: String) throws {
                    guard let style = Style(rawValue: name) else {
                        throw TokenizationError(message: "Unknown BarButtonItem style \(name)!")
                    }
                    self = style
                }
            }

            public enum SystemItem: String {
                case done
                case cancel
                case edit
                case save
                case add
                case flexibleSpace
                case fixedSpace
                case compose
                case reply
                case action
                case organize
                case bookmarks
                case search
                case refresh
                case stop
                case camera
                case trash
                case play
                case pause
                case rewind
                case fastForward
                case undo
                case redo
            }
        }
    }
}

