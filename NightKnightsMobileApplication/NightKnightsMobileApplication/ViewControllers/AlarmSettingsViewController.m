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
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
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
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    alarmTones = @[@"/alarmChimes.mp3",@"/birdsChirping.mp3",@"/danceRave.mp3",@"/videogame.mp3",@"/progressiveAnnoyance.mp3",@"/basicAlarm.mp3"];
    alarmNames = @[@"Chimes", @"Chirping Birds", @"Techo", @"VideoGame Theme", @"Random Sounds", @"Standard Alarm"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultsName;
    NSString *findToneName;
    NSArray *settings = [defaults objectForKey:@"alarmSettings"];
    if(settings)
    {
        defaultsName  = settings[1];
        self.volumeSlider.value = [settings[0] floatValue];
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
    

    // Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSNumber *volume = @(self.volumeSlider.value);
    
    NSArray *loginInfo = [NSArray arrayWithObjects:volume, pickedAlarm, nil];
    
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
    audioPlayer.volume = self.volumeSlider.value;
    [audioPlayer setDelegate:self];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
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
