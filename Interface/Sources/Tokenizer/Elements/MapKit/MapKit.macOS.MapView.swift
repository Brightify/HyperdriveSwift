//
//  MapKit.macOS.MapView.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 26/06/2019.
//

#if canImport(AppKit)
import AppKit
import MapKit
#endif

extension Module.MapKit.macOS {
    public class MapView: Module.AppKit.View {
        public override class var availableProperties: [PropertyDescription] {
            return Module.AppKit.Properties.mapView.allProperties
        }

        public override class var parentModuleImport: String {
            return "MapKit"
        }

        public override var requiredImports: Set<String> {
            return ["MapKit"]
        }

        public class override func runtimeType() -> String {
            return "MKMapView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            switch platform {
            case .macOS:
                return RuntimeType(name: "MKMapView", module: "MapKit")
            case .iOS, .tvOS:
                fatalError("Using macOS MKMapView. Use the iOS one.")
            }
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
            return MKMapView()
        }
        #endif
    }

    public class MapViewProperties: Module.AppKit.ViewProperties {
//        public let mapType: StaticAssignablePropertyDescription<MapType>
        public let isZoomEnabled: StaticAssignablePropertyDescription<Bool>
        public let isScrollEnabled: StaticAssignablePropertyDescription<Bool>
        public let isPitchEnabled: StaticAssignablePropertyDescription<Bool>
        public let isRotateEnabled: StaticAssignablePropertyDescription<Bool>
        public let showsPointsOfInterest: StaticAssignablePropertyDescription<Bool>
        public let showsBuildings: StaticAssignablePropertyDescription<Bool>
        public let showsCompass: StaticAssignablePropertyDescription<Bool>
        public let showsZoomControls: StaticAssignablePropertyDescription<Bool>
        public let showsScale: StaticAssignablePropertyDescription<Bool>
        public let showsTraffic: StaticAssignablePropertyDescription<Bool>
        public let showsUserLocation: StaticAssignablePropertyDescription<Bool>
        public let isUserLocationVisible: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
//            mapType = configuration.property(name: "mapType", defaultValue: .standard)
            isZoomEnabled = configuration.property(name: "isZoomEnabled", key: "zoomEnabled", defaultValue: true)
            isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled", defaultValue: true)
            isPitchEnabled = configuration.property(name: "isPitchEnabled", key: "pitchEnabled", defaultValue: true)
            isRotateEnabled = configuration.property(name: "isRotateEnabled", key: "rotateEnabled", defaultValue: true)
            showsPointsOfInterest = configuration.property(name: "showsPointsOfInterest", defaultValue: true)
            showsBuildings = configuration.property(name: "showsBuildings", defaultValue: true)
            showsCompass = configuration.property(name: "showsCompass", defaultValue: true)
            showsZoomControls = configuration.property(name: "showsZoomControls")
            showsScale = configuration.property(name: "showsScale")
            showsTraffic = configuration.property(name: "showsTraffic")
            showsUserLocation = configuration.property(name: "showsUserLocation")
            isUserLocationVisible = configuration.property(name: "isUserLocationVisible", key: "userLocationVisible")

            super.init(configuration: configuration)
        }
    }
}
