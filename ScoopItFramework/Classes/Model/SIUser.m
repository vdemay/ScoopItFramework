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


-(id) init:(SIScoopIt*)_scoopIt withLid:(int)_lid {
	self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
		self.lid = _lid;
		self.connectedUser = NO;
	}
	return self;
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
    if (!connectedUser) {
        return [NSString stringWithFormat:@"%@api/1/profile?id=%d", BASE_URL, self.lid];
    } else {
        return [NSString stringWithFormat:@"%@api/1/profile", BASE_URL];
    }
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
        //TODO sharer
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
