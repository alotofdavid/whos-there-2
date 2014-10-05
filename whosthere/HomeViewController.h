//
//  HomeViewController.h
//  whosthere
//
//  Created by Myles Scolnick on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface HomeViewController : UIViewController
@property(nonatomic, retain) NSMutableArray *zvals;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end
