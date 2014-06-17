//
//  MessageFilterXRefService.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageFilterXRefService : NSObject

+(MessageFilterXRefService *)instance;

-(BOOL) insertMessageXRefMessageID:(NSString *)messageID funnelId:(NSString *)funnelId;
-(BOOL) deleteXRefWithMessageID:(NSString *)messageID funnelId:(NSString *)funnelId;
-(BOOL) deleteXRefWithMessageID:(NSString *)messageID;
-(BOOL) deleteXRefWithFunnelId:(NSString *)funnelId;
-(NSArray *) xrefWithMessageID:(NSString *)messageID;
-(NSArray *) xrefWithFunnelId:(NSString *)funnelId;
-(NSArray *) messagesWithFunnelId:(NSString*)funnelId;
@end
