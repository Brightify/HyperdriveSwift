//
//  Foundation.Properties.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 27/06/2019.
//

extension Module.Foundation {
    public struct Properties: PropertiesContainer {
        public static let attributedText = prepare(AttributedTextProperties.self)
        public static let paragraphStyle = prepare(ParagraphStyleProperties.self)
    }
}
