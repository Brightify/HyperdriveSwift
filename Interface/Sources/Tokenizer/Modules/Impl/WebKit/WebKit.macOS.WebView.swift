//
//  WebKit.macOS.WebView.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 26/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
import WebKit
#endif

extension Module.WebKit.macOS {
    public class WebView: Module.AppKit.View {
        public override class var availableProperties: [PropertyDescription] {
            return Module.AppKit.Properties.webView.allProperties
        }

        public override class var parentModuleImport: String {
            return "WebKit"
        }

        public override var requiredImports: Set<String> {
            return ["WebKit"]
        }

        public override class func runtimeType() throws -> String {
            return "WKWebView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            switch platform {
            case .macOS:
                return RuntimeType(name: "WKWebView", module: "WebKit")
            case .iOS, .tvOS:
                throw TokenizationError.unsupportedElementError(element: WebView.self)
            }
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> NSView {
            return WKWebView()
        }
        #endif
    }

    public class WebViewProperties: Module.AppKit.ViewProperties {
        public let allowsMagnification: StaticAssignablePropertyDescription<Bool>
        public let magnification: StaticAssignablePropertyDescription<Double>
        public let allowsBackForwardNavigationGestures: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            allowsMagnification = configuration.property(name: "allowsMagnification")
            magnification = configuration.property(name: "magnification")
            allowsBackForwardNavigationGestures = configuration.property(name: "allowsBackForwardNavigationGestures")

            super.init(configuration: configuration)
        }
    }
}
