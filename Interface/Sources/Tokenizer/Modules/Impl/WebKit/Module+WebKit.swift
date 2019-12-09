//
//  Module+WebKit.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

extension Module {
    public static let webKit = WebKit()

    public struct WebKit: RuntimeModule {
        public struct iOS { }
        public struct macOS { }

        public let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
            .macOS,
        ]

        public func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            let webViewFactory: UIElementFactory
            switch platform {
            case .iOS, .tvOS:
                webViewFactory = factory(named: "WebView", for: iOS.WebView.init)
            case .macOS:
                webViewFactory = factory(named: "WebView", for: macOS.WebView.init)
            }
            return [
                webViewFactory,
            ]
        }
    }
}
