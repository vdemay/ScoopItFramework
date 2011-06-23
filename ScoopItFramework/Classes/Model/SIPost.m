//
//  SIPost.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIPost.h"
#import "OAuthConsumer.h"

@interface SIPost (Private)
- (void) postAction:(PostAction)action withParameters:(NSArray*) params;
@end



@implementation SIPost

@synthesize lid;
@synthesize content;
@synthesize title;
@synthesize thanksCount;
@synthesize source;
@synthesize url;
@synthesize scoopUrl;
@synthesize imageUrl;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize imageSize;
@synthesize imagePosition;
@synthesize imageUrls;
@synthesize commentsCount;
@synthesize isUserSuggestion;
@synthesize publicationDate;
@synthesize currationDate;
@synthesize postComments;
@synthesize thanked;
@synthesize topic;

@synthesize actionDelegate;

- (id) init:(SIScoopIt*) _scoopIt withLid:(int) _lid
{
	self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
		self.lid = lid;
	}
	return self;
}


-(void) getFromDictionary:(NSDictionary*) dic {
	if (dic != nil) {
		self.lid = [[dic objectForKey:@"id"] intValue];
		self.content = [dic objectForKey:@"content"];
		self.title = [dic objectForKey:@"title"];
		self.thanksCount = [[dic objectForKey:@"thanksCount"] intValue];
		self.source = [[SISource alloc] init];
		[self.source getFromDictionary:[dic objectForKey:@"source"]];
		self.url = [dic objectForKey:@"url"];
		self.scoopUrl = [dic objectForKey:@"scoopUrl"];
		self.imageUrl = [dic objectForKey:@"imageUrl"];
		self.imageWidth = [[dic objectForKey:@"imageWidth"] intValue];
		self.imageHeight = [[dic objectForKey:@"imageHeight"] intValue];
		self.imageSize = [[dic objectForKey:@"imageSize"] intValue];
		NSArray *imageUrlsJson = [dic objectForKey:@"imageUrls"];
        self.imageUrls = [[NSArray alloc] initWithArray:imageUrlsJson];
		self.commentsCount = [[dic objectForKey:@"commentsCount"] intValue];
		self.isUserSuggestion = [[dic objectForKey:@"isUserSuggestion"] boolValue];
		self.publicationDate = [[dic objectForKey:@"publicationDate"] doubleValue];
		self.currationDate = [[dic objectForKey:@"currationDate"] doubleValue];
		//TODO Comments
		self.thanked = [[dic objectForKey:@"thanked"] boolValue];
		NSDictionary* topicJson = [dic objectForKey:@"topic"];
		if (topicJson) {
			self.topic = [[SITopic alloc] init];
			[self.topic getFromDictionary:topicJson];
		}
		
	}
}

- (void) dealloc
{
	[content release];
	content = nil;
	[title release];
	title = nil;
	[source release];
	source = nil;
	[url release];
	url = nil;
	[scoopUrl release];
	scoopUrl = nil;
	[imagePosition release];
	imagePosition = nil;
	[imageUrls release];
	imageUrls = nil;
	[postComments release];
	postComments = nil;
	[topic release];
	topic = nil;
	
	[super dealloc];
}

///////////////////////////////////// ACTIONS //////////////////////////////////////
- (void) thanks {
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"thank"];
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%d", self.lid]];
    NSArray *params = [NSArray arrayWithObjects:actionParam, idParam, nil];
    
    [self postAction:PostActionThanks withParameters:params];
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) postAction:(PostAction)action withParameters:(NSArray*) params {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[SIScoopIt shared].key
													secret:[SIScoopIt shared].secret];
	
	NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/1/post", BASE_URL]];
	
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
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(postActionRequest:didFinishWithData:)
				  didFailSelector:@selector(postActionRequest:didFailWithError:)];
}

//////////////////////////////////////////// DELEGATE /////////////////////////////////////////////

- (void)postActionRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    TTDASSERT([data isKindOfClass:[NSData class]]);
    NSDictionary* feed = nil;
	if ([data isKindOfClass:[NSData class]]) {
		NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(json);
		feed = [json JSONValue];
    }
    
    if (ticket.request.tag == PostActionThanks) {
        //update post
        int _thankCount = [[feed objectForKey:@"thankCount"] intValue];
        int _thanked = [[feed objectForKey:@"thanked"] boolValue];
        
        self.thanked = _thanked;
        self.thanksCount = _thankCount;
    }
    
    if (actionDelegate != nil) {
        [actionDelegate post:self actionSucceeded:ticket.request.tag withData:feed];
    }
    //TT_RELEASE_SAFELY(feed);
}

- (void) postActionRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    if (actionDelegate != nil) {
        [actionDelegate post:self actionFailed:ticket.request.tag];
    }
}


@end
