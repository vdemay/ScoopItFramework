//
//  SIPost.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIPost.h"
#import "OAuthConsumer.h"
#import "NSString+SBJSON.h"

@interface SIPost (Private)
- (void) postAction:(PostAction)action withParameters:(NSArray*) params;
- (void) postActionRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) postActionRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
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
@synthesize smallImageUrl;
@synthesize mediumImageUrl;
@synthesize largeImageUrl;
@synthesize commentsCount;
@synthesize isUserSuggestion;
@synthesize publicationDate;
@synthesize currationDate;
@synthesize postComments;
@synthesize thanked;
@synthesize topic;
@synthesize pagesView;
@synthesize reactionsCount;
@synthesize tags;

@synthesize actionDelegate;

- (id) init:(SIScoopIt*) _scoopIt withLid:(long long) _lid
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
		self.lid = [[dic objectForKey:@"id"] longLongValue];
		self.content = [dic objectForKey:@"content"];
		self.title = [dic objectForKey:@"title"];
		self.thanksCount = [[dic objectForKey:@"thanksCount"] intValue];
		self.source = [[[SISource alloc] init] autorelease] ;
		[self.source getFromDictionary:[dic objectForKey:@"source"]];
		self.url = [dic objectForKey:@"url"];
		self.scoopUrl = [dic objectForKey:@"scoopUrl"];
        self.imagePosition = [dic objectForKey:@"imagePosition"];
		self.imageUrl = [dic objectForKey:@"imageUrl"];
		self.smallImageUrl = [dic objectForKey:@"smallImageUrl"];
		self.mediumImageUrl = [dic objectForKey:@"mediumImageUrl"];
		self.largeImageUrl = [dic objectForKey:@"largeImageUrl"];
		self.imageWidth = [[dic objectForKey:@"imageWidth"] intValue];
		self.imageHeight = [[dic objectForKey:@"imageHeight"] intValue];
		self.imageSize = [[dic objectForKey:@"imageSize"] intValue];
		self.imageUrls = [NSMutableArray arrayWithArray:[dic objectForKey:@"imageUrls"]];
		self.commentsCount = [[dic objectForKey:@"commentsCount"] intValue];
		self.reactionsCount = [[dic objectForKey:@"reactionsCount"] intValue];
		self.isUserSuggestion = [[dic objectForKey:@"isUserSuggestion"] boolValue];
		self.publicationDate = [[dic objectForKey:@"publicationDate"] doubleValue];
		self.currationDate = [[dic objectForKey:@"curationDate"] doubleValue];
        self.pagesView = [[dic objectForKey:@"pagesView"] intValue];
		//TODO Comments
		self.thanked = [[dic objectForKey:@"thanked"] boolValue];
		NSDictionary* topicJson = [dic objectForKey:@"topic"];
		if (topicJson) {
			self.topic = [[[SITopic alloc] init] autorelease];
			[self.topic getFromDictionary:topicJson];
		}
        self.tags = [NSArray arrayWithArray:[dic objectForKey:@"tags"]];
		
	}
}

- (void) populateModel:(NSDictionary*) dic {
    [self getFromDictionary:dic];
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
	
    [imageUrl release];
	imageUrl = nil;
	
    [smallImageUrl release];
	smallImageUrl = nil;
	
    [mediumImageUrl release];
	mediumImageUrl = nil;
	
    [largeImageUrl release];
	largeImageUrl = nil;
	
    [postComments release];
	postComments = nil;
	
    [topic release];
	topic = nil;
    
    [tags release];
    tags = nil;

	
	[super dealloc];
}

///////////////////////////////////// ACTIONS //////////////////////////////////////
- (void) thanks {
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"thank"];
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld", self.lid]];
    NSArray *params = [NSArray arrayWithObjects:actionParam, idParam, nil];
    TT_RELEASE_SAFELY(actionParam);
    TT_RELEASE_SAFELY(idParam);
    
    [self postAction:PostActionThanks withParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) pin {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"pin"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    [self postAction:PostActionDelete withParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) commentWithMessage:(NSString*) message {
    
    if (!self.topic) {
        [self postActionRequest:nil didFailWithError:[NSError errorWithDomain:@"Can not comment a post not yet accpeted" code:0 userInfo:nil]];
        return;
    }
    
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"comment"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    OARequestParameter *commentTextParam = [[OARequestParameter alloc] initWithName:@"commentText"
                                                                     value:message];
    [params addObject:commentTextParam];
    TT_RELEASE_SAFELY(commentTextParam);
    
    
    [self postAction:PostActionComment withParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) edit {
    //https://issues.koorjet.com/browse/IPHIT-32
    /*if (!self.publicationDate) {
        [self postActionRequest:nil didFailWithError:[NSError errorWithDomain:@"Can not edit a post not yet accpeted" code:0 userInfo:nil]];
        return;
    }*/
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"edit"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    
    OARequestParameter *titleParam = [[OARequestParameter alloc] initWithName:@"title"
                                                                              value:self.title];
    [params addObject:titleParam];
    TT_RELEASE_SAFELY(titleParam);
    
    OARequestParameter *contentParam = [[OARequestParameter alloc] initWithName:@"content"
                                                                        value:self.content];
    [params addObject:contentParam];
    TT_RELEASE_SAFELY(contentParam);
    
    if (self.imageUrl == nil) {
        self.imageUrl = @"";
    }
    OARequestParameter *imageUrlParam = [[OARequestParameter alloc] initWithName:@"imageUrl"
                                                                          value:self.imageUrl];
    [params addObject:imageUrlParam];
    TT_RELEASE_SAFELY(imageUrlParam);
    
    [self postAction:PostActionEdit withParameters:params];
}

//////////////////////////////////////////////////////////////////////////////

- (void) saveTags {
    if (!self.publicationDate) {
        [self postActionRequest:nil didFailWithError:[NSError errorWithDomain:@"Can not set tags on a post not yet accepted" code:0 userInfo:nil]];
        return;
    }
    
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"edit"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    for (NSString *tag in self.tags) {
        OARequestParameter *tagsParam = [[OARequestParameter alloc] initWithName:@"tag"
                                                                     value:tag];
        [params addObject:tagsParam];
        TT_RELEASE_SAFELY(tagsParam);
    }
    
    [self postAction:PostActionSetTags withParameters:params];
    
    
}


//////////////////////////////////////////////////////////////////////////////


- (void) shareOnSingle:(SISharer *) sharer { 
    NSArray *sharers = [[NSArray alloc] initWithObjects:sharer, nil];
    [self shareOnSharersArray:sharers];
    TT_RELEASE_SAFELY(sharers);
}

- (void) shareOnSharersArray:(NSArray *)sharers {
    [self shareOn:[SISharer getSharerFragmentFor:sharers]];
}

- (void) shareOn:(NSString *) shareOn {
    if (!self.publicationDate) {
        [self postActionRequest:nil didFailWithError:[NSError errorWithDomain:@"Can not set tags on a post not yet accepted" code:0 userInfo:nil]];
        return;
    }
    
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"share"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    OARequestParameter *sharerParam = [[OARequestParameter alloc] initWithName:@"shareOn"
                                                                           value:shareOn];
    [params addObject:sharerParam];
    TT_RELEASE_SAFELY(sharerParam);
    
    [self postAction:PostActionShare withParameters:params];
    
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) refuse {
    [self refuseWithReason:nil];
}

- (void) refuseWithReason:(NSString*) reason {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"refuse"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    if (self.isUserSuggestion && reason == nil) {
        OARequestParameter * reasonParam = [[OARequestParameter alloc] initWithName:@"reason"
                                                                              value:reason];
        [params addObject:reasonParam];
        TT_RELEASE_SAFELY(reasonParam);
    }
    
    [self postAction:PostActionRefuse withParameters:params];
}


/////////////////////////////////////////////////////////////////////////////////////

- (void) acceptToTopic:(long long) topicLid {
    [self acceptToTopic:topicLid andSharers:nil];
}

- (void) acceptToTopic:(long long) topicLid andSharersArray:(NSArray*) sharers {
    [self acceptToTopic:topicLid andSharers:[SISharer getSharerFragmentFor:sharers]];
}

- (void) acceptToTopic:(long long) topicLid andSharers:(NSString*) shareOn {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"accept"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                         value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    
    OARequestParameter *topicId = [[OARequestParameter alloc] initWithName:@"topicId"
                                                                     value:[NSString stringWithFormat:@"%lld",topicLid]];
    [params addObject:topicId];
    TT_RELEASE_SAFELY(topicId);
    
    
    if (self.title) {
        OARequestParameter *titleParam = [[OARequestParameter alloc] initWithName:@"title"
                                                                        value:self.title];
        [params addObject:titleParam];
        TT_RELEASE_SAFELY(titleParam);
    }
    if (self.content) {
        OARequestParameter *contentParam = [[OARequestParameter alloc] initWithName:@"content"
                                                                          value:self.content];
        [params addObject:contentParam];
        TT_RELEASE_SAFELY(contentParam);
    }
    if (self.imageUrl) {
        OARequestParameter *imageUrlParam = [[OARequestParameter alloc] initWithName:@"imageUrl"
                                                                          value:self.imageUrl];
        [params addObject:imageUrlParam];
        TT_RELEASE_SAFELY(imageUrlParam);
    }
    
    if (shareOn) {
        OARequestParameter *shareOnParam = [[OARequestParameter alloc] initWithName:@"shareOn"
                                                                     value:shareOn];
        [params addObject:shareOnParam];
        TT_RELEASE_SAFELY(shareOnParam);
    }
    
    [self postAction:PostActionAccept withParameters:params];
}


/////////////////////////////////////////////////////////////////////////////////////

- (void) createOn:(long long) topicLid {
    [self createOn:topicLid andSharers:nil];
}

- (void) createOn:(long long)topicLid andSharersArray:(NSArray *)sharers {
    [self createOn:topicLid andSharers:[SISharer getSharerFragmentFor:sharers]];
}

- (void) createOn:(long long) topicLid andSharers:(NSString*) shareOn {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"create"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    if (self.lid) {
        OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
        [params addObject:idParam];
        TT_RELEASE_SAFELY(idParam);
    }
    
    
    OARequestParameter *topicId = [[OARequestParameter alloc] initWithName:@"topicId"
                                                                     value:[NSString stringWithFormat:@"%lld",topicLid]];
    [params addObject:topicId];
    TT_RELEASE_SAFELY(topicId);
    
    
    if (self.title) {
        OARequestParameter *titleParam = [[OARequestParameter alloc] initWithName:@"title"
                                                                            value:self.title];
        [params addObject:titleParam];
        TT_RELEASE_SAFELY(titleParam);
    }
    if (self.content) {
        OARequestParameter *contentParam = [[OARequestParameter alloc] initWithName:@"content"
                                                                              value:self.content];
        [params addObject:contentParam];
        TT_RELEASE_SAFELY(contentParam);
    }
    if (self.imageUrl) {
        OARequestParameter *imageUrlParam = [[OARequestParameter alloc] initWithName:@"imageUrl"
                                                                               value:self.imageUrl];
        [params addObject:imageUrlParam];
        TT_RELEASE_SAFELY(imageUrlParam);
    }
    if (self.url) {
        OARequestParameter *imageUrlParam = [[OARequestParameter alloc] initWithName:@"url"
                                                                               value:self.url];
        [params addObject:imageUrlParam];
        TT_RELEASE_SAFELY(imageUrlParam);
    }
    if (shareOn) {
        OARequestParameter *shareOnParam = [[OARequestParameter alloc] initWithName:@"shareOn"
                                                                              value:shareOn];
        [params addObject:shareOnParam];
        TT_RELEASE_SAFELY(shareOnParam);
    }
    
    [self postAction:PostActionCreate withParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) remove {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"delete"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    [self postAction:PostActionDelete withParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) forwardTo:(long long) topicLid {
    [self forwardTo:topicLid andSharers:nil];
}

- (void) forwardTo:(long long)topicLid andSharersArray:(NSArray *)sharers {
    [self forwardTo:topicLid andSharers:[SISharer getSharerFragmentFor:sharers]];
}

- (void) forwardTo:(long long) topicLid andSharers:(NSString*) shareOn {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"forward"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *idParam = [[OARequestParameter alloc] initWithName:@"id"
                                                                     value:[NSString stringWithFormat:@"%lld",self.lid]];
    [params addObject:idParam];
    TT_RELEASE_SAFELY(idParam);
    
    
    OARequestParameter *topicId = [[OARequestParameter alloc] initWithName:@"topicId"
                                                                     value:[NSString stringWithFormat:@"%lld",topicLid]];
    [params addObject:topicId];
    TT_RELEASE_SAFELY(topicId);
    
    
    if (self.title) {
        OARequestParameter *titleParam = [[OARequestParameter alloc] initWithName:@"title"
                                                                            value:self.title];
        [params addObject:titleParam];
        TT_RELEASE_SAFELY(titleParam);
    }
    if (self.content) {
        OARequestParameter *contentParam = [[OARequestParameter alloc] initWithName:@"content"
                                                                              value:self.content];
        [params addObject:contentParam];
        TT_RELEASE_SAFELY(contentParam);
    }
    if (self.imageUrl) {
        OARequestParameter *imageUrlParam = [[OARequestParameter alloc] initWithName:@"imageUrl"
                                                                               value:self.imageUrl];
        [params addObject:imageUrlParam];
        TT_RELEASE_SAFELY(imageUrlParam);
    }
    
    if (shareOn) {
        OARequestParameter *shareOnParam = [[OARequestParameter alloc] initWithName:@"shareOn"
                                                                              value:shareOn];
        [params addObject:shareOnParam];
        TT_RELEASE_SAFELY(shareOnParam);
    }
    
    [self postAction:PostActionForward withParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////

- (void) preparForUrl:(NSString*) urlToPrepar {
    NSMutableArray *params = [[[NSMutableArray alloc] init] autorelease];
    
    OARequestParameter *actionParam = [[OARequestParameter alloc] initWithName:@"action"
                                                                         value:@"prepare"];
    [params addObject:actionParam];
    TT_RELEASE_SAFELY(actionParam);
    
    OARequestParameter *urlParam = [[OARequestParameter alloc] initWithName:@"url"
                                                                     value:urlToPrepar];
    [params addObject:urlParam];
    TT_RELEASE_SAFELY(urlParam);
    
    [self postAction:PostActionPrepare withParameters:params];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    TT_RELEASE_SAFELY(consumer);
    TT_RELEASE_SAFELY(request);
    TT_RELEASE_SAFELY(fetcher);
}

//////////////////////////////////////////// DELEGATE /////////////////////////////////////////////

- (void)postActionRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    TTDASSERT([data isKindOfClass:[NSData class]]);
    NSDictionary* feed = nil;
	if ([data isKindOfClass:[NSData class]]) {
		NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		feed = [json JSONValue];
        TT_RELEASE_SAFELY(json);
    }
    
    if (ticket.request.tag == PostActionThanks) {
        //update post
        int _thankCount = [[feed objectForKey:@"thankCount"] intValue];
        int _thanked = [[feed objectForKey:@"thanked"] boolValue];
        
        self.thanked = _thanked;
        self.thanksCount = _thankCount;
    } else if (ticket.request.tag == PostActionEdit || ticket.request.tag == PostActionAccept || ticket.request.tag == PostActionCreate || ticket.request.tag == PostActionPrepare || ticket.request.tag == PostActionForward || ticket.request.tag == PostActionSetTags) {
        //update the post
        [self populateModel:[feed objectForKey:@"post"]];
    }
    
    if (actionDelegate != nil) {
        [actionDelegate post:self actionSucceeded:ticket.request.tag withData:feed];
    }
}

- (void) postActionRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    if (actionDelegate != nil) {
        [actionDelegate post:self actionFailed:ticket.request.tag];
    }
}


@end
