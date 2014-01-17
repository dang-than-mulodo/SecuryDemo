//
//  SDConstants.h
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#ifndef SecuryDemo_SDConstants_h
#define SecuryDemo_SDConstants_h

// Used for saving to NSUserDefaults that a PIN has been set, and is the unique identifier for the Keychain.
#define PIN_SAVED @"hasSavedPIN"

// Used for saving the user's name to NSUserDefaults.
#define USERNAME @"username"

// Used to help secure the PIN.
// Ideally, this is randomly generated, but to avoid the unnecessary complexity and overhead of storing the Salt separately, we will standardize on this key.
// !!KEEP IT A SECRET!!
#define SALT_HASH @"FvTivqTqZXsgLLx1v3P8TGRyVHaSOB1pvfm02wvGadj7RLHV8GrfxaZ84oGA8RsKdNRpxdAojXYg9iAj"
// Used to specify the application used in accessing the Keychain.
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define kSecuryManager [SDSecuryManaged sharedInstance]
#define kKeychainWrapper [SDKeychainWrapper sharedInstance]

#define kTextKey    @"text"
#define kImageKey   @"imageName"
#define kSecuryKey  @"secury"


typedef enum {
    kAlertTypePIN = 0,
    kAlertTypeSetup
}AlertType;

typedef enum {
    kTextFieldPIN = 0,
    kTextFieldName = 1,
    kTextFieldPassword
}TextFieldType;

#endif
