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
@property (strong, nonatomic) NSNumber *value;
@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSNumber *dsid;


@end

@implementation LoginViewController

bool loginSuccessful;

-(NSUserDefaults *) defaults{
    if(!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.value = @(0.5);
    _dsid = @1;
    
    //setup NSURLSession (ephemeral)
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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *texts = [defaults objectForKey:@"loginInformation"];
    if(texts){
        self.emailTextField.text = texts[0];
        self.passwordTextField.text = texts[1];
    }
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;

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
}

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
    
    // an example for sending some data as JSON in the HTTP body
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/api/login",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    // data to send in body of post request (send arguments as json)
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"email":self.emailTextField.text,@"password":self.passwordTextField.text};
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    NSLog(@"%@",request);
    NSLog(@"%@",baseURL);
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    NSLog(@"%@",self.session);
    
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         //NSLog(@"11%@",response);
                                                         NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                         NSLog(@"%@",jsonDictionary);
                                                         NSLog(@"%@",jsonDictionary[@"success"]);
                                                         if ([jsonDictionary[@"success"] isEqual:@1]){
                                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                                             [self performSegueWithIdentifier:@"loginSuccess" sender:self];                                                         });
                                                         }
                                                     }];
    [postTask resume];
}

@end
