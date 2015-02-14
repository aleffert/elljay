//
//  Friend.swift
//  elljay
//
//  Created by Akiva Leffert on 2/13/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

public struct Friend {
    public let user : Username
    public let name : String?
    
    public init(user : Username, name : String?) {
        self.user = user
        self.name = name
    }
    
    public var displayName : String {
        return name ?? user
    }
    
    public func hash() -> NSInteger {
        return self.user.hash
    }
}


extension Friend : Equatable {}

public func ==(lhs : Friend, rhs : Friend) -> Bool {
    // ignore name. people can change their real names, but not user names
    return lhs.user == rhs.user
}

