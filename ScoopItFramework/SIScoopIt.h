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
#import "SITopicTag.h"
#import "SICompilation.h"
#import "SISharer.h"
#import "SISearch.h"
#import "SIStats.h"
#import "SIProfile.h"

#define BASE_URL @"http://www.scoop.it/"
//#define BASE_URL @"https://qa.scoop.it/"
//#define BASE_URL @"http://10.9.2.26:8888/"
//#define BASE_URL @"http://philou.integration.scoop.it/"

typedef enum SIRequestType {
    SIRequestTopicById,
    SIRequestProfile,
} SIRequestType;    

@protocol SIScoopItAuthorizationDelegate;

/////////////////////////////////////////////////////////////////////////////////////////

@interface SIScoopIt : NSObject<SIDialogDelegate> {
	
	UIWebView* _loginPopup;
    UIActivityIndicatorView* _spinner;
	
	NSString* _key;
	NSString* _secret;
	
	//the application Token
	OAToken* _requestToken;
	//the authenticated Token
	OAToken* _accessToken;
    //the connected user
    SIUser* _connectedUser;
    //the connected profile
    SIProfile* _connectedProfile;
	
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
- (void) getAuthorizationWithKey:(NSString*)key andSecret:(NSString*) secret andDelegate:(id<SIScoopItAuthorizationDelegate>) delegate;

- (void) logout;

//MODEL GET
- (SITopic*) getTopic:(int)lid;

// This method does not create an object each time. It will create object on 
// demand. In all cases, the user is not loaded from network. user method is in charge
// of the loading. If the object is not loaded all property will be nil
- (SIUser*) getConnectedUser;

- (SIUser*) getUser:(int)lid;

- (SIProfile*) getProfile:(int)lid;
- (SIProfile*) getConnectedProfile;

- (SICompilation*) getCompilation;

- (SICompilation*) getCompilationWithNumberOfItem:(int) number;
- (SICompilation*) getFollowingCompilationWithNumberOfItem:(int) number;

- (SISearch*) getSearchForTopic: (NSString*) query;
- (SISearch*) getSearchForPosts: (NSString*) query;


@end

//////////////////////////////////////////////////////////////////////////////////////////
// AUthentication Deleagte
@protocol SIScoopItAuthorizationDelegate
- (void)scoopIt:(SIScoopIt*)scoopIt authenticationReturned:(BOOL)success;
@end
