//
//  CustomTableViewCell.h
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property NSInteger vibrationCount;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (strong, nonatomic)NSString *idForCell;

@end
