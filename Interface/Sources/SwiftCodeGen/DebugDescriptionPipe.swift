//
//  DebugDescriptionPipe.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public class DebugDescriptionPipe: DescriptionPipe {
    public override init() {
        super.init()
    }

    deinit {
        print(result.joined(separator: "\n"))
    }
}
