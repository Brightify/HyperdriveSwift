//
//  PickerView.swift
//  Reactant
//
//  Created by Matouš Hýbl on 02/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

//import RxSwift

#if os(iOS)
import UIKit

public class PickerView<Item>: ConfigurableHyperViewBase, HyperView, UIPickerViewDataSource, UIPickerViewDelegate where Item: Equatable {
    public final class State: HyperViewState {
        fileprivate weak var owner: PickerView? { didSet { resynchronize() } }

        public var items: [Item] = [] { didSet { owner?.notifyItemsChanged() } }
        public var titleSelection: (Item) -> String = { String(describing: $0) } { didSet { owner?.notifyTitleSelectionChanged() } }
        public var selectedItem: Item? { didSet { owner?.notifySelectedItemChanged() } }

        public init() { }

        public func resynchronize() {
            guard let owner = owner else { return }

            owner.notifyItemsChanged()
            owner.notifySelectedItemChanged()
            owner.notifyTitleSelectionChanged()
        }

        public func apply(from otherState: PickerView<Item>.State) {
            items = otherState.items
            titleSelection = otherState.titleSelection
            selectedItem = otherState.selectedItem
        }
    }
    public enum Action {
        case itemSelected(Item)
    }

    private let pickerView = UIPickerView()

    public var state: State {
        willSet { state.owner = nil }
        didSet { state.owner = self }
    }
    public let actionPublisher: ActionPublisher<Action>

    public required init(initialState: State, actionPublisher: ActionPublisher<Action>) {
        self.state = initialState
        self.actionPublisher = actionPublisher

        super.init()

        loadView()
        setupConstraints()

        state.owner = self
    }

    public convenience init(actionPublisher: ActionPublisher<Action> = ActionPublisher(), items: [Item], initialSelection: Item? = nil, titleSelection: @escaping (Item) -> String) {
        let state = State()
        state.items = items
        state.selectedItem = initialSelection
        state.titleSelection = titleSelection

        self.init(initialState: state, actionPublisher: actionPublisher)
    }

    private func loadView() {
        addSubview(pickerView)

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return state.items.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = state.items[row]
        
        return state.titleSelection(model)
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let model = state.items[row]

        actionPublisher.publish(action: .itemSelected(model))
    }

    private func notifyItemsChanged() {
        pickerView.reloadAllComponents()
    }

    private func notifyTitleSelectionChanged() {
        pickerView.reloadAllComponents()
    }

    private func notifySelectedItemChanged() {
        guard let selectedItem = state.selectedItem, let index = state.items.firstIndex(of: selectedItem) else { return }

        pickerView.selectRow(index, inComponent: 0, animated: true)
    }
}

extension PickerView where Item: CaseIterable {
    public convenience init(actionPublisher: ActionPublisher<Action> = ActionPublisher(), initialSelection: Item? = Item.allCases.first, titleSelection: @escaping (Item) -> String) {
        let state = State()
        state.items = Array(Item.allCases)
        state.selectedItem = initialSelection
        state.titleSelection = titleSelection

        self.init(initialState: state, actionPublisher: actionPublisher)
    }


}
#endif
