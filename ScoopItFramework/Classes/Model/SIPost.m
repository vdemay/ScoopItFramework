//
//  SIPost.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIPost.h"


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
		self.publicationDate = [[dic objectForKey:@"publicationDate"] intValue];
		self.currationDate = [[dic objectForKey:@"currationDate"] intValue];
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


@end
