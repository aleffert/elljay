//
//  NSNotificationCenterAdditions.swift
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

extension NSNotificationCenter {
    func addObserver(observer : AnyObject, name : String, object: AnyObject?, action : (NSNotification!) -> Void) {
        let listener = self.addObserverForName(name, object: object, queue: NSOperationQueue.currentQueue(), usingBlock: {
            [weak observer] notification in
                action(notification)
            })
        observer.performActionOnDealloc {_ in
            self.removeObserver(listener);
        }
    }
    
    func addAnimatedKeyboardObserver(observer : AnyObject, view : UIView?, action : (UIView?, CGFloat) -> Void) {
        self.addObserver(observer, name: UIKeyboardWillChangeFrameNotification, object: nil, action: {
            [weak view] notification in
            let globalFrame : CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let localFrame = view?.convertRect(globalFrame, fromView: view)
            
            let intersection = CGRectIntersection(localFrame!, view!.bounds);
            let keyboardHeight = intersection.size.height;
            let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
            UIView.animateWithDuration(duration, delay: Double(0), options: UIViewAnimationOptions(), animations: {
                action(view, keyboardHeight)
                }, completion: nil)

            })
    }
}