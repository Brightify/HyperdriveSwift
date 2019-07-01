//
//  AppKit.ImageView.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/06/2019.
//

#if HyperdriveRuntime && canImport(AppKit)
import AppKit
#endif

extension Module.AppKit {
    public class ImageView: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.imageView.allProperties
        }

        #if HyperdriveRuntime && canImport(AppKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> NSView {
            return NSImageView()
        }
        #endif
    }

    public class ImageViewProperties: ViewProperties {
        public let image: StaticAssignablePropertyDescription<Image?>
        public let highlightedImage: StaticAssignablePropertyDescription<Image?>
        public let animationDuration: StaticAssignablePropertyDescription<Double>
        public let animationRepeatCount: StaticAssignablePropertyDescription<Int>
        public let isHighlighted: StaticAssignablePropertyDescription<Bool>
        public let adjustsImageWhenAncestorFocused: StaticAssignablePropertyDescription<Bool>

        public required init(configuration: Configuration) {
            image = configuration.property(name: "image")
            highlightedImage = configuration.property(name: "highlightedImage")
            animationDuration = configuration.property(name: "animationDuration")
            animationRepeatCount = configuration.property(name: "animationRepeatCount")
            isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
            adjustsImageWhenAncestorFocused = configuration.property(name: "adjustsImageWhenAncestorFocused")

            super.init(configuration: configuration)
        }
    }
}
