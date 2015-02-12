//
//  NSObject+ELJDeallocActions.h
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ELJDeallocAction <NSObject>

- (void)remove;

@end

@interface NSObject (ELJDeallocActions)

- (id <ELJDeallocAction>)performActionOnDealloc:(void(^)(void))action;

@end

