//
//  ExampleSelectionController.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import HyperdriveInterface
import RxSwift

enum ExampleType: CaseIterable {
    case plainTableView
    case headerTableView
    case footerTableView
    case simpleTableView
    case simulatedSeparatorTableView
    case playground
    case stackView
    case progressView

    var name: String {
        switch self {
        case .plainTableView:
            return "Plain table view"
        case .headerTableView:
            return "Header table view"
        case .footerTableView:
            return "Footer table view"
        case .simpleTableView:
            return "Simple table view"
        case .simulatedSeparatorTableView:
            return "Simulated separator table view"
        case .playground:
            return "Playground"
        case .stackView:
            return "Stack view"
        case .progressView:
            return "Progress view"
        }
    }
}

final class ExampleSelectionController: HyperViewController<ExampleSelectionRootView> {
    struct Reactions {
        let exampleSelected: (ExampleType) -> Void
    }

    private let reactions: Reactions

    init(reactions: Reactions) {
        self.reactions = reactions

        super.init()

        title = "Examples"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hyperView.set(exampleTypes: ExampleType.allCases)
    }

    override func handle(action: ExampleSelectionRootView.Action) {
        super.handle(action: action)

        switch action {
        case .selected(let exampleType, _):
            reactions.exampleSelected(exampleType.type)
        }
//
    }
}
