//
//  SDItemStored.m
//  SecuryDemo
//
//  Created by Than Dang on 1/16/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "SDItemStored.h"

@interface SDItemStored()
- (void) deleteImageWithName:(NSString *)imgName;

@end

@implementation SDItemStored
@synthesize items;

- (id) initWithJSONFile:(NSString *)fileName {
    self = [super init];
    if (self) {
        self.items = [self dataFromJSONFile:fileName];
        [self writeDefaultImageToDocuments];
    }
    return self;
}

- (NSMutableArray *)dataFromJSONFile:(NSString *)fileName {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSError *err = nil;
        NSData *responseData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
        return [[NSMutableArray alloc] initWithArray:[json objectForKey:kSecuryKey]];
    }
    
    //if it's not exist
    return [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"test funny", kTextKey, @"noImage", kImageKey, nil], nil];
}

- (void) writeDefaultImageToDocuments {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *imagePath = [documentDirectory stringByAppendingPathComponent:@"default_image.png"];
    //if it's does not, save it
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *img = [UIImage imageNamed:@"funny.jpg"];
        NSData *imgData = UIImageJPEGRepresentation(img, 0);
        [imgData writeToFile:imagePath atomically:YES]; //store image
    }
}


//main protect data api
- (void) saveJSONDataToDict {
    NSError *err = nil;
    
    NSDictionary *jSonDictData = [NSDictionary dictionaryWithObject:self.items forKey:kSecuryKey];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jSonDictData options:NSJSONWritingPrettyPrinted error:&err];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *jsonPath = [documentDirectory  stringByAppendingPathComponent:@"items.json"];
    [jsonData writeToFile:jsonPath options:NSDataWritingFileProtectionComplete error:&err];
    
    [[NSFileManager defaultManager]  setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey] ofItemAtPath:jsonPath error:&err];
}

- (void) saveJSONDataToDictNotProtected {
    NSError *err = nil;
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:self.items forKey:kSecuryKey];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&err];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentDirectory stringByAppendingPathComponent:@"items.json"];
    [jsonData writeToFile:jsonPath options:kNilOptions error:&err];

}

- (void)addAnItemToItemsList:(NSDictionary *)newItem {
    [self.items addObject:newItem];
    [self saveJSONDataToDict];
//    [self saveJSONDataToDictNotProtected];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteImageWithName:[[self.items objectAtIndex:indexPath.row] objectForKey:kImageKey]];
    [self.items removeObjectAtIndex:indexPath.row];
    [self saveJSONDataToDict];
}

- (void) deleteImageWithName:(NSString *)imgName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *itemPath = [documentDirectory stringByAppendingPathComponent:imgName];
    
    //do not delete default image
    if ([[NSFileManager defaultManager] fileExistsAtPath:itemPath] && ![@"default_image.png" isEqualToString:imgName]) {
        [[NSFileManager defaultManager] removeItemAtPath:itemPath error:NULL];
    }
}

- (NSString *) textForItemAtIndex:(NSIndexPath *)indexPath {
    return [[self.items objectAtIndex:indexPath.row] objectForKey:kTextKey];
}

- (NSString *) imageNameForPresentAtIndex:(NSIndexPath *)indexPath {
    return [[self.items objectAtIndex:indexPath.row] objectForKey:kImageKey];
}

- (UIImage *)imageForPresentAtIndex:(NSIndexPath *)indexPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *imgName = [[self.items objectAtIndex:indexPath.row]  objectForKey:kImageKey];
    NSString *imgPath = [documentDirectory stringByAppendingPathComponent:imgName];
    
    UIImage *returnImage = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
        returnImage = [UIImage imageWithContentsOfFile:imgPath];
    } else {
        returnImage = [UIImage imageNamed:@"funny.jpg"];
    }
    return returnImage;
}

@end
