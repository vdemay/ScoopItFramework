//
//  SIUser.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIUser.h"

#import "SITopic.h"
#import "SIScoopIt.h"
#import "SISharer.h"

@implementation SIUser


@synthesize lid;
@synthesize name;
@synthesize shortName;
@synthesize bio;
@synthesize avatarUrl;
@synthesize sharers;
@synthesize curatedTopics;
@synthesize followedTopics;
@synthesize connectedUser;
@synthesize nbCuratedPost;
@synthesize nbCurablePost;


-(id) init:(SIScoopIt*)_scoopIt withLid:(int)_lid {
	self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
		self.lid = _lid;
		self.connectedUser = NO;
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



-(id) initWithConnectedUser:(SIScoopIt*)_scoopIt {
    self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
		self.connectedUser = YES;
	}
	return self;
}

- (NSString*) generateUrl {
    NSString *url = nil;
    if (!connectedUser) {
        url =  [NSString stringWithFormat:@"%@api/1/profile?id=%d", BASE_URL, self.lid];
    } else {
        url =  [NSString stringWithFormat:@"%@api/1/profile?1=1", BASE_URL];
    }
    
    url = [NSString stringWithFormat:@"%@&curated=%d&curable=%d", url, self.nbCuratedPost, self.nbCurablePost];
    
    return url;
}
- (void) populateModel:(NSDictionary*) dic {
	NSDictionary* topicJson = [dic objectForKey:@"user"];
	[self getFromDictionary:topicJson];
}

-(void) getFromDictionary:(NSDictionary*) dic {
	if (dic != nil) {
		self.lid = [[dic objectForKey:@"id"] intValue];
		self.name = [dic objectForKey:@"name"];
		self.shortName = [dic objectForKey:@"shortName"];
		self.bio = [dic objectForKey:@"bio"];
		self.avatarUrl = [dic objectForKey:@"avatarUrl"];
        
        NSMutableArray* sharersToAdd  = [[NSMutableArray alloc] init];
        NSArray* sharersJson = [dic objectForKey:@"sharers"];
        for (NSDictionary* sharerJson in sharersJson) {
            SISharer *sharer = [[SISharer alloc] init];
            [sharer populateModel:sharerJson];
            [sharersToAdd addObject:sharer];
        }
        self.sharers = [[NSArray alloc] initWithArray:sharersToAdd];
        TT_RELEASE_SAFELY(sharersJson);
        
		NSArray* curatedTopicsJson = [dic objectForKey:@"curatedTopics"];
		NSMutableArray* curatedTopicsToAdd = [[NSMutableArray alloc] init];
		for (NSDictionary* curatedTopicJson in curatedTopicsJson) {
			SITopic *topic = [[SITopic alloc] init];
			[topic getFromDictionary:curatedTopicJson];
			[curatedTopicsToAdd addObject:topic];
		}
		self.curatedTopics = [[NSArray alloc] initWithArray:curatedTopicsToAdd];
        NSArray* followedTopicsJson = [dic objectForKey:@"followedTopics"];
		NSMutableArray* followedTopicsToAdd = [[NSMutableArray alloc] init];
		for (NSDictionary* followedTopicJson in followedTopicsJson) {
			SITopic *topic = [[SITopic alloc] init];
			[topic getFromDictionary:followedTopicJson];
			[followedTopicsToAdd addObject:topic];
		}
		self.followedTopics = [[NSArray alloc] initWithArray:followedTopicsToAdd];
    }
}

- (void) dealloc
{
	[name release];
	name = nil;
	[shortName release];
	shortName = nil;
	[bio release];
	bio = nil;
	[sharers release];
	sharers = nil;
	[curatedTopics release];
	curatedTopics = nil;
	[followedTopics release];
	followedTopics = nil;
	[super dealloc];
}


@end
