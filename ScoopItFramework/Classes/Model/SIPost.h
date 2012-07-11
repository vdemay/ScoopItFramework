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
#import "SISharer.h"

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
    PostActionSetTags,
    PostActionShare,
    PostActionPin
} PostAction;

/////////////////////////////////////// SIPOST //////////////////////////////////

@class SITopic;
@class SISource;

@protocol SIPostActionDelegate;

@interface SIPost : SIModel {
	long long lid;
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
    
    NSArray* tags;
    
    id<SIPostActionDelegate> actionDelegate;
	
}

@property (nonatomic) long long lid;
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
@property (nonatomic, retain) NSArray* tags;
@property (nonatomic, assign) id<SIPostActionDelegate> actionDelegate;

- (id) init:(SIScoopIt*) _scoopIt withLid:(long long) _lid;
- (void) getFromDictionary:(NSDictionary*) dic;

/*
 * Accept a Post into a Topic
 * Edit properties of the post before calling this method
 */
- (void) acceptToTopic:(long long) topicLid;

/*
 * Accept a Post into a Topic
 * Edit properties of the post before calling this method
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) acceptToTopic:(long long) topicLid andSharers:(NSString *) shareOn;

/*
 * Accept a Post into a Topic
 * Edit properties of the post before calling this method
 * You can also set sharers via an Array
 * You can set a specific texy using property "specificText" in sharer it self
 */
- (void) acceptToTopic:(long long) topicLid andSharersArray:(NSArray *) sharers;

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
- (void) createOn:(long long) topicLid;

/*
 * Create this post from scratch
 * The post need to be populated first
 * Usefull information are : title / url / content / imageUrl 
 * You can also set sharers via an Array
 * You can set a specific texy using property "specificText" in sharer it self
 */
- (void) createOn:(long long) topicLid andSharersArray:(NSArray*) sharers;

/*
 * Create this post from scratch
 * The post need to be populated first
 * Usefull information are : title / url / content / imageUrl 
 * topic
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) createOn:(long long) topicLid andSharers:(NSString *) sharerOn;

/*
 * Forward this post to another topic
 * this action is equivalent to Accept but to another
 * topic
 */
- (void) forwardTo:(long long) topicLid;

/*
 * Forward this post to another topic
 * this action is equivalent to Accept but to another
 * topic
 * You can also set sharers via an Array
 * You can set a specific texy using property "specificText" in sharer it self
 */
- (void) forwardTo:(long long) topicLid andSharersArray:(NSArray *) sharers;

/*
 * Forward this post to another topic
 * this action is equivalent to Accept but to another
 * topic
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) forwardTo:(long long) topicLid andSharers:(NSString *) sharerOn;


/*
 * Thanks the current : no effect if already posted
 */
- (void) thanks;

/*
 * Share a post to a sharer
 * You can set a specific texy using property "specificText" in sharer it self
 */
- (void) shareOnSingle:(SISharer *) sharer;

/*
 * Directly share to multiple sharer 
 * You can also set sharers via an Array
 * You can set a specific texy using property "specificText" in sharer it self
 */
- (void) shareOnSharersArray:(NSArray *) sharers;

/*
 * Directly share to multiple sharer 
 * You can also set sharers : see http://www.scoop.it/dev/api/1/types#sharer
 */
- (void) shareOn:(NSString *) shareOn;


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
 * Tags are not save here : use saveTags instead 
 */
- (void) edit;

/*
 * Save tags set on the topic
 */
- (void) saveTags; 

/*
 * Pin a post
 */
- (void) pin;

/*
 * Prepar a post. It will init this object with data from the given url
 */
- (void) preparForUrl:(NSString*) urlToPrepar;


@end



/////////////////////////////// DELEGATE ////////////////////////////////////////
@protocol SIPostActionDelegate <NSObject>

- (void) post:(SIPost*)post actionFailed:(PostAction)action;
- (void) post:(SIPost*)post actionSucceeded:(PostAction)action withData:(NSDictionary*) data;

@end
