//
//  HomeViewController.m
//  whosthere
//
//  Created by Myles Scolnick on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#define DATA_SIZE 5
#define SAMPLE_DELAY 0.1
#define KNOCK_DETECT_SENSITIVITY 0.65
//higher sensitivity is less sensitive

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UITextField *defaultMessage;
@property BOOL readyToListen;
@property int knockCounter;
@property int varyingDelay;

@property (nonatomic, strong) AVQueuePlayer *player;//for audio stuff
@property (nonatomic, strong) id timeObserver;

@end

@implementation HomeViewController
@synthesize zvals;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Hello World");
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def objectForKey:@"message"] == nil){
        [def setObject:self.defaultMessage.text forKey:@"message"];
    }
    self.defaultMessage.text = [def objectForKey:@"message"];
    
    self.doneButton.enabled = NO;
    
    // swagmandu
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    
    self.readyToListen = YES;
    self.knockCounter = 0;
    self.varyingDelay = 1;
    
    self.zvals = [NSMutableArray arrayWithCapacity:DATA_SIZE];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error){ dispatch_async(dispatch_get_main_queue(), ^{
        [self outputAccelertionData:accelerometerData];
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            if(error){
                
                NSLog(@"%@", error);
            }
        
        });
            }];
    // Set AVAudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&sessionError];

}

- (BOOL)detectKnock:(NSNumber*)firstArg and:(NSNumber*) secondArg and:(NSNumber*)thirdArg {
    //float slope = .18;
    float slope = KNOCK_DETECT_SENSITIVITY;
    if ([firstArg floatValue] - [secondArg floatValue] > slope) {
        if ([thirdArg floatValue] - [secondArg floatValue] > slope) {
            return true;
        }
    }
    if ([firstArg floatValue] - [secondArg floatValue] < -1*slope) {
        if ([thirdArg floatValue] - [secondArg floatValue] < -1*slope) {
            NSLog(@"Detected a knock");
            return true;
        }
    }
    return false;
}


-(void)outputAccelertionData:(CMAccelerometerData *)accelerometerData {
    
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    //////////////////////////////////////
    
    
    if([self.zvals count] >= DATA_SIZE){
        [self.zvals removeObjectAtIndex:DATA_SIZE-1];
    }
    [self.zvals insertObject:[[NSNumber alloc] initWithFloat:acceleration.z] atIndex:0];
    
    if ([self.zvals count] > 2) {
        if([self detectKnock:[self.zvals objectAtIndex:0] and:[self.zvals objectAtIndex:1] and:[self.zvals objectAtIndex:2]]) {
            if(self.readyToListen){
                self.knockCounter++;
                self.readyToListen = NO;
                [self performSelector:@selector(resetReadyToListen) withObject:nil afterDelay:SAMPLE_DELAY];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reportNumKnocks) object: nil];
                
                [self performSelector:@selector(reportNumKnocks) withObject:nil afterDelay: self.varyingDelay];
                
            }
        }
    }
}
-(void)resetReadyToListen{
    self.readyToListen = YES;
}
-(void)reportNumKnocks{
    if(self.knockCounter > 1){
        NSLog(@"Registered %d Knocks",self.knockCounter);
        NSArray *userIds = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeysForObject:[NSNumber numberWithInt: self.knockCounter]];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if([userIds count] > 0 ){
            if([def boolForKey:@"vibrationSettings"]){
                for(int i = 0; i < self.knockCounter; i++) {
                    [self performSelector:@selector(vibratePhone) withObject:nil afterDelay:i/1.75];
                }
            }
            if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You sent a knock!"
                                                                message:[NSString stringWithFormat:@"You knocked %d times",self.knockCounter ]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }

        }
        for( NSString *userId in userIds){
            [self sendNotificationToUserWithObjectId:userId];
        }}
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
    
    PFObject *recentKnock = [PFObject objectWithClassName:@"History"];
    recentKnock[@"senderId"] = [PFUser currentUser].objectId;
    recentKnock[@"recipientId"] = objId;
    recentKnock[@"message"] = message;
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"MMM d, K:mm a"];
    recentKnock[@"sentTime"] = [dateFormatter stringFromDate: currentTime];
    
    [recentKnock saveInBackground];
    
}

-(void)vibratePhone{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
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
