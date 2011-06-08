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

- (NSString*) generateUrl {
	return nil;
}

- (void) populateModel:(NSDictionary*) dic {
}


- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:self.scoopIt.key
													secret:self.scoopIt.secret];
	
	NSString* urlString = [self generateUrl];
	if (urlString == nil) {
		[self didFailLoadWithError:nil];
		return;
	}
	NSURL *_url = [NSURL URLWithString:urlString];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:_url
																   consumer:consumer
																	  token:nil   // we don't have a Token yet
																	  realm:nil   // our service provider doesn't specify a realm
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[request setHTTPMethod:@"GET"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestModel:didFinishWithData:)
				  didFailSelector:@selector(requestModel:didFailWithError:)];
	
	[self didStartLoad];
}

- (void)requestModel:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	TTDASSERT([data isKindOfClass:[NSData class]]);
	
	if ([data isKindOfClass:[NSData class]]) {
		NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary* feed = [[json JSONValue] retain];
		[self populateModel:feed];
	}	
	[self didFinishLoad];
}

- (void)requestModel:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[self didFailLoadWithError:error];
}

@end