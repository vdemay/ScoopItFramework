//
//  SIScoopIt.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 06/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>

//OAUTH AND UI 
#import "OAuthConsumer.h"
#import "SIDialog.h"

//MODELS
#import "SIPost.h"
#import "SISource.h"
#import "SITopic.h"
#import "SIUser.h"


#define BASE_URL @"https://www.scoop.it/"


@protocol SIScoopItAuthorizationDelegate;

/////////////////////////////////////////////////////////////////////////////////////////

@interface SIScoopIt : NSObject<SIDialogDelegate> {
	
	UIWebView* _loginPopup;
	
	NSString* _key;
	NSString* _secret;
	
	//the application Token
	OAToken* _requestToken;
	//the authenticated Token
	OAToken* _accessToken;
	
	//delegate for authorization
	id<SIScoopItAuthorizationDelegate> _authorizationDelegate;
}
@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) NSString* secret;

+ (SIScoopIt*) sharedWithKey:(NSString*)key andSecret:(NSString*) secret;

- (bool) isAuthorized;
- (void) getAuthorizationWithDelegate:(id<SIScoopItAuthorizationDelegate>) delegate;

//- (SITopic*) getTopic:(int)lid WithDelegate:(id<SIScoopItAuthorizationDelegate>) delegate;


@end

//////////////////////////////////////////////////////////////////////////////////////////

@protocol SIScoopItAuthorizationDelegate

- (void)scoopIt:(SIScoopIt*)scoopIt authenticationReturned:(BOOL)success;


@end
