//
//  DataSourceVendor.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

class DataSourceVendor: NSObject {
    
    struct Environment {
        let dataStore : UserDataStore
        let ljservice : LJService
        let networkService : AuthenticatedNetworkService
    }
    
    let feedSource : FeedDataSource
    let friendsSource : FriendsDataSource
    
    private let environment : Environment
    
    init(environment : Environment) {
        self.environment = environment
        self.friendsSource = FriendsDataSource(
            environment : FriendsDataSource.Environment(
                dataStore: environment.dataStore,
                networkService: environment.networkService,
                ljservice: environment.ljservice
            )
        )
        self.feedSource = FeedDataSource(environment: FeedDataSource.Environment(friendsSource: self.friendsSource, dataStore: self.environment.dataStore))
    }
    
}
