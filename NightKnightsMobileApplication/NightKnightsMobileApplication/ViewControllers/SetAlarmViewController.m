//
//  SetAlarmViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "SetAlarmViewController.h"
#import "AlarmRunningViewController.h"

@interface SetAlarmViewController ()
@property (strong, nonatomic) IBOutlet UIDatePicker *alarmPickerDisplay;

@end

@implementation SetAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.alarmPickerDisplay.locale = [NSLocale systemLocale];
    NSDate *convertedDate = [NSDate dateWithTimeInterval:300 sinceDate:[NSDate date]];
    self.alarmPickerDisplay.date = convertedDate;
    self.alarmPickerDisplay.datePickerMode = UIDatePickerModeTime;
    self.alarmPickerDisplay.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"CDT"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"startAlarm"])
    {
        AlarmRunningViewController *transferViewController = segue.destinationViewController;
        transferViewController.alarmDate = self.alarmPickerDisplay.date;
    }
    
}

@end
