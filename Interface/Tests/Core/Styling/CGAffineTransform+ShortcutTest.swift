//
//  CGAffineTransform+ShortcutTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import HyperdriveInterface

class CGAffineTransformShortcutTest: QuickSpec {
    
    override func spec() {
        describe("rotate") {
            it("creates CGAffineTransform") {
                expect(CGAffineTransform.rotate(radians: 0)) == CGAffineTransform(rotationAngle: 0)
                expect(CGAffineTransform.rotate(radians: 10)) == CGAffineTransform(rotationAngle: 10)
            }
        }
        describe("translate") {
            it("creates CGAffineTransform") {
                expect(CGAffineTransform.translate()) == CGAffineTransform(translationX: 0, y: 0)
                expect(CGAffineTransform.translate(x: 1)) == CGAffineTransform(translationX: 1, y: 0)
                expect(CGAffineTransform.translate(y: 1)) == CGAffineTransform(translationX: 0, y: 1)
                expect(CGAffineTransform.translate(x: 1, y: 1)) == CGAffineTransform(translationX: 1, y: 1)
            }
        }
        describe("scale") {
            it("creates CGAffineTransform") {
                expect(CGAffineTransform.scale()) == CGAffineTransform(scaleX: 1, y: 1)
                expect(CGAffineTransform.scale(x: 2)) == CGAffineTransform(scaleX: 2, y: 1)
                expect(CGAffineTransform.scale(y: 2)) == CGAffineTransform(scaleX: 1, y: 2)
                expect(CGAffineTransform.scale(x: 2, y: 2)) == CGAffineTransform(scaleX: 2, y: 2)
            }
        }
        describe("+") {
            it("sums vectors") {
                expect(CGAffineTransform.translate(x: 5) + CGAffineTransform.translate(y: 3)) == CGAffineTransform.translate(x: 5, y: 3)
            }
        }
    }
}
