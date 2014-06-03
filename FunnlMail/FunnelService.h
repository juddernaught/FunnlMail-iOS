//
//  FunnelService.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunnelModel.h"

@interface FunnelService : NSObject

+(FunnelService *)instance;

-(BOOL) insertEmailServer:(FunnelModel *)funnelModel;
-(NSArray *) allFunnels;
-(FunnelModel *) emailServersWithFunnelName:(NSString *)funnelName;
-(BOOL) deleteFunnel:(NSString *)funnelName;

@end
