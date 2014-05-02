//
//  SetAlarmViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "SetAlarmViewController.h"
#import "AlarmRunningViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SetAlarmViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *goToSettingsButton;
@property (strong, nonatomic) IBOutlet UIButton *logOutButton;
@property (strong, nonatomic) IBOutlet UILabel *viewTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *alarmDateTextField;
@property (strong, nonatomic) IBOutlet UIButton *setAlarmButton;


@end

@implementation SetAlarmViewController

NSDate * dateOfAlarm;
- (IBAction)setAlarmPressed:(UIButton *)sender {
    [self.alarmDateTextField becomeFirstResponder];
}



-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.alarmDateTextField setDelegate:self];
    UIColor* backgroundColor = [self createColorWithHexValue:@"#240672"];
    UIColor* buttonColor = [self createColorWithHexValue:@"#7908aa"];

    [self.view setBackgroundColor:backgroundColor];
    [self.logOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goToSettingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logOutButton setBackgroundColor:buttonColor];
    [self.viewTitleLabel setTextColor:[UIColor whiteColor]];
    [self.goToSettingsButton setBackgroundColor:buttonColor];
    [self.startButton setBackgroundColor:buttonColor];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setAlarmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.setAlarmButton setBackgroundColor:buttonColor];
    
    [self.setAlarmButton.layer setCornerRadius:5];
    [self.logOutButton.layer setCornerRadius:5];
    [self.goToSettingsButton.layer setCornerRadius:5];
    [self.startButton.layer setCornerRadius:5];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    NSDate *dateFromPrevious;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *alarmDate = [defaults objectForKey:@"alarmInformation"];
    
    //A User has previously Saved an Alarm Time.
    if(alarmDate){
        dateFromPrevious = alarmDate[0];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"startAlarm"])
    {
        // Send the Alarm time info to the AlarmRunningViewController
        AlarmRunningViewController *transferViewController = segue.destinationViewController;
        transferViewController.alarmDate = dateOfAlarm;
        
        // Save the Alarm to NSUserDefaults
        NSDate *alarmInfo = dateOfAlarm;
        NSArray *alarmTime = [NSArray arrayWithObjects:alarmInfo, nil];
        [self.defaults setObject:alarmTime forKey:@"alarmInformation"];
        [self.defaults synchronize];
    }
    
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    
    // Create a date picker for the date field.
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.maximumDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
    datePicker.minimumDate = [NSDate date];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateDateField:) forControlEvents:UIControlEventValueChanged];
    
    // If the date field has focus, display a date picker instead of keyboard.
    // Set the text to the date currently displayed by the picker.
    if (textField)
    {
        self.alarmDateTextField.inputView = datePicker;
    }
}


// Dismiss the keyboard When the User touches outside of a UITextField.
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(touch.phase==UITouchPhaseBegan){
        //find first response view
        for (UIView *view in [self.view subviews]) {
            if ([view isFirstResponder]) {
                [view resignFirstResponder];
                break;
            }
        }
    }
}



// Called when the date picker changes.
- (void)updateDateField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.alarmDateTextField.inputView;
    self.alarmDateTextField.text = [self formatDate:picker.date];
    dateOfAlarm = picker.date;
    NSLog(@"%@",dateOfAlarm);
}


// Formats the date chosen with the date picker.
- (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterLongStyle];
    [format setDateFormat:@"MMM dd, hh:mm a"];
    
    NSString *formattedDate = [format stringFromDate:date];
    return formattedDate;
}




- (IBAction)unwindToSetAlarm:(UIStoryboardSegue *)unwindSegue
{
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
