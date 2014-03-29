//
//  AlarmRunningViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/22/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "AlarmRunningViewController.h"

@interface AlarmRunningViewController ()
@property (strong, nonatomic) IBOutlet UILabel *finalAlarmLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (strong, nonatomic) IBOutlet UIButton *wakeUpButton;
@property (strong, nonatomic) IBOutlet UIButton *snooozeButton;

@end

@implementation AlarmRunningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDate *convertedDate = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:self.alarmDate];
    NSString *stringDate = [NSString stringWithFormat:@"%@",convertedDate];
    NSString *timeWithSeconds = [self getSubstring:stringDate betweenString:@" "];
    NSString *timeNoSeconds = [timeWithSeconds substringToIndex:5];
    NSString *labelText = @"Until: ";
//    labelText = [labelText stringByAppendingString:timeNoSeconds];
    NSString *hour = [timeNoSeconds substringToIndex:3];
    int alarmHour = [hour integerValue];
    NSString *minutes = [timeNoSeconds substringFromIndex:3];
    int alarmMinute = [minutes integerValue];
    if (alarmHour < 12)
    {
        NSString *time = [NSString stringWithFormat:@"%d:%d",alarmHour,alarmMinute];
        labelText = [labelText stringByAppendingString:time];
        labelText = [labelText stringByAppendingString:@" AM"];
    }
    else
    {
        NSString *time = [NSString stringWithFormat:@"%d:%d",(alarmHour-12),alarmMinute];
        labelText = [labelText stringByAppendingString:time];
        labelText = [labelText stringByAppendingString:@" PM"];
    }
    self.finalAlarmLabel.text = labelText;
    
    NSDate *now = [NSDate date];
    NSDate *convertedNow = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:now];


    NSTimeInterval alarmRunTime = [convertedDate timeIntervalSinceDate: convertedNow];
    NSLog(@"%@",now);
    NSLog(@"%@",convertedDate);
    NSLog(@"%f",(float)alarmRunTime);
    
    NSTimer *alarm = [NSTimer scheduledTimerWithTimeInterval:alarmRunTime
                                                          target:self
                                                        selector:@selector(alarmComplete)
                                                        userInfo:nil
                                                        repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:alarm forMode:NSRunLoopCommonModes];

}

- (void)alarmComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.snooozeButton.hidden = false;
        self.wakeUpButton.hidden = false;
        self.timeRemainingLabel.text = @"Wake-Up!";
    });
}

- (NSString *)getSubstring:(NSString *)value betweenString:(NSString *)separator
{
    NSRange firstInstance = [value rangeOfString:separator];
    NSRange secondInstance = [[value substringFromIndex:firstInstance.location + firstInstance.length] rangeOfString:separator];
    NSRange finalRange = NSMakeRange(firstInstance.location + separator.length, secondInstance.location);
    
    return [value substringWithRange:finalRange];
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
