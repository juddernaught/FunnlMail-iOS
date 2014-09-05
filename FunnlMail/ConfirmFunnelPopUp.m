//
//  ConfirmFunnelPopUp.m
//  FunnlMail
//
//  Created by iauro001 on 6/23/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ConfirmFunnelPopUp.h"
#import "CreateFunnlViewController.h"
#import "EmailsTableViewController.h"
#import "MessageFilterXRefService.h"
#import "UIColor+HexString.h"
#import <Mixpanel/Mixpanel.h>

@implementation ConfirmFunnelPopUp

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withNewPopup:(BOOL)isNew withMessageId:(NSString*)mID withMessage:(MCOIMAPMessage*)m onViewController:(id)someViewController withFunnelModel:(FunnelModel *)funnelDS
{
    self = [super initWithFrame:frame];
    if (self) {
        tempDS = funnelDS;
        emailViewController = someViewController;
        isNewCreatePopup = isNew;
        messageID = mID;
        if(m != nil)
            message = m;
//        [self setup];
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    int width = 280;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 400)];
    [mainView setBackgroundColor:[UIColor colorWithHexString:@"#E2E2E2"]];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 149, width - 70 - 10, 50)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextAlignment:NSTextAlignmentLeft];
    messageLabel.numberOfLines = 2;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.text = [NSString stringWithFormat:@"Message will be funnled under %@",tempDS.funnelName];
    [mainView addSubview:messageLabel];
    messageLabel = nil;
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 280, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [mainView addSubview:seperator];
    seperator = nil;
    
    UIButton *undoButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 200 + 30, width - 20, 30)];
    undoButton.clipsToBounds = YES;
    undoButton.layer.cornerRadius = 2.0;
    [undoButton setTitle:@"Undo" forState:UIControlStateNormal];
    [undoButton addTarget:self action:@selector(dismissPopUp:) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setBackgroundColor:[UIColor colorWithHexString:UNDO_BUTTON_RED_COLOR]];
    [mainView addSubview:undoButton];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 200 + 30 + 40, width - 20, 30)];
    doneButton.clipsToBounds = YES;
    doneButton.layer.cornerRadius = 2.0;
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(createAddFunnlView) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    [mainView addSubview:doneButton];
    
    mainView.center = self.center;
    [self addSubview:mainView];
    [[(EmailsTableViewController*)emailViewController view] addSubview:self];
}

- (void)dismissPopUp:(UIButton*)sender {
    [self removeFromSuperview];
    [[Mixpanel sharedInstance] track:@"Funnl Popup undo pressed"];
    [[(EmailsTableViewController*)emailViewController tableView] reloadData];
}

-(void)createAddFunnlView{
    [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID funnelId:tempDS.funnelId];
    [[Mixpanel sharedInstance] track:@"Funnl Popup done pressed"];
    [self removeFromSuperview];
    [[(EmailsTableViewController*)emailViewController tableView] reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
