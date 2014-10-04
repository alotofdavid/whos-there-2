//
//  accelTestController.m
//  test
//
//  Created by Dennis Fang on 10/3/14.
//  Copyright (c) 2014 Dennis Fang. All rights reserved.
//

#import "accelTestController.h"
#define kFilteringFactor .1

@interface accelTestController ()

@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (strong, nonatomic) NSMutableArray *accArray;@end

@implementation accelTestController
NSTimer *timer;
bool handModeOn, pocketFlag, timerFlag, addValueFlag;
float rollingX, rollingY, rollingZ;
NSNumber *sensitivity;


- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    if (pause)
    {
        return;
    }
    if (handModeOn == NO)
    {
        if(pocketFlag == NO)
            return;
    }
    
    //  float accelZ = 0.0;
    //  float accelX = 0.0;
    //  float accelY = 0.0;
    
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = acceleration.x - rollingX;
    float accelY = acceleration.y - rollingY;
    float accelZ = acceleration.z - rollingZ;
    
    if((-accelZ >= [sensitivity floatValue] && timerFlag) || (-accelZ <= -[sensitivity floatValue] && timerFlag)|| (-accelX >= [sensitivity floatValue] && timerFlag) || (-accelX <= -[sensitivity floatValue] && timerFlag) || (-accelY >= [sensitivity floatValue] && timerFlag) || (-accelY <= -[sensitivity floatValue] && timerFlag))
    {
        timerFlag = false;
        addValueFlag = true;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    }
    
    if(addValueFlag)
    {
        [self.accArray addObject:[NSNumber numberWithFloat:-accelX]];
        [self.accArray addObject:[NSNumber numberWithFloat:-accelY]];
        [self.accArray addObject:[NSNumber numberWithFloat:-accelZ]];
    }
}
- (void)timerTick:(NSTimer *)timer1
{
    [timer1 invalidate];
    addValueFlag = false;
    int count = 0;
    
    for(int i = 0; i < self.accArray.count; i++)
    {
        if(([[self.accArray objectAtIndex:i] floatValue] >= [sensitivity floatValue]) || ([[self.accArray objectAtIndex:i] floatValue] <= -[sensitivity floatValue]))
        {
            count++;
            //[self playAlarm:@"beep-1" FileType:@"mp3"];
        }
        
        if(count >= 3)
        {
           // [self playAlarm:@"06_Alarm___Auto___Rapid_Beeping_1" FileType:@"caf"];
           // [self showAlert];
            [self.lbl setText:@"TRIPLE TAP"];
            timerFlag = true;
            
            [self.accArray removeAllObjects];
            return;
        }
    }
    [self.accArray removeAllObjects];
    timerFlag = true;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    sensitivity = [NSNumber numberWithDouble:.5];
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

@end
