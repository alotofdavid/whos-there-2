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
#define DATA_SIZE 50

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UILabel *labelX;
@property (nonatomic, retain) IBOutlet UILabel *labelY;
@property (nonatomic, retain) IBOutlet UILabel *labelZ;

@property (nonatomic, retain) IBOutlet UIProgressView *progressX;
@property (nonatomic, retain) IBOutlet UIProgressView *progressY;
@property (nonatomic, retain) IBOutlet UIProgressView *progressZ;

@property (weak, nonatomic) IBOutlet GraphView *graphV;

@end

@implementation ViewController
@synthesize plots, totals;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray* signal = [[NSMutableArray alloc] init];
    [signal addObject:[NSNumber numberWithFloat:5]];
    [signal addObject:[NSNumber numberWithFloat:2]];
    

    NSLog(@"%d", [self detectKnock:signal]);
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    self.motionManager.gyroUpdateInterval = .01;
    
    self.plots = [NSMutableArray arrayWithCapacity:DATA_SIZE];
    self.totals = [NSMutableArray arrayWithCapacity:DATA_SIZE];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    self.labelX.text = [NSString stringWithFormat:@"%@%f", @"X: ", acceleration.x];
    self.labelY.text = [NSString stringWithFormat:@"%@%f", @"Y: ", acceleration.y];
    self.labelZ.text = [NSString stringWithFormat:@"%@%f", @"Z: ", acceleration.z];
    
    self.progressX.progress = ABS(acceleration.x);
    self.progressY.progress = ABS(acceleration.y);
    self.progressZ.progress = ABS(acceleration.z);
   // NSLog(@"X is %f, Y is %f, Z is %f",acceleration.x, acceleration.y, acceleration.z);
   
}

- (BOOL)detectKnock:(NSMutableArray *)signal {
    for (int i=0; i<signal.count-1; i++) {
        int tolerance = 1;
        if (((NSInteger)[signal objectAtIndex:i] - (NSInteger)[signal objectAtIndex:i+1])/ 2 > tolerance) {
            return true;
        }
    }
    return false;
}


-(void)outputAccelertionData:(CMAccelerometerData *)accelerometerData {
    
    CMAcceleration acceleration = accelerometerData.acceleration;

    //////////////////////////////////////////////////////////////////
    
    ////  THIS SLOWS DOWN ALOT SINCE IT UPDATES TEXT ALOT
//    
//    self.labelX.text = [NSString stringWithFormat:@"%@%f", @"X: ", acceleration.x];
//    self.labelY.text = [NSString stringWithFormat:@"%@%f", @"Y: ", acceleration.y];
//    self.labelZ.text = [NSString stringWithFormat:@"%@%f", @"Z: ", acceleration.z];
//    
//    self.progressX.progress = ABS(acceleration.x);
//    self.progressY.progress = ABS(acceleration.y);
//    self.progressZ.progress = ABS(acceleration.z);
//    NSLog(@"X is %f, Y is %f, Z is %f",acceleration.x, acceleration.y, acceleration.z);
    
    //////////////////////////////////////
    
    [[self view] setNeedsDisplay];
    [self.graphV setNeedsDisplay];
    
    float minimumAcceleration = 0.0f;
    
    NSLog(@"%lu", (unsigned long)[self.plots count]);
    if([self.plots count] >= DATA_SIZE){
        [self.plots removeObjectAtIndex:DATA_SIZE-1];
    }
    if([self.totals count] >= DATA_SIZE){
        [self.totals removeObjectAtIndex:DATA_SIZE-1];
    }
    [self.plots insertObject:accelerometerData atIndex:0];
    
    NSNumber *n = [NSNumber numberWithDouble:(fabs(acceleration.x)+fabs(acceleration.y)+fabs(acceleration.z))];
    
    [self.totals insertObject:n atIndex:0];
    
    if(abs(acceleration.x)+abs(acceleration.y)+abs(acceleration.z) > minimumAcceleration){
        
    }
    
    
}
- (IBAction)sendNotification:(id)sender {
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                   withMessage:@"Hello World!"];
}

@end

