//
//  MsgViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 4/4/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

// a bunch of code taken from: https://github.com/MailCore/mailcore2

#import "MsgViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "MCOMessageView.h"
#import "PreviewEmailViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"


@interface MsgViewController () <MCOMessageViewDelegate>

@end

@implementation MsgViewController

@synthesize folder = _folder;
@synthesize session = _session;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setUpView];
//    [self.view addSubview:headerView];
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(25, headerView.frame.origin.y + headerView.frame.size.height, WIDTH - 20, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
//    [self.view addSubview:seperator];
    
//    subjectView.frame = CGRectMake(0, headerView.frame.origin.y + headerView.frame.size.height, WIDTH, subjectHeight + 20);
    subjectView.frame = CGRectMake(0, 0, WIDTH, subjectHeight + 20);
//    [self.view addSubview:subjectView];
    
    _messageView = [[MCOMessageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-28)];
    _messageView.tempMessageModel = _message;
    _messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.view addSubview:_messageView];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateWebView) userInfo:nil repeats:NO];
    
    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-34)];
//    [messageTableView setSeparatorColor:[UIColor clearColor]];
    [messageTableView setScrollEnabled:YES];
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    messageTableView.tableFooterView = seperator;
    [self.view addSubview:messageTableView];
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-42, self.view.bounds.size.width, 42)];
    centeredButtons.backgroundColor = [UIColor colorWithHexString:@"FEFEFE"];
    //EBE6E9 spare color i was testing
    
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *replyAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [replyButton addTarget:self action:@selector(replyButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyButton.frame = CGRectMake(70, 0, 42, 42);
    [replyButton setBackgroundImage:[UIImage imageNamed:@"reply.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:replyButton];

    [replyAllButton addTarget:self action:@selector(forwardButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyAllButton.frame = CGRectMake(140, 0, 42, 42);
    [replyAllButton setBackgroundImage:[UIImage imageNamed:@"replyAll.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:replyAllButton];
    
    [forwardButton addTarget:self action:@selector(forwardButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    forwardButton.frame = CGRectMake(210, 0, 42, 42);
    [forwardButton setBackgroundImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:forwardButton];
    
    UIView *topBorder = [[UIView alloc]
                          initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
    topBorder.backgroundColor = [UIColor lightGrayColor];
    [centeredButtons addSubview:topBorder];
    
    [self.view addSubview:centeredButtons];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
        [_messageView setDelegate:self];
        [_messageView setFolder:_folder];
        [_messageView setMessage:_message];
    }
    else {
        [_messageView setMessage:NULL];
        MCOIMAPFetchContentOperation * op = [_session fetchMessageByUIDOperationWithFolder:_folder uid:[_message uid]];
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
    //customize back button.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    AppDelegate *tempAppDelegate = APPDELEGATE;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [titleLabel setFont:[UIFont systemFontOfSize:22]];
    [titleLabel setTextColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE_COLOR]];
    if ([tempAppDelegate.currentFunnelString.lowercaseString isEqualToString:@"all"]) {
        self.navigationItem.title =@"All mails";
    }
    else {
        self.navigationItem.title = tempAppDelegate.currentFunnelString.capitalizedString;
//        titleLabel.text = tempAppDelegate.currentFunnelString.capitalizedString;
    }
//    [titleLabel setTextAlignment:NSTextAlignmentCenter];
//    self.navigationItem.titleView = titleLabel;
//    titleLabel = nil;
}

-(void)updateWebView{
    NSLog(@"----> %d",_messageView.height);
    webViewHeight = MAX(HEIGHT-40, _messageView.height+60);
    _messageView.webView.scrollView.alwaysBounceVertical = NO;
    _messageView.webView.frame = CGRectMake(0, 0, _messageView.webView.frame.size.width, webViewHeight);
    [messageTableView reloadData];
}

#pragma mark -
#pragma mark Helper
- (void)setUpView
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 100)];
    int padding = 0;
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, padding + 10, 50, 16)];
    [fromLabel setTextAlignment:NSTextAlignmentLeft];
    [fromLabel setTextColor:[UIColor blackColor]];
    fromLabel.text = @"From:";
    [fromLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:fromLabel];
    fromLabel = nil;
    
    UIButton *fromValue = [[UIButton alloc] initWithFrame:CGRectMake(20 + 50, padding + 10, WIDTH - 20 - 50, 16)];
    [fromValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (_message.header.sender.displayName) {
        [fromValue setTitle:_message.header.sender.displayName forState:UIControlStateNormal];
    }
    else
        [fromValue setTitle:_message.header.sender.mailbox forState:UIControlStateNormal];
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
    headerView.frame = CGRectMake(0, 0, WIDTH, finalY);
    headerHeight = finalY;
    int height = [self calculateSize:_message.header.subject];
    subjectHeight = height;
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, height)];
    [subjectLabel setFont:[UIFont boldSystemFontOfSize:16]];
    subjectLabel.numberOfLines = 0;
    subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subjectLabel.text = _message.header.subject;
    
    subjectView = [[UIView alloc] init];
    [subjectView addSubview:subjectLabel];
    subjectLabel = nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy h:mm a"];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10 + height + 3, 280, 15)];
    [dateLabel setFont:[UIFont systemFontOfSize:14]];
    [dateLabel setTextColor:[UIColor blackColor]];
    dateLabel.text = [dateFormatter stringFromDate:_message.header.date];
    [subjectView addSubview:dateLabel];
    dateLabel = nil;
    
    UIView *seperator = [[UILabel alloc] initWithFrame:CGRectMake(20, 10 + height + 3 + 15 + 11, 300, 0.5)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [subjectView addSubview:seperator];
    seperator = nil;
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
        UIButton *toValue = [[UIButton alloc] initWithFrame:CGRectMake(x, y, expectedLength, 16)];
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

#pragma mark -
#pragma mark UITableViewDelegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        [cell.contentView addSubview:headerView];
    }
    else if (indexPath.row == 1)
        [cell.contentView addSubview:subjectView];
    else
        [cell.contentView addSubview:_messageView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return headerHeight;
    }
    else if (indexPath.row == 1)
        return subjectView.frame.size.height + 20;
    else
        return webViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark EventHandler
//newly added by iauro001 on 24th June 2014
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setMessage:(MCOIMAPMessage *)message
{
	MCLog("set message : %s", message.description.UTF8String);
    NSLog(@"set message : %s", message.description.UTF8String);
    for(MCOOperation * op in _ops) {
        [op cancel];
    }
    [_ops removeAllObjects];
    
    [_callbacks removeAllObjects];
    [_pending removeAllObjects];
    [_storage removeAllObjects];
    _message = message;
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
    
    MCOIMAPPart * part = (MCOIMAPPart *) [_message partForUniqueID:partUniqueID];
    NSAssert(part != nil, @"part != nil");
    
    [_pending addObject:partUniqueID];
    
    MCOIMAPFetchContentOperation * op = [_session fetchMessageAttachmentByUIDOperationWithFolder:folder uid:[_message uid] partID:[part partID] encoding:[part encoding]];
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
		return [attachment data];
	}
	else {
		NSData * data = [_storage objectForKey:partUniqueID];
		return data;
	}
}

- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished
{
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

- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage
{
    if (isHTMLInlineImage) {
        return data;
    }
    else {
        return [self _convertToJPEGData:data];
    }
}

#define IMAGE_PREVIEW_HEIGHT 300
#define IMAGE_PREVIEW_WIDTH 500

- (NSData *) _convertToJPEGData:(NSData *)data {
    NSLog(@"Got here");
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


-(void) replyButtonSelected{
    NSLog(@"reply Email selected");
    PreviewEmailViewController *viewEmail = [[PreviewEmailViewController alloc]init];
    viewEmail.address = self.address;
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.reply = @1;
    [self presentViewController:viewEmail animated:YES completion:NULL];
}

-(void) forwardButtonSelected{
    NSLog(@"reply Email selected");
    PreviewEmailViewController *viewEmail = [[PreviewEmailViewController alloc]init];
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    viewEmail.forward = @1;
    [self presentViewController:viewEmail animated:YES completion:NULL];
}


@end
