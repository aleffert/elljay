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
    
    func testDataStoreCleared() {
        let credentials = CredentialFactory.freshCredentials()
        let path = PathUtils.pathForUser(credentials.userID).path!
        let startExpectation = expectationWithDescription("Queue executes")
        let queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL)
        
        func make() {
            let dataStore = EphemeralUserDataStore(userID: credentials.userID)
            dataStore.t_enqueue {
                let pathExists = NSFileManager.defaultManager().fileExistsAtPath(path)
                XCTAssertTrue(pathExists)
                startExpectation.fulfill()
                
            }
        }
        let endExpectation = expectationWithDescription("Queue executes")
        
        make()
        
        dispatch_async(queue)  {
            while(NSFileManager.defaultManager().fileExistsAtPath(path)) {
                usleep(10)
            }
            endExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    class FriendTestEnvironment {
        let friends = [
            User(userID : "cummings", name : nil),
            User(userID : "eliot", name : nil)
        ]
        
        var friendNames : [UserID] {
            return friends.map {
                $0.userID
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
            let dataStore = EphemeralUserDataStore(userID : CredentialFactory.freshCredentials().userID)
            dataStore.saveFriends(friends)
            self.dataStore = dataStore
        }
    }
    
    func testFriendsNoEntries() {
        let env = FriendTestEnvironment()
        
        XCTAssertEqual(env.dataStore.friendsToLoad(env.friends, quickRefresh : true, checkDate : env.present.nextDay()), env.friendNames)
        XCTAssertEqual(env.dataStore.friendsToLoad(env.friends, quickRefresh : false, checkDate : env.present.nextDay()), env.friendNames)
    }
    
    func testFriendsOldDate() {
        let env = FriendTestEnvironment()
        let entryDate = NSDate.distantPast() as! NSDate
        let entries = [
            Entry(title : "Foo bar", author : "cummings", date : entryDate, tags : [])
        ]
        
        let date = env.present
        env.dataStore.addEntries(entries, fromFriends: env.friendNames, requestDate: env.present)
        
        XCTAssertEqual(env.dataStore.friendsToLoad(env.friends, quickRefresh : true, checkDate : date.nextDay()), ["eliot"])
        XCTAssertEqual(env.dataStore.friendsToLoad(env.friends, quickRefresh : false, checkDate : date.nextDay()), env.friendNames)
    }
    
    func testFriendsNewDate() {
        let env = FriendTestEnvironment()
        let entryDate = env.present.previousDay()
        let entries = [
            Entry(title : "Foo bar", author : "cummings", date : entryDate, tags : [])
        ]
        
        let date = env.present
        env.dataStore.addEntries(entries, fromFriends: env.friendNames, requestDate: env.present)
        
        XCTAssertEqual(env.dataStore.friendsToLoad(env.friends, quickRefresh : true, checkDate : date.nextDay()), env.friendNames)
        XCTAssertEqual(env.dataStore.friendsToLoad(env.friends, quickRefresh : false, checkDate : date.nextDay()), env.friendNames)
    }
    
    func testFriendsRoundTrip() {
        let env = FriendTestEnvironment()
        env.dataStore.saveFriends(env.friends)
        let expectation = expectationWithDescription("will load friends")
        env.dataStore.loadFriends {
            XCTAssertEqual(env.friends, $0)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFriendsPersist() {
        let userID = CredentialFactory.freshCredentials().userID
        let store = UserDataStore(userID: userID)
        let friends = [
            User(userID: "abc", name: "def"),
            User(userID: "ghi", name: "jlk"),
        ]
        store.saveFriends(friends)
        let saveExpectation = expectationWithDescription("friends saved")
        store.t_enqueue {
            saveExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
        
        let loadExpectation = expectationWithDescription("friends saved")
        let freshStore = EphemeralUserDataStore(userID: userID)
        store.loadFriends {loadedFriends in
            XCTAssertEqual(friends, loadedFriends)
            loadExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
