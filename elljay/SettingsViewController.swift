//
//  SettingsViewController.swift
//  elljay
//
//  Created by Akiva Leffert on 10/19/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate : class {
    func signOut(#fromController: SettingsViewController)
}

struct SettingsViewControllerEnvironment {
    weak var delegate : SettingsViewControllerDelegate?
}

class SettingsViewController: UIViewController {
    
    let environment : SettingsViewControllerEnvironment
    
    init(environment : SettingsViewControllerEnvironment) {
        self.environment = environment
        super.init(nibName: "SettingsViewController", bundle: nil)
        self.title = "Settings"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Not designed to be loaded via archive")
        super.init(coder: aDecoder)
    }
    
    @IBAction func signOut(sender : AnyObject) {
        self.environment.delegate?.signOut(fromController: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutMargins = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)
    }
}
