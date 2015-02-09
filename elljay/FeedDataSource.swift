//
//  FeedDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

class FeedDataSource: NSObject {
    
    let friendsSource : FriendsDataSource
    
    init(friendsSource : FriendsDataSource) {
        self.friendsSource = friendsSource
    }
}
