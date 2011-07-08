//
//  SIScoopIt.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 06/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIScoopIt.h"

static SIScoopIt* sharedObj;

@implementation SIScoopIt

@synthesize key = _key;
@synthesize secret = _secret;
@synthesize accessToken = _accessToken;

+ (SIScoopIt*) sharedWithKey:(NSString*)key andSecret:(NSString*) secret {
	if (!sharedObj) {
		sharedObj = [[SIScoopIt alloc] init];
	}
	sharedObj.key = key;
	sharedObj.secret = secret;
	return sharedObj;
}

+ (SIScoopIt*) shared {
    return sharedObj;
}

#pragma mark Authorization

- (bool) isAuthorized {
	return _requestToken != nil;
}

//////////////////////////////////////////// AUTH PROCESS /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) getAuthorizationWithDelegate:(id<SIScoopItAuthorizationDelegate>) delegate {
	
	_authorizationDelegate = delegate;
	
	//try to get in the keychain
	_accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"SIAPP" prefix:@"scoop.it"];
	if (_accessToken == nil) {
		// not found in key chain
		//-> request it
		OAConsumer *consumer = [[OAConsumer alloc] initWithKey:self.key
														secret:self.secret];
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/request", BASE_URL]];
		
		OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																	   consumer:consumer
																		  token:nil   // we don't have a Token yet
																		  realm:nil   // our service provider doesn't specify a realm
															  signatureProvider:nil]; // use the default method, HMAC-SHA1
		
		[request setHTTPMethod:@"POST"];
		
		OADataFetcher *fetcher = [[OADataFetcher alloc] init];
		
		[fetcher fetchDataWithRequest:request
							 delegate:sharedObj
					didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	} else {
		[_authorizationDelegate scoopIt:self authenticationReturned:YES];
	}
}
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		_requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
		
		SIDialog *dialog = [[[SIDialog alloc] init] retain];
		dialog.delegate = self;
		[dialog show];
		[dialog loadURL:[NSString stringWithFormat:@"%@oauth/authorize?oauth_token=%@&oauth_callback=http://si.ok", BASE_URL, _requestToken.key]];
	} else {
		[_authorizationDelegate scoopIt:self authenticationReturned:NO];
	}
}
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[_authorizationDelegate scoopIt:self authenticationReturned:NO];
}


#pragma mark SIDialogDelegate
- (void)dialogDidSucceed:(SIDialog*)dialog{
	//autheticated token is in dialog.token
	//ask for a authenticated token
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:self.key
													secret:self.secret];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/access", BASE_URL]];
	
	[_requestToken setKey:dialog.token];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:_requestToken
																	  realm:nil   // our service provider doesn't specify a realm
																   verifier:dialog.verifier
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[request setHTTPMethod:@"POST"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:sharedObj
				didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
	if (ticket.didSucceed) {
		_accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
		//store the token
		[_accessToken storeInUserDefaultsWithServiceProviderName:@"SIAPP" prefix:@"scoop.it"];
		
		[_authorizationDelegate scoopIt:self authenticationReturned:YES];
		
	} else {
		[_authorizationDelegate scoopIt:self authenticationReturned:NO];
	}
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	[_authorizationDelegate scoopIt:self authenticationReturned:NO];
}


- (void)dialogDidCancel:(SIDialog*)dialog {
	NSLog(@"FAIL");
	[_authorizationDelegate scoopIt:self authenticationReturned:NO];
}

- (BOOL)dialog:(SIDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url {
	return YES;
}

//////////////////////////////////////////////// MODEL /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (SITopic*) getTopic:(int)lid {
	return [[SITopic alloc] init:self withLid:lid];
}

- (SIUser*) getConnectedUser {
    if (self.accessToken != nil) {
        if (_connectedUser == nil) {
            _connectedUser = [[[SIUser alloc] initWithConnectedUser:self] retain];
        }
        return _connectedUser;
    }
    return nil;
}

- (SIUser*) getUser:(int)lid {
    return [[SIUser alloc] init:self withLid:lid];
}

- (SICompilation*) getCompilation {
    if (self.accessToken != nil) {
        return [[SICompilation alloc] init:self];
    }
    return nil;
}
- (SICompilation*) getCompilationWithNumberOfItem:(int) number {
    if (self.accessToken != nil) {
        return [[SICompilation alloc] init:self withItemNumber:number];
    }
    return nil;
}

@end
