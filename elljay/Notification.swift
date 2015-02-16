//
//  Observer.swift
//  elljay
//
//  Created by Akiva Leffert on 2/7/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

public protocol Removable {
    func remove()
}

private class Observer<A> : Equatable, Removable {
    private weak var owner : Stream<A>?
    private var action : A -> ()
    
    init(action : A -> (), observer : Stream<A>) {
        self.action = action
        self.owner = observer
    }
    
    func remove() {
        owner?.removeObserver(self)
    }
}

private func ==<A>(lhs: Observer<A>, rhs: Observer<A>) -> Bool {
    return lhs === rhs
}


// This really wants to be a protocol, but swift doesn't support protocols with type
// parameters. If it ever does, change this
public class Stream<A> {
    
    /// not mean to be instantiated, since it has no way to notify listeners
    private init() {}
    
    private var observers : [Observer<A>] = []
    
    public func addObserver(owner : AnyObject?, action : A -> ()) -> Removable {
        let listener = Observer(action : action, observer: self)
        observers.append(listener)
        if let o : AnyObject = owner {
            o.performActionOnDealloc({
                listener.remove()
            })
        }
        return listener
    }
    
    public func addObserver(action : A -> ())  -> Removable {
        return addObserver(nil, action : action)
    }
    
    private func removeObserver(observer : Observer<A>) {
        find(observers, observer).bind {
            self.observers.removeAtIndex($0)
        }
    }
}

/// A notification is a Stream that can actually change
/// The idea is to make it easy to expose a read only Observable
/// just by upcasting
public class Notification<A> : Stream<A> {
    public private(set) var lastValue : A? = nil
    
    override public init() {
    }
    
    public func notifyObservers(a : A) {
        lastValue = a
        for observer in observers {
            observer.action(a)
        }
    }
}
