//
//  User.swift
//  elljay
//
//  Created by Akiva Leffert on 2/13/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

public class User : NSObject, NSCoding {
    public let userID : UserID
    public let name : String?
    
    public init(userID : UserID, name : String?) {
        self.userID = userID
        self.name = name
        super.init()
    }
    
    public required init(coder aDecoder: NSCoder) {
        userID = aDecoder.decodeObjectForKey("user") as UserID
        name = aDecoder.decodeObjectForKey("name") as? String
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userID, forKey: "user")
        aCoder.encodeObject(name, forKey: "name")
    }
    
    public var displayName : String {
        return name ?? userID
    }
    
    public func hash() -> NSInteger {
        return self.userID.hash
    }
}


extension User : Equatable {}

public func ==(lhs : User, rhs : User) -> Bool {
    // ignore name. people can change their real names, but not user ids
    return lhs.userID == rhs.userID
}

