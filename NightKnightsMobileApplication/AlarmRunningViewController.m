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
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic) NSTimer * minuteHourRemover;

@end

@implementation AlarmRunningViewController
int snoozeCount = -1;
bool alarmStillRunning = YES;
int timeRemaining = 0.0;
int iHour = 0;
int iMinute = 0;


- (IBAction)snoozedPressed:(UIButton *)sender {
    self.snooozeButton.hidden = YES;
    self.wakeUpButton.hidden = YES;
//    self.timeRemainingLabel.text = @"Wake-Up!";
    self.headerLabel.hidden = NO;
    self.headerLabel.text = @"Snoozing for";
    self.timeRemainingLabel.text = @"05:00";
    NSTimer *isSnoozing = [NSTimer scheduledTimerWithTimeInterval:300
                                                      target:self
                                                    selector:@selector(alarmComplete)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:isSnoozing forMode:NSRunLoopCommonModes];
    self.minuteHourRemover = [NSTimer scheduledTimerWithTimeInterval:60
                                                              target:self
                                                            selector:@selector(removeMinuteOrHour)
                                                            userInfo:nil
                                                             repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.minuteHourRemover forMode:NSRunLoopCommonModes];

    snoozeCount ++;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    bool firstMinute = true;
    NSDate *convertedDate = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:self.alarmDate];
    NSLog(@"%@",convertedDate);
    NSLog(@"%@",self.alarmDate);
    NSString *stringDate = [NSString stringWithFormat:@"%@",convertedDate];
    NSString *timeWithSeconds = [self getSubstring:stringDate betweenString:@" "];
    NSString *timeNoSeconds = [timeWithSeconds substringToIndex:5];
    NSString *labelText = @"Until: ";
    
    NSString *hours = [timeNoSeconds substringToIndex:3];
    int alarmHour = (int)[hours integerValue];
    NSString *minutes = [timeNoSeconds substringFromIndex:3];
    int alarmMinute = (int)[minutes integerValue];
    
    if (alarmHour < 13)
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

    NSString *sSeconds = [self getSubstring:stringDate betweenString:@" "];
    sSeconds = [sSeconds substringFromIndex:6];
    int seconds = (int)[sSeconds integerValue];
    NSTimeInterval alarmRunTime = [convertedDate timeIntervalSinceDate: convertedNow];
    timeRemaining = (int)alarmRunTime - seconds;
    
    // Checks to see if you want an alarm time for the morning.
    if (timeRemaining < 0)
        timeRemaining = timeRemaining + 60*60*24;
    
    iHour = (int)timeRemaining/(60*60);
    iMinute = timeRemaining%3600 / 60 + 1;
    NSLog(@"%i",seconds);
    
    NSString *remainingTimeLabel;
    if(iHour < 10)
    {
        remainingTimeLabel = [NSString stringWithFormat:@"0%d:", iHour];
    }
    else
    {
        remainingTimeLabel = [NSString stringWithFormat:@"%d:",iHour];
    }
    if (iMinute < 10)
    {
        remainingTimeLabel = [remainingTimeLabel stringByAppendingString:[NSString stringWithFormat:@"0%d",iMinute]];
        
    }
    else
    {
        remainingTimeLabel = [remainingTimeLabel stringByAppendingString:[NSString stringWithFormat:@"%d",iMinute]];
    }
    self.timeRemainingLabel.text = remainingTimeLabel;
    
    NSTimer *alarm = [NSTimer scheduledTimerWithTimeInterval:timeRemaining
                                                          target:self
                                                        selector:@selector(alarmComplete)
                                                        userInfo:nil
                                                        repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:alarm forMode:NSRunLoopCommonModes];
    if (firstMinute)
    {
        self.minuteHourRemover = [NSTimer scheduledTimerWithTimeInterval:60-seconds+1
                                                                  target:self
                                                                selector:@selector(removeMinuteOrHour)
                                                                userInfo:nil
                                                                 repeats:NO];
        firstMinute = NO;
    }
    self.minuteHourRemover = [NSTimer scheduledTimerWithTimeInterval:60
                                                                target:self
                                                                selector:@selector(removeMinuteOrHour)
                                                                userInfo:nil
                                                                repeats:YES];
        
    [[NSRunLoop mainRunLoop] addTimer:self.minuteHourRemover forMode:NSRunLoopCommonModes];
}

-(void) removeMinuteOrHour
{
    NSLog(@"Reached Here");
    if (iMinute != 0)
    {
        iMinute --;
    }
    else
    {
        iMinute = 59;
        iHour --;
    }
    NSString *remainingTimeLabel;
    if(iHour < 10)
    {
        remainingTimeLabel = [NSString stringWithFormat:@"0%d:", iHour];
    }
    else
    {
        remainingTimeLabel = [NSString stringWithFormat:@"%d:",iHour];
    }
    if (iMinute < 10)
    {
        remainingTimeLabel = [remainingTimeLabel stringByAppendingString:[NSString stringWithFormat:@"0%d",iMinute]];

    }
    else
    {
        remainingTimeLabel = [remainingTimeLabel stringByAppendingString:[NSString stringWithFormat:@"%d",iMinute]];
    }
    self.timeRemainingLabel.text = remainingTimeLabel;
}

- (void) alarmComplete
{
    [self.minuteHourRemover invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.snooozeButton.hidden = NO;
        self.wakeUpButton.hidden = NO;
        self.timeRemainingLabel.text = @"Wake-Up!";
        self.finalAlarmLabel.hidden = YES;
        self.headerLabel.hidden = YES;
        
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
