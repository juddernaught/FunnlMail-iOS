//
//  MCOMessageView.m
//  testUI
//
//  Created by DINH Viêt Hoà on 1/19/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOMessageView.h"
#import "MCOCIDURLProtocol.h"
#import "MessageService.h"

static NSString * mainJavascript = @"\
var imageElements = function() {\
	var imageNodes = document.getElementsByTagName('img');\
	return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
	var images = imageElements();\
	\
	var imgLinks = [];\
	for (var i = 0; i < images.length; i++) {\
		var url = images[i].getAttribute('src');\
		if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
			imgLinks.push(url);\
	}\
	return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
	var images = imageElements();\
	\
	for (var i = 0; i < images.length; i++) {\
		var url = images[i].getAttribute('src');\
		if (url.indexOf(info.URLKey) == 0) {\
			images[i].setAttribute('src', info.LocalPathKey);\
			break;\
		}\
	}\
};\
";

static NSString * mainStyle = @"\
body {\
  font-family: Helvetica;\
  font-size: 14px;\
  word-wrap: break-word;\
  -webkit-text-size-adjust:none;\
  -webkit-nbsp-mode: space;\
  padding: 10px;\
}\
\
pre {\
  white-space: pre-wrap;\
}\
";

@interface MCOMessageView () <MCOHTMLRendererIMAPDelegate>

@end

@implementation MCOMessageView {
    UIWebView * _webView;
    NSString * _folder;
    MCOAbstractMessage * _message;
    id <MCOMessageViewDelegate> __unsafe_retained_delegate;
    BOOL _prefetchIMAPImagesEnabled;
    BOOL _prefetchIMAPAttachmentsEnabled;
}

@synthesize folder = _folder;
@synthesize delegate = _delegate;
@synthesize prefetchIMAPImagesEnabled = _prefetchIMAPImagesEnabled;
@synthesize prefetchIMAPAttachmentsEnabled = _prefetchIMAPAttachmentsEnabled;
@synthesize tempMessageModel;
@synthesize webView = _webView;
@synthesize height;


@synthesize headerView,footerViewHeight,headerViewHeight,footerView,actualContentHeight,actualContentWidth,shouldScrollToTopOnLayout,webScrollView,oldScrollViewDelegate,webViewDelegate;
@synthesize activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"THIS HAPPENED");
    self = [super initWithFrame:frame];
    
    // defaults
    self.headerViewHeight = 0;
    self.footerViewHeight = 0;
    
    // create webview
    _webView = [[UIWebView alloc] initWithFrame:frame];
//    _webView.scrollView.bounces = NO;
//    [_webView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [_webView setDelegate:self];
    _webView.scrollView.delegate = self;
    [self addSubview:_webView];
    self.webView.scalesPageToFit = YES;

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(150, headerViewHeight + 20, 25, 25);
    [_webView addSubview:activityIndicator];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicator startAnimating];
    });

    
    return self;
}

/*- (void) dealloc
{
    [super dealloc];
}*/

- (void) setMessage:(MCOAbstractMessage *)message
{
//    _message = [message retain];
    _message = message;
    
    [_webView stopLoading];
    [self _refresh];
}

- (MCOAbstractMessage *) message
{
    return _message;
}

- (void) _refresh
{
    NSString *uidKey = [NSString stringWithFormat:@"%d",tempMessageModel.uid];
    NSString * content = @"";

    if (_message == nil) {
        content = nil;
        [_webView loadHTMLString:@"" baseURL:nil];
    }
    else {
        NSString *string = [[MessageService instance] retrieveHTMLContentWithID:uidKey];
        if (string == nil || string.length == 0 )
            string = @"";
            
        if (![string isEqualToString:EMPTY_DELIMITER] && string && ![string isEqualToString:@""]) {
            [activityIndicator removeFromSuperview];
            
            NSMutableString * html = [NSMutableString string];
            [html appendFormat:@"<html><head><script>%@</script><style>%@</style><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=3\"></head>"
             @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
             @"</iframe></html>", mainJavascript, mainStyle, string];
            [_webView loadHTMLString:html baseURL:nil];
            return;
        }
        [_webView loadHTMLString:@"" baseURL:nil];
        
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        if ([_message isKindOfClass:[MCOIMAPMessage class]]) {
            content = [(MCOIMAPMessage *) _message htmlRenderingWithFolder:_folder delegate:self];
            if (content) {
                NSArray *tempArray = [content componentsSeparatedByString:@"<div><b>Date:<"];
                if (tempArray.count > 1) {
                    NSArray *tempArray1 = [[tempArray objectAtIndex:1] componentsSeparatedByString:@"</div>"];
                    if (tempArray1.count > 1) {
                        NSString *body = [[[tempArray objectAtIndex:1] componentsSeparatedByString:[tempArray1 objectAtIndex:0]] objectAtIndex:1];
                        content = body;
                    }
                }
                else {
                }
                paramDict[uidKey] = content;
            }
            else
                [_webView loadHTMLString:@"Content not found 1" baseURL:nil];
        }
        else if ([_message isKindOfClass:[MCOMessageBuilder class]]) {
            content = [(MCOMessageBuilder *) _message htmlRenderingWithDelegate:self];
            if (content) {
                NSArray *tempArray = [content componentsSeparatedByString:@"<html xmlns=\"http://www.w3.org/1999/xhtml\">"];
                if (tempArray.count > 1) {
                    content = [tempArray objectAtIndex:1];
                }
            }
            else
                [_webView loadHTMLString:@"Content not found 2" baseURL:nil];
        }
        else if ([_message isKindOfClass:[MCOMessageParser class]]) {
            content = [(MCOMessageParser *) _message htmlRenderingWithDelegate:self];
            if (content) {
                NSArray *tempArray = [content componentsSeparatedByString:@"<html xmlns=\"http://www.w3.org/1999/xhtml\">"];
                if (tempArray.count > 1) {
                    content = [tempArray objectAtIndex:1];
                }
            }
            else
                [_webView loadHTMLString:@"" baseURL:nil];
        }
        else {
            content = nil;
            MCAssert(0);
        }
        
        if(content) {
            NSLog(@"----HTML data callback recieved -----");
            paramDict[uidKey] = content;
            [[MessageService instance] updateMessageWithHTMLContent:paramDict];
            NSMutableString * html = [NSMutableString string];
            [html appendFormat:@"<html><head><script>%@</script><style>%@</style><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=3\"></head>"
             @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
             @"</iframe></html>", mainJavascript, mainStyle, content];
            
            [_webView loadHTMLString:html baseURL:nil];

            activityIndicator.hidden = YES;
        }
        else{
            [_webView loadHTMLString:@"" baseURL:nil];
        }
    }
}

- (void) _loadImages
{
    NSString *heightOfWebViewStr = [_webView stringByEvaluatingJavaScriptFromString:@"document.height;"];
	NSString * result = [_webView stringByEvaluatingJavaScriptFromString:@"findCIDImageURL()"];
    NSLog(@"----------");
    NSLog(@"%@ %@", result,heightOfWebViewStr);
    height = [heightOfWebViewStr integerValue];
	NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSArray * imagesURLStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	NSInteger imagesCount = imagesURLStrings.count;
    __block NSInteger currentImageCount = 0;
    if(imagesCount){
       	for(NSString * urlString in imagesURLStrings) {

            MCOAbstractPart * part = nil;
            NSURL * url;
            
            url = [NSURL URLWithString:urlString];
            if ([MCOCIDURLProtocol isCID:url]) {
                part = [self _partForCIDURL:url];
            }
            else if ([MCOCIDURLProtocol isXMailcoreImage:url]) {
                NSString * specifier = [url resourceSpecifier];
                NSString * partUniqueID = specifier;
                part = [self _partForUniqueID:partUniqueID];
            }
            
            if (part == nil)
                continue;
            
            NSString * partUniqueID = [part uniqueID];
            NSData * data = [[self delegate] MCOMessageView:self dataForPartWithUniqueID:partUniqueID];
            
            void (^replaceImages)(NSError *error) = ^(NSError *error) {
                NSData * downloadedData = [[self delegate] MCOMessageView:self dataForPartWithUniqueID:partUniqueID];
                NSData * previewData = [[self delegate] MCOMessageView:self previewForData:downloadedData isHTMLInlineImage:[MCOCIDURLProtocol isCID:url]];
                NSString * filename = [NSString stringWithFormat:@"%lu", (unsigned long)downloadedData.hash];
                NSURL * cacheURL = [self _cacheJPEGImageData:previewData withFilename:filename];
                
                NSDictionary * args = @{ @"URLKey": urlString, @"LocalPathKey": cacheURL.absoluteString };
                NSString * jsonString = [self _jsonEscapedStringFromDictionary:args];
                
                NSString * replaceScript = [NSString stringWithFormat:@"replaceImageSrc(%@)", jsonString];
                [_webView stringByEvaluatingJavaScriptFromString:replaceScript];
                currentImageCount++;
            };
            
            if (data == nil) {
                [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
                    replaceImages(error);
                }];
            } else {
                replaceImages(nil);
//                [[self delegate] MCOMessageViewLoadingCompleted:self];
            }
        }
        
    }
    else{
//        [[self delegate] MCOMessageViewLoadingCompleted:self];
    }
}

- (NSString *) _jsonEscapedStringFromDictionary:(NSDictionary *)dictionary
{
	NSData * json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
	NSString * jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
	return jsonString;
}

- (NSURL *) _cacheJPEGImageData:(NSData *)imageData withFilename:(NSString *)filename
{
	NSString * path = [[NSTemporaryDirectory() stringByAppendingPathComponent:filename] stringByAppendingPathExtension:@"jpg"];
	[imageData writeToFile:path atomically:YES];
	return [NSURL fileURLWithPath:path];
}

- (MCOAbstractPart *) _partForCIDURL:(NSURL *)url
{
    return [_message partForContentID:[url resourceSpecifier]];
}

- (MCOAbstractPart *) _partForUniqueID:(NSString *)partUniqueID
{
    return [_message partForUniqueID:partUniqueID];
}

- (NSData *) _dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    NSData * data;
    NSString * partUniqueID = [part uniqueID];
    data = [[self delegate] MCOMessageView:self dataForPartWithUniqueID:partUniqueID];
    if (data == NULL) {
        [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
            [self _refresh];
        }];
    }
    return data;
}

- (BOOL)webView:(UIWebView *)webView1 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURLRequest *responseRequest = [self webView:webView1 resource:nil willSendRequest:request redirectResponse:nil fromDataSource:nil];
    if([request.URL.scheme isEqualToString:@"funnl"]){
        NSLog(@"funnl scheme detected");
        NSString *stringData = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"funnl://" withString:@""];
            [[self delegate] MCOMessageView:self getFunlShareString:stringData];
    }
    if(responseRequest == request) {
        return YES;
    } else {
        [webView1 loadRequest:responseRequest];
        return NO;
    }
}

- (NSURLRequest *)webView:(UIWebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource
{
    if ([[[request URL] scheme] isEqualToString:@"x-mailcore-msgviewloaded"]) {
        [self _loadImages];
    }
	
	return request;
}

- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg canPreviewPart:(MCOAbstractPart *)part
{
    static NSMutableSet * supportedImageMimeTypes = NULL;
    if (supportedImageMimeTypes == NULL) {
        supportedImageMimeTypes = [[NSMutableSet alloc] init];
        [supportedImageMimeTypes addObject:@"image/png"];
        [supportedImageMimeTypes addObject:@"image/gif"];
        [supportedImageMimeTypes addObject:@"image/jpg"];
        [supportedImageMimeTypes addObject:@"image/jpeg"];
    }
    static NSMutableSet * supportedImageExtension = NULL;
    if (supportedImageExtension == NULL) {
        supportedImageExtension = [[NSMutableSet alloc] init];
        [supportedImageExtension addObject:@"png"];
        [supportedImageExtension addObject:@"gif"];
        [supportedImageExtension addObject:@"jpg"];
        [supportedImageExtension addObject:@"jpeg"];
    }
    
    if ([supportedImageMimeTypes containsObject:[[part mimeType] lowercaseString]]) {
        return YES;
    }
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([supportedImageExtension containsObject:ext])
            return YES;
    }
    
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:canPreviewPart:)]) {
        return NO;
    }
    return [[self delegate] MCOMessageView:self canPreviewPart:part];
}

- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:templateValuesForHeader:)]) {
        return nil;
    }
    return [[self delegate] MCOMessageView:self templateValuesForHeader:header];
}

- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForPart:(MCOAbstractPart *)part
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:templateValuesForPartWithUniqueID:)]) {
        return nil;
    }
    return [[self delegate] MCOMessageView:self templateValuesForPartWithUniqueID:[part uniqueID]];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForMainHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForMainHeader:)]) {
        return nil;
    }
    return [[self delegate] MCOMessageView_templateForMainHeader:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForImage:(MCOAbstractPart *)header
{
    NSString * templateString;
    if ([[self delegate] respondsToSelector:@selector(MCOMessageView_templateForImage:)]) {
        templateString = [[self delegate] MCOMessageView_templateForImage:self];
    }
    else {
        templateString = @"<img src=\"{{URL}}\"/>";
    }
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForAttachment:(MCOAbstractPart *)part
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForAttachment:)]) {
        return NULL;
    }
    NSString * templateString = [[self delegate] MCOMessageView_templateForAttachment:self];
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
}

- (NSString *) MCOAbstractMessage_templateForMessage:(MCOAbstractMessage *)msg
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForMessage:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForMessage:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessage:(MCOAbstractMessagePart *)part
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForEmbeddedMessage:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForEmbeddedMessage:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessageHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForEmbeddedMessageHeader:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForEmbeddedMessageHeader:self];
}

- (NSString *) MCOAbstractMessage_templateForAttachmentSeparator:(MCOAbstractMessage *)msg
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView_templateForAttachmentSeparator:)]) {
        return NULL;
    }
    return [[self delegate] MCOMessageView_templateForAttachmentSeparator:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForPart:(NSString *)html
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:filteredHTMLForPart:)]) {
        return html;
    }
    return [[self delegate] MCOMessageView:self filteredHTMLForPart:html];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForMessage:(NSString *)html
{
    if (![[self delegate] respondsToSelector:@selector(MCOMessageView:filteredHTMLForMessage:)]) {
        return html;
    }
    return [[self delegate] MCOMessageView:self filteredHTMLForMessage:html];
}

- (NSData *) MCOAbstractMessage:(MCOAbstractMessage *)msg dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    return [self _dataForIMAPPart:part folder:folder];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchAttachmentIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (!_prefetchIMAPAttachmentsEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchImageIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (!_prefetchIMAPImagesEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}


#pragma mark -
-(UIWebView *)webView
{
    return _webView;
}

-(void) setHeaderView:(UIView *)view {
    
	// remove old header if there is one
	if (headerView) {
		if ([headerView superview] == self) {
			[headerView removeFromSuperview];
		}
		headerView = nil;
	}
	
    
	// set new one
	headerView = view;
	
	[self setNeedsLayout];
}

-(UIView*) headerView {
	return headerView;
}

-(void) setFooterView:(UIView *)view {
	
	// remove old footer if there is one
	if (footerView) {
		if ([footerView superview] == self) {
			[footerView removeFromSuperview];
		}
		footerView = nil;
	}
	
	// set new one
	footerView = view;
	
	[self setNeedsLayout];
}

-(UIView*) footerView {
	return footerView;
}

-(void) setHeaderViewHeight:(float)_height {
	headerViewHeight = _height;
    activityIndicator.frame = CGRectMake(150, headerViewHeight + 20, 25, 25);

	[self setNeedsLayout];
}

-(float) headerViewHeight {
	return headerViewHeight;
}

-(void) setFooterViewHeight:(float)_height {
	footerViewHeight = _height;
	[self setNeedsLayout];
}

-(float) footerViewHeight {
	return footerViewHeight;
}

- (void)recalculateContentHeight {
    NSString* bottomDivID = [NSString stringWithFormat:@"bottomdiv%u", arc4random()];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@" \
                                                          var ele = document.createElement('div'); \
                                                          ele.setAttribute('id', '%@'); \
                                                          ele.setAttribute('style', 'width: 100%%; height: 1px; clear: both;'); \
                                                          document.body.appendChild(ele);", bottomDivID]];
    
    // get the actual content size of the body
    self.actualContentHeight = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('%@').offsetTop", bottomDivID]] floatValue];
    if (self.actualContentHeight < 1.0) {
        self.actualContentHeight = self.frame.size.height / 2 - self.headerViewHeight - self.footerViewHeight;
    }
    
    self.actualContentWidth = self.webScrollView.contentSize.width;
    if (self.actualContentWidth < 1.0) {
        self.actualContentWidth = self.frame.size.width;
    }
    
    self.webScrollView.contentInset = UIEdgeInsetsMake(self.headerViewHeight, 0, self.footerViewHeight, 0);
    self.webScrollView.contentOffset = CGPointMake(0, 0-self.headerViewHeight);
    
    [self setNeedsLayout];
}

-(void) layoutHeaderAndFooterViews {
	
	if (self.webScrollView) {
		
		
		// get my frame size
		CGRect rcSelf = [self frame];
		
		// get scroll info
		CGPoint offset = self.webScrollView.contentOffset;
		CGSize contentSize = self.webScrollView.contentSize;
		
		// set content height
		contentSize.height = self.webScrollView.contentSize.width * self.actualContentHeight / self.actualContentWidth;
		self.webScrollView.contentSize = contentSize;
		
		if (self.headerView) {
			
            // position the header
			CGRect rcHeader = self.headerView.frame;
			rcHeader.origin.y = 0 - rcHeader.size.height;
			rcHeader.origin.x = offset.x;
			rcHeader.size.width = rcSelf.size.width;
			rcHeader.size.height = self.headerViewHeight;
			self.headerView.frame = rcHeader;
		}
		
		if (self.footerView) {
			
            // position the footer
			CGRect rcFooter = self.footerView.frame;
			rcFooter.origin.y = contentSize.height;
			rcFooter.origin.x = offset.x;
			rcFooter.size.width = rcSelf.size.width;
			rcFooter.size.height = self.footerViewHeight;
			self.footerView.frame = rcFooter;
        }
		
		
	}
}

-(void) layoutSubviews {
    
    
	// set content inset on scrollview
	if (self.webScrollView) {
		
		self.webView.frame = CGRectMake(0,
										0,
										self.frame.size.width,
										self.frame.size.height - 40);
	}
	else {
		// set frame of web control
		if (self.webView) {
			self.webView.frame = CGRectMake(0,
											self.headerViewHeight,
											self.frame.size.width,
											self.frame.size.height - self.footerViewHeight - 40);
		}
	}
	[self layoutHeaderAndFooterViews];
}



#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)sender didFailLoadWithError:(NSError *)error {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
		[self.webViewDelegate webView:sender didFailLoadWithError:error];
	}
}

-(void) webViewDidFinishLoad:(UIWebView *)sender {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
		[self.webViewDelegate webViewDidFinishLoad:sender];
	}
	
    self.webScrollView = self.webView.scrollView;
    self.webScrollView.scrollsToTop = YES;
    
    for (UIView* shadowView in [self.webScrollView subviews])
    {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
    }
    
    if (self.webScrollView.delegate)
        self.oldScrollViewDelegate = self.webScrollView.delegate;
    else if ([self.webView conformsToProtocol:@protocol(UIScrollViewDelegate)])
        self.oldScrollViewDelegate = self.webView;
    
    //self.webScrollView.delegate = self;
    
    if (self.headerView) {
        [self.webScrollView addSubview:self.headerView];
    }
    
    if (self.footerView) {
        [self.webScrollView addSubview:self.footerView];
    }
    
    NSString* jsSetViewport =
    @"var meta = document.createElement('meta'); \
    meta.name = 'viewport'; \
    meta.content = 'user-scalable=yes, initial-scale=1.0, maximum-scale=5.0'; \
    document.getElementsByTagName('head')[0].appendChild(meta);";
    [self.webView stringByEvaluatingJavaScriptFromString:jsSetViewport];
    
//    [[self delegate] MCOMessageViewLoadingCompleted:self];

    [self recalculateContentHeight];
	
    [self setNeedsLayout];
}

- (void)webViewDidStartLoad:(UIWebView *)sender {
    [activityIndicator startAnimating];
    // forward web view delegate invocations
	if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
		[self.webViewDelegate webViewDidStartLoad:sender];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate
//delegate not getting called
-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
//    self.headerView.frame = CGRectMake(scrollView.contentOffset.x, self.headerView.frame.origin.x, self.headerView.frame.size.width, self.headerView.frame.size.height);
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
//		[self.oldScrollViewDelegate scrollViewDidScroll:scrollView];
//	}
//	[self layoutHeaderAndFooterViews];
    AppDelegate *tempAppDelegate = APPDELEGATE;
    tempAppDelegate.headerViewForMailDetailView.frame = CGRectMake(scrollView.contentOffset.x, tempAppDelegate.headerViewForMailDetailView.frame.origin.y, tempAppDelegate.headerViewForMailDetailView.frame.size.width, tempAppDelegate.headerViewForMailDetailView.frame.size.height);
}

//-(void) scrollViewDidZoom:(UIScrollView *)scrollView {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
//		[self.oldScrollViewDelegate scrollViewDidZoom:scrollView];
//	}
//	[self layoutHeaderAndFooterViews];
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
//		[self.oldScrollViewDelegate scrollViewWillBeginDragging:scrollView];
//	}
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
//		[self.oldScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//	}
//}
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
//		[self.oldScrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
//	}
//}
//
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
//		
//		[self.oldScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
//	}
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
//		
//		[self.oldScrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
//	}
//}
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
//		
//		return [self.oldScrollViewDelegate viewForZoomingInScrollView:scrollView];
//	}
//	else
//		return nil;
//}
//
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view  {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
//		
//		[self.oldScrollViewDelegate scrollViewWillBeginZooming:scrollView withView:view];
//	}
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
//		
//		[self.oldScrollViewDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
//	}
//	
//	[self layoutHeaderAndFooterViews];
//}
//
//- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
//{
//    return YES;
//}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//	if ([self.oldScrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
//		
//		[self.oldScrollViewDelegate scrollViewDidScrollToTop:scrollView];
//	}
//}


@end
