//
//  FunnlPopUpView.m
//  FunnlMail
//
//  Created by macbook on 6/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnlPopUpView.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "FunnlPopupViewCell.h"
//#import "FilterModel.h"
#import "FunnelModel.h"
//newly added by iauro001 on 10th June 2014
#import "FunnelService.h"
#import "EmailService.h"
#import "UIColor+HexString.h"
#import "CreateFunnlViewController.h"
#import "ConfirmFunnelPopUp.h"
#import "EmailsTableViewController.h"
#import "FunnelPopUpForExtraRules.h"

static NSString *MAIN_FILTER_CELL = @"MainFilterCell";
static NSString *ADD_MAIN_FILTER_CELL = @"MainFilterCellAdd";

@implementation FunnlPopUpView

- (id)init
{
    self = [super init];
    if (self) {
        isNewCreatePopup = NO;
        [self setup];
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withNewPopup:(BOOL)isNew withMessageId:(NSString*)mID withMessage:(MCOIMAPMessage*)m  subViewOnViewController:(id)viewCOntroller
{
    self = [super initWithFrame:frame];
    if (self) {
        isNewCreatePopup = isNew;
        messageID = mID;
        if(m != nil)
            message = m;
        viewController = viewCOntroller;
        [self setup];
        [self setupViews];
    }
    return self;
}

-(void)setup{
    filterArray = [[NSMutableArray alloc] init];
}

-(void)reloadView{
    filterArray = [[FunnelService instance] allFunnels];
    [self.collectionView reloadData];
}

- (void)setupViews
{
	// Do any additional setup after loading the view.
    //changes made by iauro001 on 11 June 2014
   
//    int width = 280;
    NSString *messageStr = nil;
    if (isNewCreatePopup) {
        messageStr = @"Create new Funnel Rule?";
    }
    else
    {
        messageStr = @"Move to Funnel";
    }
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(40, 100, 320 - 80, 80)];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 320 - 100, 25)];
    messageLabel.numberOfLines = 1;
    [messageLabel setFont:[UIFont systemFontOfSize:17]];
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [messageLabel setBackgroundColor:[UIColor whiteColor]];
    messageLabel.text = messageStr;
    [mainView addSubview:messageLabel];
    [mainView setUserInteractionEnabled:YES];
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 320-100, 25)];
    [tempLabel setFont:[UIFont systemFontOfSize:15]];
    [tempLabel setTextColor:[UIColor lightGrayColor]];
    tempLabel.text = @"Select one";
    [mainView addSubview:tempLabel];
    tempLabel = nil;
    
    [self addSubview:mainView];
    filterArray = [[FunnelService instance] getFunnelsExceptAllFunnel];
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    //self.collectionView.backgroundColor = [UIColor greenColor];
    self.collectionView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
//    [mainView addSubview:self.collectionView];
    
    [self.collectionView registerClass:[FunnlPopupViewCell class] forCellWithReuseIdentifier:MAIN_FILTER_CELL];
    [self.collectionView registerClass:[FunnlPopupViewCell class] forCellWithReuseIdentifier:ADD_MAIN_FILTER_CELL];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(160);
        make.left.equalTo(self.mas_left).with.offset(40);
        make.right.equalTo(self.mas_right).with.offset(-40);
        make.bottom.equalTo(self.mas_bottom).with.offset(-50);
    }];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    singleFingerTap.cancelsTouchesInView = NO;
    
    [self addGestureRecognizer:singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self setHidden:YES];
}

#pragma mark - Collection view datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    if(isNewCreatePopup)
        return filterArray.count+1;
    return [filterArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FunnlPopupViewCell *cell;
    
    if(indexPath.row == filterArray.count){
        cell = (FunnlPopupViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ADD_MAIN_FILTER_CELL forIndexPath:indexPath];
        cell.barColor = [UIColor colorWithHexString:@"#636466"];
        cell.filterTitle = ADD_FUNNL;
    }
    else{
        cell = (FunnlPopupViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MAIN_FILTER_CELL forIndexPath:indexPath];
        cell.barColor = [UIColor yellowColor];
        FunnelModel *fm = (FunnelModel *)filterArray[indexPath.row];
        cell.barColor = fm.barColor;
        cell.filterTitle = fm.filterTitle;
        //[cell.notificationButton addTarget:self action:@selector(notificationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.collectionView.frame.size.width-30)/2, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == filterArray.count){
        [self createAddFunnlView];
    }else{
        if (isNewCreatePopup) {
            NSLog(@"Cell swiped fully!!");
            FunnelModel *funnel = [filterArray objectAtIndex:indexPath.row];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:funnel.sendersArray];
            BOOL flag = FALSE;
            for (NSString *email in tempArray) {
                if ([email isEqualToString:message.header.sender.mailbox]) {
                    flag = TRUE;
                }
            }
            if (!flag) {
                [tempArray addObject:message.header.sender.mailbox];
                funnel.sendersArray = nil;
                funnel.sendersArray = tempArray;
            }
            tempArray = nil;
            FunnelPopUpForExtraRules *funnelPopUp = [[FunnelPopUpForExtraRules alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) withMessage:message withFunnel:funnel];
            [[(EmailsTableViewController*)viewController view] addSubview:funnelPopUp];
        }
        else {
            FunnelModel *funnel = [filterArray objectAtIndex:indexPath.row];
            ConfirmFunnelPopUp *confirmMessagePopUp = [[ConfirmFunnelPopUp alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) withNewPopup:YES withMessageId:messageID withMessage:message onViewController:viewController withFunnelModel:funnel];
            [[(EmailsTableViewController*)viewController view] addSubview:confirmMessagePopUp];
        }
    }
}

-(void)createAddFunnlView{
    
    MCOAddress *emailAddress = message.header.from;
    NSMutableArray *mailArray = [[NSMutableArray alloc] init];
    [mailArray addObject:emailAddress];
    [mailArray addObjectsFromArray:message.header.cc];
    
    NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
    int count = 0;
    for (MCOAddress *address in mailArray) {
        NSString *email = [address.mailbox lowercaseString];
        [sendersDictionary setObject:email forKey:[NSIndexPath indexPathForRow:count inSection:1]];
        count ++;
    }
    
    CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:nil filterModel:nil];
    creatFunnlViewController.mainVCdelegate = self.mainVCdelegate;
    [self.mainVCdelegate pushViewController:creatFunnlViewController];
    creatFunnlViewController = nil;
}

@end

