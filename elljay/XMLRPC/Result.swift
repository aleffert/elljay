//
//  File.swift
//  elljay
//
//  Created by Akiva Leffert on 10/22/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

// ideally this would all be an enum but swift doesn't support enums with generic parameters
public class Result<A> {
    func cata<B>(success : A -> B, _ failure : NSError -> B) -> B {
        assert(false)
    }
    
    func bind<B>(f : A -> Result<B>) -> Result<B> {
        assert(false)
    }
    
    func ifSuccess(f : A -> Void) {
        // do nothing
    }
    
    func ifError(f : NSError -> Void) {
        // do nothing
    }
}

public final class Success<A> : Result<A> {
    
    private let data : A
    init(_ data : A) {
        self.data = data
    }
    
    override func cata<B>(success : A -> B, _ failure : NSError -> B) -> B {
        return success(data)
    }
    
    override func bind<B> (f : A -> Result<B>) -> Result<B> {
        return f(data)
    }
    
    override func ifSuccess(f : A -> Void) {
        f(data)
    }
}

public final class Failure<A> : Result<A> {
    private let error : NSError
    init(_ error : NSError) {
        self.error = error
    }
    
    override func cata<B>(success : A -> B, _ failure : NSError -> B) -> B {
        return failure(error)
    }
    
    override func bind<B> (f : A -> Result<B>) -> Result<B> {
        return Failure<B>(error)
    }
    
    override func ifError(f : NSError -> Void) {
        f(error)
    }
}

struct Request<A> {
    let urlRequest : (sessionInfo : AuthSessionInfo, challenge : String) -> NSURLRequest
    let parser : NSData -> Result<A>
    
}
