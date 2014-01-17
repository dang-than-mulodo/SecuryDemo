//
//  SDListTableViewCell.m
//  SecuryDemo
//
//  Created by Than Dang on 1/17/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "SDListTableViewCell.h"

@implementation SDListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
