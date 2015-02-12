//
//  Observer.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class Observer<A> : Equatable {
    private weak var owner : Notification<A>?
    private var action : A -> ()
    
    init(action : A -> (), observer : Notification<A>) {
        self.action = action
        self.owner = observer
    }
    
    public func remove() {
        owner?.removeListener(self)
    }
}

public func ==<A>(lhs: Observer<A>, rhs: Observer<A>) -> Bool {
    return lhs === rhs
}

public class Notification<A> {
    
    public init() {
        
    }
    
    private var observers : [Observer<A>] = []
    
    public func addObserver(owner : AnyObject?, action : A -> ()) -> Observer<A> {
        let listener = Observer(action : action, observer: self)
        observers.append(listener)
        if let o : AnyObject = owner {
            o.performActionOnDealloc({ () -> Void in
                listener.remove()
            })
        }
        return listener
    }
    
    public func addObserver(action : A -> ())  -> Observer<A> {
        return addObserver(nil, action : action)
    }
    
    private func removeListener(listener : Observer<A>) {
        find(observers, listener).bind {
            self.observers.removeAtIndex($0)
        }
    }
    
    public func notifyListeners(a : A) {
        for observer in observers {
            observer.action(a)
        }
    }
}
