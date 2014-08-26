//
//  NSObject+ELJDeallocActions.m
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "NSObject+ELJDeallocActions.h"

#import <objc/runtime.h>

@interface ELJDeallocActionRunner : NSObject

@property (copy, nonatomic) void (^action)(void);

@end

@implementation ELJDeallocActionRunner

- (void)dealloc {
    if(self.action) {
        self.action();
    }
}

@end

@implementation NSObject (ELJDeallocActions)

- (void)performActionOnDealloc:(void(^)(void))action {
    ELJDeallocActionRunner* runner = [[ELJDeallocActionRunner alloc] init];
    runner.action = action;
    @synchronized(self) {
        objc_setAssociatedObject(runner, (__bridge void*)runner, runner, OBJC_ASSOCIATION_RETAIN);
    }
}

@end
