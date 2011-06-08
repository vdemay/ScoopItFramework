//
//  SISource.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 01/01/01.
//  Copyright 2001 Goojet. All rights reserved.
//

#import "SISource.h"


@implementation SISource

@synthesize lid;
@synthesize name;
@synthesize description;
@synthesize type;
@synthesize iconUrl;
@synthesize url;


-(void) getFromDictionary:(NSDictionary*) dic {
	//TODO
}

- (void) dealloc
{
	[name release];
	name = nil;
	[description release];
	description = nil;
	[type release];
	type = nil;
	[iconUrl release];
	iconUrl = nil;
	[url release];
	url = nil;
	[super dealloc];
}


@end
