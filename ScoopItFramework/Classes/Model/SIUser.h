//
//  SIUser.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"

@class SIScoopIt;


@interface SIUser : SIModel {
	long long lid;
	NSString* name;
	NSString* shortName;
	NSString* bio;
	NSString* avatarUrl;
	NSArray* sharers;
	NSArray* curatedTopics;
	NSArray* followedTopics;
    
    BOOL connectedUser;
    
    int nbCuratedPost;
    int nbCurablePost;
    
    BOOL getCuratedTopics;
    BOOL getFollowedTopics;
    BOOL getStats;
    BOOL getTags;
    BOOL getCreator;
}
@property (nonatomic) long long lid;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* shortName;
@property (nonatomic, retain) NSString* bio;
@property (nonatomic, retain) NSString* avatarUrl;
@property (nonatomic, retain) NSArray* sharers;
@property (nonatomic, retain) NSArray* curatedTopics;
@property (nonatomic, retain) NSArray* followedTopics;
@property (nonatomic) BOOL getCuratedTopics;
@property (nonatomic) BOOL getFollowedTopics;
@property (nonatomic) BOOL getStats;
@property (nonatomic) BOOL getTags;
@property (nonatomic) BOOL getCreator;
@property (nonatomic) BOOL connectedUser;

@property (nonatomic) int nbCuratedPost;
@property (nonatomic) int nbCurablePost;


-(void) getFromDictionary:(NSDictionary*) dic;

-(id) init:(SIScoopIt*)_scoopIt withLid:(long long)_lid;
-(id) initWithConnectedUser:(SIScoopIt*)_scoopIt;

@end
