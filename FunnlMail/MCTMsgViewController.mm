//
//  MCTMsgViewController.m
//  testUI
//
//  Created by DINH Viêt Hoà on 1/20/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCTMsgViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "MCOMessageView.h"

//-New headers
#import "UIColor+HexString.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "ComposeViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "CreateFunnlViewController.h"
#import "FunnelService.h"
#import "EmailService.h"
#import "FunnelModel.h"
#import "FunnlPopUpView.h"
#import "FMCreateFunnlViewController.h"
#import "FMContactDetailViewController.h"

@interface UIBarButtonItem (NegativeSpacer)
+(UIBarButtonItem*)negativeSpacerWithWidth:(NSInteger)width;
@end
@implementation UIBarButtonItem (NegativeSpacer)
+(UIBarButtonItem*)negativeSpacerWithWidth:(NSInteger)width {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                             target:nil
                             action:nil];
    item.width = (width >= 0 ? -width : width);
    return item;
}
@end


@interface MCTMsgViewController () <MCOMessageViewDelegate>

@end

@implementation MCTMsgViewController

@synthesize folder = _folder;
@synthesize session = _session;
@synthesize selectedIndexPath,messageModel,address;

- (void) awakeFromNib
{
    _storage = [[NSMutableDictionary alloc] init];
    _ops = [[NSMutableArray alloc] init];
    _pending = [[NSMutableSet alloc] init];
    _callbacks = [[NSMutableDictionary alloc] init];
}

- (id)init {
    self = [super init];
    
    if(self) {
        [self awakeFromNib];
    }
    
    return self;
}

- (void) viewWillDisappear:(BOOL)animated{
    for(MCOOperation * op in _ops) {
        [op cancel];
    }
    [_ops removeAllObjects];
    
    [_callbacks removeAllObjects];
    [_pending removeAllObjects];
    [_storage removeAllObjects];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {

    CGFloat offset = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIView *CoverView = [[UIView alloc]init];
        CoverView.frame = CGRectMake(0,0,self.view.bounds.size.width,20);
        CoverView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:CoverView];
        offset = CoverView.bounds.size.height;
    }
    appDelegate = APPDELEGATE;

    _messageView = [[MCOMessageView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT- 64)];
    _messageView.tempMessageModel = _message;
    _messageView.webView.opaque = YES;
    _messageView.webView.backgroundColor = CLEAR_COLOR;
    [self.view addSubview:_messageView];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
        [_messageView setDelegate:self];
        [_messageView setFolder:_folder];
        [_messageView setMessage:_message];
   
        if(appDelegate.internetAvailable == NO){
            if(_messageView.activityIndicator)
                [_messageView.activityIndicator removeFromSuperview];
            [_messageView.webView loadHTMLString:@"Internet not available" baseURL:nil];
        }
        
    }
    else {
        [_messageView setMessage:NULL];
        
        if(appDelegate.internetAvailable){
            MCOIMAPFetchContentOperation * op = [_session fetchMessageByUIDOperationWithFolder:_folder uid:[_message uid] urgent:YES];
            [_ops addObject:op];
            [op start:^(NSError * error, NSData * data) {
                if ([error code] != MCOErrorNone) {
                    return;
                }
                
                NSAssert(data != nil, @"data != nil");
                
                MCOMessageParser * msg = [MCOMessageParser messageParserWithData:data];
                [_messageView setDelegate:self];
                [_messageView setFolder:_folder];
                [_messageView setMessage:msg];
            }];
        }
        else{
            if(_messageView.activityIndicator)
                [_messageView.activityIndicator removeFromSuperview];
            [_messageView.webView loadHTMLString:@"Internet not available" baseURL:nil];
        }
    }
    
    //---New changes
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-42, self.view.bounds.size.width, 42)];
    centeredButtons.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
    //EBE6E9 spare color i was testing
    
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *replyAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [replyButton addTarget:self action:@selector(replyButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyButton.frame = CGRectMake(51, 6, 40, 35);
    [replyButton setImage:[UIImage imageNamed:@"emailDetailViewReply.png"] forState:UIControlStateNormal];
//    [replyButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//    [replyButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [centeredButtons addSubview:replyButton];
    
    [replyAllButton addTarget:self action:@selector(replyAllButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyAllButton.frame = CGRectMake(140, 6, 40, 35);
    [replyAllButton setImage:[UIImage imageNamed:@"emailDetailViewReplyAll.png"] forState:UIControlStateNormal];
//    [replyAllButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//    [replyAllButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [centeredButtons addSubview:replyAllButton];
    
    [forwardButton addTarget:self action:@selector(forwardButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    forwardButton.frame = CGRectMake(WIDTH - 42 - 51, 6, 35, 35);
    [forwardButton setImage:[UIImage imageNamed:@"emailDetailViewForward.png"] forState:UIControlStateNormal];
//    [forwardButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//    [forwardButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [centeredButtons addSubview:forwardButton];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
    topBorder.backgroundColor = [UIColor lightGrayColor];
    [centeredButtons addSubview:topBorder];
    
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(25, headerView.frame.origin.y + headerView.frame.size.height, WIDTH - 20, 0)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];

    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 100)];
    int padding = 0;
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, padding + 10, 50, 16)];
    [fromLabel setTextAlignment:NSTextAlignmentLeft];
    [fromLabel setTextColor:[UIColor blackColor]];
    fromLabel.text = @"From:";
    [fromLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:fromLabel];
    fromLabel = nil;
    
    UIButton *fromValue = [[UIButton alloc] initWithFrame:CGRectMake(20 + 50 - 5, padding + 10, WIDTH - 20 - 50, 16)];
    fromValue.tag = -1;
    [fromValue addTarget:self action:@selector(contactTaped:) forControlEvents:UIControlEventTouchUpInside];
    [fromValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (_message.header.from.displayName) {
        [fromValue setTitle:_message.header.from.displayName forState:UIControlStateNormal];
    }
    else
        [fromValue setTitle:_message.header.from.mailbox forState:UIControlStateNormal];
    [fromValue setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR] forState:UIControlStateNormal];
    [fromValue.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:fromValue];
    fromValue = nil;
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, padding + 10 + 16 + 8, 25, 16)];
    [toLabel setTextAlignment:NSTextAlignmentLeft];
    [toLabel setTextColor:[UIColor blackColor]];
    toLabel.text = @"To:";
    [toLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:toLabel];
    toLabel = nil;
    
    int finalY = [self insertToAddress:_message.header.to withX:45 andY:padding + 10 + 16 + 8];
    if (_message.header.cc.count > 0) {
        UILabel *ccLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY, 25, 16)];
        [ccLabel setTextAlignment:NSTextAlignmentLeft];
        [ccLabel setTextColor:[UIColor blackColor]];
        ccLabel.text = @"Cc:";
        [ccLabel setFont:[UIFont systemFontOfSize:16]];
        [headerView addSubview:ccLabel];
        ccLabel = nil;
        finalY = [self insertCCAddress:_message.header.cc withX:45 andY:finalY];
    }
    
    seperator = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY, 300, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:seperator];
    seperator = nil;
    
    finalY = finalY + 5;
    
    headerView.frame = CGRectMake(0, 0, WIDTH, finalY);
    headerHeight = finalY;
    int height = [self calculateSize:_message.header.subject];
    subjectHeight = height;
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY, 280, height + 5)]; // Added +5 to enable multi-line
    [subjectLabel setFont:[UIFont boldSystemFontOfSize:16]];
    subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subjectLabel.numberOfLines = 0;
    subjectLabel.text = _message.header.subject;
    
    [headerView addSubview:subjectLabel];
    headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height + height + 30);
    
    subjectView = [[UIView alloc] init];
    //    [subjectView addSubview:subjectLabel];
    subjectLabel = nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy h:mm a"]; //Changed by Chad
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, finalY + height + 3, 280, 15)];
    [dateLabel setFont:[UIFont systemFontOfSize:14]];
    [dateLabel setTextColor:[UIColor blackColor]];
    dateLabel.text = [dateFormatter stringFromDate:_message.header.date];
    [headerView addSubview:dateLabel];
    //    [subjectView addSubview:dateLabel];
    dateLabel = nil;
    
    seperator = [[UILabel alloc] initWithFrame:CGRectMake(20, headerView.frame.size.height - 1, 300, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:seperator];
    seperator = nil;
    
    AppDelegate *tempAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    tempAppDelegate.headerViewForMailDetailView = headerView;
    
    subjectView.frame = CGRectMake(0, 0, WIDTH, subjectHeight + 20);
    _messageView.headerView.backgroundColor = WHITE_CLR;
    _messageView.backgroundColor = WHITE_CLR;
    [_messageView setHeaderViewHeight:headerView.frame.size.height];
    [_messageView setHeaderView:headerView];

    
    [self.view addSubview:centeredButtons];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [titleLabel setFont:[UIFont systemFontOfSize:22]];
    [titleLabel setTextColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    if ([tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:[ALL_FUNNL lowercaseString]] || [tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:[ALL_OTHER_FUNNL lowercaseString]]) {
        self.navigationItem.title = @"";
    }
    else {
        self.navigationItem.title = @"";
    }
    
    /*UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTitle:@"Back"];
    [self.navigationItem setLeftBarButtonItem:leftButton];*/


    UIBarButtonItem *actualfixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [UIBarButtonItem negativeSpacerWithWidth:-10];
   // fixedSpace.width = 4;

//    UIBarButtonItem *funnelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewFunnel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(createFunnl:)];
    UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewArchive.png"] style:UIBarButtonItemStylePlain target:self action:@selector(archiveMail:)];
    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewMail.png"] style:UIBarButtonItemStylePlain target:self action:@selector(unreadMail:)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"emailDetailViewTrash.png"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteMail:)];
//    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:actualfixedSpace, deleteButton,fixedSpace, archiveButton,fixedSpace, emailButton,fixedSpace, funnelButton, nil]];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:actualfixedSpace, deleteButton,fixedSpace, archiveButton,fixedSpace, emailButton, fixedSpace, nil]];
    //---end of new changes
}

- (void) setMessage:(MCOIMAPMessage *)message
{
	MCLog("set message : %s", message.description.UTF8String);
    for(MCOOperation * op in _ops) {
        [op cancel];
    }
    [_ops removeAllObjects];
    
    [_callbacks removeAllObjects];
    [_pending removeAllObjects];
    [_storage removeAllObjects];
    _message = message;
    
    [self setReadMessage:messageModel];
}

- (MCOIMAPMessage *) message
{
    return _message;
}

- (MCOIMAPFetchContentOperation *) _fetchIMAPPartWithUniqueID:(NSString *)partUniqueID folder:(NSString *)folder
{
    MCLog("%s is missing, fetching", partUniqueID.description.UTF8String);
    
    if ([_pending containsObject:partUniqueID]) {
        return nil;
    }
    if(appDelegate.internetAvailable){

        MCOIMAPPart * part = (MCOIMAPPart *) [_message partForUniqueID:partUniqueID];
        NSAssert(part != nil, @"part != nil");
        
        [_pending addObject:partUniqueID];
        
        MCOIMAPFetchContentOperation * op = [_session fetchMessageAttachmentByUIDOperationWithFolder:folder uid:[_message uid] partID:[part partID] encoding:[part encoding] urgent:YES];
        [_ops addObject:op];
        [op start:^(NSError * error, NSData * data) {
            if ([error code] != MCOErrorNone) {
                [self _callbackForPartUniqueID:partUniqueID error:error];
                return;
            }
            
            NSAssert(data != NULL, @"data != nil");
            [_ops removeObject:op];
            [_storage setObject:data forKey:partUniqueID];
            [_pending removeObject:partUniqueID];
            MCLog("downloaded %s", partUniqueID.description.UTF8String);
            
            [self _callbackForPartUniqueID:partUniqueID error:nil];
        }];
        return op;
    }
    return nil;
}

typedef void (^DownloadCallback)(NSError * error);

- (void) _callbackForPartUniqueID:(NSString *)partUniqueID error:(NSError *)error
{
    NSArray * blocks;
    blocks = [_callbacks objectForKey:partUniqueID];
    for(DownloadCallback block in blocks) {
        block(error);
    }
}

- (NSString *) MCOMessageView_templateForAttachment:(MCOMessageView *)view
{
    return @"<div><img src=\"http://www.iconshock.com/img_jpg/OFFICE/general/jpg/128/attachment_icon.jpg\"/></div>\
{{#HASSIZE}}\
<div>- {{FILENAME}}, {{SIZE}}</div>\
{{/HASSIZE}}\
{{#NOSIZE}}\
<div>- {{FILENAME}}</div>\
{{/NOSIZE}}";
}

- (NSString *) MCOMessageView_templateForMessage:(MCOMessageView *)view
{
    return @"<div style=\"padding-bottom: 20px; font-family: Helvetica; font-size: 13px;\">{{HEADER}}</div><div>{{BODY}}</div>";
}

- (BOOL) MCOMessageView:(MCOMessageView *)view canPreviewPart:(MCOAbstractPart *)part
{
    // tiff, tif, pdf
    NSString * mimeType = [[part mimeType] lowercaseString];
    if ([mimeType isEqualToString:@"image/tiff"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"image/tif"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"application/pdf"]) {
        return YES;
    }
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([ext isEqualToString:@"tiff"]) {
            return YES;
        }
        else if ([ext isEqualToString:@"tif"]) {
            return YES;
        }
        else if ([ext isEqualToString:@"pdf"]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTML:(NSString *)html
{
    return html;
}

- (NSData *) MCOMessageView:(MCOMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
		MCOAttachment * attachment = (MCOAttachment *) [[_messageView message] partForUniqueID:partUniqueID];
        //[self updateWebView];
		return [attachment data];
	}
	else {
		NSData * data = [_storage objectForKey:partUniqueID];
        //[self updateWebView];
        return data;
	}
}

- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished
{
    
    if(appDelegate.internetAvailable){

        MCOIMAPFetchContentOperation * op = [self _fetchIMAPPartWithUniqueID:partUniqueID folder:_folder];
        [op setProgress:^(unsigned int current, unsigned int maximum) {
            MCLog("progress content: %u/%u", current, maximum);
        }];
        if (op != nil) {
            [_ops addObject:op];
        }
        if (downloadFinished != NULL) {
            NSMutableArray * blocks;
            blocks = [_callbacks objectForKey:partUniqueID];
            if (blocks == nil) {
                blocks = [NSMutableArray array];
                [_callbacks setObject:blocks forKey:partUniqueID];
            }
            [blocks addObject:[downloadFinished copy]];
        }
    }
    //[self updateWebView];
}

- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage
{
    if (isHTMLInlineImage) {
        return data;
    }
    else {
        return [self _convertToJPEGData:data];
    }
}

- (void) MCOMessageViewLoadingCompleted:(MCOMessageView *)view;
{
    //[self updateWebView];
}


#define IMAGE_PREVIEW_HEIGHT 300
#define IMAGE_PREVIEW_WIDTH 500

- (NSData *) _convertToJPEGData:(NSData *)data {
    CGImageSourceRef imageSource;
    CGImageRef thumbnail;
    NSMutableDictionary * info;
    int width;
    int height;
    float quality;

    width = IMAGE_PREVIEW_WIDTH;
    height = IMAGE_PREVIEW_HEIGHT;
    quality = 1.0;

    imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    if (imageSource == NULL)
        return nil;

    info = [[NSMutableDictionary alloc] init];
    [info setObject:(id) kCFBooleanTrue forKey:(__bridge id) kCGImageSourceCreateThumbnailWithTransform];
    [info setObject:(id) kCFBooleanTrue forKey:(__bridge id) kCGImageSourceCreateThumbnailFromImageAlways];
    [info setObject:(id) [NSNumber numberWithFloat:(float) IMAGE_PREVIEW_WIDTH] forKey:(__bridge id) kCGImageSourceThumbnailMaxPixelSize];
    thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef) info);

    CGImageDestinationRef destination;
    NSMutableData * destData = [NSMutableData data];

    destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) destData,
                                                   (CFStringRef) @"public.jpeg",
                                                   1, NULL);
    
    CGImageDestinationAddImage(destination, thumbnail, NULL);
    CGImageDestinationFinalize(destination);

    CFRelease(destination);

    CFRelease(thumbnail);
    CFRelease(imageSource);

    return destData;
}

#pragma mark - new methods

- (void) MCOMessageView:(MCOMessageView *)view getFunlShareString:(NSString *)dataString;
{
    if(dataString.length){
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dataString options:0];
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:decodedData options:kNilOptions error:&error];
        BOOL isValid = [NSJSONSerialization isValidJSONObject:jsonObj];
        if(isValid){
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", decodedString);
            NSData *data = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if([json isKindOfClass:[NSDictionary class]]){
                NSString *name = [json objectForKey:@"name"];
                NSArray *sendersArray = [json objectForKey:@"senders"];
                NSArray *subjectsArray = [json objectForKey:@"subjects"];
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                NSArray *randomColors = GRADIENT_ARRAY;
                //NSInteger gradientInt = randomColors.count;
                NSInteger gradientInt = arc4random_uniform((uint32_t)randomColors.count);
                NSString *colorString = [randomColors objectAtIndex:gradientInt];
                UIColor *color = [UIColor colorWithHexString:colorString];
                if(color == nil){
                    color = [UIColor colorWithHexString:@"#F7F7F7"];
                }
                FunnelModel *funnlModel = [[FunnelModel alloc] initWithBarColor:color filterTitle:name newMessageCount:0 dateOfLastMessage:nil sendersArray:(NSMutableArray *)sendersArray subjectsArray:(NSMutableArray *)subjectsArray skipAllFlag:NO funnelColor:colorString];
                [self performSelector:@selector(createFunnlFromShareLink:) withObject:funnlModel afterDelay:0.01];
                
                // save to db
            }
        }
        else{
            NSLog(@"%@",error.description);
        }
    }
}

-(void)createFunnlFromShareLink:(FunnelModel*)fm{
    
    NSMutableDictionary *sendersDictionary = [[NSMutableDictionary alloc] init];
    int count = 0;
    for (NSString *tempAddress in fm.sendersArray) {
        if (![tempAddress isEqualToString:@""]) {
            [sendersDictionary setObject:[tempAddress lowercaseString] forKey:[NSIndexPath indexPathForRow:count inSection:1]];
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
    //[[Mixpanel sharedInstance] track:@"user clicked get funnl"];
    if (IS_NEW_CREATE_FUNNEL) {
        FMCreateFunnlViewController *viewcontroller = [[FMCreateFunnlViewController alloc] initWithSelectedContactArray:(NSMutableArray *)sendersDictionary.allValues name:fm.funnelName andSubjects:(NSMutableArray *)subjectsDictionary.allValues];
        viewcontroller.isEditFunnel = NO;
        viewcontroller.shareFunnl = YES;
        viewcontroller.isFunnelStore = YES;
        viewcontroller.oldModel = fm;
        viewcontroller.mainVCdelegate = nil;
        [self.navigationController pushViewController:viewcontroller animated:YES];
        viewcontroller = nil;
    }
    else {
        CreateFunnlViewController *creatFunnlViewController = [[CreateFunnlViewController alloc] initTableViewWithSenders:sendersDictionary subjects:subjectsDictionary filterModel:fm];
        creatFunnlViewController.isEdit = NO;
        [self.navigationController pushViewController:creatFunnlViewController animated:YES];
        creatFunnlViewController = nil;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


- (CGFloat)calculateSize:(NSString*)string
{
    CGSize maximumSize = CGSizeMake(280, 568);
    UIFont *myFont = [UIFont boldSystemFontOfSize:16];
    CGSize myStringSize = [string sizeWithFont:myFont constrainedToSize:maximumSize lineBreakMode:NSLineBreakByWordWrapping];
    return myStringSize.height;
}

- (int)insertCCAddress:(NSArray*)to withX:(int)x andY:(int)y{
    for (int counter = 0; counter < to.count; counter++) {
        NSString *toString = nil;
        if ([[_message.header.cc objectAtIndex:counter] displayName]) {
            toString = [[_message.header.cc objectAtIndex:counter] displayName];
        }
        else
            toString = [[_message.header.cc objectAtIndex:counter] mailbox];
        int expectedLength = [self getLengthOf:toString];
        if (expectedLength > (WIDTH - 40 - x)) {
            y = y + 16 + 8;
            x = 20;
        }
        UIButton *toValue = [[UIButton alloc] initWithFrame:CGRectMake(x+3, y, expectedLength, 16)];
        [toValue addTarget:self action:@selector(contactTaped:) forControlEvents:UIControlEventTouchUpInside];
        [toValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if (toString) {
            [toValue setTitle:[NSString stringWithFormat:@"%@",toString] forState:UIControlStateNormal];
        }
        else
        {
            [toValue setTitle:[[_message.header.to objectAtIndex:0] mailbox] forState:UIControlStateNormal];
        }
        [toValue setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR] forState:UIControlStateNormal];
        [toValue.titleLabel setFont:[UIFont systemFontOfSize:16]];
        toValue.tag = CC_TAG_STARTING + counter;
        [headerView addSubview:toValue];
        toValue = nil;
        UIImageView *arrorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x + expectedLength-5, y, 16, 16)];
        [arrorImageView setImage:[UIImage imageNamed:@"arrow.png"]];
        [headerView addSubview:arrorImageView];
        arrorImageView = nil;
        x = x + expectedLength + 15;
    }
    return y + 16 + 8;
}

- (int)insertToAddress:(NSArray*)to withX:(int)x andY:(int)y{
    for (int counter = 0; counter < to.count; counter++) {
        NSString *toString = nil;
        if ([[_message.header.to objectAtIndex:counter] displayName]) {
            toString = [[_message.header.to objectAtIndex:counter] displayName];
        }
        else
            toString = [[_message.header.to objectAtIndex:counter] mailbox];
        int expectedLength = [self getLengthOf:toString];
        if (expectedLength > (WIDTH - 40 - x)) {
            y = y + 16 + 8;
            x = 20;
        }
        UIButton *toValue = [[UIButton alloc] initWithFrame:CGRectMake(x, y, expectedLength, 16)];
        [toValue addTarget:self action:@selector(contactTaped:) forControlEvents:UIControlEventTouchUpInside];
        [toValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if (toString) {
            [toValue setTitle:[NSString stringWithFormat:@"%@",toString] forState:UIControlStateNormal];
        }
        else
        {
            [toValue setTitle:[[_message.header.to objectAtIndex:0] mailbox] forState:UIControlStateNormal];
        }
        [toValue setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR] forState:UIControlStateNormal];
        [toValue.titleLabel setFont:[UIFont systemFontOfSize:16]];
        toValue.tag = TO_TAG_STARTING + counter;
        [headerView addSubview:toValue];
        toValue = nil;
        UIImageView *arrorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x + expectedLength-5, y, 16, 16)];
        [arrorImageView setImage:[UIImage imageNamed:@"arrow.png"]];
        [headerView addSubview:arrorImageView];
        arrorImageView = nil;
        x = x + expectedLength + 15;
    }
    return y + 16 + 8;
}

- (CGFloat)getLengthOf:(NSString*)string {
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *userAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor blackColor]};
    CGSize sizeNeeded = [string sizeWithAttributes:userAttributes];
    return sizeNeeded.width + 5;
}

-(void) replyButtonSelected{
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Reply Email Selected"];
#endif
    NSLog(@"reply Email selected");
    ComposeViewController *viewEmail = [[ComposeViewController alloc]init];
    viewEmail.address = self.message.header.from;
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.reply = @1;
    [self.navigationController pushViewController:viewEmail animated:YES];
}

-(void) replyAllButtonSelected{
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Reply All selected"];
#endif
    NSLog(@"reply Email selected");
    ComposeViewController *viewEmail = [[ComposeViewController alloc]init];
    viewEmail.addressArray = self.message.header.to;
    viewEmail.address = self.message.header.from;
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.replyAll = @1;
    [self.navigationController pushViewController:viewEmail animated:YES];
}

-(void) forwardButtonSelected{
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Forward selected"];
#endif
    NSLog(@"reply Email selected");
    ComposeViewController *viewEmail = [[ComposeViewController alloc]init];
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.forward = @1;
    [self.navigationController pushViewController:viewEmail animated:YES];
}



#pragma mark -
#pragma mark EventHandler
- (void)contactTaped:(UIButton *)sender {
    NSLog(@"Sender.tag,%ld",(long)sender.tag);
    if (sender.tag == -1) {
        //from taped
        FMContactDetailViewController *contactDetailViewCOntroller = [[FMContactDetailViewController alloc] initWithMessage:_message.header.sender];
        [self.navigationController pushViewController:contactDetailViewCOntroller animated:YES];
        contactDetailViewCOntroller = nil;
    }
    else if (sender.tag >= TO_TAG_STARTING && sender.tag < CC_TAG_STARTING) {
        //to contact taped
        int index = sender.tag % TO_TAG_STARTING;
        if (index < _message.header.to.count) {
            FMContactDetailViewController *contactDetailViewCOntroller = [[FMContactDetailViewController alloc] initWithMessage:[_message.header.to objectAtIndex:index]];
            [self.navigationController pushViewController:contactDetailViewCOntroller animated:YES];
            contactDetailViewCOntroller = nil;
        }
        else {
            NSLog(@"To array out of bound");
        }
    }
    else {
        //cc contact taped
        int index = sender.tag % CC_TAG_STARTING;
        if (index < _message.header.cc.count) {
            FMContactDetailViewController *contactDetailViewCOntroller = [[FMContactDetailViewController alloc] initWithMessage:[_message.header.cc objectAtIndex:index]];
            [self.navigationController pushViewController:contactDetailViewCOntroller animated:YES];
            contactDetailViewCOntroller = nil;
        }
        else {
            NSLog(@"CC array out of bound");
        }
    }
}


-(void)updateWebView{
    CGFloat contentHeight = _messageView.webView.scrollView.contentSize.height;
//    NSLog(@"----> %d %d",_messageView.height,contentHeight);
    
    CGRect frame = _messageView.webView.frame;
    frame.size.height = 1;
    _messageView.webView.frame = frame;
    CGSize fittingSize = [_messageView.webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    float wHeight = frame.size.height;
    wHeight = MAX(wHeight, 500);
    _messageView.webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, wHeight - 60);
//    _messageView.webScrollView.contentSize = CGSizeMake(frame.size.width, wHeight);
    [_messageView.webView setNeedsDisplay];
    [_messageView.webView setNeedsLayout];
    _messageView.frame = CGRectMake(_messageView.frame.origin.x, _messageView.frame.origin.y, _messageView.frame.size.width, wHeight - 40);
    NSLog(@"size: webViewHt:%f,  messageViewHt:%f", _messageView.webView.frame.size.height,  _messageView.frame.size.height);
}

- (void)setReadMessage:(MessageModel*)_messageModel{
    _message.flags = _message.flags | MCOMessageFlagSeen;
    MCOIMAPOperation *msgOperation=[[EmailService instance].imapSession storeFlagsOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagSeen];
    [msgOperation start:^(NSError * error)
     {
         if(error){
             NSLog(@"Error in read: %@",error.userInfo.description);
         }
         NSLog(@"Read --- selected message flags %u UID is %u",_message.flags,_message.uid );
     }];
    [messageModel setRead:YES];
    [[MessageService instance] updateMessage:messageModel];

}

- (void)unreadMail:(UIButton*)sender {
    _message.flags = MCOMessageFlagNone;
    MCOIMAPOperation *msgOperation=[[EmailService instance].imapSession storeFlagsOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] kind:MCOIMAPStoreFlagsRequestKindRemove flags:MCOMessageFlagSeen];
    [msgOperation start:^(NSError * error)
     {
         NSLog(@"Unread --- selected message flags %u UID is %u",_message.flags,_message.uid );
     }];
    [messageModel setRead:NO];
    [[MessageService instance] updateMessage:messageModel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteMail:(UIButton*)sender {
    
    NSString *uidKey = [NSString stringWithFormat:@"%d",_message.uid];
    [[MessageService instance] deleteMessage:uidKey];
    MCOIMAPCopyMessagesOperation *opt = [[EmailService instance].imapSession copyMessagesOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] destFolder:TRASH];
    [opt start:^(NSError *error, NSDictionary *uidMapping) {
        NSLog(@"copied to folder with UID %@", uidMapping);
    }];
    [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
    [[EmailService instance].filterMessages removeObjectAtIndex:selectedIndexPath.row];
    [[EmailService instance].messages removeObjectIdenticalTo:_message];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)archiveMail:(UIButton*)sender {
    
    NSString *uidKey = [NSString stringWithFormat:@"%d",_message.uid];
    [[MessageService instance] deleteMessage:uidKey];
    MCOIMAPOperation *msgOperation = [[EmailService instance].imapSession storeFlagsOperationWithFolder:self.folder uids:[MCOIndexSet indexSetWithIndex:_message.uid] kind:MCOIMAPStoreFlagsRequestKindAdd flags:MCOMessageFlagDeleted];
    [msgOperation start:^(NSError * error)
     {
         NSLog(@"selected message flags %u UID is %u",_message.flags,_message.uid );
     }];
    [[EmailService instance].filterMessagePreviews removeObjectForKey:uidKey];
    [[EmailService instance].filterMessages removeObjectAtIndex:selectedIndexPath.row];
    [[EmailService instance].messages removeObjectIdenticalTo:_message];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createFunnl:(UIButton*)sender{
    AppDelegate *appDelegate = APPDELEGATE;
    NSString *uidKey = [NSString stringWithFormat:@"%d",_message.uid];
    FunnlPopUpView *funnlPopUpView = [[FunnlPopUpView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withNewPopup:YES withMessageId:uidKey withMessage:_message subViewOnViewController:self];
    funnlPopUpView.mainVCdelegate = appDelegate.mainVCdelegate;
    if ([FunnelService instance].allFunnels.count < 4){
    }
    [self.view addSubview:funnlPopUpView];
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
