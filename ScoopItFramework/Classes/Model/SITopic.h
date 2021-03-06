//
//  SITopic.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SIModel.h"

@class SIUser;
@class SIPost;
@class SIScoopIt;

@protocol SITopicActionDelegate;

typedef enum actions_topics {
    TopicActionReorder = 0,
    TopicActionFollow,
    TopicActionUnfollow,
    TopicActionMarkread
} TopicAction;

@interface SITopic : SIModel {
	long long lid;
	NSString* imageUrl;
	NSString* smallImageUrl;
	NSString* mediumImageUrl;
	NSString* largeImageUrl;
	NSString* description;
	NSString* name;
	NSString* shortName;
	NSString* url;
	BOOL isCurator;
	int curablePostCount;
	int curatedPostCount;
	int unreadPostCount;
	SIUser* creator;
	SIPost* pinnedPost;
	NSArray* curablePosts;
	NSArray* curatedPosts;
	NSArray* tags;
    
    int nbCuratedPost;
    int nbCurablePost;
    
    id<SITopicActionDelegate> actionDelegate;
	
}
@property (nonatomic) long long lid;
@property (nonatomic, retain) NSString* imageUrl;
@property (nonatomic, retain) NSString* smallImageUrl;
@property (nonatomic, retain) NSString* mediumImageUrl;
@property (nonatomic, retain) NSString* largeImageUrl;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* shortName;
@property (nonatomic, retain) NSString* url;
@property (nonatomic) BOOL isCurator;
@property (nonatomic) int curablePostCount;
@property (nonatomic) int curatedPostCount;
@property (nonatomic) int unreadPostCount;
@property (nonatomic, retain) SIUser* creator;
@property (nonatomic, retain) SIPost* pinnedPost;
@property (nonatomic, retain) NSArray* curablePosts;
@property (nonatomic, retain) NSArray* curatedPosts;
@property (nonatomic, retain) NSArray* tags;

@property (nonatomic) int nbCuratedPost;
@property (nonatomic) int nbCurablePost;

@property (nonatomic, assign) id<SITopicActionDelegate> actionDelegate;


-(id) init:(SIScoopIt*)_scoopIt withLid:(long long)_lid;

-(void) getFromDictionary:(NSDictionary*) dic;

-(void) follow;
-(void) unfollow;

@end


/////////////////////////////// DELEGATE ////////////////////////////////////////
@protocol SITopicActionDelegate <NSObject>

- (void) topic:(SITopic*)topic actionFailed:(TopicAction)action;
- (void) topic:(SITopic*)topic actionSucceeded:(TopicAction)action withData:(NSDictionary*) data;
@end

