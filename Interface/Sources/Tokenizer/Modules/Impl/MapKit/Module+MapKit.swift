//
//  Module+MapKit.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

extension Module {
    public static let mapKit = MapKit()

    public struct MapKit: RuntimeModule {
        public struct iOS { }
        public struct macOS { }

        public let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
            .macOS,
        ]

        public func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            let mapViewFactory: UIElementFactory
            switch platform {
            case .iOS, .tvOS:
                mapViewFactory = factory(named: "MapView", for: iOS.MapView.init)
            case .macOS:
                mapViewFactory = factory(named: "MapView", for: macOS.MapView.init)
            }
            return [
                mapViewFactory,
            ]
        }
    }
}
