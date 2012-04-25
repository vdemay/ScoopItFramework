//
//  SIProfile.m
//  ReScoop
//
//  Created by Vincent Demay on 25/04/12.
//  Copyright (c) 2012 Goojet. All rights reserved.
//

#import "SIProfile.h"
#import "SIModel.h"
#import "SIScoopIt.h"

@implementation SIProfile

@synthesize stats = _stats;
@synthesize user = _user;

@synthesize lid;
@synthesize nbCuratedPost;
@synthesize nbCurablePost;
@synthesize getCuratedTopics;
@synthesize getFollowedTopics;


-(id) init:(SIScoopIt*)_scoopIt withLid:(int)_lid {
	self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
		self.lid = _lid;
        self.getCuratedTopics = YES;
        self.getFollowedTopics = YES;
	}
	return self;
}

- (void) setNbCurablePost:(int)nb {
    nbCurablePost = nb;
    [self invalidate:YES];
}

- (void) setNbCuratedPost:(int)nb {
    nbCuratedPost = nb;
    [self invalidate:YES];
}


- (NSString*) generateUrl {
    NSString *url = nil;
    url =  [NSString stringWithFormat:@"%@api/1/profile?id=%d", BASE_URL, self.lid];
         
    url = [NSString stringWithFormat:@"%@&curated=%d&curable=%d", url, self.nbCuratedPost, self.nbCurablePost];
    
    if (!getCuratedTopics) {
        url = [NSString stringWithFormat:@"%@&getCuratedTopics=false", url];
    }
    if (!getFollowedTopics) {
        url = [NSString stringWithFormat:@"%@&getFollowedTopics=false", url];
    }
    
    return url;
}

- (void) populateModel:(NSDictionary*) dic {
    self.stats = [[SIStats alloc] init];
	[self.stats populateModel:dic];
    self.user = [[SIUser alloc] init];
    [self.user populateModel:dic];
}

@end
