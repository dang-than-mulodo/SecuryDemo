//
//  SDKeychainWrapper.m
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//




#import "SDKeychainWrapper.h"
#import "NSString+md5.h"

@interface SDKeychainWrapper (private)
- (NSMutableDictionary *) setupSearchDirectoryForIdentifier:(NSString *) identifier;
@end

@implementation SDKeychainWrapper


// *** NOTE *** This class is ARC compliant - any references to CF classes must be paired with a "__bridge" statement to
// cast between Objective-C and Core Foundation Classes.  WWDC 2011 Video "Introduction to Automatic Reference Counting" explains this.
// *** END NOTE ***

+ (id) sharedInstance {
    static SDKeychainWrapper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SDKeychainWrapper alloc] init];
    });
    return instance;
}

//private method
- (NSMutableDictionary *) setupSearchDirectoryForIdentifier:(NSString *) identifier {
    //set up dictionary to access keychain
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    // Specify we are using a password (rather than a certificate, internet password, etc).
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Uniquely identify this keychain accessor.
    [searchDictionary setObject:APP_NAME forKey:(__bridge id)kSecAttrService];
    
    //Uniquely identify the account who will be accessing the keychain
    NSData *encodeIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodeIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodeIdentifier forKey:(__bridge id)kSecAttrAccount];
    
    return searchDictionary;
}


- (NSData *) searchKeychainCopyMatchingIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    
    //limit search result to one
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    //specify we want NSData/CFData returned
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    //search
    NSData *result = nil;
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    if (status == noErr)
        return (__bridge_transfer NSData *)foundDict;
    else
        result = nil;
    
    return result;
}

- (NSString *) keychainStringFromMatchingIdentifier:(NSString *)identifier {
    NSData *valueData = [self searchKeychainCopyMatchingIdentifier:identifier];
    if (valueData) {
        NSString *value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
        return value;
    }
    return nil;
}

- (BOOL) createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:valueData forKey:(__bridge id)kSecValueData];
    
    //Protect the keychain entry so it's only valid when the device is unlocked
    [searchDictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    //add
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
    if (status == errSecSuccess)
        return YES;
    else if (status == errSecDuplicateItem)
        return [self updateKeychainValue:value forIdentifier:identifier];
    else
        return NO;
}

- (BOOL) updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:valueData forKey:(__bridge id)kSecValueData];
    
    //update
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);
    if (status ==errSecSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL) compareKeychainValueForMatchingPIN:(NSUInteger)pinHash {
    return [[self keychainStringFromMatchingIdentifier:PIN_SAVED] isEqualToString:[self securedSHA256DigestHashForPIN:pinHash]];
}






- (void) deleteItemFromKeychainWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    CFDictionaryRef dictionary = (__bridge CFDictionaryRef)searchDictionary;
    
    SecItemDelete(dictionary);
}

//We can replace this algorithm for EAS256


// This is where most of the magic happens (the rest of it happens in computeSHA256DigestForString: method below).
// Here we are passing in the hash of the PIN that the user entered so that we can avoid manually handling the PIN itself.
// Then we are extracting the username that the user supplied during setup, so that we can add another unique element to the hash.
// From there, we mash the user name, the passed-in PIN hash, and the secret key (from ChristmasConstants.h) together to create
// one long, unique string.
// Then we send that entire hash mashup into the SHA256 method below to create a "Digital Digest," which is considered
// a one-way encryption algorithm. "One-way" means that it can never be reverse-engineered, only brute-force attacked.
// The algorthim we are using is Hash = SHA256(Name + Salt + (Hash(PIN))). This is called "Digest Authentication."

- (NSString *) securedSHA256DigestHashForPIN:(NSUInteger)pinHash {
    // 1
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 2
    NSString *computedHashString = [NSString stringWithFormat:@"%@%i%@", name, pinHash, SALT_HASH];
    // 3
    NSString *finalHash = [self computedSHA256DigestForString:computedHashString];
    NSLog(@"** Computed hash: %@ for SHA256 Digest: %@", computedHashString, finalHash);
    return finalHash;
}

//Like AES encrypt
- (NSString *) computedSHA256DigestForString:(NSString *)input {
    const char *cStr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cStr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    //This is a iOS5 specific method
    //It takes in the data, how much data and then output format with in this case is a init array
    CC_SHA256(data.bytes, data.length, digest);
    
    // Setup our Objective-C output.
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}




@end
