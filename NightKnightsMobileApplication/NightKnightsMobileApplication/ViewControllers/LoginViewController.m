//
//  LoginViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "LoginViewController.h"
#import "SetAlarmViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SERVER_URL "http://54.84.248.48"

@interface LoginViewController () <NSURLSessionTaskDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong,nonatomic) NSURLSession *session;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UILabel *passwordLabel;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *guestLogin;


@end

@implementation LoginViewController

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
    
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    //    UIColor* buttonColor = [self createColorWithHexValue:@"#7908aa"];
    //    UIColor* buttonColor = [self createColorWithHexValue:@"#8C19A5"];
    //    UIColor* buttonColor = [self createColorWithHexValue:@"#C362D8"];
    //    UIColor* buttonColor = [self createColorWithHexValue:@"#68007F"];
    //    UIColor* buttonColor = [self createColorWithHexValue:@"#54F1FE"];
    //    UIColor* buttonColor = [self createColorWithHexValue:@"#2A787F"];
    UIColor* buttonColor = [self createColorWithHexValue:@"#500DFE"];
    UIColor* warningColor = [self createColorWithHexValue:@"#FF684E"];
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.emailLabel.textColor = [UIColor whiteColor];
    self.passwordLabel.textColor = [UIColor whiteColor];
    self.loginButton.backgroundColor=buttonColor;
    self.createAccountButton.backgroundColor=buttonColor;
    self.loginButton.layer.cornerRadius = 5;
    self.createAccountButton.layer.cornerRadius = 5;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.guestLogin setBackgroundColor:buttonColor];
    [self.guestLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.guestLogin.layer setCornerRadius:5];
    [self.warningLabel setTextColor:warningColor];

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
    [super viewWillAppear:animated];
    
    NSArray *texts = [self.defaults objectForKey:@"loginInformation"];
    if(texts){
        self.emailTextField.text = texts[0];
        self.passwordTextField.text = texts[1];
    }
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;

}


// Hide the error message when the User begins typing
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self.warningLabel setHidden:YES];
}

// Function to pass the Keyboard Delegate to the Next UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
     }
    return YES;
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

- (IBAction)loginButtonPushed:(UIButton*)sender {
    
    NSString *baseURL = [NSString stringWithFormat:@"%s/api/login",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"email":self.emailTextField.text,@"password":self.passwordTextField.text};
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         
                                                         NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &error];
                                                         
                                                         
                                                         if ([jsonDictionary[@"success"] isEqual:@1])
                                                         {
                                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                                 [self performSegueWithIdentifier:@"login" sender:self];
                                                            });
                                                         }
                                                         else
                                                         {
                                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                             [self.warningLabel setText:@"Email or Password is incorrect"];
                                                             [self.warningLabel setHidden:NO];
                                                             });
                                                         }
                                                         if (response == nil)
                                                         {
                                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                             [self.warningLabel setText:@"Please Connect to the Internet"];
                                                             [self.warningLabel setHidden:NO];
                                                             });
                                                         }
                                                     }];
    [postTask resume];
}

#pragma mark - Methods for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.warningLabel setHidden:YES];
    
    if([segue.identifier isEqualToString:@"login"])
    {
        NSString *email = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
        
        NSArray *loginInfo = [NSArray arrayWithObjects:email,password, nil];
        
        [self.defaults setObject:loginInfo forKey:@"loginInformation"];
    }
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue
{
}
- (IBAction)cancelCreateAccount:(UIStoryboardSegue *)unwindSegue
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
-(UIColor *) createColorWithHexValue: (NSString *)hexValue withAlpha:(float)alpha
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexValue];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}
@end
