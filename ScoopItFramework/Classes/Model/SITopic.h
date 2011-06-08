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

@interface SITopic : SIModel {
	int lid;
	NSString* imageUrl;
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
	
}
@property (nonatomic) int lid;
@property (nonatomic, retain) NSString* imageUrl;
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


- (id) init:(SIScoopIt*) _scoopIt withLid:(int) _lid;

-(void) getFromDictionary:(NSDictionary*) dic;

@end