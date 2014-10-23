//
//  SettingsViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/19/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var router : AppRouter?
    
    override init() {
        super.init(nibName: "SettingsViewController", bundle: nil)
        self.title = "Settings"
    }
    
    required init(coder aDecoder: NSCoder) {
        assert(false, "Not designed to be loaded via archive")
        super.init(coder: aDecoder)
    }
    
    @IBAction func signOut(sender : AnyObject) {
        self.router?.signOut()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutMargins = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)
    }
}
