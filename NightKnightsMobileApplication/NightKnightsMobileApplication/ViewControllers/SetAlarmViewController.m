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
@property (strong, nonatomic) NSUserDefaults* defaults;


@end

@implementation SetAlarmViewController



-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];   
}
- (void) viewWillAppear:(BOOL)animated
{
    NSDate *dateFromPrevious;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *alarmDate = [defaults objectForKey:@"alarmInformation"];
    if(alarmDate){
        dateFromPrevious = alarmDate[0];
        NSDate *midnight = [self dateAtBeginningOfDayForDate:[NSDate date]];
        while ([dateFromPrevious compare:midnight] == NSOrderedAscending)
        {
            dateFromPrevious = [NSDate dateWithTimeInterval:24*60*60 sinceDate:dateFromPrevious];
        }
        self.alarmPickerDisplay.date = dateFromPrevious;
        self.alarmPickerDisplay.datePickerMode = UIDatePickerModeTime;
        self.alarmPickerDisplay.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"CDT"];
    }
    else
    {
        NSDate *convertedDate = [NSDate dateWithTimeInterval:300 sinceDate:[NSDate date]];
        self.alarmPickerDisplay.date = convertedDate;
        self.alarmPickerDisplay.datePickerMode = UIDatePickerModeTime;
        self.alarmPickerDisplay.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"CDT"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSDate *alarmInfo = self.alarmPickerDisplay.date;
    NSArray *alarmTime = [NSArray arrayWithObjects:alarmInfo, nil];
    [self.defaults setObject:alarmTime forKey:@"alarmInformation"];
    [self.defaults synchronize];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"startAlarm"])
    {
        AlarmRunningViewController *transferViewController = segue.destinationViewController;
        transferViewController.alarmDate = self.alarmPickerDisplay.date;
    }
    
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}




- (IBAction)unwindToSetAlarm:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"hi");    
}



@end
