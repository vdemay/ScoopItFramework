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
	int thanksCount;
	SISource* source;
	NSString* url;
	NSString* scoopUrl;
	NSString* imageUrl;
	int imageWidth;
	int imageHeight;
	int imageSize;
	NSString* imagePosition;
	NSArray* imageUrls;
	int commentsCount;
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

@property (nonatomic, assign) id<SIPostActionDelegate> actionDelegate;

- (id) init:(SIScoopIt*) _scoopIt withLid:(int) _lid;
- (void) getFromDictionary:(NSDictionary*) dic;

//ACTIONS
- (void) thanks;

@end



/////////////////////////////// DELEGATE ////////////////////////////////////////
@protocol SIPostActionDelegate <NSObject>

- (void) post:(SIPost*)post actionFailed:(PostAction)action;
- (void) post:(SIPost*)post actionSucceeded:(PostAction)action withData:(NSDictionary*) data;

@end
