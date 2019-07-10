import AppKit
import Hyperdrive
import HyperdriveInterface
import SnapKit
public enum ApplicationTheme: String, ReactantThemeDefinition {
	public struct Colors {
		fileprivate let theme: ApplicationTheme

	}
	public struct Images {
		fileprivate let theme: ApplicationTheme

	}
	public struct Fonts {
		fileprivate let theme: ApplicationTheme

	}

	case none

	public static var current: ApplicationTheme {
		return selector.currentTheme
	}
	public static let selector = ReactantThemeSelector<ApplicationTheme>(defaultTheme: .none)
	public var colors: Colors {
		return Colors(theme: self)
	}
	public var images: Images {
		return Images(theme: self)
	}
	public var fonts: Fonts {
		return Fonts(theme: self)
	}

}
import Hyperdrive
import AppKit
private class __HyperdriveUIBundleToken {
}
private let __resourceBundle = Bundle(for: __HyperdriveUIBundleToken.self)
// Generated from /Users/matyas/iDev/Hyperdrive/Showcases/Showcase-macOS/Sources/gg.ui.xml
final class GoodGame: HyperViewBase, HyperView {
	final class State: HyperViewState {
		fileprivate weak var owner: GoodGame? {
			didSet { resynchronize() }
		}

		init() {
		}

		func apply(from otherState: State) {
		}

		func resynchronize() {
		}
	}
	enum Action {
		case moved
		case WTF
		case textko(text: String)

	}
	final class Constraints {
	}

	static let triggerReloadPaths: Set<String> = [
		"/Users/matyas/iDev/Hyperdrive/Showcases/Showcase-macOS/Sources/gg.ui.xml",
	]
	
	let layout = Constraints()
	let state: State
	let actionPublisher: ActionPublisher<Action>
	private let field: NSTextField
	private let slider: NSSlider
	private let _1_Button: NSButton

	init(initialState: State = State(), actionPublisher: ActionPublisher<Action> = ActionPublisher()) {
		field = NSTextField()
		slider = NSSlider()
		_1_Button = NSButton()
		
		state = initialState
		self.actionPublisher = actionPublisher
		
		super.init()
		
		loadView()
		setupConstraints()
		initialState.owner = self
		observeActions(actionPublisher: actionPublisher)
	}

	private func observeActions(actionPublisher: ActionPublisher<Action>) {
		ControlEventObserver.bind(to: slider, handler: {
			actionPublisher.publish(action: .moved)
		})
		ControlEventObserver.bind(to: _1_Button, handler: {
			actionPublisher.publish(action: .WTF)
		})
		HyperdriveInterface.NSTextFieldObserver.bind(to: field, handler: { text in
			actionPublisher.publish(action: .textko(text: text))
		})
	}

	private func loadView() {
		self.addSubview(field)
		self.addSubview(slider)
		self.addSubview(_1_Button)
	}

	private func setupConstraints() {
		field.snp.makeConstraints({ make in
			make.width.equalTo(300.0)
			make.top.equalTo(self).offset(20.0)
			make.height.equalTo(100.0)
			make.leading.equalTo(self).offset(20.0)
		})
		slider.snp.makeConstraints({ make in
			make.top.equalTo(field.snp.bottom).offset(25.0)
			make.width.equalTo(250.0)
			make.leading.equalTo(self).offset(30.0)
		})
		_1_Button.snp.makeConstraints({ make in
			make.top.equalTo(slider.snp.bottom)
		})
	}
}
extension GoodGame {
	struct StylesStyles {
	}
	struct Templates {
	}

}
public func activateLiveInterface(in window: NSWindow) {
}
