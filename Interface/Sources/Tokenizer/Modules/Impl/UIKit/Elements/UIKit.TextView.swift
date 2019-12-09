//
//  TextView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class TextView: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.textView.allProperties
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UITextView()
        }
        #endif
    }

    public class TextViewProperties: ViewProperties {
        public let text: StaticAssignablePropertyDescription<TransformedText?>
        public let font: StaticAssignablePropertyDescription<Font?>
        public let textColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let textAlignment: StaticAssignablePropertyDescription<TextAlignment>
        public let textContainerInset: StaticAssignablePropertyDescription<EdgeInsets>
        public let allowsEditingTextAttributes: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            text = configuration.property(name: "text", defaultValue: .text(""))
            font = configuration.property(name: "font")
            textColor = configuration.property(name: "textColor")
            textAlignment = configuration.property(name: "textAlignment", defaultValue: .natural)
            textContainerInset = configuration.property(name: "textContainerInset", defaultValue: EdgeInsets(horizontal: 0, vertical: 8))
            allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")

            super.init(configuration: configuration)
        }
    }
}
