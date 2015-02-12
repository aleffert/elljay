//
//  NotificationTests.swift
//  elljay
//
//  Created by Akiva Leffert on 2/11/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class NotificationTests: XCTestCase {

    func testAdd() {
        let notification : Notification<()> = Notification()
        var observed = false
        let listener = notification.addObserver() {
            observed = true
        }
        notification.notifyListeners(())
        XCTAssertTrue(observed)
    }
    
    func testRemove() {
        let notification : Notification<()> = Notification()
        var observed = false
        let listener = notification.addObserver() {
            observed = true
        }
        listener.remove()
        notification.notifyListeners(())
        XCTAssertFalse(observed)
    }
    
    func testMultipleListeners() {
        let notification : Notification<()> = Notification()
        var observed = 0
        let listener = notification.addObserver {
            observed = observed + 1
        }
        let otherListener = notification.addObserver {
            observed = observed + 2
        }
        notification.notifyListeners(())
        XCTAssertEqual(observed, 3)
        listener.remove()
        notification.notifyListeners(())
        XCTAssertEqual(observed, 5)
        otherListener.remove()
        XCTAssertEqual(observed, 5)
    }
    
    func testAutoRemove() {
        let notification : Notification<()> = Notification()
        var observed = false
        func make() {
            let owner = NSObject()
            let listener = notification.addObserver(owner) {
                observed = true
            }
        }
        make()
        notification.notifyListeners(())
        XCTAssertFalse(observed)
    }

}
