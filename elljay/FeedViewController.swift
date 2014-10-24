//
//  FeedViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/23/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

typealias FeedViewControllerEnvironment = protocol<LJServiceOwner, AuthenticatedNetworkServiceOwner>

class FeedViewController : UIViewController {

    let environment : FeedViewControllerEnvironment!

    init(environment : FeedViewControllerEnvironment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        assert(false, "Not designed to be loaded via archive")
        self.environment = RuntimeEnvironment()
        super.init(coder: aDecoder)
    }
    
}