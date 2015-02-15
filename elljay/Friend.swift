//
//  User.swift
//  elljay
//
//  Created by Akiva Leffert on 2/13/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

public struct User {
    public let user : UserID
    public let name : String?
    
    public init(user : UserID, name : String?) {
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


extension User : Equatable {}

public func ==(lhs : User, rhs : User) -> Bool {
    // ignore name. people can change their real names, but not user names
    return lhs.user == rhs.user
}

