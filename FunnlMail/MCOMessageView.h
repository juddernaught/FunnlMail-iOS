//
//  MCOMessageView.h
//  testUI
//
//  Created by DINH Viêt Hoà on 1/19/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#include <MailCore/MailCore.h>
#import <UIKit/UIKit.h>
#import "MessageModel.h"

@protocol MCOMessageViewDelegate;

@interface MCOMessageView : UIView <UIWebViewDelegate>

@property (nonatomic, copy) NSString * folder;
@property (nonatomic, strong) MCOAbstractMessage * message;

@property (nonatomic, assign) id <MCOMessageViewDelegate> delegate;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) BOOL prefetchIMAPImagesEnabled;
@property (nonatomic, assign) BOOL prefetchIMAPAttachmentsEnabled;
@property (nonatomic, strong) MCOIMAPMessage *tempMessageModel;
@end

@protocol MCOMessageViewDelegate <NSObject>

@optional
- (void) MCOMessageViewLoadingCompleted:(MCOMessageView *)view;

- (void) MCOMessageView:(MCOMessageView *)view getFunlShareString:(NSString *)dataString;

- (NSData *) MCOMessageView:(MCOMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID;
- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished;

- (NSString *) MCOMessageView_templateForMainHeader:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForImage:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForAttachment:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForMessage:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForEmbeddedMessage:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForEmbeddedMessageHeader:(MCOMessageView *)view;
- (NSString *) MCOMessageView_templateForAttachmentSeparator:(MCOMessageView *)view;

- (NSDictionary *) MCOMessageView:(MCOMessageView *)view templateValuesForPartWithUniqueID:(NSString *)uniqueID;
- (NSDictionary *) MCOMessageView:(MCOMessageView *)view templateValuesForHeader:(MCOMessageHeader *)header;
- (BOOL) MCOMessageView:(MCOMessageView *)view canPreviewPart:(MCOAbstractPart *)part;

- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTMLForPart:(NSString *)html;
- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTMLForMessage:(NSString *)html;
- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage;
- (id)initWithFrame:(CGRect)frame withMessage:(MessageModel*)message;
@end
