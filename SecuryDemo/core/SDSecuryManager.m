//
//  SDSecuryManager.m
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

/*
 
 That object using AES2 encrypt and accociate with some method to make harder data
 1. Convert data string to MD5
 2. Encrypted data with AES256 with MD5 key and Data (has been encode)
 Remember to using initialization vertor and the odd of key
 3. Convert data encrypted to hex
 
 */

#import "SDSecuryManager.h"
#import "NSString+md5.h"

@implementation SDSecuryManager

+ (id) sharedInstance {
    static SDSecuryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SDSecuryManager alloc] init];
    });
    return instance;
}

//Encrypt
- (NSString *) aesEncryptWithString:(NSString *)textString {
    NSData *d = [textString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *t = [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding];
    NSMutableString *s = [[NSMutableString alloc] initWithString:textString];
    
    if (t.length % 16 != 0) {
        int nMod = 16 - t.length % 16;
        while (nMod > 0) {
            [s appendString:@"\0"];
            nMod--;
        }
    }
    
    //convert it to data object
    NSData *data = [[NSData alloc] initWithData:[s dataUsingEncoding:NSUTF8StringEncoding]];
    
    //get MD5 of key
    NSString *key = [keyEncrypt md5];
    
    //Starting ecnrypt
    NSData *ret = [self AES128EncryptWithKey:key andData:data];
    
    //Convert it to hex
    NSString *result = [self hexEncode:ret];
    
    return result;
}

//Descrypt
- (NSString *)aesDescryptWithString:(NSString *)textString {
    NSData *ret = [self decodeHexString:textString];
    NSData *ret2 = [self AES128DescryptWithKey:[keyEncrypt md5] andData:ret];
    
    NSString *st2 = [[NSString alloc] initWithData:ret2 encoding:NSUTF8StringEncoding];
    return st2;
}


//Main encrypt
- (NSData *) AES128EncryptWithKey:(NSString *)key andData:(NSData *)data {
    // key should be 32 bytes  for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; //room for terminator
    bzero(keyPtr, sizeof(keyPtr)); //fill with zeros for padding
    
    //fetch data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
    size_t buffSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(buffSize); //malloc a store area
    
    unsigned char iv[16]; //vector
    int j = 0;
    //travel all item of key length
    //travel to all odd of key. Please notice
    for (int i = 1; i < 32; i += 2) {
        iv[j] = [key characterAtIndex:i];
        j++;
    }
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0,
                                          keyPtr, kCCKeySizeAES256,
                                          iv, /*initialization vertor (optional)*/
                                          [data bytes], dataLength, /*input*/
                                          buffer, buffSize, /*output*/
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer); //free buffer
    
    return nil;
}

- (NSData *) AES128DescryptWithKey:(NSString *)key andData:(NSData *)data {
    //key should be 32 bytes for AES 256 will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    //fetch data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For bock cipher, the output size will be always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t buffSize = dataLength + kCCBlockSizeAES128;
    
    void *buffer = malloc(sizeof(buffSize));
    
    unsigned char iv[16];
    int j = 0;
    for (int i = 0; i < 32; i += 2) {
        iv[j] = [key characterAtIndex:i];
        j++;
    }
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0,
                                          keyPtr, sizeof(keyPtr),
                                          iv,
                                          [data bytes], dataLength,
                                          buffer, buffSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    
    return nil;
}

- (NSString *) hexEncode:(NSData *)data {
    static const char hexDigits[] = "0123456789abcdef";
    const size_t numBytes = [data length];
    const unsigned char *bytes = [data bytes];
    char *strBuff = (char *) malloc(numBytes * 2 + 1); //position is odd
    char *hex = strBuff;
    NSString *hexBytes = nil;
    
    for (int i = 0; i < numBytes; i++) {
        const unsigned char c = *bytes++;
        *hex++ = hexDigits[(c >> 4) & 0xF];
        *hex++ = hexDigits[c & 0xF];
    }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strBuff];
    free(strBuff);
    
    return hexBytes;
}

- (NSData *) decodeHexString:(NSString *)hexString {
    const char *bytes = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = strlen(bytes);
    
    unsigned char *r = (unsigned char *) malloc(length / 2 + 1); //khởi tạo vùng nhớ
    unsigned char *index = r;
    
    while ((*bytes) && (* (bytes + 1))) {
        char encoder[3] = {'\0','\0','\0'};
        encoder[0] = *bytes;
        encoder[1] = *(bytes + 1);
        *index = (char) strtol(encoder, NULL, 16);
        index++;
        bytes += 2;
    }
    *index = '\0';
    NSData *result = [NSData dataWithBytes:r length:length/2];
    free(r);
    
    return result;
}



- (NSString *) password {
    return nil;
}

@end
