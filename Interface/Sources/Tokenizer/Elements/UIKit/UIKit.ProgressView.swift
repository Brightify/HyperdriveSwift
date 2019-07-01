//
//  ProgressView.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/04/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

extension Module.UIKit {
    public class ProgressView: View {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.progressView.allProperties
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
            return UIProgressView()
        }
        #endif
    }

    public class ProgressViewProperties: ViewProperties {
        public let progress: StaticAssignablePropertyDescription<Double>
        public let progressViewStyle: StaticAssignablePropertyDescription<ProgressViewStyle>
        public let progressTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let progressImage: StaticAssignablePropertyDescription<Image?>
        public let trackTintColor: StaticAssignablePropertyDescription<UIColorPropertyType?>
        public let trackImage: StaticAssignablePropertyDescription<Image?>

        public required init(configuration: Configuration) {
            progress = configuration.property(name: "progress")
            progressViewStyle = configuration.property(name: "progressViewStyle", defaultValue: .default)
            progressTintColor = configuration.property(name: "progressTintColor")
            progressImage = configuration.property(name: "progressImage")
            trackTintColor = configuration.property(name: "trackTintColor")
            trackImage = configuration.property(name: "trackImage")

            super.init(configuration: configuration)
        }
    }
}
