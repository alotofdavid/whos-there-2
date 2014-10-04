//
//  GraphView.h
//  whosthere
//
//  Created by Myles Scolnick on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>


@interface GraphView : UIView {
    ViewController *currentV;
}

@property(nonatomic, retain) IBOutlet ViewController *currentV;
@end
