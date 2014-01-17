//
//  SDAddTableViewController.m
//  SecuryDemo
//
//  Created by Than Dang on 1/16/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "SDAddTableViewController.h"

@interface SDAddTableViewController ()
- (void) presentPickerImage;
@end

@implementation SDAddTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.imagePicker = [[UIImagePickerController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) presentPickerImage {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.delegate = self;
    
    //disable image editting
    self.imagePicker.allowsEditing = NO;
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - Table view data source

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self presentPickerImage];
            break;
            
        default:
            break;
    }
}


#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self.imgAdd setImage:img];
    
    //capture the file name
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSError *err = nil;
    NSArray *dirContain = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:&err];
    NSString *fileName = [[NSString alloc] initWithFormat:@"photo_%i", [dirContain count]];
    NSString *imgPath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    self.imgName = [NSString stringWithFormat:@"%@", fileName];
    
    //save it to document directory
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *editedImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *webData = UIImagePNGRepresentation(editedImg);
        [webData writeToFile:imgPath atomically:YES];
    }
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)done:(id)sender {
    //don't be blank image name
    if (!self.imgName) {
        self.imgName = @"default_image.png";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addItemToDict:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_txtAdd.text, kTextKey, self.imgName, kImageKey, nil];
        [self.delegate addItemToDict:dict];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
