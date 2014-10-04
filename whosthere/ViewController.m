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
@synthesize plots, totals, zvals;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSLog(@"%d",[self detectKnock:testSignal]);
    // Do any additional setup after loading the view.
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
    int down_edge = -100;
    int duration = 1;
    int slope = .4;
    for (int i=0; i<[signal count]-1; i++) {
        if (([[signal objectAtIndex:i] floatValue] - [[signal objectAtIndex:i+1] floatValue]) > slope) {
            down_edge = i;
        } else if (((NSInteger)[signal objectAtIndex:i+1] - (NSInteger)[signal objectAtIndex:i]) > slope) {
            if (down_edge >= i - duration) {
                return true;
            }
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
    
    if ([self.plots count] > 10) {
        NSLog(@"%d", [self detectKnock:self.plots]);
    }
    [[self view] setNeedsDisplay];
    [self.graphV setNeedsDisplay];
    
    //NSLog(@"%lu", (unsigned long)[self.plots count]);
    if([self.plots count] >= DATA_SIZE){
        [self.plots removeObjectAtIndex:DATA_SIZE-1];
    }
    if([self.totals count] >= DATA_SIZE){
        [self.totals removeObjectAtIndex:DATA_SIZE-1];
    }
    [self.plots insertObject:accelerometerData atIndex:0];
    [self.zvals insertObject:[[NSNumber alloc] initWithFloat:accelerometerData.acceleration.z] atIndex:0];
    NSNumber *n = [NSNumber numberWithDouble:(fabs(acceleration.x)+fabs(acceleration.y)+fabs(acceleration.z))];
    
    [self.totals insertObject:n atIndex:0];

    
    
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

