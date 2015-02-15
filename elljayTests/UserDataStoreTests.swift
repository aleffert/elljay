//
//  UserDataStoreTests.swift
//  elljay
//
//  Created by Akiva Leffert on 1/3/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class UserDataStoreTests: XCTestCase {
    
    class FriendTestEnvironment {
        let friends = [
            User(user : "cummings", name : nil),
            User(user : "eliot", name : nil)
        ]
        
        var friendNames : [UserID] {
            return friends.map {
                $0.user
            }
        }
        
        let dataStore : UserDataStore
        var present : NSDate {
            let components = NSDateComponents()
            components.year = 2015
            components.day = 10
            components.month = 1
            return NSCalendar.currentCalendar().dateFromComponents(components)!
        }
        
        init() {
            let dataStore = UserDataStore(userID : "$$TEST$$")
            dataStore.performActionOnDealloc {[weak dataStore] in
                dataStore?.removeStore()
                return
            }
            dataStore.useFriends(friends)
            self.dataStore = dataStore
        }
    }
    
    func testFriendsNoEntries() {
        let env = FriendTestEnvironment()
        
        XCTAssertEqual(env.dataStore.friendsToLoad(quickRefresh : true, checkDate : env.present.nextDay()), env.friendNames)
        XCTAssertEqual(env.dataStore.friendsToLoad(quickRefresh : false, checkDate : env.present.nextDay()), env.friendNames)
    }
    
    func testFriendsOldDate() {
        let env = FriendTestEnvironment()
        let entryDate = NSDate.distantPast() as NSDate
        let entries = [
            Entry(title : "Foo bar", author : "cummings", date : entryDate, tags : [])
        ]
        
        let date = env.present
        env.dataStore.addEntries(entries, fromFriends: env.friendNames, requestDate: env.present)
        
        XCTAssertEqual(env.dataStore.friendsToLoad(quickRefresh : true, checkDate : date.nextDay()), ["eliot"])
        XCTAssertEqual(env.dataStore.friendsToLoad(quickRefresh : false, checkDate : date.nextDay()), env.friendNames)
    }
    
    func testFriendsNewDate() {
        let env = FriendTestEnvironment()
        let entryDate = env.present.previousDay()
        let entries = [
            Entry(title : "Foo bar", author : "cummings", date : entryDate, tags : [])
        ]
        
        let date = env.present
        env.dataStore.addEntries(entries, fromFriends: env.friendNames, requestDate: env.present)
        
        XCTAssertEqual(env.dataStore.friendsToLoad(quickRefresh : true, checkDate : date.nextDay()), env.friendNames)
        XCTAssertEqual(env.dataStore.friendsToLoad(quickRefresh : false, checkDate : date.nextDay()), env.friendNames)
    }
    
    func testFriendsRoundTrip() {
        let env = FriendTestEnvironment()
        env.dataStore.useFriends(env.friends)
        let expectation = expectationWithDescription("will load friends")
        env.dataStore.loadFriends {
            XCTAssertEqual(env.friends, $0)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
