//
//  FriendsDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

struct FriendChangeRecord {
    
}

class FriendsDataSource: NSObject {
    let changeObserver = Notification<FriendChangeRecord>()
}
