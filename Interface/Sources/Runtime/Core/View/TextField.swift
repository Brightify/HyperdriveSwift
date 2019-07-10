//
//  TextField.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public enum TextInputState {
    case string(String)
    case attributedString(NSAttributedString)
}

extension TextInputState: TextInputStateConvertible {
    public func asTextInputState() -> TextInputState {
        return self
    }
}

public protocol TextInputStateConvertible {
    func asTextInputState() -> TextInputState
}

extension TextInputStateConvertible {
    public func asString() -> String {
        switch asTextInputState() {
        case .string(let string):
            return string
        case .attributedString(let attributedString):
            return attributedString.string
        }
    }

    public func asAttributedString() -> NSAttributedString {
        switch asTextInputState() {
        case .string(let string):
            return NSAttributedString(string: string)
        case .attributedString(let attributedString):
            return attributedString
        }
    }
}

extension String: TextInputStateConvertible {
    public func asTextInputState() -> TextInputState {
        return .string(self)
    }
}

extension NSAttributedString: TextInputStateConvertible {
    public func asTextInputState() -> TextInputState {
        return .attributedString(self)
    }
}

private class ContentInsetTextField: UITextField {
    @objc
    public var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = super.textRect(forBounds: bounds)
        return superBounds.inset(by: contentEdgeInsets)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superBounds = super.editingRect(forBounds: bounds)
        return superBounds.inset(by: contentEdgeInsets)
    }
}

public final class HyperTextField: ConfigurableHyperViewBase {
    public typealias StateType = TextInputStateConvertible
    public typealias ActionType = String

    public enum Content {
        case text(String?)
        case attributedText(NSAttributedString?)
    }

    public final class State: HyperViewState {
        fileprivate weak var owner: HyperTextField? { didSet { resynchronize() } }

        public var content: Content = .text("") { didSet { owner?.notifyContentChanged() } }

        public var text: String? {
            get {
                switch content {
                case .text(let text):
                    return text
                case .attributedText(let attributedText):
                    return attributedText?.string
                }
            }
            set {
                content = .text(newValue)
            }
        }

        public var attributedText: NSAttributedString? {
            get {
                switch content {
                case .text(let text):
                    return text.map(NSAttributedString.init(string:))
                case .attributedText(let attributedText):
                    return attributedText
                }
            }
            set {
                content = .attributedText(newValue)
            }
        }

        public init() { }

        public func resynchronize() {
            guard let owner = owner else { return }
            owner.notifyContentChanged()
        }

        public func apply(from otherState: HyperTextField.State) {
            content = otherState.content
        }
    }
    public enum Action {
        case textChanged(String?)
    }

    public override var configuration: Configuration {
        didSet {
            layoutMargins = configuration.get(valueFor: Properties.layoutMargins)
            configuration.get(valueFor: Properties.Style.textField)(self)
        }
    }

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    @objc
    public var contentEdgeInsets: UIEdgeInsets {
        get {
            return _textField.contentEdgeInsets
        }
        set {
            _textField.contentEdgeInsets = newValue
        }
    }

    @objc
    public var placeholderColor: UIColor? {
        get {
            return placeholderAttributes[.foregroundColor] as? UIColor
        }
        set {
            placeholderAttributes[.foregroundColor] = newValue
        }
    }

    @objc
    public var placeholderFont: UIFont? {
        get {
            return placeholderAttributes[.font] as? UIFont
        }
        set {
            placeholderAttributes[.font] = newValue
        }
    }

    public var placeholderAttributes: [NSAttributedString.Key: Any] = [:] {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    public var placeholder: String? = nil {
        didSet {
            updateAttributedPlaceholder()
        }
    }

    public let state: State
    public let actionPublisher: ActionPublisher<Action>

    private let _textField = ContentInsetTextField()
    public var textField: UITextField {
        return _textField
    }

    public required init(initialState: State = State(), actionPublisher: ActionPublisher<Action> = ActionPublisher()) {
        self.state = initialState
        self.actionPublisher = actionPublisher

        super.init()

        translatesAutoresizingMaskIntoConstraints = false

        loadView()
        setupConstraints()

        reloadConfiguration()

        afterInit()

        state.owner = self
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func afterInit() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func loadView() {
        addSubview(textField)
    }

    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func needsUpdate(previousState: StateType?) -> Bool {
        return true
    }

    @objc
    internal func textFieldDidChange() {
        actionPublisher.publish(action: .textChanged(textField.text))
    }

    private func notifyContentChanged() {
        let oldSelectedRange = textField.selectedTextRange

        switch state.content {
        case .text(let string):
            textField.text = string
        case .attributedText(let attributedText):
            textField.attributedText = attributedText
        }


        textField.selectedTextRange = oldSelectedRange
    }

    private func updateAttributedPlaceholder() {
        if placeholderAttributes.isEmpty {
            textField.placeholder = placeholder
        } else {
            textField.attributedPlaceholder = placeholder.map { NSAttributedString(string: $0, attributes: placeholderAttributes) }
        }
    }
}
#endif
