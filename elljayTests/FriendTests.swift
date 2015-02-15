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
        XCTAssertEqual(User(user: "Test", name: nil), User(user: "Test", name: nil))
    }
    
    func testInequality() {
        XCTAssertEqual(User(user: "Test", name: nil), User(user: "Other", name: nil))
    }
    
    func testNameIrrelevant() {
        XCTAssertEqual(User(user: "Test", name: "foo"), User(user: "Other", name: "bar"))
    }
   
}
