//
//  File.swift
//  elljay
//
//  Created by Akiva Leffert on 10/22/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

public class Box <A> {
    public let value : A
    init(_ value : A) {
        self.value = value
    }
}

public func Success<A>(a : A) -> Result<A> {
    return .Success(Box(a))
}

public func Failure<A>(error : NSError) -> Result<A> {
    return .Failure(error)
}

public enum Result<A> {
    case Success(Box<A>)
    case Failure(NSError)
    
    public func map<B>(f : A -> B) -> Result<B> {
        switch(self) {
        case let .Success(box): return .Success(Box(f(box.value)))
        case let .Failure(error): return .Failure(error)
        }
    }
    
    public func bind<B>(f : A -> Result<B>) -> Result<B> {
        switch(self) {
        case let .Success(box): return f(box.value)
        case let .Failure(error): return .Failure(error)
        }
    }
    
    public var value : A? {
        switch(self) {
        case let .Success(box): return box.value
        case .Failure(_): return nil
        }
    }
    
    public var error : NSError? {
        switch(self) {
        case .Success(_): return nil
        case let .Failure(error): return error
        }
    }
    
    public var isSuccess : Bool {
        return self.value != nil
    }
    
    public var isFailure : Bool {
        return self.error != nil
    }
}
//
//public class Result<A> {
//    public func cata<B>(success : A -> B, _ failure : NSError -> B) -> B {
//        fatalError("This method must be overridden")
//    }
//    
//    public func bind<B>(f : A -> Result<B>) -> Result<B> {
//        fatalError("This method must be overridden")
//    }
//    
//    public func map<B>(f : A -> B) -> Result<B> {
//        fatalError("This method must be overridden")
//    }
//    
//    public func ifSuccess(f : A -> Void) {
//        // do nothing
//    }
//    
//    public func ifError(f : NSError -> Void) {
//        // do nothing
//    }
//    
//    public func toOption() -> A? {
//        fatalError("This method must be overridden")
//    }
//    
//    public func isSuccess() -> Bool {
//        fatalError("This method must be overriden")
//    }
//    
//    public func isFailure() -> Bool {
//        fatalError("This method must be overriden")
//    }
//    
//}
//
//public final class Success<A> : Result<A> {
//    
//    private let data : A
//    public init(_ data : A) {
//        self.data = data
//    }
//    
//    public override func cata<B>(success : A -> B, _ failure : NSError -> B) -> B {
//        return success(data)
//    }
//    
//    public override func bind<B> (f : A -> Result<B>) -> Result<B> {
//        return f(data)
//    }
//    
//    public override func map<B> (f : A -> B) -> Result<B> {
//        return Success<B>(f(data))
//    }
//    
//    public override func ifSuccess(f : A -> Void) {
//        f(data)
//    }
//    
//    public override func toOption() -> A? {
//        return data
//    }
//    
//    public override func isSuccess() -> Bool {
//        return true
//    }
//}
//
//public final class Failure<A> : Result<A> {
//    private let error : NSError
//    public init(_ error : NSError) {
//        self.error = error
//    }
//    
//    public override func cata<B>(success : A -> B, _ failure : NSError -> B) -> B {
//        return failure(error)
//    }
//    
//    public override func bind<B> (f : A -> Result<B>) -> Result<B> {
//        return Failure<B>(error)
//    }
//    
//    public override func map<B> (f : A -> B) -> Result<B> {
//        return Failure<B>(error)
//    }
//    
//    public override func ifError(f : NSError -> Void) {
//        f(error)
//    }
//    
//    public override func toOption() -> A? {
//        return nil
//    }
//    
//    public override func isFailure() -> Bool {
//        return true
//    }
//
//}
//
