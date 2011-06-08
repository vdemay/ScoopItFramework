//
//  SIPost.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"

@class SITopic;
@class SISource;

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
	int publicationDate;
	int currationDate;
	NSArray* postComments;
	BOOL thanked;
	SITopic* topic;
	
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
@property (nonatomic) int publicationDate;
@property (nonatomic) int currationDate;
@property (nonatomic, retain) NSArray* postComments;
@property (nonatomic) BOOL thanked;
@property (nonatomic, retain) SITopic* topic;


- (id) init:(SIScoopIt*) _scoopIt withLid:(int) _lid;
- (void) getFromDictionary:(NSDictionary*) dic;

@end
