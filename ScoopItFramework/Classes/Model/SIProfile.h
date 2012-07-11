//
//  SIProfile.h
//  ReScoop
//
//  Created by Vincent Demay on 25/04/12.
//  Copyright (c) 2012 Goojet. All rights reserved.
//

#import "SIModel.h"
#import "SIUser.h"
#import "SIStats.h"

@class SIScoopIt;

@interface SIProfile : SIModel {
    SIUser *_user;
    SIStats *_stats;
    long long lid;
    
    
    int nbCuratedPost;
    int nbCurablePost;
    
    BOOL getCuratedTopics;
    BOOL getFollowedTopics;
}
@property (nonatomic, retain) SIUser* user;
@property (nonatomic, retain) SIStats* stats;
@property (nonatomic) long long lid;
@property (nonatomic) BOOL getCuratedTopics;
@property (nonatomic) BOOL getFollowedTopics;

@property (nonatomic) int nbCuratedPost;
@property (nonatomic) int nbCurablePost;

@end
