//
//  TableViewOptions.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 04/02/2020.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Module.UIKit.TableView {
    public struct TableViewOptions {
        public let style: Style
        public let reloadable: Bool
        public let deselectsAutomatically: Bool

        public init(node: XMLElement) throws {
            style = try node.value(ofAttribute: "tableView.style", defaultValue: Style.plain)
            reloadable = try node.value(ofAttribute: "reloadable", defaultValue: false)
            deselectsAutomatically = try node.value(ofAttribute: "deselectsAutomatically", defaultValue: true)
        }

        #if canImport(SwiftCodeGen)
        public func initialization(kind: InitializedKind) -> Expression {
            switch kind {
            case .style:
                return .member(target: .constant("UITableView.Style"), name: style.rawValue)
            case .tableViewOptions:
                var expressions: [Expression] = []
                if reloadable {
                    expressions.append(.member(target: .constant("TableViewOptions"), name: "reloadable"))
                }
                if deselectsAutomatically {
                    expressions.append(.member(target: .constant("TableViewOptions"), name: "deselectsAutomatically"))
                }
                return .arrayLiteral(items: expressions)
            }
        }
        #endif

        public enum InitializedKind {
            case style
            case tableViewOptions
        }

        public enum Style: String, XMLAttributeDeserializable, CaseIterable {
            case plain
            case grouped
            case insetGrouped

            public static func deserialize(_ attribute: XMLAttribute) throws -> Module.UIKit.TableView.TableViewOptions.Style {
                guard let style = Style(rawValue: attribute.text) else {
                    throw TokenizationError(
                        message: "Couldn't deserialize \(attribute.text) as UITableView.Style. Available values \(Style.allCases.map { $0.rawValue }.joined(separator: ", "))")
                }

                return style
            }
        }
    }
}
