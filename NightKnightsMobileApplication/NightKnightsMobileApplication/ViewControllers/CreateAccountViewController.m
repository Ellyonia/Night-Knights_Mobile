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
@property (strong, nonatomic) NSNumber *value;
@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSNumber *dsid;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSArray *loginInfo = [NSArray arrayWithObjects:email,password, nil];
    
    [self.defaults setObject:loginInfo forKey:@"loginInformation"];
    [self.defaults synchronize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSLog(@"asdf:");
    if (textField == self.emailTextField) {
        NSLog(@"email");
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        NSLog(@"pass");
        [textField resignFirstResponder];
        [self.passwordCheckTextField becomeFirstResponder];
    }
    else if (textField == self.passwordCheckTextField){
        NSLog(@"check");
        [textField resignFirstResponder];
        [self.knightNameTextField becomeFirstResponder];
    }
    else if (textField == self.knightNameTextField) {
        NSLog(@"knight");
        [textField resignFirstResponder];
        //[self.passwordCheckTextField becomeFirstResponder];
    }
    NSLog(@"end");
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    self.warningLabel.hidden = YES;
}

- (IBAction)createAccountButton:(UIButton *)sender {
    // an example for sending some data as JSON in the HTTP body
    // setup the url
    NSString *originalPass = self.passwordTextField.text;
    NSString *retypedPass = self.passwordCheckTextField.text;
    if ([originalPass isEqualToString:retypedPass])
    {
        NSString *baseURL = [NSString stringWithFormat:@"%s/api/users",SERVER_URL];
        NSURL *postUrl = [NSURL URLWithString:baseURL];
        
        // data to send in body of post request (send arguments as json)
        NSError *error = nil;
        NSDictionary *jsonUpload = @{@"email":self.emailTextField.text,@"password":self.passwordTextField.text,@"username":self.knightNameTextField.text};
        NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
        
        // create a custom HTTP POST request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
        NSLog(@"%@",request);
        NSLog(@"%@",baseURL);
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:requestBody];
        
        // start the request, print the responses etc.
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
    else{
        self.warningLabel.hidden = NO;
        self.passwordCheckTextField.text = @"";
        self.passwordTextField.text = @"";
    }
}

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


@end