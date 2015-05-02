//
//  FeedDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class FeedDataSource : NSObject {
    public struct Environment {
        public let dataStore : UserDataStore
        public let friendsSource : FriendsDataSource
        public let ljservice : LJService
        public let networkService : AuthenticatedNetworkService
    }
    
    private let environment : Environment
    private let loadQueue = NSOperationQueue()
    
    public init(environment : Environment) {
        self.environment = environment
        super.init()
        self.environment.friendsSource.changeSignal.addObserver(self) {[weak self] friends in
            self?.friendsChanged(friends)
            return
        }
    }
    
    private func friendsChanged(friends : [User]) {
        if self.loadQueue.operationCount == 0 {
            let friendsToLoad = self.environment.dataStore.friendsToLoad(friends, quickRefresh: true, checkDate: NSDate())
            let env = LoadFriendFeedOperation.Environment(
                dataStore : environment.dataStore,
                ljservice : environment.ljservice,
                networkService : environment.networkService
                )
            let operations = friendsToLoad.map {friend in
                LoadFriendFeedOperation(friend: friend, environment: env)
            }
            let flushOperation = NSBlockOperation(block: {
                self.environment.dataStore.commit()
            })
            for operation in operations {
                flushOperation.addDependency(operation)
            }
            loadQueue.addOperations(operations, waitUntilFinished: false)
            loadQueue.addOperation(flushOperation)
        }
    }

    public func refresh() {
        self.environment.friendsSource.load()
    }
}
