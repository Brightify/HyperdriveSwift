//
//  AppKit.TextField.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 27/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class TextField: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.textField.allProperties
        }

        public class override func runtimeType() -> String {
            return "NSTextField"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            return RuntimeType(name: "NSTextField", module: "AppKit")
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
            return NSTextField()
        }
        #endif
    }

    public class TextFieldProperties: ControlProperties {
        public let text: StaticAssignablePropertyDescription<TransformedText?>
        public let placeholder: StaticAssignablePropertyDescription<TransformedText?>
        public let font: StaticAssignablePropertyDescription<Font?>
        public let textColor: StaticAssignablePropertyDescription<UIColorPropertyType>
        public let textAlignment: StaticAssignablePropertyDescription<TextAlignment>
        public let allowsEditingTextAttributes: StaticAssignablePropertyDescription<Bool>
        public let backgroundColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let isAutomaticTextCompletionEnabled: StaticAssignablePropertyDescription<Bool>
        public let maximumNumberOfLines: StaticAssignablePropertyDescription<Int>
        public let attributedText: StaticElementAssignablePropertyDescription<Module.Foundation.AttributedText?>
        public let attributedPlaceholder: StaticElementAssignablePropertyDescription<Module.Foundation.AttributedText?>

        public required init(configuration: Configuration) {
            text = configuration.property(name: "text", swiftName: "stringValue", defaultValue: .text(""))
            placeholder = configuration.property(name: "placeholder", swiftName: "placeholderString", defaultValue: nil)
            font = configuration.property(name: "font")
            textColor = configuration.property(name: "textColor", defaultValue: .black)
            textAlignment = configuration.property(name: "textAlignment", swiftName: "alignment", defaultValue: .natural)
            allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")
            backgroundColor = configuration.property(name: "backgroundColor")
            isAutomaticTextCompletionEnabled = configuration.property(name: "isAutoCompleteEnabled", swiftName: "isAutomaticTextCompletionEnabled", defaultValue: false)
            maximumNumberOfLines = configuration.property(name: "maximumNumberOfLines", defaultValue: 0)

            attributedText = configuration.property(name: "attributedText", swiftName: "attributedStringValue")
            attributedPlaceholder = configuration.property(name: "attributedPlaceholder", swiftName: "placeholderAttributedString")

            super.init(configuration: configuration)
        }
    }
}
