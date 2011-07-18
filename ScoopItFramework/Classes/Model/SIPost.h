//
//  SIPost.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"
#import "SIScoopIt.h"

typedef enum actions {
    PostActionPrepare = 0,
    PostActionCreate,
    PostActionComment,
    PostActionThanks,
    PostActionAccept,
    PostActionForward,
    PostActionRefuse,
    PostActionDelete,
    PostActionEdit,
    PostActionPin
} PostAction;

/////////////////////////////////////// SIPOST //////////////////////////////////

@class SITopic;
@class SISource;

@protocol SIPostActionDelegate;

@interface SIPost : SIModel {
	int lid;
	NSString* content;
	NSString* title;
	SISource* source;
	NSString* url;
	NSString* scoopUrl;
    
	NSString* imageUrl;
    NSString* smallImageUrl;
    NSString* mediumImageUrl;
    NSString* largeImageUrl;
	int imageWidth;
	int imageHeight;
	int imageSize;
	NSString* imagePosition;
	NSArray* imageUrls;
    
    int pagesView;
	int commentsCount;
	int thanksCount;
    int reactionsCount;
    
	BOOL isUserSuggestion;
    
	double publicationDate;
	double currationDate;
	NSArray* postComments;
	BOOL thanked;
	SITopic* topic;
    
    id<SIPostActionDelegate> actionDelegate;
	
}

@property (nonatomic) int lid;
@property (nonatomic, retain) NSString* content;
@property (nonatomic, retain) NSString* title;
@property (nonatomic) int thanksCount;
@property (nonatomic, retain) SISource* source;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* scoopUrl;
@property (nonatomic, retain) NSString* imageUrl;
@property (nonatomic, retain) NSString* smallImageUrl;
@property (nonatomic, retain) NSString* mediumImageUrl;
@property (nonatomic, retain) NSString* largeImageUrl;
@property (nonatomic) int imageWidth;
@property (nonatomic) int imageHeight;
@property (nonatomic) int imageSize;
@property (nonatomic, retain) NSString* imagePosition;
@property (nonatomic, retain) NSArray* imageUrls;
@property (nonatomic) int commentsCount;
@property (nonatomic) BOOL isUserSuggestion;
@property (nonatomic) double publicationDate;
@property (nonatomic) double currationDate;
@property (nonatomic, retain) NSArray* postComments;
@property (nonatomic) BOOL thanked;
@property (nonatomic, retain) SITopic* topic;
@property (nonatomic) int pagesView;
@property (nonatomic) int reactionsCount;

@property (nonatomic, assign) id<SIPostActionDelegate> actionDelegate;

- (id) init:(SIScoopIt*) _scoopIt withLid:(int) _lid;
- (void) getFromDictionary:(NSDictionary*) dic;

/*
 * Accept a Post into a Topic
 * Edit properties of the post before calling this method
 */
- (void) acceptToTopic:(int) topicLid;

/*
 * Accept a Post into a Topic
 * Edit properties of the post before calling this method
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) acceptToTopic:(int) topicLid andSharers:(NSString*) shareOn;

/*
 * Refuse this post
 */
- (void) refuse;

/*
 * refuse this post with a reason
 * if this post is not a user suggestion the reason parameter will be 
 * ignored
 */
- (void) refuseWithReason:(NSString*) reason;

/*
 * Create this post from scratch
 * The post need to be populated first
 * Usefull information are : title / url / content / imageUrl 
 */
- (void) createOn:(int) topicLid;

/*
 * Create this post from scratch
 * The post need to be populated first
 * Usefull information are : title / url / content / imageUrl 
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) createOn:(int) topicLid andSharers:(NSString*) shareOn;

/*
 * Forward this post to another topic
 * this action is equivalent to Accept but to another
 * topic
 */
- (void) forwardTo:(int) topicLid;

/*
 * Forward this post to another topic
 * this action is equivalent to Accept but to another
 * topic
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) forwardTo:(int) topicLid andSharers:(NSString*) shareOn;


/*
 * Thanks the current : no effect if already posted
 */
- (void) thanks;


/*
 * Add a comment to this post
 */
- (void) commentWithMessage:(NSString*) message;

/*
 * Remove this post to its current topic
 * if the post is suggested use refuse instead of remove
 */
- (void) remove;

/*
 * Save post edition
 * the post need to be edited before calling this method
 * content / title / imageUrl
 * TODO : tag
 */
- (void) edit;


/*
 * Pin a post
 */
- (void) pin;

/*
 * Prepar a post. It will init this object with data from the given url
 */
- (void) preparForUrl:(NSString*) url;


@end



/////////////////////////////// DELEGATE ////////////////////////////////////////
@protocol SIPostActionDelegate <NSObject>

- (void) post:(SIPost*)post actionFailed:(PostAction)action;
- (void) post:(SIPost*)post actionSucceeded:(PostAction)action withData:(NSDictionary*) data;

@end
