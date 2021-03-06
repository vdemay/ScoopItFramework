//
//  SICompilation.m
//  ScoopItFramework
//
//  Created by Vincent Demay on 10/06/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SICompilation.h"
#import "SIScoopIt.h"

@implementation SICompilation

@synthesize posts = _posts;

-(id) init:(SIScoopIt*)_scoopIt {
	self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
	}
	return self;
}

- (id) init:(SIScoopIt*) _scoopIt withItemNumber:(int) itemNumber {
    self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
        _nbPost = itemNumber;
	}
	return self;
}

- (id) initWithFollowedType:(SIScoopIt*) _scoopIt withItemNumber:(int) itemNumber {
    self = [super init];
	if (self != nil) {
		self.scoopIt = _scoopIt;
        _nbPost = itemNumber;
        followed = true;
	}
	return self;
}

- (NSString*) generateUrl {
    NSString * url;
    if (_nbPost > 0) {
        url =  [NSString stringWithFormat:@"%@api/1/compilation?count=%d", BASE_URL,_nbPost];
    } else {
        url =  [NSString stringWithFormat:@"%@api/1/compilation?count=30", BASE_URL];
    }
    
    if (followed) {
        url = [NSString stringWithFormat:@"%@&sort=following", url];
    }
    return url;
}

- (void) populateModel:(NSDictionary*) dic {
	NSArray* postsJson = [dic objectForKey:@"posts"];
    
    NSMutableArray *postsToAdd = [[NSMutableArray alloc] init];
    for (NSDictionary* postJson in postsJson) {
        SIPost *post = [[SIPost alloc] init];
        [post getFromDictionary:postJson];
        [postsToAdd addObject:post];
        TT_RELEASE_SAFELY(post);
    }
    self.posts = [[[NSArray alloc] initWithArray:postsToAdd] autorelease];
    TT_RELEASE_SAFELY(postsToAdd);
}


- (void) dealloc {
    [_posts release];
    _posts = nil;
    [super dealloc];
}


@end
