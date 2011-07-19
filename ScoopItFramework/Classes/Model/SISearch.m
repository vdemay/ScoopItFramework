//
//  SISearch.m
//  ScoopItFramework
//
//  Created by Vincent Demay on 18/07/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SISearch.h"
#import "SIScoopIt.h"


@implementation SISearch

@synthesize user = _users;
@synthesize topics = _topics;


- (id) init:(SIScoopIt*) _scoopIt withSearch:(NSString*) query {
    self = [super init];
    if (self) {
        self.scoopIt = _scoopIt;
        _query = [query retain];
    }
    return self;
}

- (id) init:(SIScoopIt*) _scoopIt withSearch:(NSString *)query andLang:(NSString*) lang {
    self = [super init];
    if (self) {
        self.scoopIt = _scoopIt;
        _query = [query retain];
        _lang = [lang retain];
    }
    return self;
}

- (NSString*) generateUrl {
    NSString * url;
    //TODO : user type
    //if () {
        url =  [NSString stringWithFormat:@"%@api/1/search?type=topic",BASE_URL];
    //} else {
    //    url =  [NSString stringWithFormat:@"%@api/1/search?type=user", BASE_URL];
    //}
    
    if (_lang) {
        url = [NSString stringWithFormat:@"%@&lang=%@", url, _lang];
    }
    if (_query) {
        url = [NSString stringWithFormat:@"%@&query=%@", url, _query];
    }
    return url;
}

- (void) populateModel:(NSDictionary*) dic {
	NSArray* topicsJson = [dic objectForKey:@"topics"];
    
    NSMutableArray *topicsToAdd = [[NSMutableArray alloc] init];
    for (NSDictionary* topicJson in topicsJson) {
        SITopic *topic = [[SITopic alloc] init];
        [topic getFromDictionary:topicJson];
        [topicsToAdd addObject:topic];
        TT_RELEASE_SAFELY(topic);
    }
    self.topics = [[[NSArray alloc] initWithArray:topicsToAdd] autorelease];
    TT_RELEASE_SAFELY(topicsToAdd);
    
   //TODO : users
}


- (void)dealloc {
    TT_RELEASE_SAFELY(_query);
    TT_RELEASE_SAFELY(_lang);
    TT_RELEASE_SAFELY(_users);
    TT_RELEASE_SAFELY(_topics);
    [super dealloc];
}
@end
