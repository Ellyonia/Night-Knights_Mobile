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
        NSLog(@"Loading from Save");
        dateFromPrevious = alarmDate[0];
        NSLog(@"%@",dateFromPrevious);
        NSDate *midnight = [self dateAtBeginningOfDayForDate:[NSDate date]];
        NSLog(@"%@",midnight);
        while ([dateFromPrevious compare:midnight] == NSOrderedAscending)
        {
            //dateFromPrevious = [NSDate dateWithTimeInterval:60*60*24 sinceDate:dateFromPrevious];
            NSLog(@"%@",dateFromPrevious);
        }
//        NSTimeInterval convertDateToToday = [[NSDate date] timeIntervalSinceDate: dateFromPrevious];
//        int dayInSeconds = 60*60*24;
//        int daysBetween = (int)convertDateToToday%dayInSeconds;
//        daysBetween *=dayInSeconds;
//
//        NSDate *newPickerDate = [NSDate dateWithTimeInterval:convertDateToToday sinceDate:dateFromPrevious];
        self.alarmPickerDisplay.date = dateFromPrevious;
        self.alarmPickerDisplay.datePickerMode = UIDatePickerModeTime;
        self.alarmPickerDisplay.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"CDT"];
//
    }
    else
    {
        NSLog(@"Loading Current Date");
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
    NSLog(@"%i",[self.defaults synchronize]);

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


@end
