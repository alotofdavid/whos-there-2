//
//  HomeViewController.m
//  whosthere
//
//  Created by Myles Scolnick on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UITextField *defaultMessage;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def objectForKey:@"message"] == nil){
        [def setObject:self.defaultMessage.text forKey:@"message"];
    }
    self.defaultMessage.text = [def objectForKey:@"message"];
    
    self.doneButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editingBegin:(id)sender {
    self.doneButton.enabled = YES;
}


- (IBAction)doneButtonPressed:(id)sender {
    self.doneButton.enabled = NO;
    [self.view endEditing:YES];
}

- (IBAction)editMessage:(id)sender {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *message = self.defaultMessage.text;
    [def setObject:message forKey:@"message"];
    [def synchronize];
    
}

@end
