//
//  FeedDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class FeedChangedInfo {
    
}

public class FeedDataSource: NSObject {
    
    private let friendsSource : FriendsDataSource
    private let dataStore : DataStore
    
    public let changeNotification : Notification<FeedChangedInfo> = Notification()
    
    public init(friendsSource : FriendsDataSource, dataStore : DataStore) {
        self.friendsSource = friendsSource
        self.dataStore = dataStore;
    }
}
