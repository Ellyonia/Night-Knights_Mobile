//
//  CreateAccountViewController.m
//  NightKnightsMobileApplication
//
//  Created by Cameron Keith on 3/20/14.
//  Copyright (c) 2014 DreamTeam. All rights reserved.
//

#import "CreateAccountViewController.h"

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


- (IBAction)createAccount:(UIButton *)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSArray *loginInfo = [NSArray arrayWithObjects:email,password, nil];
    
    [self.defaults setObject:loginInfo forKey:@"loginInformation"];
    [self.defaults synchronize];

    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//- (IBAction)load
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSArray *texts = [defaults objectForKey:@"items"];
//    for(NSString *currentText in texts)
//    {
//        [self setTheTextOfLabelWith:currentText];
//    }
//}
//
//- (void)savingData
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSMutableArray *textToSave = [[NSMutableArray alloc] init];
//    for(UILabel *currentLabel in _objects)
//    {
//        [textToSave addObject:currentLabel.text];
//    }
//    
//    [defaults setObject:textToSave forKey:@"items"];
//    [defaults synchronize];
//}
@end