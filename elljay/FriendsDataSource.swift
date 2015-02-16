//
//  FriendsDataSource.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class FriendsDataSource {
    
    enum LoadState {
        case Unloaded
        case Loading
        case Loaded
    }
    
    public struct Environment {
        let dataStore : UserDataStore
        let networkService : AuthenticatedNetworkService
        let ljservice : LJService
    }
    
    private let environment : Environment
    
    private var loadTask : NetworkTask?
    private var loadState = LoadState.Unloaded
    
    private let changeNotification = Notification<[User]>()
    
    init(environment : Environment) {
        self.environment = environment
    }
    
    var changeSignal : Stream<[User]> {
        return changeNotification
    }
    
    var friends : [User] {
        return changeNotification.lastValue ?? []
    }
    
    func load() {
        switch(loadState) {
        case .Unloaded:
            loadLocal()
        case .Loading:
            break
        case .Loaded:
            loadRemote()
        }
    }
    
    private func loadLocal() {
        loadState = .Loading
        self.environment.dataStore.loadFriends {[weak self] in
            self?.changeNotification.notifyObservers($0)
            self?.loadState = .Loaded
            self?.loadRemote()
        }
    }
    
    private func loadRemote() {
        if loadTask == nil {
            let friendRequest = environment.ljservice.getFriends()
            self.environment.networkService.send(request: friendRequest) {[weak self]
                (result, response) in
                if let friendsResponse = result.value {
                    self?.environment.dataStore.saveFriends(friendsResponse.friends)
                    self?.changeNotification.notifyObservers(friendsResponse.friends)
                    return
                }
            }
        }
    }
}
