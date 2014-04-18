//
//  AlarmRunningViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/22/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "AlarmRunningViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define SERVER_URL "http://54.84.248.48"

@interface AlarmRunningViewController () <NSURLSessionTaskDelegate>
@property (strong, nonatomic) IBOutlet UILabel *finalAlarmLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (strong, nonatomic) IBOutlet UIButton *wakeUpButton;
@property (strong, nonatomic) IBOutlet UIButton *snooozeButton;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic) NSTimer * minuteHourRemover;
@property (nonatomic) NSTimer *alarm;
@property (strong, nonatomic) NSNumber *value;


@end

@implementation AlarmRunningViewController

- (IBAction)wakeUpButtonPushed:(id)sender
{
    energyGained = timeRemaining/100*(1-(snoozeCount*0.05));
    NSLog(@"Energy gained: %i",energyGained);

    NSString *baseURL = [NSString stringWithFormat:@"%s/api/character/energy",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    // data to send in body of post request (send arguments as json)
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"energy":@(energyGained)};
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:requestBody];
    NSLog(@"%@",self.session);
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            
                                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                                            [self performSegueWithIdentifier:@"wakeUpButtonPushed" sender:self];                                                         });
                                                        }];
    
    [postTask resume];

    
}

AVAudioPlayer *audioPlayer;
int snoozeCount = -1;
bool alarmStillRunning = YES;
int timeRemaining = 0;int iHour = 0;
int iMinute = 0;
int second = 0;
int energyGained = 0;
int systemSoundID  = 1304;


- (IBAction)snoozedPressed:(UIButton *)sender {
    self.snooozeButton.hidden = YES;
    self.wakeUpButton.hidden = YES;
    self.headerLabel.hidden = NO;
    self.headerLabel.text = @"Snoozing for";
    self.timeRemainingLabel.text = @"05:00";
    second = 0;
    NSTimer *isSnoozing = [NSTimer scheduledTimerWithTimeInterval:300
                                                      target:self
                                                    selector:@selector(alarmComplete)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:isSnoozing forMode:NSRunLoopCommonModes];
    self.minuteHourRemover = [NSTimer scheduledTimerWithTimeInterval:1
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
    
    
    //setup NSURLSession (ephemeral)
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.timeoutIntervalForResource = 8.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    self.alarmDate = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:self.alarmDate];
    NSString *stringDate = [NSString stringWithFormat:@"%@",self.alarmDate];
    NSString *timeWithSeconds = [self getSubstring:stringDate betweenString:@" "];
    NSString *timeNoSeconds = [timeWithSeconds substringToIndex:5];
    NSString *labelText = @"Until: ";
    
    NSString *timePart = [timeNoSeconds substringToIndex:3];
    int alarmHour = (int)[timePart integerValue];
    timePart = [timeNoSeconds substringFromIndex:3];
    int alarmMinute = (int)[timePart integerValue];
    
    NSLog(@"AlarmHour%i",alarmHour);
    if (alarmHour < 13)
    {
        NSLog(@"Reached Here2");
        if (alarmMinute > 9){
        NSString *time = [NSString stringWithFormat:@"%d:%d",alarmHour,alarmMinute];
        labelText = [labelText stringByAppendingString:time];
        labelText = [labelText stringByAppendingString:@" AM"];
        }
        else{
            NSString *time = [NSString stringWithFormat:@"%d:0%d",alarmHour,alarmMinute];
            labelText = [labelText stringByAppendingString:time];
            labelText = [labelText stringByAppendingString:@" AM"];
        }
    }
    else
    {
        NSLog(@"Reached Here1");
        if (alarmMinute > 9){
            NSString *time = [NSString stringWithFormat:@"%d:%d",(alarmHour-12),alarmMinute];
            labelText = [labelText stringByAppendingString:time];
            labelText = [labelText stringByAppendingString:@" PM"];
        }
        else{
            NSString *time = [NSString stringWithFormat:@"%d:0%d",(alarmHour-12),alarmMinute];
            labelText = [labelText stringByAppendingString:time];
            labelText = [labelText stringByAppendingString:@" PM"];
        }
    }
    self.finalAlarmLabel.text = labelText;
    
    NSDate *now = [NSDate date];
    NSDate *convertedNow = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:now];
    NSString *sSeconds = [NSString stringWithFormat:@"%@",self.alarmDate];
    sSeconds = [self getSubstring:sSeconds betweenString:@" "];
    sSeconds = [sSeconds substringFromIndex:6];
    second = (int)[sSeconds integerValue];
    
    NSTimeInterval alarmRunTime = [self.alarmDate timeIntervalSinceDate: convertedNow];
    timeRemaining = (int)alarmRunTime - second;
    
    // Checks to see if you want an alarm time for the morning.
    if (timeRemaining < 0)
        timeRemaining = timeRemaining + 60*60*24;
    
    iHour = (int)timeRemaining/(60*60);
    iMinute = timeRemaining%3600 / 60 + 1;
    
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
    
    self.alarm = [NSTimer scheduledTimerWithTimeInterval:timeRemaining
                                                          target:self
                                                        selector:@selector(alarmComplete)
                                                        userInfo:nil
                                                        repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.alarm forMode:NSRunLoopCommonModes];

    sSeconds = [NSString stringWithFormat:@"%@",convertedNow];
    sSeconds = [self getSubstring:sSeconds betweenString:@" "];
    sSeconds = [sSeconds substringFromIndex:6];
    second = (int)[sSeconds integerValue] + 1;
    self.minuteHourRemover = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                            selector:@selector(removeMinuteOrHour)
                                                            userInfo:nil
                                                            repeats:YES];
                              
    
    [[NSRunLoop mainRunLoop] addTimer:self.minuteHourRemover forMode:NSRunLoopCommonModes];
}

-(void) removeMinuteOrHour
{
    NSLog(@"%i",second);
    if (second == 60)
    {
        AudioServicesPlaySystemSound (systemSoundID);
        if (iMinute != 0)
        {
            iMinute --;
        }
        else
        {
            iMinute = 59;
            iHour --;
        }
        second = 1;
    }
    else
    {
        second ++;
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
        AudioServicesPlaySystemSound (systemSoundID);

        
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
    //Cancel the current alarms running.
    if([segue.identifier isEqualToString:@"cancel"])
    {
        [self.minuteHourRemover invalidate];
        [self.alarm invalidate];
        NSLog(@"Alarm Exiting");
    }
//    if([segue.identifier isEqualToString:@"wakeUp"])
//    {
////       //    }
}


@end
