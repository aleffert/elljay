//
//  FriendTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/13/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import XCTest

import elljay

class FriendTests: XCTest {
    
    func testEquality() {
        XCTAssertEqual(Friend(user: "Test", name: nil), Friend(user: "Test", name: nil))
    }
    
    func testInequality() {
        XCTAssertEqual(Friend(user: "Test", name: nil), Friend(user: "Other", name: nil))
    }
    
    func testNameIrrelevant() {
        XCTAssertEqual(Friend(user: "Test", name: "foo"), Friend(user: "Other", name: "bar"))
    }
   
}
