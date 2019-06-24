//
//  ParagraphStyleProperties.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

public class ParagraphStyleProperties: PropertyContainer {
    public let alignment: StaticAssignablePropertyDescription<TextAlignment>
    public let firstLineHeadIndent: StaticAssignablePropertyDescription<Double>
    public let headIndent: StaticAssignablePropertyDescription<Double>
    public let tailIndent: StaticAssignablePropertyDescription<Double>
//    public let tabStops: StaticAssignablePropertyDescription<[TextTab]>
    public let lineBreakMode: StaticAssignablePropertyDescription<LineBreakMode>
    public let maximumLineHeight: StaticAssignablePropertyDescription<Double>
    public let minimumLineHeight: StaticAssignablePropertyDescription<Double>
    public let lineHeightMultiple: StaticAssignablePropertyDescription<Double>
    public let lineSpacing: StaticAssignablePropertyDescription<Double>
    public let paragraphSpacing: StaticAssignablePropertyDescription<Double>
    public let paragraphSpacingBefore: StaticAssignablePropertyDescription<Double>

    public required init(configuration: Configuration) {
        let defaultTabStops = (1...12).map { i in
            TextTab(textAlignment: .left, location: Double(28 * i))
        }

        alignment = configuration.property(name: "alignment", defaultValue: .natural)
        firstLineHeadIndent = configuration.property(name: "firstLineHeadIndent")
        headIndent = configuration.property(name: "headIndent")
        tailIndent = configuration.property(name: "tailIndent")
//        tabStops = configuration.property(name: "tabStops", defaultValue: defaultTabStops)
        lineBreakMode = configuration.property(name: "lineBreakMode", defaultValue: .byWordWrapping)
        maximumLineHeight = configuration.property(name: "maximumLineHeight")
        minimumLineHeight = configuration.property(name: "minimumLineHeight")
        lineHeightMultiple = configuration.property(name: "lineHeightMultiple")
        lineSpacing = configuration.property(name: "lineSpacing")
        paragraphSpacing = configuration.property(name: "paragraphSpacing")
        paragraphSpacingBefore = configuration.property(name: "paragraphSpacingBefore")

        super.init(configuration: configuration)
    }
}
