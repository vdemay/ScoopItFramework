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
#import "SICompilation.h"


#define BASE_URL @"https://www.scoop.it/"

typedef enum SIRequestType {
    SIRequestTopicById,
    SIRequestProfile,
} SIRequestType;


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
@property (nonatomic, retain) OAToken* accessToken;

+ (SIScoopIt*) sharedWithKey:(NSString*)key andSecret:(NSString*) secret;
+ (SIScoopIt*) shared;

- (bool) isAuthorized;
- (void) getAuthorizationWithDelegate:(id<SIScoopItAuthorizationDelegate>) delegate;

//MODEL GET
- (SITopic*) getTopic:(int)lid;
- (SIUser*) getConnectedUser;
- (SIUser*) getUser:(int)lid;
- (SICompilation*) getCompilation;


@end

//////////////////////////////////////////////////////////////////////////////////////////
// AUthentication Deleagte
@protocol SIScoopItAuthorizationDelegate
- (void)scoopIt:(SIScoopIt*)scoopIt authenticationReturned:(BOOL)success;
@end
