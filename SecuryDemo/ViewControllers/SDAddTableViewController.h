//
//  SDAddTableViewController.h
//  SecuryDemo
//
//  Created by Than Dang on 1/16/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDAddItemDelefate <NSObject>

- (void) addItemToDict:(NSDictionary *) item;

@end

@interface SDAddTableViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAdd;
@property (weak, nonatomic) IBOutlet UITextView *txtAdd;
@property (strong, nonatomic) UIImagePickerController   *imagePicker;
@property (strong, nonatomic) NSString *imgName;
@property (weak, nonatomic) id<SDAddItemDelefate> delegate;




@end
