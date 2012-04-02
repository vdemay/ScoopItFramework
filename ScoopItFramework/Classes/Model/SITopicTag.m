//
//  SIPost.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SITopicTag.h"

@implementation SITopicTag

@synthesize tag;
@synthesize count;

- (void) getFromDictionary:(NSDictionary*) dic {
	if (dic != nil) {
		self.count = [[dic objectForKey:@"count"] intValue];
		self.tag = [dic objectForKey:@"tag"];
    }
}

- (void) populateModel:(NSDictionary*) dic {
    [self getFromDictionary:dic];
}


- (void)dealloc {
    TT_RELEASE_SAFELY(tag);
    [super dealloc];
}

@end
