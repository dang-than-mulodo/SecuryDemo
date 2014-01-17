//
//  SDListTableViewController.h
//  SecuryDemo
//
//  Created by Than Dang on 1/16/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDAddTableViewController.h"
@class SDItemStored;


@interface SDListTableViewController : UITableViewController <SDAddItemDelefate>

@property (nonatomic, strong) SDItemStored  *itemStored;
@property (nonatomic, strong) NSIndexPath   *selectedRow;

@end
