//
//  FilterView.h
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"
#import "MainVCDelegate.h"
#import <MailCore/MailCore.h>


@interface FilterView : UIView<UITableViewDataSource, UITableViewDelegate>{
    UIView *filterNavigationView;
    UILabel *filterLabel;
}

@property (nonatomic, strong) NSArray *messages;

@property (strong) UITableView *tableView;
@property (strong,nonatomic) FilterModel *filterModel;
@property (weak) id<MainVCDelegate> mainVCdelegate;


@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;


@property (nonatomic) NSInteger totalNumberOfInboxMessages;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;


- (void) startLogin;

@end
