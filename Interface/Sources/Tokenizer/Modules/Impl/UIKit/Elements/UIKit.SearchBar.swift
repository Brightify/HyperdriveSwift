//
//  SearchBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class SearchBar: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.searchBar.allProperties
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            if let runtimeTypeOverride = runtimeTypeOverride {
                return runtimeTypeOverride
            }
            switch platform {
            case .iOS:
                return RuntimeType(name: "UISearchBar", module: "UIKit")
            case .tvOS, .macOS:
                throw TokenizationError.unsupportedElementError(element: SearchBar.self)
            }
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            #if os(tvOS)
                throw TokenizationError.unsupportedElementError(element: SearchBar.self)
            #else
                return UISearchBar()
            #endif
        }
        #endif
    }

    public class SearchBarProperties: ViewProperties {
        public let text: StaticAssignablePropertyDescription<TransformedText?>
        public let placeholder: StaticAssignablePropertyDescription<TransformedText?>
        public let prompt: StaticAssignablePropertyDescription<TransformedText?>
        public let barTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let barStyle: StaticAssignablePropertyDescription<BarStyle>
        public let searchBarStyle: StaticAssignablePropertyDescription<SearchBarStyle>
        public let isTranslucent: StaticAssignablePropertyDescription<Bool>
        public let showsBookmarkButton: StaticAssignablePropertyDescription<Bool>
        public let showsCancelButton: StaticAssignablePropertyDescription<Bool>
        public let showsSearchResultsButton: StaticAssignablePropertyDescription<Bool>
        public let isSearchResultsButtonSelected: StaticAssignablePropertyDescription<Bool>
        public let selectedScopeButtonIndex: StaticAssignablePropertyDescription<Int>
        public let showsScopeBar: StaticAssignablePropertyDescription<Bool>
        public let backgroundImage: StaticAssignablePropertyDescription<Image?>
        public let scopeBarBackgroundImage: StaticAssignablePropertyDescription<Image?>

        public required init(configuration: Configuration) {
            text = configuration.property(name: "text", defaultValue: TransformedText.text(""))
            placeholder = configuration.property(name: "placeholder")
            prompt = configuration.property(name: "prompt")
            barTintColor = configuration.property(name: "barTintColor")
            barStyle = configuration.property(name: "barStyle", defaultValue: .default)
            searchBarStyle = configuration.property(name: "searchBarStyle", defaultValue: .default)
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent", defaultValue: true)
            showsBookmarkButton = configuration.property(name: "showsBookmarkButton")
            showsCancelButton = configuration.property(name: "showsCancelButton")
            showsSearchResultsButton = configuration.property(name: "showsSearchResultsButton")
            isSearchResultsButtonSelected = configuration.property(name: "isSearchResultsButtonSelected", key: "searchResultsButtonSelected")
            selectedScopeButtonIndex = configuration.property(name: "selectedScopeButtonIndex")
            showsScopeBar = configuration.property(name: "showsScopeBar")
            backgroundImage = configuration.property(name: "backgroundImage")
            scopeBarBackgroundImage = configuration.property(name: "scopeBarBackgroundImage")

            super.init(configuration: configuration)
        }
    }
}
