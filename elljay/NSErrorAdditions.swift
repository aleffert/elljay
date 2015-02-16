//
//  NSErrorAdditions.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

extension NSError {

    func isNoConnectionError() -> Bool {
        return self.domain == NSURLErrorDomain && self.code == NSURLErrorNotConnectedToInternet
    }
    
    func isFileNotFoundError() -> Bool {
        return self.domain == NSCocoaErrorDomain && self.code == NSFileReadNoSuchFileError
    }
   
}
