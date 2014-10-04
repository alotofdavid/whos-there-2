//
//  ViewController.h
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface ViewController : UIViewController{
    NSMutableArray *plots;
    NSMutableArray *totals;
}
@property(nonatomic, retain) NSMutableArray *plots;
@property(nonatomic, retain) NSMutableArray *totals;

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

