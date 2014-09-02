//
//  NSDateOrderingTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/31/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import XCTest
import UIKit

import elljay

class NSDateOrderingTests : XCTestCase {
    
    func testDateOrdering() {
        let earlier = NSDate.dateWithTimeIntervalSinceReferenceDate(100)
        let later = NSDate.dateWithTimeIntervalSinceReferenceDate(1000)
        XCTAssertLessThan(earlier, later, "An earlier date sould be correctly less than")
    }
    
    func testDateEquality() {
        let a = NSDate.dateWithTimeIntervalSinceReferenceDate(100)
        let b = NSDate.dateWithTimeIntervalSinceReferenceDate(100)
        XCTAssertEqual(a, b, "Dates with the same time interval should be equal")
    }
    
    func testDateInequality() {
        let a = NSDate.dateWithTimeIntervalSinceReferenceDate(100)
        let b = NSDate.dateWithTimeIntervalSinceReferenceDate(1000)
        XCTAssertNotEqual(a, b, "Dates with different time intervals should be different")
    }
   
}
