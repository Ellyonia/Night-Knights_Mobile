//
//  LoginViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) NSUserDefaults* defaults;


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
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *texts = [defaults objectForKey:@"loginInformation"];
    NSLog(@" %@ %@",texts[0], texts[1]);
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
    bool synch = [self.defaults synchronize];
    NSLog(@" %@ %@", loginInfo[0],loginInfo[1]);
    NSLog(@" %i", synch);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"hello");
    
    
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
     }
    return YES;
}

@end
