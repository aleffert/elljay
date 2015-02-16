//
//  UserTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/13/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import XCTest

import elljay

class UserTests: XCTest {
    
    func testEquality() {
        XCTAssertEqual(User(userID: "Test", name: nil), User(userID: "Test", name: nil))
    }
    
    func testInequality() {
        XCTAssertEqual(User(userID: "Test", name: nil), User(userID: "Other", name: nil))
    }
    
    func testEqualityNameIrrelevant() {
        XCTAssertEqual(User(userID: "Test", name: "foo"), User(userID: "Other", name: "bar"))
    }
    
    func testEncodeDecode() {
        let user = User(userID: "Test", name: "foo")
        let data = NSKeyedArchiver.archivedDataWithRootObject(user)
        let otherUser = NSKeyedUnarchiver.unarchiveObjectWithData(data) as User
        XCTAssertEqual(user, otherUser)
        XCTAssertEqual(user.name!, otherUser.name!)
        XCTAssertEqual(user.userID, otherUser.userID)
    }
   
    func testDisplayNameFound() {
        let user = User(userID: "ID", name: "name")
        XCTAssertEqual(user.displayName, "name")
    }
    
    func testDisplayNameMissing() {
        let user = User(userID: "ID", name: nil)
        XCTAssertEqual(user.displayName, "ID")
    }
}
