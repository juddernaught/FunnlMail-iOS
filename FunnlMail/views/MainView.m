//
//  MainView.m
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MainView.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "MainFilterCell.h"
//#import "FilterModel.h"
#import "FunnelModel.h"
//newly added by iauro001 on 10th June 2014
#import "FunnelService.h"
#import "EmailService.h"
#import "UIColor+HexString.h"
#import "CreateFunnlViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "MBProgressHUD.h"
#import "ShareView.h"
#import "FMCreateFunnlViewController.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>

static NSString *MAIN_FILTER_CELL = @"MainFilterCell";
static NSString *ADD_MAIN_FILTER_CELL = @"MainFilterCellAdd";
NSData * rfc822Data;
NSString *msgBody;


@implementation MainView
@synthesize backgroundImageView;
- (id)init
{
  self = [super init];
  if (self) {
//      UIGraphicsBeginImageContext(self.window.bounds.size);
//      [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//      UIGraphicsEndImageContext();
//      NSData * data = UIImagePNGRepresentation(image);
//      //[data writeToFile:@"foo.png" atomically:YES];
//      backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//      [backgroundImageView setImage:[UIImage imageWithData:data]];
//      [self addSubview:backgroundImageView];
//
//    FXBlurView *backgroundView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    backgroundView.blurRadius = 0.5;
//    [self addSubview:backgroundView];
//    [backgroundView setUserInteractionEnabled:YES];
//    backgroundView = nil;

    [self setup];
    [self setupViews];
    editOn = FALSE;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        UIGraphicsBeginImageContext(self.window.bounds.size);
//        [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        NSData * data = UIImagePNGRepresentation(image);
//        if (backgroundImageView) {
//            backgroundImageView = nil;
//        }
//        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//        [backgroundImageView setImage:[UIImage imageWithData:data]];
//        data = nil;
//        [self addSubview:backgroundImageView];
//        FXBlurView *backgroundView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//        [backgroundView setBlurEnabled:YES];
//        backgroundView.tintColor = [UIColor whiteColor];
//        backgroundView.blurRadius = 10;
//        [self addSubview:backgroundView];
//        backgroundView = nil;
//        [backgroundView setUserInteractionEnabled:YES];
//        backgroundView = nil;
        
        [self setup];
        [self setupViews];
        editOn = FALSE;

    }
    return self;
}

-(void)setup{
  filterArray = [[NSMutableArray alloc] init];
}

-(void)reloadView{
    editOn = FALSE;
//    [editButton setImage:[UIImage imageNamed:@"manage_Button"] forState:UIControlStateNormal];
    UIImage *sampleImage = [UIImage imageNamed:@"settingIcon-FunnlOverlay.png"];
    sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [editButton setImage:sampleImage forState:UIControlStateNormal];
    editButton.tintColor = [UIColor whiteColor];
    sampleImage = nil;
    self.imapSession = [EmailService instance].imapSession;
    filterArray = [[FunnelService instance] getFunnelsExceptAllFunnel];
    [self.collectionView reloadData];
}

- (void)setupViews
{
    UIImage *funnlIconImage = [UIImage imageNamed:@"funnlIcon-FunnlOverlay.png"];
    funnlIconImage = [funnlIconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *funnlImageView = [[UIImageView alloc] initWithFrame:CGRectMake(228, 23, 30, 30)];
    [funnlImageView setImage:funnlIconImage];
    funnlImageView.tintColor = [UIColor whiteColor];
    [funnlImageView setUserInteractionEnabled:YES];
    [self addSubview:funnlImageView];
    funnlImageView = nil;
    
//    UIView *backGroundViewForAlpha = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    [backGroundViewForAlpha setUserInteractionEnabled:YES];
//    [backGroundViewForAlpha setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
//    [self addSubview:backGroundViewForAlpha];
    
	// Do any additional setup after loading the view.
    //inserting default @"All" filter
    FunnelModel *defaultFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#F7F7F7"] filterTitle:ALL_FUNNL newMessageCount:0 dateOfLastMessage:[NSDate new]];
    defaultFilter.funnelName = ALL_FUNNL;
    defaultFilter.funnelId = @"0";
    defaultFilter.emailAddresses = @"";
    defaultFilter.webhookIds = @"";
    defaultFilter.phrases = @"";
    [[FunnelService instance] insertFunnel:defaultFilter];
    defaultFilter = nil;
    
    FunnelModel *otherFilter = [[FunnelModel alloc]initWithBarColor:[UIColor colorWithHexString:@"#F7F7F7"] filterTitle:ALL_OTHER_FUNNL newMessageCount:0 dateOfLastMessage:[NSDate new]];
    otherFilter.funnelName = ALL_OTHER_FUNNL;
    otherFilter.funnelId = @"1";
    otherFilter.emailAddresses = @"";
    otherFilter.webhookIds = @"";
    otherFilter.phrases = @"";
    [[FunnelService instance] insertFunnel:otherFilter];
    otherFilter = nil;

    filterArray = [[FunnelService instance] allFunnels];
//   self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    UIButton *outterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    [outterButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [outterButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
    [outterButton addTarget:self action:@selector(outterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:outterButton];
//    [backGroundViewForAlpha addSubview:outterButton];
    
    UIView *headerView =[[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
    [self addSubview:headerView];
//    [backGroundViewForAlpha addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(44);
        make.left.equalTo(self.mas_left).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(0);
        make.bottom.equalTo(self.mas_bottom).with.offset(-60);
    }];
   
    UILabel *funnelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
    funnelLabel.text = @"Funnels";
    [funnelLabel setTextAlignment:NSTextAlignmentLeft];
    [funnelLabel setFont:[UIFont boldSystemFontOfSize:20]];
    funnelLabel.textColor = WHITE_CLR;
//    [headerView addSubview:funnelLabel];
    headerView.backgroundColor = CLEAR_COLOR;

    editButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 40, 40)];
    [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [editButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [editButton setContentMode:UIViewContentModeCenter];
    UIImage *sampleImage = [UIImage imageNamed:@"settingIcon-FunnlOverlay.png"];
    sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [editButton setImage:sampleImage forState:UIControlStateNormal];
    editButton.tintColor = [UIColor whiteColor];
    sampleImage = nil;
    [editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [headerView addSubview:editButton];
    [self addSubview:editButton];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//    [self.collectionView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
    self.collectionView.backgroundColor = CLEAR_COLOR;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
//    [backGroundViewForAlpha addSubview:self.collectionView];

    [self.collectionView registerClass:[MainFilterCell class] forCellWithReuseIdentifier:MAIN_FILTER_CELL];
    [self.collectionView registerClass:[MainFilterCell class] forCellWithReuseIdentifier:ADD_MAIN_FILTER_CELL];
    
  
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(80);
        make.left.equalTo(self.mas_left).with.offset(14);
        make.right.equalTo(self.mas_right).with.offset(-14);
        make.bottom.equalTo(self.mas_bottom).with.offset(-20);
    }];
  
//    self.collectionView.backgroundColor = [UIColor colorWithHexString:@"#CDCDCD"];
//    [headerView setBackgroundColor:[UIColor colorWithHexString:@"#CDCDCD"]];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    singleFingerTap.cancelsTouchesInView = NO;
    singleFingerTap.delaysTouchesEnded = NO;
    [self addGestureRecognizer:singleFingerTap];
//    [backGroundViewForAlpha addGestureRecognizer:singleFingerTap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
        if ([touch.view isKindOfClass:[UIControl class]]) {
            return NO; // ignore the touch
        }
    return YES; // handle the touch
}

- (void)outterButtonClicked {
    AppDelegate *tempAppDelegate = APPDELEGATE;
    [tempAppDelegate.mainVCControllerInstance hideMainView];
    editOn = FALSE;
//    [editButton setImage:[UIImage imageNamed:@"manage_Button"] forState:UIControlStateNormal];
    UIImage *sampleImage = [UIImage imageNamed:@"settingIcon-FunnlOverlay.png"];
    sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [editButton setImage:sampleImage forState:UIControlStateNormal];
    editButton.tintColor = [UIColor whiteColor];
    sampleImage = nil;
    
//    [self setHidden:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    AppDelegate *tempAppDelegate = APPDELEGATE;
    [tempAppDelegate.mainVCControllerInstance hideMainView];
    editOn = FALSE;
//    [editButton setImage:[UIImage imageNamed:@"manage_Button"] forState:UIControlStateNormal];
    UIImage *sampleImage = [UIImage imageNamed:@"settingIcon-FunnlOverlay.png"];
    sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [editButton setImage:sampleImage forState:UIControlStateNormal];
    editButton.tintColor = [UIColor whiteColor];
    sampleImage = nil;
//    [self setHidden:YES];
//    [UIView animateWithDuration:ANIMATION_DURATION
//                          delay:0.0
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
//                         self.alpha = 0;
//                     }
//                     completion:^(BOOL finished){
//                         if(finished)
//                         {
//                             self.hidden = YES;
//                             NSLog(@"Finished !!!!!");
//                         }
//                         // do any stuff here if you want
//                     }];
}

- (void)editButtonPressed:(UIButton*)sender {
    
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Pressed 'Manage' button in Funnl Overlay"];
#endif
    if (editOn) {
        editOn = FALSE;
        
//        [editButton setImage:[UIImage imageNamed:@"manage_Button"] forState:UIControlStateNormal];
        UIImage *sampleImage = [UIImage imageNamed:@"settingIcon-FunnlOverlay.png"];
        sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [editButton setImage:sampleImage forState:UIControlStateNormal];
        editButton.tintColor = [UIColor whiteColor];
        sampleImage = nil;
    }
    else {
        editOn = TRUE;
//        [editButton setImage:[UIImage imageNamed:@"Done_Button"] forState:UIControlStateNormal];
        UIImage *sampleImage = [UIImage imageNamed:@"doneIcon-FunnlOverlay.png"];
        sampleImage = [sampleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [editButton setImage:sampleImage forState:UIControlStateNormal];
        editButton.tintColor = [UIColor whiteColor];
        sampleImage = nil;
        
    }
    [self.collectionView reloadData];
}

#pragma mark - Collection view datasource
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 25;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
  return [filterArray count]+1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView{
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  MainFilterCell *cell;
  
  if(indexPath.row == filterArray.count){
    cell = (MainFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ADD_MAIN_FILTER_CELL forIndexPath:indexPath];
    cell.barColor = [UIColor colorWithHexString:@"#636466"];
    cell.filterTitle = ADD_FUNNL;
    cell.newMessageCount = 0;
    cell.dateOfLastMessage = 0;
      
    
  }
  else{
    cell = (MainFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MAIN_FILTER_CELL forIndexPath:indexPath];
    cell.barColor = [UIColor yellowColor];
    FunnelModel *fm = (FunnelModel *)filterArray[indexPath.row];
    cell.barColor = [UIColor colorWithHexString:fm.funnelColor];
    cell.filterTitle = fm.filterTitle;
    cell.newMessageCount = fm.newMessageCount;
    cell.dateOfLastMessage = fm.dateOfLastMessage;
    cell.settingsButton.tag = indexPath.row;
    cell.shareButton.tag = indexPath.row;
    [cell.settingsButton addTarget:self action:@selector(settingsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.notificationButton.tag = indexPath.row;
    //[cell.notificationButton addTarget:self action:@selector(notificationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
      
      if (editOn) {
          if( [fm.funnelName.lowercaseString isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]){
              cell.filterTitle = ALL_OTHER_FUNNL_DISPLAY_NAME;
          }
          
          if([fm.funnelName.lowercaseString isEqualToString:[ALL_FUNNL lowercaseString]] || [fm.funnelName.lowercaseString isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]){
              [cell.notificationButton setHidden:YES];
              [cell.settingsButton setHidden:NO];
              [cell.shareButton setHidden:YES];
              [cell.mailImageView setHidden:YES];
              [cell.messageCountLabel setHidden:YES];
          }
          else{
              [cell.notificationButton setHidden:NO];
              [cell.settingsButton setHidden:NO];
              [cell.shareButton setHidden:NO];
              [cell.mailImageView setHidden:YES];
              [cell.messageCountLabel setHidden:YES];
          }
      }
      else {
          if( [fm.funnelName.lowercaseString isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]){
              cell.filterTitle = ALL_OTHER_FUNNL_DISPLAY_NAME;
          }
          
          [cell.notificationButton setHidden:YES];
          [cell.settingsButton setHidden:YES];
          [cell.shareButton setHidden:YES];
          [cell.mailImageView setHidden:NO];
          [cell.messageCountLabel setHidden:NO];
      }
  }
  cell.contentView.backgroundColor = [UIColor clearColor];
    
  return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //changes made by iauro
//  return UIEdgeInsetsMake(13, 13, 12, 12);
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.collectionView.frame.size.width-36)/2, 120);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  if(indexPath.row == filterArray.count){
    [self createAddFunnlView];
  }else{
    AppDelegate *tempAppDelegate = APPDELEGATE;
    tempAppDelegate.currentFunnelString = [[(FunnelModel *)filterArray[indexPath.row] funnelName] lowercaseString];
      tempAppDelegate.currentFunnelDS = (FunnelModel *)filterArray[indexPath.row];
    [self.mainVCdelegate filterSelected:(FunnelModel *)filterArray[indexPath.row]];
  }
}

-(void)createAddFunnlView{
    if (IS_NEW_CREATE_FUNNEL) {
        FMCreateFunnlViewController *viewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:nil name:nil andSubjects:nil];
        viewController.mainVCdelegate = self.mainVCdelegate;
        [self.mainVCdelegate pushViewController:viewController];
        viewController = nil;
    }
    else {
        CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:nil subjects:nil filterModel:nil];
        creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
        [self.mainVCdelegate pushViewController:creatFunnlViewController];
        creatFunnlViewController = nil;
    }
}



-(void)shareButtonClicked:(id)sender{
    self.hidden = YES;
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"Pressed 'Sharing' button in manage overlay"];
#endif
    UIButton *b = (UIButton*)sender;
    FunnelModel *fm = (FunnelModel *)filterArray[b.tag];
    ShareView *shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) withFunnlModel:fm];
//    [shareView setBlurEnabled:YES];
//    shareView.backgroundColor = [UIColor blackColor];
//    shareView.blurRadius = 10;
//    shareView.tintColor = [UIColor blackColor];
    [self.superview addSubview:shareView];
    [self setHidden:YES];
    
/*    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:self.imapSession.username]];
    NSMutableArray *toArray = [[NSMutableArray alloc] init];
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:@"iaurosys@gmail.com"];
    [toArray addObject:newAddress];
    
    NSMutableArray *ccArray = [[NSMutableArray alloc] init];
    newAddress = [MCOAddress addressWithMailbox:@"iaurosys@gmail.com"];
    [ccArray addObject:newAddress];
    [[builder header] setCc:ccArray];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fm.filterTitle,fm.sendersArray,fm.subjectsArray,nil] forKeys:[NSArray arrayWithObjects:@"name",@"senders",@"subjects", nil]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (! jsonData) {
        jsonString = @"";
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSLog(jsonString);
    NSString *base64EncodedString = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

    
    NSString *subjectString = [NSString stringWithFormat:@"FunnlMail - Makes Email Simpler, '%@' has shared '%@' Funnl with you.",self.imapSession.username,fm.filterTitle];
    [[builder header] setSubject:subjectString];
    
//    NSString *funnlLinkStr = [NSString stringWithFormat:@"<a href=funnl://name=%@&from=%@&subject=%@> Get Funnl </a>",fm.filterTitle,[fm.sendersArray componentsJoinedByString:@","],[fm.subjectsArray componentsJoinedByString:@","]];
    NSString *funnlLinkStr = [NSString stringWithFormat:@"<a href=funnl://%@> Get Funnl </a>",base64EncodedString];
    NSString *htmlString = [[NSString alloc] initWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\
                            <html>\
                            <head>\
                            <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\
                            <meta http-equiv=\"Content-Style-Type\" content=\"text/css\">\
                            <title></title>\
                            <meta name=\"Generator\" content=\"Cocoa HTML Writer\">\
                            <style type=\"text/css\">\
                            p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px '.Helvetica Neue Interface'}\
                            span.s1 {font-family: '.HelveticaNeueInterface-Regular'; font-weight: normal; font-style: normal; font-size: 12.00pt}\
                            </style>\
                            </head>\
                            <body>\
                            <p class=\"p1\"><span class=\"s1\">\
                            Hi,<br/><br/>\
                            I have  been using Funnl Mail (iOS) to organize my inbox and wanted share Funnl '%@' to help you organize. <br/><br/>%@</span></p>\
                            </body>\
                            </html>",fm.filterTitle,funnlLinkStr];
    [builder setHTMLBody:htmlString];
    rfc822Data = [builder data];

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    MCOSMTPSendOperation *sendOperation = [[EmailService instance].smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnl" message:@"Error sending email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
            NSLog(@"%@ Error sending email:%@", [EmailService instance].smtpSession.username, error);
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
        } else {
            NSLog(@"%@ Successfully sent email!", [EmailService instance].smtpSession.username);
            [[Mixpanel sharedInstance] track:@"Send Button from composeVC"];
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
            [[[EmailService instance].imapSession appendMessageOperationWithFolder:SENT messageData:rfc822Data flags:MCOMessageFlagMDNSent] start:^(NSError *error, uint32_t createdUID) {
                if (error)
                    NSLog(@"error adding message to sent folder");
                else NSLog(@"successfully appended message to sent folder");
            }];
        }
    }];
*/
}

-(void)settingsButtonClicked:(id)sender{
    self.hidden = YES;
#ifdef TRACK_MIXPANEL
  [[Mixpanel sharedInstance] track:@"Pressed 'Settings' button in manage overlay"];
#endif
  UIButton *b = (UIButton*)sender;
  FunnelModel *fm = (FunnelModel *)filterArray[b.tag];
  if([[fm.funnelName lowercaseString]  isEqualToString:[ALL_FUNNL lowercaseString]] || [[fm.funnelName lowercaseString]  isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]){
      PrimarySettingViewController *primarySettingController = [[PrimarySettingViewController alloc] init];
      [self.mainVCdelegate pushViewController:primarySettingController];
      primarySettingController = nil;

  }
  else{
      NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
      int count = 0;
      for (NSString *address in fm.sendersArray) {
          if (![address isEqualToString:@""]) {
              [sendersDictionary setObject:[address lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
              count ++;
          }
      }
      
      NSMutableDictionary *subjectsDictionary = [[NSMutableDictionary alloc] init];
      count = 0;
      for (NSString *subject in fm.subjectsArray) {
          if (![subject isEqualToString:@""])
          {
              [subjectsDictionary setObject:[subject lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:2]];
              count ++;
          }
      }
      if (IS_NEW_CREATE_FUNNEL) {
          NSMutableArray *sender = [[NSMutableArray alloc] initWithArray:sendersDictionary.allValues];
          NSMutableArray *subject = [[NSMutableArray alloc] initWithArray:subjectsDictionary.allValues];
          FMCreateFunnlViewController *viewController = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:sender name:nil andSubjects:subject];
          viewController.isEditFunnel = TRUE;
          viewController.oldModel = fm;
          viewController.mainVCdelegate = self.mainVCdelegate;
          [self.mainVCdelegate pushViewController:viewController];
          
          sender = nil;
          subject = nil;
          viewController = nil;
      }
      else {
          CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:subjectsDictionary filterModel:fm];
          creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
          [self.mainVCdelegate pushViewController:creatFunnlViewController];
          creatFunnlViewController = nil;
      }
  }
}

-(void)notificationButtonClicked:(id)sender{
//  UIButton *b = (UIButton*)sender;
}



@end
