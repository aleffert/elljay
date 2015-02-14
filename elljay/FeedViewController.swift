//
//  FeedViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit


class FeedViewController : UIViewController {
    
    struct Environment {
        let dataVendor : DataSourceVendor
        let ljservice : LJService
        let networkService : AuthenticatedNetworkService
    }
    
    let environment : FeedViewController.Environment

    init(environment : FeedViewController.Environment) {
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