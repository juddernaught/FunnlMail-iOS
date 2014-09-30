//
//  FMFunnlStoreViewController.m
//  CSVParser
//
//  Created by shrinivas on 26/09/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "FMFunnlStoreViewController.h"
#import "FMCreateFunnelViewControllers/FMCreateFunnlViewController.h"
@interface FMFunnlStoreViewController ()

@end

@implementation FMFunnlStoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Funnel Store";
    
    // Do any additional setup after loading the view.
    funnlStorageArray = [[NSMutableArray alloc] init];
    funnlStorageAccordingToSection = [[NSMutableArray alloc] init];
    funnlStoreTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 00, 0)];
    funnlStoreTableView.tableFooterView = footerView;
    funnlStoreTableView.delegate = self;
    funnlStoreTableView.dataSource = self;
    [self.view addSubview:funnlStoreTableView];
    [self readFileContent];
    [self parseString];
    [self processAccordingToCategory];
    [funnlStoreTableView reloadData];
}

#pragma mark DELEGATE
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return funnlStorageAccordingToSection.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *tempArray = [funnlStorageAccordingToSection objectAtIndex:section];
    return tempArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    FMFunnlObject *tempObject = [[funnlStorageAccordingToSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    cell.textLabel.text = tempObject.funnelName;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [(FMFunnlObject *)[[funnlStorageAccordingToSection objectAtIndex:section] objectAtIndex:0] categoryName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FMFunnlObject *tempObject = [[funnlStorageAccordingToSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *funnelName = [tempObject funnelName];
    NSMutableArray *senderArray = (NSMutableArray*)[[tempObject senderString] componentsSeparatedByString:@"~"];
    NSMutableArray *subjectArray = (NSMutableArray*)[[tempObject subjectString] componentsSeparatedByString:@"~"];
    NSString *categoryName = [tempObject categoryName];
    
    if(senderArray.count == 1){
        NSString *str = [senderArray objectAtIndex:0];
        if(str.length == 0){
            senderArray = nil;
        }
    }

    if(subjectArray.count == 1){
        NSString *str = [subjectArray objectAtIndex:0];
        if(str.length == 0){
            subjectArray = nil;
        }
    }

    
    NSArray *randomColors = GRADIENT_ARRAY;
    //NSInteger gradientInt = randomColors.count;
    NSInteger gradientInt = arc4random_uniform((uint32_t)randomColors.count);
    NSString *colorString = [randomColors objectAtIndex:gradientInt];
    UIColor *color = [UIColor colorWithHexString:colorString];
    if(color == nil){
        color = [UIColor colorWithHexString:@"#F7F7F7"];
    }
    FunnelModel *funnlModel = [[FunnelModel alloc] initWithBarColor:color filterTitle:funnelName newMessageCount:0 dateOfLastMessage:nil sendersArray:(NSMutableArray *)senderArray subjectsArray:(NSMutableArray *)subjectArray skipAllFlag:NO funnelColor:colorString];

    
    AppDelegate *appDeleage = APPDELEGATE;
    FMCreateFunnlViewController *viewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:senderArray name:nil andSubjects:subjectArray];
    viewController.isEditFunnel = FALSE;
    viewController.shareFunnl = true;
    viewController.oldModel = funnlModel;
    viewController.mainVCdelegate = appDeleage.mainVCdelegate;
    [appDeleage.mainVCdelegate pushViewController:viewController];
    

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT)];
    [returnView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT)];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    titleLabel.text = [(FMFunnlObject *)[[funnlStorageAccordingToSection objectAtIndex:section] objectAtIndex:0] categoryName];
    [returnView addSubview:titleLabel];
    titleLabel = nil;
    return returnView;
}

#pragma mark HELPER
- (void) readFileContent {
    NSString *sampleString = [[NSBundle mainBundle] pathForResource:CSV_FILE_NAME ofType:@"csv"];
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:sampleString encoding:NSUTF8StringEncoding error:&error];
    fileContentString = fileContent;
}

- (void)parseString {
    NSArray *csvComponent = [fileContentString componentsSeparatedByString:@"\n"];
    for (NSString *tuple in csvComponent) {
        NSArray *column = [tuple componentsSeparatedByString:@","];
        FMFunnlObject *tempObject = [[FMFunnlObject alloc] init];
        [tempObject setFunnelName:column[0]];
        [tempObject setSenderString:column[1]];
        [tempObject setSubjectString:column[2]];
        [tempObject setCategoryName:column[3]];
        [funnlStorageArray addObject:tempObject];
    }
}

- (void)processAccordingToCategory {
    for (FMFunnlObject *tempObject in funnlStorageArray) {
        if (funnlStorageAccordingToSection.count) {
            BOOL flag = FALSE;
            for (NSMutableArray *tempArray in funnlStorageAccordingToSection) {
                if ([[[tempArray objectAtIndex:0] categoryName] isEqualToString:tempObject.categoryName]) {
                    [tempArray addObject:tempObject];
                    flag = TRUE;
                    break;
                }
            }
            if (!flag) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                [tempArray addObject:tempObject];
                [funnlStorageAccordingToSection addObject:tempArray];
            }
        }
        else {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObject:tempObject];
            [funnlStorageAccordingToSection addObject:tempArray];
        }
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
