//
//  SITopic.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SITopic.h"
#import "SIScoopIt.h"
#import "NSString+SBJSON.h"

#import "SIUser.h"
#import "SIPost.h"

@interface SITopic (Private)
- (void) topicAction:(TopicAction)action withParameters:(NSArray*) params;
- (void) topicActionRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) topicActionRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
@end

@implementation SITopic

@synthesize lid;
@synthesize imageUrl;
@synthesize smallImageUrl;
@synthesize mediumImageUrl;
@synthesize largeImageUrl;
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

@synthesize actionDelegate;

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
		self.smallImageUrl = [dic objectForKey:@"smallImageUrl"];
		self.mediumImageUrl = [dic objectForKey:@"mediumImageUrl"];
		self.largeImageUrl = [dic objectForKey:@"largeImageUrl"];
		self.description = [dic objectForKey:@"description"];
		self.name = [dic objectForKey:@"name"];
		self.shortName = [dic objectForKey:@"shortName"];
		self.url = [dic objectForKey:@"url"];
		self.isCurator = [[dic objectForKey:@"isCurator"] boolValue];
		self.curatedPostCount = [[dic objectForKey:@"curatedPostCount"] intValue];
		self.curablePostCount = [[dic objectForKey:@"curablePostCount"] intValue];
		self.unreadPostCount = [[dic objectForKey:@"unreadPostCount"] intValue];
		
		NSDictionary* creatorJson = [dic objectForKey:@"creator"];
		self.creator = [[[SIUser alloc] init] autorelease];
		[self.creator getFromDictionary:creatorJson];
		
		NSDictionary* pinnedPostJson = [dic objectForKey:@"pinnedPost"]; 
		self.pinnedPost = [[[SIPost alloc] init] autorelease];
		[self.pinnedPost getFromDictionary:pinnedPostJson];
		
		NSArray* curablePostsJson = [dic objectForKey:@"curablePosts"];
		NSMutableArray* curablePostsToAdd = [[NSMutableArray alloc] init];
		for (NSDictionary* curablePostJson in curablePostsJson) {
			SIPost *post = [[SIPost alloc] init];
			[post getFromDictionary:curablePostJson];
			[curablePostsToAdd addObject:post];
            TT_RELEASE_SAFELY(post);
		}
		self.curablePosts = [[[NSArray alloc] initWithArray:curablePostsToAdd] autorelease];
        TT_RELEASE_SAFELY(curablePostsToAdd);
		
		NSArray* curatedPostsJson = [dic objectForKey:@"curatedPosts"];
		NSMutableArray* curatedPostsToAdd = [[NSMutableArray alloc] init];
		for (NSDictionary* curatedPostJson in curatedPostsJson) {
			SIPost *post = [[SIPost alloc] init];
			[post getFromDictionary:curatedPostJson];
			[curatedPostsToAdd addObject:post];
            TT_RELEASE_SAFELY(post);
		}
		self.curatedPosts = [[[NSArray alloc] initWithArray:curatedPostsToAdd] autorelease];
        TT_RELEASE_SAFELY(curatedPostsToAdd);
        
        
        NSArray* topicTagsJson = [dic objectForKey:@"tags"];
        NSMutableArray* topicTagsToAdd = [[NSMutableArray alloc] init];
        for (NSDictionary* topicTagJson in topicTagsJson) {
			SITopicTag *tag = [[SITopicTag alloc] init];
			[tag getFromDictionary:topicTagJson];
			[topicTagsToAdd addObject:tag];
            TT_RELEASE_SAFELY(tag);
		}
		self.tags = [[[NSArray alloc] initWithArray:topicTagsToAdd] autorelease];
        TT_RELEASE_SAFELY(topicTagsToAdd);
	}	
}

- (void) dealloc {
    //detach delegate
    actionDelegate = nil;
    
	[imageUrl release];
	imageUrl = nil;
    
	[smallImageUrl release];
	smallImageUrl = nil;
    
	[mediumImageUrl release];
	mediumImageUrl = nil;
    
	[largeImageUrl release];
	largeImageUrl = nil;
    
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

-(void) follow {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"follow"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                      value:[NSString stringWithFormat:@"%d",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    [self topicAction:TopicActionFollow withParameters:params];
}

-(void) unfollow {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"unfollow"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%d",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    [self topicAction:TopicActionUnfollow withParameters:params];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) topicAction:(TopicAction)action withParameters:(NSArray*) params {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[SIScoopIt shared].key
													secret:[SIScoopIt shared].secret];
	
	NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/1/topic", BASE_URL]];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:_url
																   consumer:consumer
																	  token:[SIScoopIt shared].accessToken
																	  realm:nil   // our service provider doesn't specify a realm
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[request setHTTPMethod:@"POST"];
    request.tag = action;
    if (params != nil) {
        [request setParameters:params];
    }
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] retain];
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(topicActionRequest:didFinishWithData:)
				  didFailSelector:@selector(topicctionRequest:didFailWithError:)];
    
    [_fetchers addObject:fetcher];
    
    TT_RELEASE_SAFELY(consumer);
    TT_RELEASE_SAFELY(fetcher);
    TT_RELEASE_SAFELY(request);
}

//////////////////////////////////////////// DELEGATE /////////////////////////////////////////////

- (void)topicActionRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    TTDASSERT([data isKindOfClass:[NSData class]]);
    NSDictionary* feed = nil;
	if ([data isKindOfClass:[NSData class]]) {
		NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		feed = [json JSONValue];
        TT_RELEASE_SAFELY(json);
    }
    if (actionDelegate != nil) {
        [actionDelegate topic:self actionSucceeded:ticket.request.tag withData:feed];
    }
}

- (void) topicActionRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    if (actionDelegate != nil) {
        [actionDelegate topic:self actionFailed:ticket.request.tag];
    }
}



@end
