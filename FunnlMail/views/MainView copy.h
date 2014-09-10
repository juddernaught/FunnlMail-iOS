//
//  MainView.h
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVCDelegate.h"
#include <MailCore/MailCore.h>
#import <MessageUI/MessageUI.h>
#import "PrimarySettingViewController.h"

@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface MainView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>{
    NSArray *filterArray;
    UIButton *editButton;
    BOOL editOn;
    
}
@property (nonatomic, strong)UIImageView *backgroundImageView;
@property (strong) UICollectionView *collectionView;
@property (weak) id<MainVCDelegate> mainVCdelegate;

@property (nonatomic, strong) MCOAddress * address;
@property (nonatomic, strong) MCOIMAPMessage * message;
@property (nonatomic, strong) NSString * folder;
@property (nonatomic, strong) MCOIMAPSession * imapSession;

-(void)reloadView;
- (void)setupViews;
@end
