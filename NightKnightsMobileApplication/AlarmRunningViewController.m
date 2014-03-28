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

@end

@implementation AlarmRunningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *stringDate = [NSString stringWithFormat:@"%@",self.alarmDate];
    NSString *timeWithSeconds = [self getSubstring:stringDate betweenString:@" "];
    NSString *timeNoSeconds = [timeWithSeconds substringToIndex:5];
    NSString *labelText = @"Until: ";
    labelText = [labelText stringByAppendingString:timeNoSeconds];
    
    self.finalAlarmLabel.text = labelText;
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
