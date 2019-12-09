//
//  TableViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public struct TableViewOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let reloadable = TableViewOptions(rawValue: 1 << 0)
    public static let deselectsAutomatically = TableViewOptions(rawValue: 1 << 1)
    // add more here, make sure to increment the shift number -----------------^
    
    public static let none: TableViewOptions = []
    public static let `default`: TableViewOptions = .deselectsAutomatically
}

@objcMembers
open class TableViewBase<MODEL, ACTION>: ConfigurableHyperViewBase, ComposableHyperView, ReactantTableView, UITableViewDelegate {
    public enum Items {
        case empty(message: String)
        case items([MODEL])
        case loading
    }

    public final class State: HyperViewState {
        fileprivate weak var owner: TableViewBase<MODEL, ACTION>? { didSet { resynchronize() } }

        public var items: Items = .loading { didSet { owner?.notifyItemsChanged() } }

        public init() { }

        public func resynchronize() {
            guard let owner = owner else { return }
            owner.notifyItemsChanged()
        }

        public func apply(from otherState: State) {
            items = otherState.items
        }
    }

    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.TableView.tableView)(self)
            
            configurationChangeTime = clock()
            setNeedsLayout()
        }
    }

    public let state: State = State()
    public let actionPublisher: ActionPublisher<ACTION> = ActionPublisher()

    public let tableView: UITableView
    #if os(iOS)
    public let refreshControl: UIRefreshControl?
    #endif
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView()

    public var items: [MODEL] {
        guard case .items(let items) = state.items else { return [] }
        return items
    }
    // Optimization that prevents configuration reloading each time cell is dequeued.
    private var configurationChangeTime: clock_t = clock()
    
    private let automaticallyDeselect: Bool

    public init(style: UITableView.Style = .plain, options: TableViewOptions) {
        self.tableView = UITableView(frame: CGRect.zero, style: style)
        #if os(iOS)
            self.refreshControl = options.contains(.reloadable) ? UIRefreshControl() : nil
        #endif

        self.automaticallyDeselect = options.contains(.deselectsAutomatically)

        super.init()

        loadView()
        setupConstraints()

        afterInit()
    }

    private func afterInit() {
        #if os(iOS)
        refreshControl?.addTarget(self, action: #selector(performRefresh), for: .valueChanged)
        #endif
    }

    @objc
    open func performRefresh() { }

    private func loadView() {
        [
            tableView,
            emptyLabel,
            loadingIndicator,
        ].forEach(addSubview(_:))

        #if os(iOS)
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
        }
        #endif
        
        loadingIndicator.hidesWhenStopped = true
        
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        #if os(iOS)
        tableView.separatorStyle = .singleLine
        #endif

        tableView.delegate = self
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }

    open func notifyItemsChanged() {
        var items: [MODEL] = []
        var emptyMessage = ""
        var loading = false

        switch state.items {
        case .items(let models):
            items = models
        case .empty(let message):
            emptyMessage = message
        case .loading:
            loading = true
        }

        emptyLabel.text = emptyMessage
        #if os(iOS)
        if let refreshControl = refreshControl {
            if loading {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        } else {
            if loading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
        #else
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        #endif

        tableView.reloadData()
        setNeedsLayout()
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if automaticallyDeselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutHeaderView()
        layoutFooterView()
    }

    open func configure<T: HyperView>(cell: TableViewCellWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        if configurationChangeTime != cell.configurationChangeTime {
            cell.configuration = configuration
            cell.configurationChangeTime = configurationChangeTime
        }
        let component = cell.cachedCellOrCreated(factory: factory)
        component.state.apply(from: model)
        (component as? Configurable)?.configuration = configuration
        component.actionPublisher.setListener(forObjectKey: self) { [actionPublisher] action in
            actionPublisher.publish(action: mapAction(action))
        }
    }
    
    open func dequeueAndConfigure<T: HyperView>(identifier: TableViewCellIdentifier<T>, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewCellWrapper<T> {
        let cell = tableView.dequeue(identifier: identifier)
        configure(cell: cell, factory: factory, model: model, mapAction: mapAction)
        return cell
    }
    
    open func configure<T: HyperView>(view: TableViewHeaderFooterWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        if configurationChangeTime != view.configurationChangeTime {
            view.configuration = configuration
            view.configurationChangeTime = configurationChangeTime
        }
        let component = view.cachedViewOrCreated(factory: factory)
        component.state.apply(from: model)
        (component as? Configurable)?.configuration = configuration
        component.actionPublisher.setListener(forObjectKey: self) { [actionPublisher] action in
            actionPublisher.publish(action: mapAction(action))
        }
    }
    
    open func dequeueAndConfigure<T: HyperView>(identifier: TableViewHeaderFooterIdentifier<T>, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> TableViewHeaderFooterWrapper<T> {
        let view = tableView.dequeue(identifier: identifier)
        configure(view: view, factory: factory, model: model, mapAction: mapAction)
        return view
    }

    public final func layoutHeaderView() {
        guard let header = tableView.tableHeaderView else { return }
        tableView.tableHeaderView = nil
        layout(view: header)
        tableView.tableHeaderView = header
    }

    public final func layoutFooterView() {
        guard let footer = tableView.tableFooterView else { return }
        tableView.tableFooterView = nil
        layout(view: footer)
        tableView.tableFooterView = footer
    }

    private func layout(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(targetSize,
                                                withHorizontalFittingPriority: UILayoutPriority.required,
                                                verticalFittingPriority: UILayoutPriority.defaultLow)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame.size = CGSize(width: targetSize.width, height: size.height)
    }
}
#endif
