//
//  SDSecuryManager.h
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#define keyEncrypt  @"anyKey"

@interface SDSecuryManager : NSObject


+ (id) sharedInstance;

- (NSString *) aesEncryptWithString:(NSString *) textString;
- (NSString *) aesDescryptWithString:(NSString *) textString;
- (NSData *) AES128EncryptWithKey:(NSString *) key andData:(NSData *) data;
- (NSData *) AES128DescryptWithKey:(NSString *) key andData:(NSData *) data;
- (NSString *) hexEncode:(NSData *) data;
- (NSData *) decodeHexString:(NSString *) hexString;

@end
