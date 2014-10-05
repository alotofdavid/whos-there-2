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
@property NSMutableArray *notificationArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
    NSUInteger count = [self.notificationArray count];
    
    PFObject *obj = [self.notificationArray objectAtIndex:(count-indexPath.row-1)];
    NSString *cellText = obj[@"message"];
    cell.textLabel.text = cellText;
    NSString *date = obj[@"sentTime"];
    cell.detailTextLabel.text = date;
    
    return cell;
}
- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return [self.notificationArray count];
}
-(void)queryData{
    
    PFQuery *query = [PFQuery queryWithClassName: @"History"];
    [query whereKey:@"recipientId" equalTo:[[PFUser currentUser] objectId]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *notifications, NSError *error) {
        self.notificationArray = [notifications mutableCopy];
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

@end
