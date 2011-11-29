//
//  SIModel.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIModel.h"
#import "OAuthConsumer.h"
#import "SIScoopIt.h"
#import "JSON.h"

@implementation SIModel

@synthesize scoopIt;
@synthesize loadedTime = _loadedTime;

- (id)init {
    self = [super init];
    if (self) {
        _fetchers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*) generateUrl {
	return nil;
}

- (void) populateModel:(NSDictionary*) dic {
}

- (BOOL)isLoading {
    return _loading;
}

- (BOOL)isLoaded {
    return !!_loadedTime;
}


- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    _loading = YES;
	NSString* urlString = [self generateUrl];
	if (urlString == nil) {
		[self didFailLoadWithError:nil];
        
		return;
	}
	NSURL *_url = [NSURL URLWithString:urlString];
    
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:self.scoopIt.key
													secret:self.scoopIt.secret];
	
    
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:_url
																   consumer:consumer
																	  token:scoopIt.accessToken
																	  realm:nil   // our service provider doesn't specify a realm
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
    
	[request setHTTPMethod:@"GET"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestModel:didFinishWithData:)
				  didFailSelector:@selector(requestModel:didFailWithError:)];
    [_fetchers addObject:fetcher];
    
    
    TT_RELEASE_SAFELY(consumer);
    TT_RELEASE_SAFELY(request);
    TT_RELEASE_SAFELY(fetcher);
    
	[self didStartLoad];
}

- (void)requestModel:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    [_loadedTime release];
    double timestamp = [ticket.request.timestamp doubleValue];
    _loadedTime = [[NSDate dateWithTimeIntervalSince1970:timestamp] retain];
    
	TTDASSERT([data isKindOfClass:[NSData class]]);
	
	if ([data isKindOfClass:[NSData class]]) {
		NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",json);
		NSDictionary* feed = [[json JSONValue] retain];
        [self populateModel:feed];
        TT_RELEASE_SAFELY(json);
        TT_RELEASE_SAFELY(feed);
	}	
    
    _loading = NO;
	[self didFinishLoad];
}

- (void)requestModel:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    
    _loading = NO;
	[self didFailLoadWithError:error];
}

- (void)dealloc {
    for (OADataFetcher *fetcher in _fetchers) {
        [fetcher cancel];
    }
    TT_RELEASE_SAFELY(_fetchers);
    [super dealloc];
}

@end