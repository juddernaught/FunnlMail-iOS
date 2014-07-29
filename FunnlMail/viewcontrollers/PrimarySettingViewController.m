//
//  PrimarySettingViewController.m
//  FunnlMail
//
//  Created by Macbook on 7/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "PrimarySettingViewController.h"

@interface PrimarySettingViewController ()

@end

@implementation PrimarySettingViewController
@synthesize mainVCdelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEIGHT)];
//        view.backgroundColor = WHITE_CLR;
//        [self.view addSubview:view];

    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    
    switchArray = [[NSMutableArray alloc] init];
    categoryArray = [[NSMutableArray alloc] init];
    
    self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, HEIGHT);
    self.view.backgroundColor = WHITE_CLR;

    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 70, WIDTH - 16, 30)];
    headingLabel.backgroundColor = CLEAR_COLOR;
    headingLabel.textColor = BLACK_CLR;
    headingLabel.textAlignment = NSTextAlignmentLeft;
    headingLabel.font = [UIFont boldSystemFontOfSize:20];
    headingLabel.text = ALL_FUNNL;
    [self.view addSubview:headingLabel];
    
    UILabel *subtitleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 100, 160 - 16, 30)];
    subtitleLabel1.backgroundColor = CLEAR_COLOR;
    subtitleLabel1.textColor = DARKEST_GRAY_COLOR;
    subtitleLabel1.textAlignment = NSTextAlignmentLeft;
    subtitleLabel1.font = [UIFont boldSystemFontOfSize:17];
    subtitleLabel1.text = @"Categories:";
    [self.view addSubview:subtitleLabel1];
    
    UILabel *subtitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(160 + 8, 95, 160 - 16, 30)];
    subtitleLabel2.backgroundColor = CLEAR_COLOR;
    subtitleLabel2.textColor = DARKEST_GRAY_COLOR;
    subtitleLabel2.textAlignment = NSTextAlignmentRight;
    subtitleLabel2.font = [UIFont systemFontOfSize:17];
    subtitleLabel2.text = @"Include?";
    [self.view addSubview:subtitleLabel2];
    
    UILabel *seperatorLabel = [[UILabel alloc] initWithFrame:CGRectMake( 8, 130, 320 - 16, 1)];
    seperatorLabel.backgroundColor = LIGHT_TEXT_COLOR;
    [self.view addSubview:seperatorLabel];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    settingsDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRIMARY_SETTING"];
    if(settingsDictionary == nil){
        settingsDictionary = [[NSMutableDictionary alloc] init];
        [settingsDictionary setObject:@"0" forKey:@"Social"];
        [settingsDictionary setObject:@"0" forKey:@"Promotions"];
        [settingsDictionary setObject:@"0" forKey:@"Updates"];
        [settingsDictionary setObject:@"0" forKey:@"Forums"];
        [[NSUserDefaults standardUserDefaults] setObject:settingsDictionary forKey:@"PRIMARY_SETTING"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSInteger count = 0;
    for (NSString *key in settingsDictionary.allKeys) {
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 140 + (count*40), 160 - 16, 30)];
        categoryLabel.backgroundColor = CLEAR_COLOR;
        categoryLabel.textColor = DARKEST_GRAY_COLOR;
        categoryLabel.textAlignment = NSTextAlignmentLeft;
        categoryLabel.font = [UIFont boldSystemFontOfSize:17];
        categoryLabel.text = key;
        [self.view addSubview:categoryLabel];
        
        UISwitch *categorySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 60, 140 + (count*40), 80, 30)];
        categorySwitch.tag = count;
        NSInteger value = [[settingsDictionary objectForKey:key] integerValue];
        [categorySwitch setOn:value animated:YES];
        [self.view addSubview:categorySwitch];
        [switchArray addObject:categorySwitch];
        [categoryArray addObject:key];
        
        count++;
    }
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

-(void)saveButtonPressed
{
    NSInteger count = 0;
    for (NSString *category in categoryArray) {
        UISwitch *categorySwitch = [switchArray objectAtIndex:count];
        NSInteger value = categorySwitch.isOn;
        [settingsDictionary setObject:[NSString stringWithFormat:@"%d",value] forKey:category];
        count++;
    }
    [[NSUserDefaults standardUserDefaults] setObject:settingsDictionary forKey:@"PRIMARY_SETTING"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshData{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSInteger count = 0;
    for (NSString *category in categoryArray) {
        UISwitch *categorySwitch = [switchArray objectAtIndex:count];
        NSInteger value = [[settingsDictionary objectForKey:category] integerValue];
        [categorySwitch setOn:value animated:YES];
        count++;
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
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
