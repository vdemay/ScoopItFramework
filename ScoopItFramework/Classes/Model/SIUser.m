//
//  SIUser.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIUser.h"


@implementation SIUser


@synthesize lid;
@synthesize name;
@synthesize shortName;
@synthesize bio;
@synthesize avatarUrl;
@synthesize sharers;
@synthesize curratedTopics;
@synthesize followedTopics;


-(void) getFromDictionary:(NSDictionary*) dic {
	//TODO
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
	[curratedTopics release];
	curratedTopics = nil;
	[followedTopics release];
	followedTopics = nil;
	[super dealloc];
}


@end
