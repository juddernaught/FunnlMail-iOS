//
//  VIPFunnelCreationConfirmationController.m
//  FunnlMail
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "VIPFunnelCreationConfirmationController.h"
#import "AppDelegate.h"

@interface VIPFunnelCreationConfirmationController ()

@end

@implementation VIPFunnelCreationConfirmationController

#pragma mark -
#pragma mark Lifecycle
- (id)initWithContacts:(NSMutableArray*)contacts
{
    self = [super init];
    if (self) {
        // Custom initialization
        contactMutableArray = contacts;
    }
    return self;
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
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self setUpCustomNavigationBar];
}

#pragma mark -
#pragma mark Helper
- (void)setUpCustomNavigationBar {
    UIView *naviGationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
    [naviGationBar setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 100 - 10, 22, 100, 44)];
    [sampleButton setTitle:@"Done" forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 2)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [naviGationBar addSubview:sampleView];
    sampleView = nil;
    
    [self.view addSubview:naviGationBar];
}

#pragma mark -
#pragma mark Event Handler 
- (void)doneButtonPressed:(UIButton*)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_FUNNEL_POP_UP_ENABLE) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
