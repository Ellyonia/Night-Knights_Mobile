//
//  AlarmSettingsViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 4/5/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "AlarmSettingsViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface AlarmSettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutlet UIPickerView *alarmTonePicker;


@end

@implementation AlarmSettingsViewController

AVAudioPlayer *audioPlayer;
NSArray *alarmTones;
NSArray *alarmNames;

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    //
    //
    // NOT FINISHED WITH THIS AREA
    //
    //
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *settings = [defaults objectForKey:@"alarmSettings"];
    if(settings){
        self.volumeSlider.value = [settings[0] floatValue];
            }
    alarmTones = @[@"/alarmChimes.mp3",@"/birdsChirping.mp3",@"/danceRave.mp3",@"/videogame.mp3",@"/progressiveAnnoyanceAlarm.mp3",@"/basicAlarm.mp3"];
//    alarmNames
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", [[NSBundle mainBundle] resourcePath]]];
	NSLog(@"%@",url);
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = -1;
	
	if (audioPlayer == nil)
    {
        NSLog(@"%@",error);
    }
	else
		[audioPlayer play];


    //
    //
    // END AREA
    //
    //
    
    
    
    // Do any additional setup after loading the view.
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSNumber *volume = @(self.volumeSlider.value);
    //NSString *password = self.passwordTextField.text;
    
    NSArray *loginInfo = [NSArray arrayWithObjects:volume, nil];
    
    [self.defaults setObject:loginInfo forKey:@"alarmSettings"];
}



- (IBAction)changeVolume:(UISlider *)sender {
    audioPlayer.volume = sender.value;
    NSLog(@"%f",sender.value);
    
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
    return [alarmTones objectAtIndex: component];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    NSString *data = [alarmTones objectAtIndex:row];
    //NSLog(@"%@",data);
    
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
