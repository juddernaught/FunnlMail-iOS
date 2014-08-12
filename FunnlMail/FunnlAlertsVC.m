//
//  FunnlAlertsVC.m
//  FunnlMail
//
//  Created by Pranav Herur on 8/11/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "AppDelegate.h"
#import "FunnlAlertsVC.h"
#import "FunnelService.h"
#import "MainVC.h"

@interface FunnlAlertsVC ()
@end

NSArray * funnls;
UITableView *tableView;
@implementation FunnlAlertsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)SetUp{
    funnls = [[FunnelService instance] allFunnels];
    FunnelModel *temp = [funnls objectAtIndex:1];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
    // Do any additional setup after loading the view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [funnls count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FunnlAlerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set the data for this cell:
    
    cell.textLabel.text = ((FunnelModel*)[funnls objectAtIndex:indexPath.row]).funnelName;
    
    // set the accessory view:
    UISwitch *Switch = [[UISwitch alloc] initWithFrame:CGRectMake(245.0, 8.0, 80.0, 45.0)];
    [Switch addTarget:self action:@selector(switchChanges:) forControlEvents:UIControlEventValueChanged];
    //Switch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [Switch setTag:indexPath.row];
    [cell.contentView addSubview:Switch];
    //cell.accessoryType = Switch;
    
    return cell;
}

-(void)switchChanges:(id)sender{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UISwitch *switchView = sender;
    
    if (switchView.isOn) {
        [switchView setOn:YES animated:YES];
    } else {
        [switchView setOn:NO animated:YES];
    }

}


@end
