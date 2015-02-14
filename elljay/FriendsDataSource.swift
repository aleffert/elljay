//
//  FriendsDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

struct FriendChangeRecord {
    let addedFriends : [Friend]
    let removedFriends : [Friend]
}

public class FriendsDataSource {
    public struct Environment {
        let dataStore : DataStore
        let networkService : AuthenticatedNetworkService
        let ljservice : LJService
    }
    
    let environment : Environment
    
    let changeNotification = Notification<Result<FriendChangeRecord>>()
    var activeRefreshTask : NetworkTask?
    
    init(environment : Environment) {
        self.environment = environment
    }
    
    func friends() -> [Friend] {
        return environment.dataStore.knownFriends()
    }
    
    func refresh() {
    }
}
