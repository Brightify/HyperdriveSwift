//
//  Line.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public struct Line: Describable {
    public let content: String

    public func describe(into pipe: DescriptionPipe) {
        pipe.line(content)
    }
}
