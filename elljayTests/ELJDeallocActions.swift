//
//  ELJDeallocActions.swift
//  elljay
//
//  Created by Akiva Leffert on 2/11/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

class ELJDeallocActions: XCTestCase {
    
    func testDealloc() {
        var observed = false
        func make() {
            let object = NSObject()
            object.performActionOnDealloc { () -> Void in
                observed = true
            }
        }
        make()
        
        XCTAssertTrue(observed)
    }
    
    func testStillAlive() {
        
        var observed = false

        let object = NSObject()
        object.performActionOnDealloc { () -> Void in
            observed = true
        }
        
        XCTAssertFalse(observed)
    }
    
    func testManualRemove() {
        var observed = false
        
        let object = NSObject()
        let action = object.performActionOnDealloc { () -> Void in
            observed = true
        }
        action.remove()
        
        XCTAssertFalse(observed)
    }

}
