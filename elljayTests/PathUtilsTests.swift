//
//  PathUtilsTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/15/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class PathUtilsTests: XCTestCase {
    
    func testDocumentsPathExists() {
        let path = PathUtils.documentsPath()
        XCTAssertNotNil(path)
    }
    
    func testUserPathExists() {
        let path = PathUtils.pathForUser("foo")
        XCTAssertNotNil(path)
    }
    
    func testUserPathStateless() {
        XCTAssertEqual(PathUtils.pathForUser("bar"), PathUtils.pathForUser("bar"))
    }
    
    func testUserPathDistinct() {
        XCTAssertNotEqual(PathUtils.pathForUser("bar"), PathUtils.pathForUser("foo"))
    }

}
