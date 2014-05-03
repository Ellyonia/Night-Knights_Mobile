//
//  AlarmSettingsViewController.h
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 4/5/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AlarmSettingsViewController;

@protocol AlarmSettingsViewControllerDelegate <NSObject>
-(void)AlarmSettingsViewControllerDidSave:(AlarmSettingsViewController *) controller;
-(void)AlarmSettingsViewControllerDidCancel:(AlarmSettingsViewController *) controller;

@end

@interface AlarmSettingsViewController : UIViewController

@property (nonatomic, weak) id <AlarmSettingsViewControllerDelegate> delegate;
@property (nonatomic) AVAudioPlayer* audioPlayer;
@property (nonatomic) NSString* pickedAlarm;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;


@end
