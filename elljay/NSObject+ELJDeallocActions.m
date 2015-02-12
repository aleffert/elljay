//
//  NSObject+ELJDeallocActions.m
//  elljay
//
//  Created by Akiva Leffert on 8/14/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "NSObject+ELJDeallocActions.h"

#import <objc/runtime.h>

@interface ELJDeallocActionRunner : NSObject <ELJDeallocAction>

@property (copy, nonatomic) void (^action)(void);
@property (copy, nonatomic) void (^removeAction)(id);

@end

@implementation ELJDeallocActionRunner

- (void)dealloc {
    if(self.action) {
        self.action();
    }
}

- (void)remove {
    self.removeAction(self);
}

@end

@implementation NSObject (ELJDeallocActions)

- (id <ELJDeallocAction>)performActionOnDealloc:(void(^)(void))action {
    ELJDeallocActionRunner* runner = [[ELJDeallocActionRunner alloc] init];
    runner.action = action;
    __weak __typeof(self) weakself = self;
    runner.removeAction = ^(id sender){
        objc_setAssociatedObject(weakself, (__bridge void*)sender, nil, OBJC_ASSOCIATION_RETAIN);
    };
    objc_setAssociatedObject(self, (__bridge void*)runner, runner, OBJC_ASSOCIATION_RETAIN);
    return runner;
}

@end
