//
//  FunnlPopUpView.h
//  FunnlMail
//
//  Created by macbook on 6/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVCDelegate.h"
#import <MailCore/MailCore.h>

@interface FunnlPopUpView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>{
    NSArray *filterArray;
    BOOL isNewCreatePopup;
    NSString *messageID;
    MCOIMAPMessage *message;
    id viewController;
}

@property (strong) UICollectionView *collectionView;
@property (weak) id<MainVCDelegate> mainVCdelegate;
-(void)reloadView;
- (void)setupViews;
- (id)initWithFrame:(CGRect)frame withNewPopup:(BOOL)isNew withMessageId:(NSString*)mID withMessage:(MCOIMAPMessage*)m subViewOnViewController:(id)viewCOntroller;
@end