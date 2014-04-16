//
//  AlarmSettingsViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 4/5/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "AlarmSettingsViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AlarmSettingsViewController ()

@end

@implementation AlarmSettingsViewController

AVAudioPlayer *audioPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)changeVolume:(UISlider *)sender {
    audioPlayer.volume = sender.value;
    NSLog(@"%f",sender.value);
    
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
