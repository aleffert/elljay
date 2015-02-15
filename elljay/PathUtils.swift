//
//  PathUtils.swift
//  elljay
//
//  Created by Akiva Leffert on 2/15/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class PathUtils {
    public class func documentsPath() -> NSURL! {
        let result = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        assert(result.count > 0)
        return result[0] as NSURL
    }
    
    public class func pathForUser(userID : UserID) -> NSURL {
        return documentsPath().URLByAppendingPathComponent(userID)
    }
   
}
