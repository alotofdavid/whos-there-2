//
//  ViewController.m
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "ViewController.h"
#import "GraphView.h"
#import <Parse/Parse.h>

// 50 is good spot
//we need to use 5 because when the app is in teh background, ios delegates less resources to the app.
#define DATA_SIZE 5
#define SAMPLE_DELAY 0.1
#define KNOCK_DETECT_SENSITIVITY 0.65
//higher sensitivity is less sensitive

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (weak, nonatomic) IBOutlet GraphView *graphV;
@property BOOL readyToListen;
@property int knockCounter;
@property int varyingDelay;

@property (strong, nonatomic) IBOutlet UITextField *defaultMessage;

@end

@implementation ViewController
@synthesize plots, totals, zvals;
int y= 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.readyToListen = YES;
    self.knockCounter = 0;
    self.varyingDelay = 1;
    NSMutableArray *testSignal = [NSMutableArray arrayWithObjects:
                         [NSNumber numberWithFloat:6.9],
                         [NSNumber numberWithFloat:4.7],
                         [NSNumber numberWithFloat:6.6],
                         [NSNumber numberWithFloat:6.9],nil];

    /*NSMutableArray *testSignal = [[NSMutableArray alloc] init];
    for (float i=0; i<10; i++) {
        NSNumber* num = [[NSNumber alloc] initWithFloat:testValues[i]];
        [testSignal addObject:num];
    }*/
    NSLog(@"%d",[self detectKnock:[testSignal objectAtIndex:0]:[testSignal objectAtIndex:1]:[testSignal objectAtIndex:2]]);
    // Do any additional setup after loading the view.
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    //self.motionManager.gyroUpdateInterval = .01;
    
   // self.plots = [NSMutableArray arrayWithCapacity:DATA_SIZE];
    //self.totals = [NSMutableArray arrayWithCapacity:DATA_SIZE];
    self.zvals = [NSMutableArray arrayWithCapacity:DATA_SIZE];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error){ dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self outputAccelertionData:accelerometerData];
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        //NSLog(@"%i\n", ++y);
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
        
        });
    }];
    
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


- (BOOL)detectKnock:(NSNumber*)first:(NSNumber*)second:(NSNumber*)third {
    int down_edge = -100;
    int duration = 1;
    //float slope = .18;
    float slope = KNOCK_DETECT_SENSITIVITY;
    if ([first floatValue] - [second floatValue] > slope) {
        if ([third floatValue] - [second floatValue] > slope) {
            return true;
        }
    }
    if ([first floatValue] - [second floatValue] < -1*slope) {
        if ([third floatValue] - [second floatValue] < -1*slope) {
            return true;
        }
    }

   /* for (int i=0; i<[signal count]-1; i++) {
        NSLog(@"checking i = %d", i);
        if (([[signal objectAtIndex:i] floatValue] - [[signal objectAtIndex:i+1] floatValue]) > slope) {
            down_edge = i;
        } else if (((NSInteger)[signal objectAtIndex:i+1] - (NSInteger)[signal objectAtIndex:i]) > slope) {
            if (down_edge >= i - duration) {
                return true;
            }
        }
    }*/
    return false;
}
int x;

-(void)outputAccelertionData:(CMAccelerometerData *)accelerometerData {
    
    CMAcceleration acceleration = accelerometerData.acceleration;

    //////////////////////////////////////
    
    [[self view] setNeedsDisplay];
    [self.graphV setNeedsDisplay];
    
    //NSLog(@"%lu", (unsigned long)[self.plots count]);
   // if([self.plots count] >= DATA_SIZE){
    //    [self.plots removeObjectAtIndex:DATA_SIZE-1];
    //}
    //if([self.totals count] >= DATA_SIZE){
     //   [self.totals removeObjectAtIndex:DATA_SIZE-1];
    //}
    if([self.zvals count] >= DATA_SIZE){
        [self.zvals removeObjectAtIndex:DATA_SIZE-1];
    }
    //[self.plots insertObject:accelerometerData atIndex:0];
    [self.zvals insertObject:[[NSNumber alloc] initWithFloat:acceleration.z] atIndex:0];
    NSNumber *n = [NSNumber numberWithDouble:(fabs(acceleration.x)+fabs(acceleration.y)+fabs(acceleration.z))];
    
    //[self.totals insertObject:n atIndex:0];
    if ([self.zvals count] > 2) {
        if([self detectKnock:[self.zvals objectAtIndex:0]:[self.zvals objectAtIndex:1]:[self.zvals objectAtIndex:2]]) {
            self.knockLabel.text = @"KNOCK!";
  
            if(self.readyToListen){
                x++;
                self.knockCounter++;
                self.readyToListen = NO;
                NSLog(@"Knock number: %i", x);
                [self performSelector:@selector(resetReadyToListen) withObject:nil afterDelay:SAMPLE_DELAY];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reportNumKnocks) object: nil];

                [self performSelector:@selector(reportNumKnocks) withObject:nil afterDelay: self.varyingDelay];
                
            }
        } else {
            self.knockLabel.text = @"";
        }
    }
    
    
}
-(void)resetReadyToListen{
    self.readyToListen = YES;
}
-(void)reportNumKnocks{
    if(self.knockCounter > 1){
        NSLog(@"Registered %d Knocks",self.knockCounter);
        
        
        PFObject *knock = [PFObject objectWithClassName:@"KNOCK"];
        knock[@"count"] = [NSNumber numberWithInt:self.knockCounter];
        [knock saveInBackground];
        
        NSArray *userIds = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeysForObject:[NSNumber numberWithInt: self.knockCounter]];
        for( NSString *userId in userIds){
            [self sendNotificationToUserWithObjectId:userId];
            
            PFObject *recentKnock = [PFObject objectWithClassName:@"History"];
            recentKnock[@"senderId"] = [PFUser currentUser].objectId;
            recentKnock[@"recipientId"] = userId;
            recentKnock[@"message"] = [NSString stringWithFormat:@"%@ Knocked you up",[PFUser currentUser][@"displayName"]];
            
            NSDate *currentTime = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"MMM d, K:mm a"];
            recentKnock[@"sentTime"] = [dateFormatter stringFromDate: currentTime];
            
            [recentKnock saveInBackground];
            
        }
        //NSString *sendId = [NSUserDefaults standardUserDefaults][@"object]
    }
    self.knockCounter = 0;

}


-(void)sendNotificationToUserWithObjectId:(NSString *)objId{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"owner" equalTo:objId];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    NSUserDefaults *NSUD = [NSUserDefaults standardUserDefaults];
    NSString *message = [NSString stringWithFormat:@"%@\n-%@", [NSUD objectForKey:@"message"], [PFUser currentUser][@"displayName"]];
    [push setMessage:message];
    [push sendPushInBackground];
   
}

- (IBAction)editMessage:(id)sender {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *message = self.defaultMessage.text;
    [def setObject:message forKey:@"message"];
    [def synchronize];
}

- (IBAction)editingBegin:(id)sender {
    self.doneButton.enabled = YES;
}


- (IBAction)doneButtonPressed:(id)sender {
    self.doneButton.enabled = NO;
    [self.view endEditing:YES];
}

@end

