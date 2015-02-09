//
//  Observer.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public class Observer<A> : Equatable{
    private weak var observer : Notification<A>?
    private var action : A -> ()
    
    init(action : A -> (), observer : Notification<A>) {
        self.action = action
        self.observer = observer
    }
    
    public func remove() {
        observer?.removeListener(self)
    }
}

public func ==<A>(lhs: Observer<A>, rhs: Observer<A>) -> Bool {
    return lhs === rhs
}

public class Notification<A> {
    
    private var observers : [Observer<A>] = []
    
    public func addObserver(a : A -> ()) -> Observer<A> {
        let listener = Observer(action : a, observer: self)
        observers.append(listener)
        return listener
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
