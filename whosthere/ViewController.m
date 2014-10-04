//
//  ViewController.m
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UILabel *labelX;
@property (nonatomic, retain) IBOutlet UILabel *labelY;
@property (nonatomic, retain) IBOutlet UILabel *labelZ;

@property (nonatomic, retain) IBOutlet UIProgressView *progressX;
@property (nonatomic, retain) IBOutlet UIProgressView *progressY;
@property (nonatomic, retain) IBOutlet UIProgressView *progressZ;

@property (nonatomic, retain) UIAccelerometer *accelerometer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.accelerometer = [UIAccelerometer sharedAccelerometer];
    self.accelerometer.updateInterval = .1;
    self.accelerometer.delegate = self;
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
    NSLog(@"X is %f, Y is %f, Z is %f",acceleration.x, acceleration.y, acceleration.z);
    
}

@end
