//
//  CreateAccountViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "SetAlarmViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SERVER_URL "http://54.84.248.48"


@interface CreateAccountViewController () <NSURLSessionTaskDelegate>
@property (strong, nonatomic) IBOutlet UITextField *knightNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordCheckTextField;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong,nonatomic) NSURLSession *session;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;
@property (strong, nonatomic) IBOutlet UILabel *viewTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UILabel *passwordLabel;
@property (strong, nonatomic) IBOutlet UILabel *repassLabel;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;


@end

@implementation CreateAccountViewController

NSString *invalidEmailMessage = @"Username or email already exists";
bool passwordsMatch = NO;
bool emailIsValid = NO;

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.knightNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordCheckTextField.delegate = self;
    
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

    [self.createAccountButton.layer setCornerRadius:5];
    [self.cancelButton.layer setCornerRadius:5];
    [self.cancelButton setBackgroundColor: buttonColor];
    [self.createAccountButton setBackgroundColor: buttonColor];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.emailLabel setTextColor:[UIColor whiteColor]];
    [self.viewTitleLabel setTextColor:[UIColor whiteColor]];
    [self.passwordLabel setTextColor:[UIColor whiteColor]];
    [self.repassLabel setTextColor:[UIColor whiteColor]];
    [self.userName setTextColor:[UIColor whiteColor]];
    [self.view setBackgroundColor:backgroundColor];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"createAccount"])
    {
        // Save the Users Login Information to NSUserDefaults
        NSString *email = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
        
        NSArray *loginInfo = [NSArray arrayWithObjects:email,password, nil];
        
        [self.defaults setObject:loginInfo forKey:@"loginInformation"];
    }
}

// Function to pass the Keyboard Delegate to the Next UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
        [self validateEmail:self.emailTextField.text];
    }
    else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self.passwordCheckTextField becomeFirstResponder];
        [self validatePassword:self.passwordTextField.text];
    }
    else if (textField == self.passwordCheckTextField){
        [textField resignFirstResponder];
        [self.knightNameTextField becomeFirstResponder];
        [self checkPasswords:self.passwordTextField.text retypedPassword:self.passwordCheckTextField.text];
    }
    else if (textField == self.knightNameTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)createAccountButton:(UIButton *)sender {
    if (emailIsValid)
    {
        if (passwordsMatch)
        {
            [self createAccount];
        }
        else
        {
            [self.warningLabel setText:@"Please check your Password"];
            [self.warningLabel setHidden:NO];
        }
    }
    else
    {
        [self.warningLabel setText:@"Please check your Email"];
        [self.warningLabel setHidden:NO];
    }
}

// Dismiss the Keyboard when the User touches outside of a UITextField.
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

// Email regex.
- (void) validateEmail: (NSString *) candidate
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    if ([emailTest evaluateWithObject:candidate])
    {
        emailIsValid = YES;
        [self.emailTextField setBackgroundColor: [UIColor whiteColor]];
        [self.warningLabel setHidden:YES];
    }
    else
    {
        self.warningLabel.hidden = NO;
        self.emailTextField.backgroundColor = [UIColor redColor];
        self.warningLabel.text = @"Invalide Email";
    }
}


- (void) checkPasswords: (NSString *)firstPassword retypedPassword:(NSString *)secondPassword
{
    if ([firstPassword isEqualToString:secondPassword] && ![firstPassword isEqualToString:@""])
    {
        passwordsMatch = YES;
        [self.warningLabel setHidden:YES];
    }
    else
    {
        [self.warningLabel setText:@"Password fields must match"];
        self.warningLabel.hidden = NO;
        self.passwordCheckTextField.text = @"";
    }
}

- (void) validatePassword: (NSString *) candidate
{
    NSString *passwordRegex = @"^(?=.{8,}$)(?=.*[a-zA-Z0-9]).*$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", passwordRegex];
    
    if ([passwordTest evaluateWithObject:candidate])
    {
        [self.warningLabel setHidden:YES];
        [self.passwordTextField setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        self.warningLabel.hidden = NO;
        self.passwordTextField.backgroundColor = [UIColor redColor];
        self.warningLabel.text = @"Password needs to be atleast 8 characters";
    }
}

- (void) createAccount
{
    NSString *baseURL = [NSString stringWithFormat:@"%s/api/users",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"email":self.emailTextField.text,@"password":self.passwordTextField.text,@"username":self.knightNameTextField.text};
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         //NSLog(@"11%@",response);
                                                         NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                         NSLog(@"%@",jsonDictionary);
                                                         
                                                         
                                                         if ([jsonDictionary[@"success"] isEqual:@1])
                                                         {
                                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                                 [self performSegueWithIdentifier:@"createAccount" sender:self];                                                         });
                                                         }
                                                         else
                                                         {
                                                             if (response == nil)
                                                             {
                                                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                                                     [self.warningLabel setHidden:NO];
                                                                     [self.warningLabel setText:@"Please connect to the Internet"];
                                                                 });
                                                             }
                                                             if ([jsonDictionary[@"message"] isEqualToString: invalidEmailMessage])
                                                             {
                                                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                                                     [self.warningLabel setHidden:NO];
                                                                     [self.warningLabel setText:@"Email or Knight name is already in use"];
                                                                 });
                                                             }
                                                         }
                                                     }];
    [postTask resume];

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