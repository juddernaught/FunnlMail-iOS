//
//  FMRenderingOperation.h
//  FunnlMail
//
//  Created by shrinivas on 06/10/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface FMRenderingOperation : NSOperation
{
  MCOIMAPMessage *messageObj;
  BOOL isPrimaryflag;
}
- (id)initWithMessage:(MCOIMAPMessage *)message andPrimaryFlag:(BOOL)flag;
@end
