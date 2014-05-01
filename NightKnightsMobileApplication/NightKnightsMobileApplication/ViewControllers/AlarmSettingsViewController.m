//
//  AlarmSettingsViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 4/5/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "AlarmSettingsViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface AlarmSettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate>
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;


@end

@implementation AlarmSettingsViewController

AVAudioPlayer *audioPlayer;
int nameRow = 0 ;
NSArray *alarmTones;
NSArray *alarmNames;
NSString *pickedAlarm;

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor* backgroundColor = [self createColorWithHexValue:@"#240672"];
    UIColor* buttonColor = [self createColorWithHexValue:@"#7908aa"];

    [self.view setBackgroundColor:backgroundColor];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    alarmTones = @[@"/alarmChimes.mp3",@"/birdsChirping.mp3",@"/danceRave.mp3",@"/videogame.mp3",@"/progressiveAnnoyance.mp3",@"/basicAlarm.mp3"];
    alarmNames = @[@"Chimes", @"Chirping Birds", @"Techno", @"VideoGame Theme", @"Random Sounds", @"Standard Alarm"];
    
    NSString *defaultsName;
    NSString *findToneName;
    NSArray *settings = [self.defaults objectForKey:@"alarmSettings"];
    if(settings)
    {
        defaultsName  = settings[0];
        for (int i = 0; i < alarmTones.count ; i++)
        {
            findToneName = alarmTones[i];
            if ([findToneName isEqualToString:defaultsName])
            {
                nameRow = i;
            }
        }
        [self.pickerView selectRow:nameRow inComponent:0 animated:NO];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    

}

-(void) viewWillDisappear:(BOOL)animated
{
    
    NSArray *loginInfo = [NSArray arrayWithObjects:pickedAlarm, nil];
    
    [self.defaults setObject:loginInfo forKey:@"alarmSettings"];
    [audioPlayer stop];
}



- (IBAction)changeVolume:(UISlider *)sender {
    audioPlayer.volume = sender.value;
    
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 6;
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component

{
    return [alarmNames objectAtIndex: row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    pickedAlarm = [alarmTones objectAtIndex:row];
    if (audioPlayer == nil)
    {
    }
    else{
        audioPlayer = nil;
    }
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath],pickedAlarm]];
    NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = 0;
    audioPlayer.volume = 1;
    [audioPlayer setDelegate:self];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
}

-(UIColor *) createColorWithHexValue: (NSString *)hexValue
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexValue];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
