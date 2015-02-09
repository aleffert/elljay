//
//  FeedViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

struct FeedViewControllerEnvironment {
    let ljservice : LJService
    let networkService : AuthenticatedNetworkService
    let dataVendor : DataSourceVendor
}

class FeedViewController : UIViewController {
    let environment : FeedViewControllerEnvironment

    init(environment : FeedViewControllerEnvironment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
        self.title = "Friends"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Not designed to be loaded via archive")
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        let feedRequest = self.environment.ljservice.feed("aleffert")
        self.environment.networkService.send(request: feedRequest, completionHandler: {(result, response) in
            result.cata ({r in
                println("result is \(r.entries)")
            }, {error in
                println("error is \(error)")
            })
        })
    }
}