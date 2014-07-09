//
//  MessageModel.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (copy) NSString *messageID;
@property (copy) NSString *messageJSON;
@property (assign) BOOL read;
@property (assign) int skipFlag;
@property (strong) NSDate *date;
//newly added by iauro001 on June 17th 2014
@property (strong) NSString *gmailThreadID;
@property int numberOfEmailInThread;
@property (strong, nonatomic) NSString *messageBodyToBeRendered;
@property (strong, nonatomic) NSString *messageHTMLBody;
@property (strong, nonatomic) NSString *funnelJson;
@end
