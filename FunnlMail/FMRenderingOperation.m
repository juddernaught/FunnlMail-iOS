//
//  FMRenderingOperation.m
//  FunnlMail
//
//  Created by shrinivas on 06/10/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FMRenderingOperation.h"
#import "EmailService.h"
//#import "<#header#>"
@implementation FMRenderingOperation
- (id)initWithMessage:(MCOIMAPMessage *)message andPrimaryFlag:(BOOL)flag {
  self = [super init];
  if (self) {
    messageObj = message;
    isPrimaryflag = flag;
  }
  return self;
}

-(void)main {
  MCOIMAPMessageRenderingOperation *messageRenderingOperation = [[EmailService instance].imapSession plainTextBodyRenderingOperationWithMessage:messageObj folder:INBOX];
  NSString *uidKey = [NSString stringWithFormat:@"%d",messageObj.uid];
  [messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
      if (plainTextBodyString) {
        if (plainTextBodyString.length > 0) {
          if ([[plainTextBodyString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
            plainTextBodyString= [plainTextBodyString substringWithRange:NSMakeRange(1, plainTextBodyString.length - 1)];
          }
          
          if(plainTextBodyString.length > 150){
            NSRange stringRange = {0,150};
            plainTextBodyString = [plainTextBodyString substringWithRange:stringRange];
          }
          NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
          paramDict[uidKey] = [self removeStartingSpaceFromString:plainTextBodyString];
          [[MessageService instance] updateMessageWithDictionary:paramDict];
        }
        else {
                  
        }
    }
    else {
              
    }
  }];
  
  if (isPrimaryflag) {
    MCOIMAPMessageRenderingOperation * op = [[EmailService instance].imapSession htmlBodyRenderingOperationWithMessage:messageObj folder:@"INBOX"];
    
    [op start:^(NSString * htmlString, NSError * error) {
      NSArray *tempArray = [htmlString componentsSeparatedByString:@"<head>"];
      if (tempArray.count > 1) {
        htmlString = [tempArray objectAtIndex:1];
      }
      else {
        tempArray = [htmlString componentsSeparatedByString:@"Subject:"];
        if (tempArray.count > 1) {
          htmlString = [tempArray objectAtIndex:1];
        }
      }
      NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
      if(htmlString){
        paramDict[uidKey] = htmlString;
        [[MessageService instance] updateMessageWithHTMLContent:paramDict];
      }
    }];
  }
}

- (NSString *)removeStartingSpaceFromString:(NSString*)sourceString {
    if (sourceString.length > 1) {
        if ([[sourceString substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
            return [sourceString substringWithRange:NSMakeRange(1, sourceString.length -1)];
        }
        return sourceString;
    }
    else
        return sourceString;
}

@end
