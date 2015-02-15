//
//  UserDataStore.swift
//  elljay
//
//  Created by Akiva Leffert on 9/8/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

public struct FeedUpdateInfo {
    let username : UserID
    let lastLoad : NSDate?
    let lastEntry : NSDate?
}


public class UserDataStore : NSObject {
    
    private let processingQueue = dispatch_queue_create("com.akivaleffert.elljay.DataStore", DISPATCH_QUEUE_SERIAL)
    
    private var friends : [User] = []
    private var entries : [Entry] = []
    
    private let userID : UserID
    
    private var lastLoadDates : [String:NSDate] = [:]
    private var lastEntryDates : [String:NSDate] = [:]
    
    public init(userID : UserID) {
        self.userID = userID
    }
    
    public func loadFriends(completion : [User] -> Void) -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            completion(self.friends)
        }
    }
    
    public func useFriends(friends : [User]) {
        self.friends = friends
    }
    
    
    public func addEntries(entries : [Entry], fromFriends : [UserID], requestDate : NSDate) {
        self.entries.extend(entries)
        for entry in entries {
            if let lastEntry = lastEntryDates[entry.author] {
                lastEntryDates[entry.author] = max(lastEntry, entry.date)
            }
            else {
                lastEntryDates[entry.author] = entry.date
            }
            
            if let lastLoad = lastLoadDates[entry.author] {
                lastLoadDates[entry.author] = max(lastLoad, requestDate)
            }
            else {
                lastLoadDates[entry.author] = requestDate
            }
        }
    }
    
    private func friendsToLoad(items : [FeedUpdateInfo], quickRefresh : Bool, checkDate : NSDate) -> [UserID] {
        return items.concatMap { item in
            let shouldLoad = { Void -> Bool in
                switch (item.lastLoad, item.lastEntry) {
                case (nil, nil):
                    return true
                case let (nil, lastEntry):
                    return true
                case let (lastLoad, nil):
                    return lastLoad < checkDate.previousDay()
                case let (lastLoad, lastEntry):
                    if quickRefresh {
                        return lastEntry > checkDate.previousMonth()
                    }
                    else {
                        return true
                    }
                }
            }()
                
            return shouldLoad ? [item.username] : []
        }
    }
    
    public func friendsToLoad(#quickRefresh : Bool, checkDate : NSDate = NSDate()) -> [UserID] {
        let infos = friends.map { friend -> FeedUpdateInfo in
            let username = friend.user
            return FeedUpdateInfo(
                username: username,
                lastLoad: self.lastLoadDates[username],
                lastEntry: self.lastEntryDates[username]
            )
        }
        
        return friendsToLoad(infos, quickRefresh: quickRefresh, checkDate : checkDate)
    }
    
    public func removeStore() {
        
    }
    
}