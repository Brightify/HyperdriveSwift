//
//  AppKit.Properties.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 26/06/2019.
//

extension Module.AppKit {
    public struct Properties: PropertiesContainer {
        public static let view = prepare(ViewProperties.self)
//        public static let label = prepare(LabelProperties.self)
        public static let button = prepare(ButtonProperties.self)
        public static let datePicker = prepare(DatePickerProperties.self)
        public static let imageView = prepare(ImageViewProperties.self)
        public static let mapView = prepare(Module.MapKit.macOS.MapViewProperties.self)
        public static let scrollView = prepare(ScrollViewProperties.self)
        public static let splitView = prepare(SplitViewProperties.self)
//        public static let searchBar = prepare(SearchBarProperties.self)
//        public static let segmentedControl = prepare(SegmentedControlProperties.self)
//        public static let slider = prepare(SliderProperties.self)
//        public static let stackView = prepare(StackViewProperties.self)
        public static let stepper = prepare(StepperProperties.self)
//        public static let `switch` = prepare(SwitchProperties.self)
//        public static let tabBar = prepare(TabBarProperties.self)
//        public static let tableView = prepare(TableViewProperties.self)
        public static let textField = prepare(TextFieldProperties.self)
//        public static let textView = prepare(TextViewProperties.self)
//        public static let toolbar = prepare(ToolbarProperties.self)
//        public static let visualEffectView = prepare(VisualEffectViewProperties.self)
        public static let webView = prepare(Module.WebKit.macOS.WebViewProperties.self)
//        public static let progressView = prepare(ProgressViewProperties.self)
        public static let attributedText = prepare(Module.Foundation.AttributedTextProperties.self)
        public static let paragraphStyle = prepare(Module.Foundation.ParagraphStyleProperties.self)
    }

    public struct ToolingProperties: PropertiesContainer {
        public static let view = prepare(ViewToolingProperties.self)
        public static let componentDefinition = prepare(ComponentDefinitionToolingProperties.self)
    }
}
