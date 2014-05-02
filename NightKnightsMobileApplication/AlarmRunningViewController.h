//
//  AlarmRunningViewController.h
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/22/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmRunningViewController : UIViewController

@property (nonatomic) NSDate *alarmDate;
@property (strong,nonatomic) NSURLSession *session;
@property (nonatomic) NSNumber *mEnergy;

@end
