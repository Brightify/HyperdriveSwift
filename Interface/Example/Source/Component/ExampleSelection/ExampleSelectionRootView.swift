//
//  ExampleSelectionRootView.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

//import Hyperdrive
//import RxSwift
//
//final class ExampleSelectionRootView: ViewBase<Void, ExampleType> {
//
//    let stackView = UIStackView()
//
//    override func update() {
//        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//
//        let selectionCells = ExampleType.allCases.map { SelectionCell().with(state: $0) }
//
//        Observable.merge(selectionCells.map { $0.action })
//            .subscribe(onNext: { [weak self] in
//                self?.perform(action: $0)
//            })
//            .disposed(by: stateDisposeBag)
//
//        selectionCells.forEach { stackView.addArrangedSubview($0) }
//    }
//}

import RxSwift

extension ExampleSelectionRootView {
    func set(exampleTypes: [ExampleType]) {
        tableView.state.items = .items(exampleTypes.map { type in
            let state = SelectionCell.State()
            state.type = type
            return state
        })
//        let selectionCells = exampleTypes.map { type -> SelectionCell in
//            let cell = SelectionCell()
//            cell.actionPublisher.listen(with: <#T##(SelectionCell.Action) -> Void#>)
//            return cell
//        }

//        selectionCells
//
//        Observable.merge(selectionCells.map { $0.action })
//            .subscribe(onNext: { [weak self] in
//                self?.perform(action: $0)
//            })
//            .disposed(by: stateDisposeBag)
//
//        selectionCells.forEach { stackView.addArrangedSubview($0) }
    }
}
