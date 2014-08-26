//
//  NSObject+ELJDeallocActions.h
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ELJDeallocActions)

- (void)performActionOnDealloc:(void(^)(void))action;

@end

