//
//  XMLRPCService.swift
//  elljay
//
//  Created by Akiva Leffert on 9/1/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import CFNetwork
import UIKit

protocol NetworkTask {
    func cancel() -> ()
}

extension NSURLSessionDataTask : NetworkTask {
}



class XMLRPCService {
    // TODO change to a class variable once they're supported
    let errorDomain = "com.akivaleffert.elljay.NetworkService"

    let errorMalformedResponseDescription = "The response from the server was malformed"
    let errorMalformedResponseCode = -1

    private let session : NSURLSession
    
    convenience init() {
        let session = NSURLSession.sharedSession()
        self.init(session : session)
    }

    init(session : NSURLSession) {
        self.session = session
    }

    private func malformedResponseError() -> NSError {
        return NSError(domain : self.errorDomain, code : errorMalformedResponseCode, userInfo : [NSLocalizedDescriptionKey : errorMalformedResponseDescription])
    }

    func send<A>(#request : Request<A>, completionHandler : (A?, NSURLResponse!, NSError?) -> Void) -> NetworkTask {
        let result = session.dataTaskWithRequest(request.urlRequest) {(result : NSData!, response : NSURLResponse!, error : NSError?) in
            if let r = result {
                let params = XMLRPCResult.from(data: r)
                switch(params) {
                    case let .Fault(error):
                        completionHandler(nil, response, error)
                    case let .Response(params):
                        if countElements(params) > 0 {
                            let parsed = request.parser(params[0])
                            let error : NSError? = parsed == nil ? nil : self.malformedResponseError()
                            completionHandler(parsed, response, error)
                        }
                        else {
                            completionHandler(nil, response, error)
                        }
                    case let .ParseError(e):
                        let error = self.malformedResponseError()
                        completionHandler(nil, response, error)
                }
            }
            else {
                completionHandler(nil, response, error)
            }
        }

        result.resume()
        return result
    }
}

protocol XMLRPCServiceOwner {
    var networkService : XMLRPCService { get }
}