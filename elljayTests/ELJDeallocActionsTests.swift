//
//  ELJDeallocActionsTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/11/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

class ELJDeallocActionsTests : XCTestCase {
    
    func testDealloc() {
        // This really just wants to be a boolean that gets set from true to false
        // but there appears to be a compiler bug causing the value to get reset
        var observed = NSMutableArray()
        func make() {
            autoreleasepool {
                let object = NSObject()
                object.performActionOnDealloc { _ in
                    observed.addObject("foo")
                    println("observed is \(observed)")
                }
            }
        }
        make()
        XCTAssertEqual(observed.count, 1)
    }
    
    func testStillAlive() {
        
        var observed = false

        let object = NSObject()
        object.performActionOnDealloc { _ in
            observed = true
        }
        
        XCTAssertFalse(observed)
    }
    
    func testManualRemove() {
        var observed = false
        
        func make() {
            autoreleasepool {
                let object = NSObject()
                let action = object.performActionOnDealloc { _ in
                    observed = true
                }
                action.remove()
            }
        }
        make();
        
        XCTAssertFalse(observed)
    }

}
