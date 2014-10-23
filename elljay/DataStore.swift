//
//  DataStore.swift
//  elljay
//
//  Created by Akiva Leffert on 9/8/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

class DataStore {
    private(set) var syncItems : [LJService.SyncItem] = []
    private let processingQueue = dispatch_queue_create("com.akivaleffert.elljay.DataStore", DISPATCH_QUEUE_SERIAL)
    
    var friends : [LJService.Friend] = []
    
    func addedSyncItems(#items : [LJService.SyncItem]) {
        let initialItems = syncItems
        dispatch_async(processingQueue) { () -> Void in
            var resultItems = initialItems
            resultItems.extend(items)
            resultItems.sort({ (item, otherItem) -> Bool in
                item.time < otherItem.time
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.syncItems = resultItems
            }
        }
    }
    
    func lastSyncDate() -> NSDate?  {
        return syncItems.last.map { $0.time }
    }
    
    
}