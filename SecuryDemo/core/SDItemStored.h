//
//  SDItemStored.h
//  SecuryDemo
//
//  Created by Than Dang on 1/16/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDItemStored : NSObject

@property (nonatomic, strong) NSMutableArray    *items;

- (id) initWithJSONFile:(NSString *) fileName;

// Exposed method to load the data directly into the items list mutable array
- (NSMutableArray *) dataFromJSONFile:(NSString *) fileName;


// Helper method to ensure that we have a default image for users who dont specify a new picture
- (void) writeDefaultImageToDocuments;

// Writes JSON file to disk, using Data Protection API
- (void) saveJSONDataToDict;

- (void) saveJSONDataToDictNotProtected;

// Should someone delete an item, we can remove it directly, then save the new list to disk (saveJSONDataToDict)
- (void) removeItemAtIndexPath:(NSIndexPath *) indexPath;


- (void) addAnItemToItemsList:(NSDictionary *) newItem;

// Accessor method to retrieve the saved image for a given present
- (UIImage *) imageForPresentAtIndex:(NSIndexPath *) indexPath;

- (NSString *) textForItemAtIndex:(NSIndexPath *) indexPath;

// Accessor method to retrieve the saved image name for a given
- (NSString *) imageNameForPresentAtIndex:(NSIndexPath *) indexPath;


@end
