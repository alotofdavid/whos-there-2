//
//  NotificationViewController.m
//  whosthere
//
//  Created by Myles Scolnick on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "NotificationViewController.h"
#import <Parse/Parse.h>


@interface NotificationViewController ()
@property NSMutableArray *recievedNotificationArray;
@property NSMutableArray *sentNotificationArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    static NSString *CellIdentifier = @"NewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    PFObject *obj;
    if(self.segControl.selectedSegmentIndex == 0){
        NSUInteger count = [self.recievedNotificationArray count];
    
        obj = [self.recievedNotificationArray objectAtIndex:(count-indexPath.row-1)];
    }else{
        NSUInteger count = [self.sentNotificationArray count];
            
        obj = [self.sentNotificationArray objectAtIndex:(count-indexPath.row-1)];
    }
    NSString *cellText = obj[@"message"];
    cell.textLabel.text = cellText;
    NSString *date = obj[@"sentTime"];
    cell.detailTextLabel.text = date;
    return cell;
}
- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    if (self.segControl.selectedSegmentIndex == 0){
        return [self.recievedNotificationArray count];
    }else{
        return [self.sentNotificationArray count];
    }
}
-(void)queryData{
    
    PFQuery *query = [PFQuery queryWithClassName: @"History"];
    [query whereKey:@"recipientId" equalTo:[[PFUser currentUser] objectId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *notifications, NSError *error) {
        self.recievedNotificationArray = [notifications mutableCopy];
        [self.tableView reloadData];
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName: @"History"];
    [query2 whereKey:@"senderId" equalTo:[[PFUser currentUser] objectId]];
    
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *notifications, NSError *error) {
        self.sentNotificationArray = [notifications mutableCopy];
        [self.tableView reloadData];
    }];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)refreshData:(id)sender {
    [self queryData];
}
- (IBAction)changeSegControl:(id)sender {
    [self.tableView reloadData];
}

@end
