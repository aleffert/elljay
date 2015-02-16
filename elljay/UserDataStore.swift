//
//  UserDataStore.swift
//  elljay
//
//  Created by Akiva Leffert on 9/8/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

public class FriendFeedUpdateInfo : NSObject, NSCoding {
    let userID : UserID
    let lastLoad : NSDate?
    let lastEntry : NSDate?
    
    public init(userID : UserID, lastLoad : NSDate?, lastEntry : NSDate?) {
        self.userID = userID
        self.lastLoad = lastLoad
        self.lastEntry = lastEntry
        super.init()
    }
    
    public required init(coder aDecoder: NSCoder) {
        userID = aDecoder.decodeObjectForKey("userID") as UserID
        lastLoad = aDecoder.decodeObjectForKey("lastLoad") as NSDate?
        lastEntry = aDecoder.decodeObjectForKey("lastEntry") as NSDate?
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userID, forKey: "userID")
        aCoder.encodeObject(lastLoad, forKey: "lasLoad")
        aCoder.encodeObject(lastEntry, forKey: "lastEntry")
    }
    
}


public class UserDataStore : NSObject {
    
    private let processingQueue = dispatch_queue_create("com.akivaleffert.elljay.DataStore", DISPATCH_QUEUE_SERIAL)
    
    private var entries : [Entry] = []
    
    private let userID : UserID
    
    private var updateInfos : [String:FriendFeedUpdateInfo] = [:]
    
    public init(userID : UserID) {
        self.userID = userID
        super.init()
        enqueue {
            let path = PathUtils.pathForUser(self.userID)
            var error : NSError?
            NSFileManager.defaultManager().createDirectoryAtURL(path, withIntermediateDirectories: true, attributes: nil, error: &error)
            assert(error == nil)
        }
    }
    
    private func enqueue (f : () -> ()) {
        dispatch_async(processingQueue, f)
    }
    
    private var friendListPath : NSURL {
        let basePath = PathUtils.pathForUser(self.userID)
        return basePath.URLByAppendingPathComponent("friends.plist")
    }
    
    private var updateInfoPath : NSURL {
        let basePath = PathUtils.pathForUser(self.userID)
        return basePath.URLByAppendingPathComponent("update-info.plist")
    }
    
    private func loadFileAtPath<A>(path : NSURL) -> A? {
        let path = self.friendListPath
        var error : NSError?
        let data = NSData(contentsOfURL: path, options: NSDataReadingOptions(), error: &error)
        assert(error == nil || error!.isFileNotFoundError())
        
        if let d = data {
            let object = NSKeyedUnarchiver.unarchiveObjectWithData(d) as NSArray
            return object as? A
        }
        else {
            return nil
        }
    
    }
    
    private func saveObject(object : NSCoding, path : NSURL) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        var error : NSError?
        data.writeToURL(path, options: NSDataWritingOptions.DataWritingAtomic, error: &error)
        assert(error == nil)
    }
    
    public func loadFriends(completion : [User] -> Void) -> Void {
        enqueue {
            let friends = self.loadFileAtPath(self.friendListPath) ?? []
            let updateInfos : [String:FriendFeedUpdateInfo] = self.loadFileAtPath(self.updateInfoPath) ?? [:]
            dispatch_async(dispatch_get_main_queue()) {
                self.updateInfos = updateInfos
                completion(friends as [User])
            }
        }
    }
    
    public func saveFriends(friends : [User]) {
        enqueue {
            self.saveObject(friends as NSArray, path : self.friendListPath)
        }
    }
    
    
    public func addEntries(entries : [Entry], fromFriends : [UserID], requestDate : NSDate) {
        
        self.entries.extend(entries)
        for entry in entries {
            let info = updateInfos[entry.author]
            let update = FriendFeedUpdateInfo(
                userID: entry.author,
                lastLoad: max(info?.lastLoad ?? requestDate, requestDate),
                lastEntry: max(info?.lastEntry ?? entry.date, entry.date)
            )
            assert(info == nil || entry.author == info!.userID)
            updateInfos[entry.author] = update
        }
        
        let infos = self.updateInfos
    
        enqueue {
            self.saveObject(infos as NSDictionary, path: self.updateInfoPath)
        }
    }
    
    private func friendsToLoad(items : [FriendFeedUpdateInfo], quickRefresh : Bool, checkDate : NSDate) -> [UserID] {
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
                
            return shouldLoad ? [item.userID] : []
        }
    }
    
    public func friendsToLoad(friends : [User], quickRefresh : Bool, checkDate : NSDate = NSDate()) -> [UserID] {
        let infos = friends.map { friend -> FriendFeedUpdateInfo in
            let existing = self.updateInfos[friend.userID]
            return FriendFeedUpdateInfo(
                userID: friend.userID,
                lastLoad: existing?.lastLoad,
                lastEntry: existing?.lastEntry
            )
        }
        
        return friendsToLoad(infos, quickRefresh: quickRefresh, checkDate : checkDate)
    }
    
    public func clear() {
        // This may get called from deinit (see EphemeralDataStore),
        // so explicitly copy object state, which may otherwise get cleared
        let userID = self.userID
        enqueue {
            let path = PathUtils.pathForUser(userID)
            var error : NSError?
            NSFileManager.defaultManager().removeItemAtURL(path, error: &error)
            assert(error == nil)
        }
    }
    
    public func t_enqueue(f : () -> ()) {
        enqueue(f)
    }
    
}
