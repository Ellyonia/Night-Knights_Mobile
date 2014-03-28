//
//  CreateAccountViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "SetAlarmViewController.h"

@interface CreateAccountViewController ()
@property (strong, nonatomic) IBOutlet UITextField *knightNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) NSUserDefaults* defaults;


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
    // Do any additional setup after loading the view.
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
    
    
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self.knightNameTextField becomeFirstResponder];
    }
    else if (textField == self.knightNameTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    SetAlarmViewController *transferViewController = segue.destinationViewController;
    
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    
}


@end