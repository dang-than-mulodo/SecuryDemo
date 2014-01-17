//
//  SDListTableViewController.m
//  SecuryDemo
//
//  Created by Than Dang on 1/16/14.
//  Copyright (c) 2014 Mulodo Inc. All rights reserved.
//

#import "SDListTableViewController.h"
#import "SDItemStored.h"
#import "SDListTableViewCell.h"
#import "SDDetailTableViewController.h"
#import "SDDetailViewController.h"

@interface SDListTableViewController ()
- (void) deviceWillLock:(id) sender; //Ensure device is locked
- (void) deviceWillUnLock:(id) sender; //Ensure device is unlock
- (void) checkFile;
@end

@implementation SDListTableViewController
@synthesize itemStored, selectedRow;

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
    self.clearsSelectionOnViewWillAppear = NO;
 
    self.itemStored = [[SDItemStored alloc] initWithJSONFile:@"items.json"];
    
    //we aren’t doing anything security-wise
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceWillLock:) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceWillUnLock:) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}


- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Device will become locked
- (void) deviceWillLock:(id) sender {
    [self performSelector:@selector(checkFile) withObject:nil afterDelay:10];
}

//Device is unlock
- (void) deviceWillUnLock:(id) sender {
    [self performSelector:@selector(checkFile) withObject:nil afterDelay:10];
}

- (void)checkFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentDirectory stringByAppendingPathComponent:@"items.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSData *responseData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:NULL];
        NSLog(@"** file %@", json);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.itemStored.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Using Storyboard don't need using itentifier
    SDListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"securyCell"];
    if (!cell) {
        cell = [[SDListTableViewCell alloc] init];
    }
    
    cell.txtDescription.text = [[self.itemStored.items objectAtIndex:indexPath.row] objectForKey:kTextKey];
    [cell.imgDescription setImage:[self.itemStored imageForPresentAtIndex:indexPath]];
    
    return cell;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.itemStored removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath;
    return indexPath;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"addItemSegue"]) { //add item
        UINavigationController *nav = segue.destinationViewController;
        SDAddTableViewController *addVC = [[nav viewControllers] objectAtIndex:0];
        addVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"detailSegue"]) {
        SDDetailViewController *detailVC = segue.destinationViewController;
        detailVC.imgName = [self.itemStored imageNameForPresentAtIndex:self.selectedRow];
        detailVC.txtDetail = [self.itemStored textForItemAtIndex:self.selectedRow];
    }
}

#pragma mark - Add Item delegate
- (void)addItemToDict:(NSDictionary *)item {
    if (item) {
        [self.itemStored addAnItemToItemsList:item];
        [self.tableView reloadData];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    //do not let user add if add is edit mode
    if (editing)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}


@end
