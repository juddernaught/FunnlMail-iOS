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
    flagArray = [[NSMutableArray alloc] init];
    for (int counter = 0; counter < funnlStorageAccordingToSection.count; counter++) {
        [flagArray setObject:@"1" atIndexedSubscript:counter];
    }
    
    [funnlStoreTableView reloadData];
}

#pragma mark DELEGATE
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return funnlStorageAccordingToSection.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[flagArray objectAtIndex:section] isEqualToString:@"1"]) {
        NSMutableArray *tempArray = [funnlStorageAccordingToSection objectAtIndex:section];
        return tempArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    FMFunnlObject *tempObject = [[funnlStorageAccordingToSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    cell.textLabel.text = tempObject.funnelName;
    if (tempObject.funnelPreview) {
        cell.detailTextLabel.text = tempObject.funnelPreview;
    }
    else {
        cell.detailTextLabel.text = @"No preview available";
    }
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

    NSString *title = [NSString stringWithFormat: @"Press OK to create the Funnel called %@!", funnelName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             AppDelegate *appDeleage = APPDELEGATE;
                             FMCreateFunnlViewController *viewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:senderArray name:nil andSubjects:subjectArray];
                             viewController.isEditFunnel = FALSE;
                             viewController.shareFunnl = true;
                             viewController.isFunnelStore = YES;
                             viewController.oldModel = funnlModel;
                             viewController.mainVCdelegate = appDeleage.mainVCdelegate;
                             [viewController setUpViewForCreatingFunnel];
                             [viewController saveButtonPressed:nil];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [alert addAction:ok];
    [alert addAction:cancel];
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"Click OK to create your new funnel!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [self presentViewController:alert animated:YES completion:nil];
    /*
    AppDelegate *appDeleage = APPDELEGATE;
    FMCreateFunnlViewController *viewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:senderArray name:nil andSubjects:subjectArray];
    viewController.isEditFunnel = FALSE;
    viewController.shareFunnl = true;
    viewController.isFunnelStore = YES;
    viewController.oldModel = funnlModel;
    viewController.mainVCdelegate = appDeleage.mainVCdelegate;
    [appDeleage.mainVCdelegate pushViewController:viewController];*/
    

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT)];
    [returnView setBackgroundColor:[UIColor colorWithHexString:@"E5E5E5"]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310, STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT)];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    titleLabel.text = [(FMFunnlObject *)[[funnlStorageAccordingToSection objectAtIndex:section] objectAtIndex:0] categoryName];
    [returnView addSubview:titleLabel];
    titleLabel = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT)];
    sampleButton.tag = section;
    [sampleButton addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [returnView addSubview:sampleButton];
    sampleButton = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, STORE_FUNNL_TABLE_VIEW_SECTION_HEIGHT - 1, WIDTH, 1)];
    [sampleButton setBackgroundColor:[UIColor whiteColor]];
    [returnView addSubview:sampleView];
    sampleView = nil;
    
    return returnView;
}

#pragma mark HELPER
- (void)headerClicked:(UIButton *)sender {
    if ([[flagArray objectAtIndex:sender.tag] isEqualToString:@"1"]) {
        [flagArray setObject:@"0" atIndexedSubscript:sender.tag];
    }
    else {
        [flagArray setObject:@"1" atIndexedSubscript:sender.tag];
    }
    [funnlStoreTableView reloadData];
}

- (void) readFileContent {
    NSString *sampleString = [[NSBundle mainBundle] pathForResource:CSV_FILE_NAME ofType:@"csv"];
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:sampleString encoding:NSUTF8StringEncoding error:&error];
    fileContentString = fileContent;
}

- (void)parseString {
    NSArray *csvComponent = [fileContentString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *tuple in csvComponent) {
        if (![tuple isEqualToString:@""]) {
            NSArray *column = [tuple componentsSeparatedByString:@","];
            FMFunnlObject *tempObject = [[FMFunnlObject alloc] init];
            if (column.count > 0 && column[0]) {
                [tempObject setFunnelName:column[0]];
            }
            if (column.count > 1 && column[1]) {
                [tempObject setSenderString:column[1]];
            }
            if (column.count > 2 && column[2]) {
                [tempObject setSubjectString:column[2]];
            }
            if (column.count > 3 && column[3]) {
                [tempObject setCategoryName:column[3]];
            }
            if (column.count > 4 && column[4]) {
                NSString *preview = [column[4] stringByReplacingOccurrencesOfString:@";" withString:@","];
                
                [tempObject setFunnelPreview:preview];
            }
            [funnlStorageArray addObject:tempObject];
        }
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
