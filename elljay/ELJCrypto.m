//
//  ELJCrypto.m
//  elljay
//
//  Created by Akiva Leffert on 8/29/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import "ELJCrypto.h"


@implementation ELJCrypto

+ (NSString*)md5OfString:(NSString *)string {
    // shamelessly cribbed from the internet
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
