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
        let feedDataSource : FeedDataSource
    }
    
    let environment : FeedViewController.Environment

    init(environment : FeedViewController.Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
        self.title = "Friends"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Not designed to be loaded via archive")
    }
    
    override func viewWillAppear(animated: Bool) {
        environment.feedDataSource.refresh()
    }
}