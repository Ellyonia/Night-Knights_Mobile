//
//  CreateAccountViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "SetAlarmViewController.h"

#define SERVER_URL "http://54.84.248.48"


@interface CreateAccountViewController () <NSURLSessionTaskDelegate>
@property (strong, nonatomic) IBOutlet UITextField *knightNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordCheckTextField;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong,nonatomic) NSURLSession *session;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;


@end

@implementation CreateAccountViewController


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
    }
    else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self.passwordCheckTextField becomeFirstResponder];
    }
    else if (textField == self.passwordCheckTextField){
        [textField resignFirstResponder];
        [self.knightNameTextField becomeFirstResponder];
    }
    else if (textField == self.knightNameTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

// Hide the error message when the User begins typing
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    self.warningLabel.hidden = YES;
}

- (IBAction)createAccountButton:(UIButton *)sender {
    // an example for sending some data as JSON in the HTTP body
    // setup the url
    NSString *originalPass = self.passwordTextField.text;
    NSString *retypedPass = self.passwordCheckTextField.text;
    NSString *email = self.emailTextField.text;
    
    if ([self validateEmail:email])
    {
        if ([originalPass isEqualToString:retypedPass])
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
                                                                 if ([jsonDictionary[@"success"] isEqual:@1]){
                                                                     NSLog(@"hi");
                                                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"hi");
                                                                     [self performSegueWithIdentifier:@"createAccount" sender:self];                                                         });
                                                                 }
                                                             }];
            [postTask resume];
        }
        else // If Passwords are mismatched clear the Password UITextFields
        {
            self.warningLabel.hidden = NO;
            self.passwordCheckTextField.text = @"";
            self.passwordTextField.text = @"";
        }
    }
    else // If Email regex failed.
    {
        self.warningLabel.hidden = NO;
        self.emailTextField.backgroundColor = [UIColor redColor];
        self.warningLabel.text = @"Invalide Email";
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
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
@end