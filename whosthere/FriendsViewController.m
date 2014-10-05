//
//  FriendsViewController.m
//  whosthere
//
//  Created by David Adams on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "FriendsViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CustomTableViewCell.h"

@interface FriendsViewController ()
@property (strong, nonatomic) NSMutableArray *friendArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryFacebookFriends];
    // Do any additional setup after loading the view.
  
}

- (IBAction)cancelButtonHandler:(id)sender {
    [self.view endEditing:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    PFObject *obj = [self.friendArray objectAtIndex:indexPath.row];
    NSString *cellText = obj[@"displayName"];
    cell.textLabel.text = cellText;
    NSString *pictureURL =obj[@"profilePictureURL"];
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureURL]]];
    cell.imageView.image = img;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    int defaultValue = 3;
    if(![def objectForKey:[obj objectId]]){
        [def setInteger:defaultValue forKey:[obj objectId]];
        [def synchronize];
    }
    ((CustomTableViewCell *)cell).numberField.text = [NSString stringWithFormat:@"%ld",(long)[def integerForKey:[obj objectId]]];
    ((CustomTableViewCell *)cell).idForCell = [obj objectId];
    //check to see if an entry exists in NSUser defualts
    //if it does not, set it to default value
    //set the field
    return cell;
}
- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return [self.friendArray count];
}
-(void)queryFacebookFriends{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookId" containedIn:friendIds];
            
            [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                self.friendArray = [objects mutableCopy];
                [self refreshTable];
            }];
        }
    }];
}
-(void)refreshTable{
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
