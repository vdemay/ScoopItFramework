//
//  SIScoopIt.m
//  iCocoaInfo
//
//  Created by Vincent Demay on 06/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SIScoopIt.h"

static SIScoopIt* sharedObj = nil;

@implementation SIScoopIt

@synthesize key = _key;
@synthesize secret = _secret;
@synthesize accessToken = _accessToken;

/*
 + (SIScoopIt*) sharedWithKey:(NSString*)key andSecret:(NSString*) secret {
 @synchronized(self) {
 if (!sharedObj) {
 sharedObj = [[SIScoopIt alloc] init];
 sharedObj.key = key;
 sharedObj.secret = secret;
 }
 }
 return sharedObj;
 }*/

+ (SIScoopIt*) shared {
    @synchronized(self) {
        if (!sharedObj) {
            sharedObj = [[SIScoopIt alloc] init];
        }        
        
    }
    return sharedObj;
}

+ (id) allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [super allocWithZone:zone];
            return sharedObj;
        }
    }    
    return nil;
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)retain {
    return self;    
}

-(NSUInteger)retainCount {
    return NSUIntegerMax;
}


-(id)autorelease {
    return self;
}


#pragma mark Authorization

- (bool) isAuthorized {
	return _requestToken != nil;
}

//////////////////////////////////////////// AUTH PROCESS /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) getAuthorizationWithKey:(NSString*)key andSecret:(NSString*) secret andDelegate:(id<SIScoopItAuthorizationDelegate>) delegate {
	
	_authorizationDelegate = delegate;
    self.key = key;
    self.secret = secret;
	
	//try to get in the keychain
	_accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"SIAPP" prefix:@"scoop.it"];
	if (_accessToken == nil) {
        NSLog(@"accessToken is nil");
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
							 delegate:self
					didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
					  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
        
        TT_RELEASE_SAFELY(consumer);
        TT_RELEASE_SAFELY(request);
	} else {
        NSLog(@"accessToken is not nil");
		[_authorizationDelegate scoopIt:self authenticationReturned:YES];
	}
}

- (void) logout {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in [[[cookieStorage cookiesForURL:[NSURL URLWithString:BASE_URL]] copy] autorelease]) {
    	[cookieStorage deleteCookie:each];
    }
    
    TT_RELEASE_SAFELY(_connectedUser);
    [OAToken removeFromUserDefaultsWithServiceProviderName:@"SIAPP" prefix:@"scoop.it"];
    self.secret = nil;
    self.key = nil;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		_requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
		TT_RELEASE_SAFELY(responseBody);
        
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


#pragma mark - SIDialogDelegate
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
    
    
    TT_RELEASE_SAFELY(consumer);
    TT_RELEASE_SAFELY(request);
}

- (void)dialogDidCancel:(SIDialog*)dialog {
	NSLog(@"FAIL");
	[_authorizationDelegate scoopIt:self authenticationReturned:NO];
}

- (void)dialog:(SIDialog*)dialog didFailWithError:(NSError*)error {
	NSLog(@"FAIL WITH ERROR");
	[_authorizationDelegate scoopIt:self authenticationReturned:NO];
}

- (BOOL)dialog:(SIDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url {
	return YES;
}


#pragma mark -

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
		_accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
        TT_RELEASE_SAFELY(responseBody);
        
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





//////////////////////////////////////////////// MODEL /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FIXME Memory management

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

- (SICompilation*) getFollowingCompilationWithNumberOfItem:(int) number {
    if (self.accessToken != nil) {
        return [[SICompilation alloc] initWithFollowedType:self withItemNumber:number];
    }
    return nil;
}

- (SISearch*) getSearchForTopic: (NSString*) query {
    return [[SISearch alloc] init:self withSearch:query];
}

@end
