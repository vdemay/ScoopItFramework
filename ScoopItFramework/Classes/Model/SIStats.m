//
//  SIStats.m
//  ReScoop
//
//  Created by Vincent Demay on 25/04/12.
//  Copyright (c) 2012 Goojet. All rights reserved.
//

#import "SIStats.h"

@implementation SIStats

@synthesize todayUniqueVisitors, todayViews, views, uniqueVisitors;

- (void) populateModel:(NSDictionary*) dic {
	NSDictionary* topicJson = [dic objectForKey:@"stats"];
	[self getFromDictionary:topicJson];
}

- (void) getFromDictionary:(NSDictionary*) dic {
	if (dic != nil) {
		self.todayUniqueVisitors = [[dic objectForKey:@"uvp"] longValue];
        self.todayViews = [[dic objectForKey:@"vp"] longValue];
        self.uniqueVisitors = [[dic objectForKey:@"uv"] longValue];
        self.views = [[dic objectForKey:@"v"] longValue];
        
    }
}

@end
