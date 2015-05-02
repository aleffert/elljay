//
//  LoadFriendFeedOperation.swift
//  elljay
//
//  Created by Akiva Leffert on 2/16/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

class LoadFriendFeedOperation: NSOperation {
    
    struct Environment {
        let dataStore : UserDataStore
        let ljservice : LJService
        let networkService : AuthenticatedNetworkService
    }
    
    private let userID : UserID
    private let environment : Environment
    private let requestDate : NSDate
    
    private var networkTask : NetworkTask?
    private var _executing : Bool = false
    private var _finished : Bool = false
    
    override var executing:Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished:Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    init(friend : UserID, environment : Environment, requestDate : NSDate = NSDate()) {
        self.environment = environment
        self.userID = friend
        self.requestDate = requestDate
        super.init()
    }
    
    
    override func start() {
        self.executing = true
        let request = environment.ljservice.feed(self.userID)
        let userID = self.userID
        let requestDate = self.requestDate
        networkTask = environment.networkService.sendRequest(request) {[weak self] (result, response) -> Void in
            switch(result) {
            case let .Success(feed):
                dispatch_async(dispatch_get_main_queue()) {
                    self?.environment.dataStore.addEntries(feed.value.entries, fromFriends: [userID], requestDate: requestDate)
                    self?.executing = false
                    self?.finished = true
                }
            case .Failure(_):
                self?.executing = false
                self?.finished = true
            }
        }
    }
    
    override func cancel() {
        networkTask?.cancel()
        self.executing = false
        self.finished = true
    }
}
