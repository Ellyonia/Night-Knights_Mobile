//
//  LoginViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "LoginViewController.h"
#import "SetAlarmViewController.h"

#define SERVER_URL "http://54.84.248.48"

@interface LoginViewController () <NSURLSessionTaskDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) NSUserDefaults* defaults;
@property (strong,nonatomic) NSURLSession *session;
@property (strong, nonatomic) IBOutlet UILabel *warningLabel;


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



@end
