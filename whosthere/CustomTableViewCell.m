//
//  CustomTableViewCell.m
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "CustomTableViewCell.h"
#import <Parse/Parse.h>

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)editingChanged:(id)sender {
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setInteger:[self.numberField.text integerValue] forKey: self.idForCell];
    [def synchronize];
}


- (IBAction)sendNotification:(id)sender {

//    // Create our Installation query
//    PFQuery *pushQuery = [PFInstallation query];
//    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
//    NSString *message = [NSString stringWithFormat: @"Hello from %@", [PFUser currentUser][@"displayName"]];
//    
//    // Send push notification to query
//    [PFPush sendPushMessageToQueryInBackground:pushQuery
//                                   withMessage:message];

    
    /// WORKS ^^
    ////////////////////////////////////
    
//    NSArray *messageRecipients = [message objectForKey:@"recipientIds"];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" equalTo:];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setMessage:[NSString stringWithFormat: @"New Message from %@!",  [PFUser currentUser][@"displayName"]]];
    [push sendPushInBackground];
    
    
    
}

@end
