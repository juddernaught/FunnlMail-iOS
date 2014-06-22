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
    _messageView = [[MCOMessageView alloc] initWithFrame:self.view.bounds];
    _messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_messageView];
    
    UIView *centeredButtons = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-28, self.view.bounds.size.width, 28)];
    centeredButtons.backgroundColor = [UIColor grayColor];
    
    
//    UIToolbar *toolbar = [UIToolbar new];
//    
//    toolbar.barStyle = UIBarStyleBlackTranslucent;
//    
//    // create a bordered style button with custom title
//    
////    UIImage *temp = [UIImage imageNamed:@"forward.png"];
////    [temp drawInRect:CGRectMake(0, 0, 28, 28)];
////    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonSelected)];
////    temp =[UIImage imageNamed:@"reply.png"];
////    [temp drawInRect:CGRectMake(0, 0, 28, 28)];
////    UIBarButtonItem *reply = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStylePlain target:self action:@selector(replyButtonSelected)];
////    
////    
////    NSArray *items = [NSArray arrayWithObjects:
////                      
////                      forward,
////                      
////                      reply,
////                      
////                      nil];
////    
////    toolbar.items = items;
//    
//    // size up the toolbar and set its frame
//    
//    // please not that it will work only for views without Navigation toolbars.
//    
//    [toolbar setFrame:CGRectMake(0, self.view.bounds.size.height-28, self.view.bounds.size.width, 28)];
//    
//    [self.view addSubview:toolbar];

    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [replyButton addTarget:self action:@selector(replyButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    replyButton.frame = CGRectMake(0, 0, 33, 28);
    [replyButton setBackgroundImage:[UIImage imageNamed:@"reply.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:replyButton];

    [forwardButton addTarget:self action:@selector(forwardButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    forwardButton.frame = CGRectMake(33, 0, 33, 28);
    [forwardButton setBackgroundImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [centeredButtons addSubview:forwardButton];
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
    [self presentViewController:viewEmail animated:YES completion:NULL];
}

-(void) forwardButtonSelected{
    NSLog(@"reply Email selected");
    PreviewEmailViewController *viewEmail = [[PreviewEmailViewController alloc]init];
    viewEmail.message = _message;
    viewEmail.folder = _folder;
    viewEmail.imapSession = _session;
    [self presentViewController:viewEmail animated:YES completion:NULL];
}


@end
