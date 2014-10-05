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
#define GRAPH_SIZE 50
#define SAMPLE_DELAY 0.1
//higher sensitivity is less sensitive

@interface ViewController ()

@property (weak, nonatomic) IBOutlet GraphView *graphV;
@property BOOL readyToListen;
@property int knockCounter;
@property int varyingDelay;

@property BOOL graphOn;

@end

@implementation ViewController
@synthesize plots, totals;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.graphOn = NO;
    
    self.readyToListen = YES;
    self.varyingDelay = 1;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    //self.motionManager.gyroUpdateInterval = .01;
    
    self.plots = [NSMutableArray arrayWithCapacity:GRAPH_SIZE];
    self.totals = [NSMutableArray arrayWithCapacity:GRAPH_SIZE];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error){ dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self outputAccelertionData:accelerometerData];
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                                                if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
        
        });
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)outputAccelertionData:(CMAccelerometerData *)accelerometerData {
    
    CMAcceleration acceleration = accelerometerData.acceleration;

    //////////////////////////////////////
    
    [[self view] setNeedsDisplay];
    [self.graphV setNeedsDisplay];
    
    if(self.graphOn == YES){
        if([self.plots count] >= GRAPH_SIZE){
            [self.plots removeObjectAtIndex:GRAPH_SIZE-1];
        }
        if([self.totals count] >= GRAPH_SIZE){
            [self.totals removeObjectAtIndex:GRAPH_SIZE-1];
        }
        [self.plots insertObject:accelerometerData atIndex:0];
        NSNumber *n = [NSNumber numberWithDouble:(fabs(acceleration.x)+fabs(acceleration.y)+fabs(acceleration.z))];
        [self.totals insertObject:n atIndex:0];
    }
}
-(void)resetReadyToListen{
    self.readyToListen = YES;
}


- (IBAction)graphSwitched:(id)sender {
    if ([sender isOn]) {
        self.graphOn = YES;
    }else {
        self.graphOn = NO;
    }
}

@end

