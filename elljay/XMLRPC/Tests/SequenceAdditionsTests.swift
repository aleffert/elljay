//
//  SequenceAdditionsTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import XCTest

class SequenceExtensionTests : XCTestCase {
    func testReduce1Empty() {
        let empty = []
        let result : AnyObject? = reduce1(empty) {acc, cur in
            return acc
        }
        XCTAssertNil(result, "Reducing an empty collection should return nil")
    }
    
    func testReduce1N() {
        let array = [1, 2, 3]
        let result = reduce1(array) {acc, cur in
            acc + cur
        }
        XCTAssert(result == 6, "Reductions reduce")
    }
    
    func testReduce1Order() {
        let array = ["a", "b", "c"]
        let result = reduce1(array) {acc, cur in
            acc + cur
        }
        XCTAssert(result == "abc", "Reducations are left to right")
    }
}