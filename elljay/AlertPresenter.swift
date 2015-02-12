//
//  AlertPresenter.swift
//  elljay
//
//  Created by Akiva Leffert on 2/11/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public protocol AlertPresenting {
    func presentAlertController(controller : UIAlertController, fromController : UIViewController)
}

struct AlertPresenter : AlertPresenting {
    func presentAlertController(controller: UIAlertController, fromController: UIViewController) {
        fromController.showViewController(controller, sender: nil)
    }
}
