//
//  SDViewController.m
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "SDViewController.h"
#import "SDKeychainWrapper.h"
#import "SDSecuryManager.h"

@interface SDViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@end

@implementation SDViewController
@synthesize hasValidated;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.hasValidated = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self generatePassword];
}

- (void) generatePassword {
    
    BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if (hasPin) {
        NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
        NSString *message = [NSString stringWithFormat:@"What's %@ password:", userName];
        
        UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Input"
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
        [alr setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        alr.tag = kAlertTypePIN;
        
        UITextField *txtPin = [alr textFieldAtIndex:0];
        txtPin.autocapitalizationType = UITextAutocapitalizationTypeWords;
        txtPin.delegate = self;
        txtPin.tag = kTextFieldPIN;
        
        [alr show];
    } else {
        UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Input"
                                                      message:@"Please input to secure"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
        [alr setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        alr.tag = kAlertTypeSetup;
        //name
        UITextField *txtName = [alr textFieldAtIndex:0];
        txtName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        txtName.delegate  = self;
        txtName.placeholder = @"name";
        txtName.tag = kTextFieldName;
        
        //password
        UITextField *txtPassword = [alr textFieldAtIndex:1];
        txtPassword.delegate = self;
        txtPassword.tag = kTextFieldPassword;
        
        [alr show];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) credenticalValidate {
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    BOOL pin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if (name && pin) {
        return YES;
    }
    return NO;
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kAlertTypePIN: {
            if (buttonIndex == 1 && self.hasValidated) {
                [self performSegueWithIdentifier:@"SecuryTableSegue" sender:self];
                self.hasValidated = NO;
            } else {
                [self generatePassword];
            }
        }
            break;
        case kAlertTypeSetup: {
            if (buttonIndex == 1 && [self credenticalValidate]) {
                [self performSegueWithIdentifier:@"SecuryTableSegue" sender:self];
            } else {
                [self generatePassword];
            }
        }
            break;
            
        default:
            break;
    }
    [self performSegueWithIdentifier:@"SecuryTableSegue" sender:self];
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case kTextFieldPIN: {
            if ([textField.text length] > 0) {
                NSUInteger textHash = [textField.text hash];
                if ([kKeychainWrapper compareKeychainValueForMatchingPIN:textHash])
                    self.hasValidated = YES;
                else
                    self.hasValidated = NO;
            }
        }
            break;
        case kTextFieldName: {
            if ([textField.text length] > 0) {
                [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize]; //conform to save
            }
        }
            
            break;
        case kTextFieldPassword: {
            if ([textField.text length] > 0) {
                NSUInteger textHash = [textField.text hash];
                
                NSString *txtSecure = [kKeychainWrapper securedSHA256DigestHashForPIN:textHash];
                if ([kKeychainWrapper createKeychainValue:txtSecure forIdentifier:PIN_SAVED]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
            
            break;
            
        default:
            break;
    }
}

@end
