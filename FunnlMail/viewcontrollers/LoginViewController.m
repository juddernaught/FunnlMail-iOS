//
//  LoginViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 4/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "LoginViewController.h"
#import "MainVC.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    self.view.backgroundColor = [UIColor whiteColor];

    UITextField *username = [[UITextField alloc] init];
    username.placeholder = @"Email Address";
    UITextField *password = [[UITextField alloc] init];
    password.secureTextEntry = YES;
    password.placeholder = @"Password";
    username.borderStyle = UITextBorderStyleRoundedRect;
    password.borderStyle = UITextBorderStyleRoundedRect;

    //username.frame = CGRectMake(40, , <#CGFloat width#>, <#CGFloat height#>)
    username.frame = CGRectMake(100, 100, 100, 50);
    password.frame = CGRectMake(100, 200, 100, 50);
    [self.view addSubview:username];
    [self.view addSubview:password];
    
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [enterButton setTitle:@"Done" forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(doneButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    enterButton.frame = CGRectMake(100, 400, 100, 50);

    [self.view addSubview:enterButton];
    

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:username attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:username attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:300.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonSelected {
    MainVC *mainvc = [[MainVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainvc];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
