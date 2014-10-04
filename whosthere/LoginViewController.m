//
//  LoginViewController.m
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//


#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()
@property (strong, nonatomic) PFUser *currentSessionUser;
@end

@implementation LoginViewController

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"hi");
    [super viewDidAppear:YES];
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {//if we are already logged in at application open -weston
        [PFFacebookUtils initializeFacebook]; //this fixed user persistence, but might be gay
        [self openMainTabBarController];
    }
    [PFFacebookUtils initializeFacebook];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"HI");
    
}
- (IBAction)loginbuttonHandler {
    NSArray *permissionsArray = @[@"user_friends"];
    //These are the things we ask facebook to know about the user
    
    [PFFacebookUtils initializeFacebook];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if(error){
            return;
        }
        [self setCurrentSessionUser:user];
        // [_activityIndicator stopAnimating]; // Hide loading indicator
        // This was given to us by parse. Hod do we make this work? -Weston
        if (!user) {
            if (!error) {
                NSLog(@"You have cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"You have cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Login Failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self storeFacebookProfilePicture];
            [self openMainTabBarController];
        } else {
            NSLog(@"User with facebook logged in!");
            [self storeFacebookProfilePicture];
            
            [self openMainTabBarController];
            [[PFUser currentUser] refresh];
        }
    }];
    
    //[_activityIndicator startAnimating]; // Show loading indicator until login is finished
    //This was given by parse. How do we make this work? -Weston
}


- (void)_presentUserDetailsViewControllerAnimated:(BOOL)animated {
    NSLog(@"SDFSJFKSFL");
}
-(void)storeFacebookProfilePicture{//and some other info lol
    NSLog(@"function was called");
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if(!error){
            NSLog(@"no error");
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200", facebookID]];
            [PFUser currentUser][@"profilePictureURL"] = [pictureURL absoluteString];
            [PFUser currentUser][@"facebookId"] = facebookID;
            NSString *firstName = userData[@"first_name"];
            NSString *fullName = [firstName stringByAppendingString:@" "];
            fullName = [fullName stringByAppendingString:userData[@"last_name"]];
            [PFUser currentUser][@"displayName"] = fullName;
            [[PFUser currentUser] saveInBackground];
            
        }else{
            NSLog(@"TAKE CAER OOF ERROR");
        }
        
        
    }];
    
    
}
- (void)openMainTabBarController{//opens main tab bar controller -Weston
   UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self presentViewController:vc animated:YES completion:nil];
    
}

@end
