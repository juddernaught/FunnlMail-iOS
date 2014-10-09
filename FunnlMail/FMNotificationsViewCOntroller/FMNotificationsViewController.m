//
//  FMNotificationsViewController.m
//  FunnlMail
//
//  Created by shrinivas on 09/10/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FMNotificationsViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "MessageFilterXRefService.h"
#import "EmailService.h"

@interface FMNotificationsViewController ()

@end

@implementation FMNotificationsViewController

#pragma mark -
#pragma mark LifeCycle
- (void)viewWillAppear:(BOOL)animated {
  //[self.view setBackgroundColor:NOTIFICATION_VIEW_CONTROLLER_BACKGROUND];
  [self.view setBackgroundColor:[UIColor whiteColor]];
  //[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self fillDataSource];
  self.title = @"Alerts";
  notificationsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
  notificationsTable.delegate = self;
  notificationsTable.dataSource = self;
  notificationsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
  randomColors = GRADIENT_ARRAY;
  /*UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 40)];
  UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, WIDTH - 80, 40)];
  [sampleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
  sampleLabel.text = @"Skip All Notifications";
  [sampleLabel setTextColor:[UIColor blackColor]];
  sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  sampleLabel.numberOfLines = 1;
  [sampleLabel setBackgroundColor:[UIColor clearColor]];
  [sampleLabel setTextAlignment:NSTextAlignmentLeft];
  [headerView addSubview:sampleLabel];
  notificationsTable.tableHeaderView = headerView;
  headerView = nil;
  sampleLabel = nil;*/
  [self.view addSubview:notificationsTable];
}

#pragma mark -
#pragma mark UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 60)];
  [headerView setBackgroundColor:[UIColor colorWithHexString:@"EFEFEF"]];
  UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, WIDTH - 80, 60)];
  [sampleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
  sampleLabel.text = @"Skip All Notifications";
  [sampleLabel setTextColor:[UIColor blackColor]];
  sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  sampleLabel.numberOfLines = 1;
  [sampleLabel setBackgroundColor:[UIColor clearColor]];
  [sampleLabel setTextAlignment:NSTextAlignmentLeft];
  [headerView addSubview:sampleLabel];
  UISwitch *switchForNotification = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 40 - 20, 6 + 7, 40, 20)];
  switchForNotification.tag = -1;
  [switchForNotification addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"all_notificatio"] isEqualToString:@"1"]) {
    [switchForNotification setOn:YES];
  }
  else {
    [switchForNotification setOn:NO];
  }
  
  UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 59, WIDTH, 1)];
  [sampleView setBackgroundColor:[UIColor lightGrayColor]];
  [headerView addSubview:sampleView];
  sampleView = nil;
  
  [headerView addSubview:switchForNotification];
  return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"notification_cell";
  FMNotificationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[FMNotificationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  [cell setTextToLabel:[(FunnelModel*)dataSource[indexPath.row] funnelName]];
  [cell setBoolForSwitch:[(FunnelModel*)dataSource[indexPath.row] notificationsFlag]];
  [cell setTagForSwitch:(int)indexPath.row];
  [cell.notificationSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"all_notificatio"] isEqualToString:@"1"]) {
    [cell.notificationSwitch setUserInteractionEnabled:NO];
    [cell.funnelName setTextColor:[UIColor lightGrayColor]];
  }
  else {
    [cell.notificationSwitch setUserInteractionEnabled:YES];
    [cell.funnelName setTextColor:[UIColor blackColor]];
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Event Handler 
- (void)switchValueChanged:(UISwitch *)sender {
  if (sender.tag == -1) {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"all_notificatio"] isEqualToString:@"0"]) {
      [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"all_notificatio"];
      [[NSUserDefaults standardUserDefaults] synchronize];
      NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
      [((AppDelegate *)[[UIApplication sharedApplication] delegate]).contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
        NSString *webhook_id = [responseDict objectForKey:@"webhook_id"];
        [[NSUserDefaults standardUserDefaults] setObject:webhook_id forKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"all_notificatio"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [notificationsTable reloadData];
        
        AppDelegate *tempAppDelegate = APPDELEGATE;
        
        UIView *tostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        [tostView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        tostView.clipsToBounds = YES;
        tostView.layer.cornerRadius = 7;
        
        UILabel *tostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 45)];
        tostLabel.numberOfLines = 2;
        tostLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tostLabel.backgroundColor = [UIColor clearColor];
        tostLabel.textColor = [UIColor whiteColor];
        [tostLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        tostLabel.center = tostView.center;
        tostLabel.text = [NSString stringWithFormat:@"Notification cannot be saved. Please try again later."];
        tostLabel.textAlignment = NSTextAlignmentCenter;
        [tostView addSubview:tostLabel];
        [tempAppDelegate.window showToast:tostView duration:TOST_DISPLAY_DURATION position:@"bottom"];
        
        tostLabel = nil;
        tostView = nil;
      }];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"all_notificatio"] isEqualToString:@"1"]) {
      [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"all_notificatio"];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [((AppDelegate *)[[UIApplication sharedApplication] delegate]).contextIOAPIClient deleteWebhookWithID:[[NSUserDefaults standardUserDefaults] stringForKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"] success:^(NSDictionary *responseDict) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ALL_NOTIFS_ON_WEBHOOK_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"all_notificatio"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [notificationsTable reloadData];
        
        AppDelegate *tempAppDelegate = APPDELEGATE;
        
        UIView *tostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        [tostView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        tostView.clipsToBounds = YES;
        tostView.layer.cornerRadius = 7;
        
        UILabel *tostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 45)];
        tostLabel.numberOfLines = 2;
        tostLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tostLabel.backgroundColor = [UIColor clearColor];
        tostLabel.textColor = [UIColor whiteColor];
        [tostLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        tostLabel.center = tostView.center;
        tostLabel.text = [NSString stringWithFormat:@"Notification cannot be saved. Please try again later."];
        tostLabel.textAlignment = NSTextAlignmentCenter;
        [tostView addSubview:tostLabel];
        [tempAppDelegate.window showToast:tostView duration:TOST_DISPLAY_DURATION position:@"bottom"];
        
        tostLabel = nil;
        tostView = nil;
      }];
    }
    [notificationsTable reloadData];
  }
  else {
    if (sender.tag < dataSource.count) {
      tempFunnlModel = [dataSource objectAtIndex:sender.tag];
      [self saveNewState];
    }
  }
}

#pragma mark -
#pragma mark Helper
- (void)saveNewState {
  AppDelegate *appDelegate = APPDELEGATE;
  if (tempFunnlModel.notificationsFlag) {
    if ([tempFunnlModel.webhookIds length]) {
      NSString *webhookJSONString = [tempFunnlModel webhookIds];
      NSData *jsonData = [webhookJSONString dataUsingEncoding:NSUTF8StringEncoding];
      NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
      NSArray *senders = [[webhooks allKeys] copy];
      __block int reqCnt = (int)[tempFunnlModel.sendersArray count];
      for (NSString *sender in senders) {
        NSDictionary *webhook_id_Dictionary = [webhooks objectForKey:sender];
        NSString *webhook_id = [webhook_id_Dictionary objectForKey:@"webhook_id"];
        [appDelegate.contextIOAPIClient deleteWebhookWithID:webhook_id success:^(NSDictionary *responseDict) {
          NSLog(@"responseDict deletion %@",responseDict);
          [webhooks removeObjectForKey:webhook_id];
          reqCnt--;
          if (reqCnt == 0) {
            [self saveFunnlWithWebhookId:nil];
          }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          reqCnt--;
          if (reqCnt == 0) {
            [self saveFunnlWithWebhookId:nil];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
          }
        }];
      }
    } else {
      [self saveFunnlWithWebhookId:nil];
    }
  }
  else {
    [self createWebhooksAndSaveFunnl];
  }
}

-(void) createWebhooksAndSaveFunnl
{
  AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  NSArray *senders = tempFunnlModel.sendersArray;
  NSArray *subjects = tempFunnlModel.subjectsArray;
  __block int reqCnt = (int)[senders count];
  if ([subjects count]) {
    reqCnt *= [subjects count];
  }
  NSMutableDictionary *webhooks = [[NSMutableDictionary alloc] init];
  //creation of webhooks
  for (NSString *sender in senders) {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:sender forKey:@"filter_from"];
    //[params setObject:@"0" forKey:@"sync_period"];
    if ([subjects count]) {
      for (NSString *subject in subjects) {
        [params setObject:subject forKey:@"filter_subject"];
        [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
          [webhooks setObject:responseDict forKey:sender];
          reqCnt--;
          //dispatch_async(dispatch_get_main_queue(), ^{
          if (reqCnt == 0) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:webhooks options:NSJSONWritingPrettyPrinted error:nil];
            NSString *webhookIds = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [self saveFunnlWithWebhookId:webhookIds];
          }
          //});
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          reqCnt--;
          //dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
          //[self showAlertForError:error];
          if (reqCnt == 0) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
          }
          //});
        }];
        continue;
      }
    } else {
      [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
        [webhooks setObject:responseDict forKey:sender];
        reqCnt--;
        //dispatch_async(dispatch_get_main_queue(), ^{
        if (reqCnt == 0) {
          NSData *jsonData = [NSJSONSerialization dataWithJSONObject:webhooks options:NSJSONWritingPrettyPrinted error:nil];
          NSString *webhookIds = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          [self saveFunnlWithWebhookId:webhookIds];
        }
        //});
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        reqCnt--;
        //dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"createWebhooksAndSaveFunnl --- Email : %@",error.userInfo.description);
        //[self showAlertForError:error];
        if (reqCnt == 0) {
          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
          [self saveFunnlWithWebhookId:nil];
        }
        //});
      }];
    }
  }
}

-(void) saveFunnlWithWebhookId:(NSString *) webhookId
{
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    FunnelModel *model;
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(webhookId != nil){
      //---- Added by Krunal to get work PNs
      NSData* jsonData = [webhookId dataUsingEncoding:NSUTF8StringEncoding];
      NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
      NSArray *senders = [[webhooks allKeys] copy];
      NSMutableArray *webhookChannelArray = [NSMutableArray new];
      PFInstallation *currentInstallation = [PFInstallation currentInstallation];
      for (NSString *sender in senders) {
        NSDictionary *webhook_id_Dictionary = [webhooks objectForKey:sender];
        NSString *webhook_id = [webhook_id_Dictionary objectForKey:@"webhook_id"];
        [webhookChannelArray addObject:webhook_id];
        [currentInstallation addUniqueObject:([NSString stringWithFormat:@"webhook_id_%@", webhook_id]) forKey:@"channels"];
      }
      [currentInstallation saveInBackground];
    }
    else{
      
    }
    
    //unsigned long temp = [[FunnelService instance] allFunnels].count%8;
    NSString *colorString = @"#F9F9F9";
    UIColor *color = [UIColor colorWithHexString:colorString];
    if(1){
      color = tempFunnlModel.barColor;
      colorString = tempFunnlModel.funnelColor;
    }
    else{
      //changed logic
      
    }
    model = [[FunnelModel alloc]initWithBarColor:color filterTitle:tempFunnlModel.funnelName newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:tempFunnlModel.sendersArray subjectsArray:tempFunnlModel.subjectsArray skipAllFlag:FALSE funnelColor:colorString];
    model.funnelId = tempFunnlModel.funnelId;
    model.notificationsFlag = !tempFunnlModel.notificationsFlag;
    model.webhookIds = webhookId ? webhookId : @"";
    model.skipFlag = tempFunnlModel.skipFlag;
    
    if(1){
      [[MessageFilterXRefService instance] deleteXRefWithFunnelId:model.funnelId];
      [[FunnelService instance] updateFunnel:model];
      [[EmailService instance] applyingFunnel:model toMessages:[[MessageService instance] messagesAllTopMessages]];
      [[MessageService instance] insertFunnelJsonForMessages];
    }else{
      [[FunnelService instance] insertFunnel:model];
      [[EmailService instance] applyingFunnel:model toMessages:[[MessageService instance] messagesAllTopMessages]];
    }
  
    dispatch_async(dispatch_get_main_queue(), ^{
      NSMutableArray *tempArray;
      if(tempAppDelegate.currentFunnelDS == nil){
        tempArray = (NSMutableArray*)[[MessageService instance] retrieveAllMessages];
        [EmailService instance].filterMessages = tempArray;
        [[EmailService instance].emailsTableViewController.tableView reloadData];
      }
      else{
        [tempAppDelegate.mainVCdelegate filterSelected:tempAppDelegate.currentFunnelDS];
      }
      
      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    model = nil;
    
  });
}

- (void)fillDataSource {
  dataSource = [[NSMutableArray alloc] initWithArray:[[FunnelService instance] getFunnelsExceptAllFunnel]];
}

#pragma mark -
#pragma mark Memory Managment
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
