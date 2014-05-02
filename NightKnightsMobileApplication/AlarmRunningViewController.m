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

@interface AlarmRunningViewController () <NSURLSessionTaskDelegate , AVAudioSessionDelegate, AVAudioPlayerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *cancelAlarm;
@property (strong, nonatomic) IBOutlet UILabel *timeRemainingLabel;
@property (strong, nonatomic) IBOutlet UIButton *wakeUpButton;
@property (strong, nonatomic) IBOutlet UIButton *snooozeButton;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic) NSTimer *alarm;
@property (strong, nonatomic) NSNumber *value;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSString *toneLocal;
@property (nonatomic) UILocalNotification* localNotif;
@property (nonatomic) UILocalNotification* localNotif2;



@end

@implementation AlarmRunningViewController

NSString *soundLocation;

-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer)
    {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath],@"/basicAlarm.mp3"]];
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 5;
    }
    return _audioPlayer;
}

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
    
}
- (IBAction)wakeUpButtonPushed:(id)sender
{
    [self.audioPlayer stop];
    energyGained = (int)((double)timeRemaining)/100.0*(1.0-((double)snoozeCount*0.05));

    NSString *baseURL = [NSString stringWithFormat:@"%s/api/character/energy",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"energy":@(energyGained)};
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:requestBody];

    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            
                                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                                            [self performSegueWithIdentifier:@"wakeUpButtonPushed" sender:self];                                                         });
                                                        }];
    
    [postTask resume];

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification * alertEnergy = [[UILocalNotification alloc]init];
    alertEnergy.alertAction = @"View";
    alertEnergy.alertBody = [NSString stringWithFormat:@"You gained %i Energy! Go to 54.84.248.48 to play!",energyGained ];
    alertEnergy.applicationIconBadgeNumber = 1;
    alertEnergy.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:alertEnergy];
}

int snoozeCount = -1;
int timeRemaining = 0;
int iHour = 0;
int iMinute = 0;
int second = 0;
int energyGained = 0;


- (IBAction)snoozedPressed:(UIButton *)sender {
    [self.audioPlayer stop];
    self.snooozeButton.hidden = YES;
    self.cancelAlarm.hidden = YES;
    self.wakeUpButton.hidden = NO;
    self.headerLabel.hidden = NO;
    self.headerLabel.text = @"Snoozing for";
    self.timeRemainingLabel.text = @"5 Minutes";
    second = 0;
    NSTimer *isSnoozing = [NSTimer scheduledTimerWithTimeInterval:300
                                                      target:self
                                                    selector:@selector(alarmComplete)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:isSnoozing forMode:NSRunLoopCommonModes];
    snoozeCount ++;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    NSDate *snoozeNotif = [NSDate dateWithTimeInterval:300 sinceDate:[NSDate date]];
    localNotif.fireDate = snoozeNotif;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertAction = @"View";
    localNotif.alertBody = @"Wake up!";
    localNotif.applicationIconBadgeNumber = 1;
    localNotif.soundName = soundLocation;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    snoozeNotif = [NSDate dateWithTimeInterval:30 sinceDate:snoozeNotif];
    UILocalNotification *localNotif2 = [[UILocalNotification alloc] init];
    if (localNotif2 == nil)
        return;
    localNotif2.fireDate = snoozeNotif;
    localNotif2.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif2.alertAction = @"View";
    localNotif2.alertBody = @"Wake up!";
    localNotif2.applicationIconBadgeNumber = 1;
    localNotif2.soundName = soundLocation;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif2];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    NSArray *settings = [self.defaults objectForKey:@"alarmSettings"];
    if(settings)
    {
        soundLocation = settings[0];
        self.audioPlayer = nil;
        NSString *urlEnding = [NSString stringWithString:settings[0]];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath],urlEnding]];
        NSError *error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.volume = 1;
        self.audioPlayer.numberOfLoops = 5;

        
    }
    
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.timeoutIntervalForResource = 8.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    
    UIColor* backgroundColor = [self createColorWithHexValue:@"#240672"];
    UIColor* buttonColor = [self createColorWithHexValue:@"#7908aa"];
    
    [self.cancelAlarm setBackgroundColor:buttonColor];
    [self.cancelAlarm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.wakeUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.snooozeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.snooozeButton setBackgroundColor:buttonColor];
    [self.wakeUpButton setBackgroundColor:buttonColor];
    [self.headerLabel setTextColor:[UIColor whiteColor]];
    [self.timeRemainingLabel setTextColor:[UIColor whiteColor]];
    [self.cancelAlarm.layer setCornerRadius:5];
    [self.snooozeButton.layer setCornerRadius:5];
    [self.wakeUpButton.layer setCornerRadius:5];
    

    [self.view setBackgroundColor:backgroundColor];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSDate* convertedAlarmDate = self.alarmDate;
    self.alarmDate = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:self.alarmDate];
    NSString *stringDate = [NSString stringWithFormat:@"%@",self.alarmDate];
    NSString *timeWithSeconds = [self getSubstring:stringDate betweenString:@" "];
    NSString *timeNoSeconds = [timeWithSeconds substringToIndex:5];
    NSString *labelText = @"";
    
    NSString *timePart = [timeNoSeconds substringToIndex:3];
    int alarmHour = (int)[timePart integerValue];
    timePart = [timeNoSeconds substringFromIndex:3];
    int alarmMinute = (int)[timePart integerValue];
    
    if (alarmHour < 12)
    {
        if (alarmHour == 0)
        {
            if (alarmMinute > 9){
            NSString *time = [NSString stringWithFormat:@"12:%d",alarmMinute];
            labelText = [labelText stringByAppendingString:time];
            labelText = [labelText stringByAppendingString:@" AM"];
            }
            else
            {
                NSString *time = [NSString stringWithFormat:@"12:0%d",alarmMinute];
                labelText = [labelText stringByAppendingString:time];
                labelText = [labelText stringByAppendingString:@" AM"];
            }
        }
        else
        {
                if (alarmMinute > 9){
                    NSString *time = [NSString stringWithFormat:@"%d:%d",alarmHour,alarmMinute];
                    labelText = [labelText stringByAppendingString:time];
                    labelText = [labelText stringByAppendingString:@" AM"];
                }
                else
                {
                    NSString *time = [NSString stringWithFormat:@"%d:0%d",alarmHour,alarmMinute];
                    labelText = [labelText stringByAppendingString:time];
                    labelText = [labelText stringByAppendingString:@" AM"];
                }
        }
    }
    else
    {
        if (alarmHour == 12)
        {
            if (alarmMinute > 9){
                NSString *time = [NSString stringWithFormat:@"12:%d",alarmMinute];
                labelText = [labelText stringByAppendingString:time];
                labelText = [labelText stringByAppendingString:@" PM"];
            }
            else
            {
                NSString *time = [NSString stringWithFormat:@"12:0%d",alarmMinute];
                labelText = [labelText stringByAppendingString:time];
                labelText = [labelText stringByAppendingString:@" PM"];
            }
        }
        else
        {
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
    }
    self.timeRemainingLabel.text = labelText;
    
    NSDate *now = [NSDate date];
    NSDate *convertedNow = [NSDate dateWithTimeInterval:-60*60*5 sinceDate:now];
    NSString *sSeconds = [NSString stringWithFormat:@"%@",self.alarmDate];
    sSeconds = [self getSubstring:sSeconds betweenString:@" "];
    sSeconds = [sSeconds substringFromIndex:6];
    second = (int)[sSeconds integerValue];
    
    NSTimeInterval alarmRunTime = [self.alarmDate timeIntervalSinceDate: convertedNow];
    timeRemaining = (int)alarmRunTime - second;
    
    convertedAlarmDate = [NSDate dateWithTimeInterval:-second sinceDate:convertedAlarmDate];

    
    // Checks to see if you want an alarm time for the morning.
    if (timeRemaining < 0)
        timeRemaining = timeRemaining + 60*60*24;
    
    
    
    
    self.alarm = [NSTimer scheduledTimerWithTimeInterval:timeRemaining
                   target:self
                   selector:@selector(alarmComplete)
                   userInfo:nil
                   repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.alarm forMode:NSRunLoopCommonModes];
    
    
    
    
    
    self.localNotif = [[UILocalNotification alloc] init];
    if (self.localNotif == nil)
        return;
    self.localNotif.fireDate = convertedAlarmDate;
    NSLog(@"%@",convertedAlarmDate);
    self.localNotif.timeZone = [NSTimeZone defaultTimeZone];

    self.localNotif.alertAction = @"View";
    self.localNotif.alertBody = @"Wake Up!";
    self.localNotif.applicationIconBadgeNumber = 1;
    self.localNotif.soundName = soundLocation;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotif];
    
    convertedAlarmDate = [NSDate dateWithTimeInterval:30 sinceDate:convertedAlarmDate];
    self.localNotif2 = [[UILocalNotification alloc] init];
    if (self.localNotif2 == nil)
        return;
    self.localNotif2.fireDate = convertedAlarmDate;
    self.localNotif2.timeZone = [NSTimeZone defaultTimeZone];

    self.localNotif2.alertAction = @"View";
    self.localNotif2.alertBody = @"Wake Up!";
    self.localNotif2.applicationIconBadgeNumber = 1;
    self.localNotif2.soundName = soundLocation;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotif2];
}

- (void) alarmComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.snooozeButton.hidden = NO;
        self.wakeUpButton.hidden = NO;
        self.timeRemainingLabel.text = @"Wake-Up!";
        self.headerLabel.hidden = YES;
        self.cancelAlarm.hidden = YES;
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
    });
}


- (NSString *)getSubstring:(NSString *)value betweenString:(NSString *)separator
{
    NSRange firstInstance = [value rangeOfString:separator];
    NSRange secondInstance = [[value substringFromIndex:firstInstance.location + firstInstance.length] rangeOfString:separator];
    NSRange finalRange = NSMakeRange(firstInstance.location + separator.length, secondInstance.location);
    
    return [value substringWithRange:finalRange];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Cancel the current alarms running.
    if([segue.identifier isEqualToString:@"cancelAlarm"])
    {
        [self.alarm invalidate];
        [self.audioPlayer stop];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] cancelLocalNotification:self.localNotif];
        [[UIApplication sharedApplication] cancelLocalNotification:self.localNotif2];
        
    }
}

-(UIColor *) createColorWithHexValue: (NSString *)hexValue
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexValue];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
