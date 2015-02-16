//
//  FeedDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class FeedDataSource: NSObject {
    public struct Environment {
        public let friendsSource : FriendsDataSource
        public let dataStore : UserDataStore
    }
    
    private let environment : Environment
    
    public init(environment : Environment) {
        self.environment = environment
    }
    
    public func load() {
        self.environment.friendsSource.changeSignal.addObserver(self) {friends in
            let friendsToLoad = self.environment.dataStore.friendsToLoad(friends, quickRefresh: true, checkDate: NSDate())
            println("friendsToLoad: \(friendsToLoad)")
        }
        self.environment.friendsSource.load()
    }
}
