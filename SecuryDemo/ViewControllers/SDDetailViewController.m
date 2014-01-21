//
//  SDDetailViewController.m
//  SecuryDemo
//
//  Created by Than Dang on 1/17/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "SDDetailViewController.h"

@interface SDDetailViewController ()

@end

@implementation SDDetailViewController
@synthesize txtDetail, imgName, lblDetail, imgDetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidUnload {
    self.imgDetail = nil;
    self.lblDetail = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    lblDetail.text = self.txtDetail;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *imgPath = [documentDirectory stringByAppendingPathComponent:self.imgName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
        self.imgDetail.image = [UIImage imageWithContentsOfFile:imgPath];
    }
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
