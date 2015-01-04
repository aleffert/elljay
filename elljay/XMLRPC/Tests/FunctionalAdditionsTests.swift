//
//  FunctionalAdditionsTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import XCTest

class FunctionalAdditionsTests : XCTestCase {
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
        XCTAssertEqual(result!, 6, "Reductions reduce")
    }
    
    func testMapOrFailSuccess() {
        let array = [1, 2, 3]
        let result : [Int]? = array.mapOrFail { return $0 + 1 }
        XCTAssertEqual(result!, [2, 3, 4], "mapOrFail is just map when nothing is nil")
    }
    
    func testMapOrFailFailure() {
        let array = [1, 2, 3]
        let result : [Int]? = array.mapOrFail { return $0 > 2 ? nil : $0 }
        XCTAssertNil(result, "mapOrFail fails when something returns nil")
    }
    
    func testReduce1Order() {
        let array = ["a", "b", "c"]
        let result = reduce1(array) {acc, cur in
            acc + cur
        }
        XCTAssertEqual(result!, "abc", "Reducations are left to right")
    }

    func testConcatMap() {
        let array = [1, 2, 3, 4]
        let result : [Int] = array.concatMap {
            return $0 > 2 ? [$0, $0] : []
        }
        XCTAssertEqual(result, [3, 3, 4, 4], "concatMap concats")
    }
}