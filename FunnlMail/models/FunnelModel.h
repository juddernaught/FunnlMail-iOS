//
//  FilterModel.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunnelModel : NSObject

@property (strong) UIColor *barColor;
@property (assign) BOOL skipFlag;
//below parameter is replaced by "funnelName" in some case
@property (copy) NSString *filterTitle;
@property (assign) NSInteger newMessageCount;
@property (copy) NSDate *dateOfLastMessage;
@property (copy) NSMutableArray *sendersArray;
@property (copy) NSMutableArray *subjectsArray;
//newly added by iauro001 on 11th June 2014
@property (copy) NSString *funnelId;
@property (copy) NSString *funnelName;
@property (copy) NSString *emailAddresses;
@property (copy) NSString *phrases;

- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage;
- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage sendersArray:(NSMutableArray*)sendersArray subjectsArray:(NSMutableArray*)subjectsArray;
- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage sendersArray:(NSMutableArray*)sendersArray subjectsArray:(NSMutableArray*)subjectsArray skipAllFlag:(BOOL)flag;
- (NSMutableDictionary*) getEmailsForFunnl: (NSString *) funnlName ;
@end
