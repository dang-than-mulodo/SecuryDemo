//
//  NSString+md5.m
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

static const void *imageTagKey = &imageTagKey; //point to itself

@implementation NSString (md5)
@dynamic numeric;

- (NSString *) md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); //md5 call in
    
    return [NSString localizedStringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void) setTag:(NSString *)tag {
//    objc_setAssociatedObject(self, imageTagKey, tag, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, @selector(tag), tag, OBJC_ASSOCIATION_COPY_NONATOMIC); //using selector
}

- (NSString *) tag {
//    return objc_getAssociatedObject(self, imageTagKey);
    return objc_getAssociatedObject(self, @selector(tag)); //using selector
}

@end
