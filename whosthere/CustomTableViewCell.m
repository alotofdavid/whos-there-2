//
//  CustomTableViewCell.m
//  whosthere
//
//  Created by Weston Mizumoto on 10/4/14.
//  Copyright (c) 2014 Weston Mizumoto. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)editingChanged:(id)sender {
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setInteger:[self.numberField.text integerValue] forKey: self.idForCell];
    [def synchronize];
}

@end
