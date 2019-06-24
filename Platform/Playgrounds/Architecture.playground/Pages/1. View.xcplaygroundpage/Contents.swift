/*:

 # 1. View

 View is defined solely in an XML file. A Swift implementation is generated automatically.

 View supports using `$x`  for properties which generates a `State` structure.

 View supports `action:x` attributes for wiring actions.

 View has Outlets structure to expose its children to its `Controller`.

 View has Layout structure to expose constraints to its `Controller`.

 Example:

 ```xml
 <CustomView>
    <TextField text="$message" action:text="messageChanged" />
    <Button text="Sign in" action:tap="signInTapped" />
    <Label outlet="title" />
 </CustomView>
 ```
 */

import UIKit
import Hyperdrive_iOS

final class CustomView: UIView, HyperView {
    private let textField1Delegate: Hyperdrive.TextFieldActionDelegate
    private let button2Delegate: Hyperdrive.ButtonActionDelegate

    private let textField1 = UITextField()
    private let button2 = UIButton()
    private let label3: UILabel

    private let actionPublisher: ActionPublisher<Action>

    let outlets = CustomView.Outlets()
 
    init(actionPublisher: ActionPublisher<Action>) {
        self.actionPublisher = actionPublisher

        self.textField1Delegate = Hyperdrive.TextFieldActionDelegate(
            onTextChanged: actionPublisher.publisher(Action.messageChanged))

        self.button2Delegate = Hyperdrive.ButtonActionDelegate(
            onTapped: actionPublisher.publisher(Action.signInTapped))

        label3 = outlets.title

        super.init(frame: .zero)

        loadView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not supported!") }

    func set(state: CustomView.State) {
        textField1.text = state.message

    }

    func apply(change: CustomView.State.Change) {
        switch change {
        case .changeMessage(let message):
            textField1.text = message
        }
    }

    private func loadView() {
        addSubview(textField1)
        addSubview(button2)
        addSubview(label3)

        // First version might use RxSwift, we should drop it later though
        // in favor of implementing delegates and using those in this view.
        textField1Delegate.bind(to: textField1)
        button2Delegate.bind(to: button2)
    }

    private func setupConstraints() {
        // ...
    }
}

extension CustomView {
    struct Outlets: HyperViewOutlets {
        let title = UILabel()

        init() {

        }
    }
    struct State: HyperViewState {
        private var changes: [Change]? = nil

        var message: String? {
            didSet {
                changes?.append(.changeMessage(message))
            }
        }

        mutating func mutateRecordingChanges(mutation: (inout State) -> Void) -> [Change] {
            var mutableState = self
            mutableState.changes = []

            mutation(&mutableState)

            let changes = mutableState.changes
            mutableState.changes = nil

            self = mutableState

            return changes ?? []
        }

        mutating func apply(change: CustomView.State.Change) {
            switch change {
            case .changeMessage(let message):
                self.message = message
            }
        }

        enum Change {
            case changeMessage(String?)
        }
    }

    enum Action {
        case messageChanged(String?)
        case signInTapped
    }
}

/*:

 ```
 <TimelineView>
     <TimelineListView injected="list" />
     <TimelineGridView injected="grid" />
 </TimelineView>
 ```

 */

//class TimelineListView { }
//class TimelineGridView { }
//
//class TimelineListControler: HyperViewController<TimlineListView> {
//
//}
//
//class TimelineView {
//    private var list = ExternalView<TimelineListView>()
//    private var grid = ExternalView<TimelineGridView>()
//
//    init(list: TimelineListView, grid: TimelineGridView) {
//        self.list = list
//        self.grid = grid
//    }
//
//    required init(actionPublisher: ActionPublisher<Action>) {
//
//    }
//
//    func bind(list: TimelineListView,
//              grid: TimelineGridView) {
//
//        self.list.view = list
//        self.grid.view = grid
//    }
//}
//
//class TimelineControler: UIViewController {
//
//    init(list: TimelineListControler)
//
//    override func loadView() {
//        view = TimelineView(list: list.view, grid: grid.view)
//    }
//
//}

//class CustomView: UIView, HyperView {
//    private let textField1Delegate: Hyperdrive.TextFieldActionDelegate
//    private let button2Delegate: Hyperdrive.ButtonActionDelegate
//
//    private let textField1 = UITextField()
//    private let button2 = UIButton()
//
//    private let actionPublisher: ActionPublisher<Action>
//
//    init(actionPublisher: ActionPublisher<Action>) {
//        self.actionPublisher = actionPublisher
//
//        self.textField1Delegate = Hyperdrive.TextFieldActionDelegate(
//            onTextChanged: actionPublisher.publisher(Action.messageChanged))
//
//        self.button2Delegate = Hyperdrive.ButtonActionDelegate(
//            onTapped: actionPublisher.publisher(Action.signInTapped))
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//
//
//    private func loadView() {
//        addSubview(textField1)
//        addSubview(button2)
//
//        // First version might use RxSwift, we should drop it later though
//        // in favor of implementing delegates and using those in this view.
//        textField1Delegate.bind(to: textField1)
//        button2Delegate.bind(to: button2)
//    }
//
//    private func setupConstraints() {
//        // ...
//    }
//}
//
//extension CustomView {
//    struct State {
//        var message: String
//    }
//
//    enum Action {
//        case messageChanged(String?)
//        case signInTapped
//    }
//}

//class HyperdriveInterface<T: HyperView> {
//    func create<T: HyperView>(_ type: T.self)
//}

/*:
 # Overrides

 In each XML file with a View, overrides can be declared to add extra functionality to certain views.

 ```xml
 <CustomView>
    <overrides
        didLayoutSubviews="aMethodDeclaredInExtension" />
 </CustomView>
 ```

 ```swift
 extension CustomView {
    func aMethodDeclaredInExtension() {
        // Custom code
    }
 }
 ```

 ## Supported overrides:
 - willLayoutSubviews [no params]
    - run from `layoutSubviews` before a call to `super`
 - didLayoutSubviews [no params]
    - run from `layoutSubviews` after a call to `super`
 - willMoveToSuperview (newSuperview: UIView?)
    - run from `willMove(toSuperview:)` before a call to `super`
 - didMoveToSuperview [no params]
    -run from `didMoveToSupervie()` after a call to `super`
 - willMoveToWindow (newWindow: UIWindow?)
    - run from `willMove(toWindow:)` before a call to `super`
 - didMoveToWindow [no params]
    - run from `didMoveToWindow()` after a call to `super`
 - didAddSubview (_ subview: UIView)
    - run from `didAddSubview(_:)` after a call to `super`
 - willRemoveSubview (_ subview: UIView)
    - run from `willRemoveSubview(_:)` before a call to `super`
 - layoutMarginsDidChange
 - safeAreaInsetsDidChange
 */

/*:
 # State description

 In addition to using `$p` to generate a state property named `p`, users can opt-in to use a more specialized description.

 Each state property has to declare its `type`, as well as its default value. The default value is in a form of a Swift code, that'll be placed in verbatim to the right of an `=` sign of property initialization in the `State` class. State properties can be marked as optional, making the default value `nil` unless explicitly stated otherwise.



 NOTE: It's recommended that each of the used properties' type is a value-type.

 ```xml
 <CustomView>
    <state>
        <profile type="Profile" default="Profile()" />
        <something type="Int" optional="true" />
        <percentage type="Float"
            type="Float"
            receiver="percentageChanged(percentage:) />
    </state>
 </CustomView>
 ```

 ```swift
 extension CustomView {
    func percentageChanged(percentage: Float) {
        // Called each time the percentage changes
    }
 }
 ```
 */

//: [Next](@next)
