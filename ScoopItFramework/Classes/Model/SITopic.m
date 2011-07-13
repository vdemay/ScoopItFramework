//
//  SITopic.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SITopic.h"
#import "SIScoopIt.h"

#import "SIUser.h"
#import "SIPost.h"

@implementation SITopic

@synthesize lid;
@synthesize imageUrl;
@synthesize description;
@synthesize name;
@synthesize shortName;
@synthesize url;
@synthesize isCurator;
@synthesize curablePostCount;
@synthesize curatedPostCount;
@synthesize unreadPostCount;
@synthesize creator;
@synthesize pinnedPost;
@synthesize curablePosts;
@synthesize curatedPosts;
@synthesize tags;

@synthesize nbCuratedPost;
@synthesize nbCurablePost;

- (id) init:(SIScoopIt*) _scoopIt withLid:(int) _lid
{
	self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
		self.lid = _lid;
        nbCuratedPost = 30;
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
	return [NSString stringWithFormat:@"%@api/1/topic?curated=%d&curable=%d&id=%d", BASE_URL, nbCuratedPost, nbCurablePost, self.lid];
}
- (void) populateModel:(NSDictionary*) dic {
	NSDictionary* topicJson = [dic objectForKey:@"topic"];
	[self getFromDictionary:topicJson];
}


-(void) getFromDictionary:(NSDictionary*) dic {
	if (dic != nil) {
		self.lid = [[dic objectForKey:@"id"] intValue];
		self.imageUrl = [dic objectForKey:@"imageUrl"];
		self.description = [dic objectForKey:@"description"];
		self.name = [dic objectForKey:@"name"];
		self.shortName = [dic objectForKey:@"shortName"];
		self.url = [dic objectForKey:@"url"];
		self.isCurator = [[dic objectForKey:@"isCurator"] boolValue];
		self.curatedPostCount = [[dic objectForKey:@"curatedPostCount"] intValue];
		self.curablePostCount = [[dic objectForKey:@"curablePostCount"] intValue];
		self.unreadPostCount = [[dic objectForKey:@"unreadPostCount"] intValue];
		
		NSDictionary* creatorJson = [dic objectForKey:@"creator"];
		self.creator = [[SIUser alloc] init];
		[self.creator getFromDictionary:creatorJson];
		
		NSDictionary* pinnedPostJson = [dic objectForKey:@"pinnedPost"]; 
		self.pinnedPost = [[SIPost alloc] init];
		[self.pinnedPost getFromDictionary:pinnedPostJson];
		
		NSArray* curablePostsJson = [dic objectForKey:@"curablePosts"];
		NSMutableArray* curablePostsToAdd = [[NSMutableArray alloc] init];
		for (NSDictionary* curablePostJson in curablePostsJson) {
			SIPost *post = [[SIPost alloc] init];
			[post getFromDictionary:curablePostJson];
			[curablePostsToAdd addObject:post];
		}
		self.curablePosts = [[NSArray alloc] initWithArray:curablePostsToAdd];
		
		NSArray* curatedPostsJson = [dic objectForKey:@"curatedPosts"];
		NSMutableArray* curatedPostsToAdd = [[NSMutableArray alloc] init];
		for (NSDictionary* curatedPostJson in curatedPostsJson) {
			SIPost *post = [[SIPost alloc] init];
			[post getFromDictionary:curatedPostJson];
			[curatedPostsToAdd addObject:post];
		}
		self.curatedPosts = [[NSArray alloc] initWithArray:curatedPostsToAdd];
	}	
}

- (void) dealloc {
	[imageUrl release];
	imageUrl = nil;
	[description release];
	description = nil;
	[name release];
	name = nil;
	[shortName release];
	shortName = nil;
	[url release];
	url = nil;
	[creator release];
	creator = nil;
	[pinnedPost release];
	pinnedPost = nil;
	[curablePosts release];
	curablePosts = nil;
	[curatedPosts release];
	curatedPosts = nil;
	[tags release];
	tags = nil;
	[super dealloc];
}


@end
