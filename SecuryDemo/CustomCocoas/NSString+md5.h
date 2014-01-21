//
//  NSString+md5.h
//  SecuryDemo
//
//  Created by Than Dang on 1/15/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (md5) {
    
}

- (NSString *) md5;

@property (nonatomic, readonly, getter = isNumeric) BOOL numeric;
@property (nonatomic, copy) NSString *tag;


@end
