//
//  PathUtils.swift
//  elljay
//
//  Created by Akiva Leffert on 2/15/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

class PathUtils {
    class func documentsDirectory() -> NSURL {
        let result = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        assert(result.count > 0)
        return result[0] as NSURL
    }
    
    class func pathForUser(userID : UserID) -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent(userID)
    }
   
}
