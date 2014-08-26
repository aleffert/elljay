//
//  Service.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

class Service {
    let urlSession = NSURLSession(configuration: nil, delegate: nil, delegateQueue: nil)
    
    private func freshRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.HTTPMethod = "POST";
        return request;
    }
    
    func loginWithUsername(username : String, password : String) {
        
    }
   
}
