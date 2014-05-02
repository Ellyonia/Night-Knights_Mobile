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
@property (strong, nonatomic) IBOutlet UIButton *returnToSetAlarm;
@property (strong, nonatomic) IBOutlet UILabel *viewTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *stopSound;


@end

@implementation AlarmSettingsViewController

AVAudioPlayer *audioPlayer;
int nameRow = 0 ;
NSArray *alarmTones;
NSArray *alarmNames;
NSString *pickedAlarm = @"/alarmChimes.mp3";

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
    
}

- (IBAction)stopSoundPressed:(UIButton *)sender {
    [audioPlayer stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor* backgroundColor = [self createColorWithHexValue:@"#240672"];
    UIColor* buttonColor = [self createColorWithHexValue:@"#7908aa"];
    
    [self.returnToSetAlarm setBackgroundColor:buttonColor];
    [self.returnToSetAlarm.layer setCornerRadius:5];
    [self.returnToSetAlarm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewTitleLabel setTextColor:[UIColor whiteColor]];
    [self.stopSound setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.stopSound setBackgroundColor:buttonColor];
    [self.stopSound.layer setCornerRadius:5];

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
    - (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
    {
        NSString *title = [alarmNames objectAtIndex:row];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        return attString;
        
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
