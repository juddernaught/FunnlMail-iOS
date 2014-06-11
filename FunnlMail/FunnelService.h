//
//  FunnelService.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunnelModel.h"
//#import "FilterModel.h"
@interface FunnelService : NSObject

+(FunnelService *)instance;

-(BOOL) insertFunnel:(FunnelModel *)funnelModel;
-(BOOL) updateFunnel:(FunnelModel *)funnelModel;
-(NSArray *) allFunnels;
-(FunnelModel *) emailServersWithFunnelName:(NSString *)funnelName;
-(BOOL) deleteFunnel:(NSString *)funnelId;

@end
