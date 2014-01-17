//
//  SDDetailViewController.h
//  SecuryDemo
//
//  Created by Than Dang on 1/17/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (nonatomic, strong) NSString  *imgName;
@property (nonatomic, strong) NSString  *txtDetail;


@end
