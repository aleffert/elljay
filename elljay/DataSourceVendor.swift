//
//  DataSourceVendor.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

class DataSourceVendor: NSObject {
    let feedSource : FeedDataSource
    let friendsSource : FriendsDataSource
    
    let dataStore : DataStore
    let networkService : AuthenticatedNetworkService
    
    init(networkService : AuthenticatedNetworkService, dataStore : DataStore) {
        self.dataStore = dataStore
        self.networkService = networkService
        self.friendsSource = FriendsDataSource()
        self.feedSource = FeedDataSource(friendsSource : self.friendsSource)
    }
    
}
