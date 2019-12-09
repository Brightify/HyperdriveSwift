//
//  BarButtonItemTapAction.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 09/12/2019.
//

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public class BarButtonItemTapAction: UIElementAction {
    public let primaryName: String

    public let aliases: Set<String> = []

    public let parameters: [Parameter] = []

    private let item: NavigationItem.BarButtonItem

    init(item: NavigationItem.BarButtonItem) {
        self.item = item
        primaryName = Self.primaryName(for: item)
    }

    public static func primaryName(for item: NavigationItem.BarButtonItem) -> String {
        return "tapBarButtonItem_\(item.id)"
    }

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        return .expression(.invoke(target: .constant("UIBarButtonItemObserver.bind"), arguments: [
            MethodArgument(name: "to", value: Expression.member(target: view, name: item.id)),
            MethodArgument(name: "handler", value: .closure(handler.listener)),
        ]))
    }
    #endif
}
