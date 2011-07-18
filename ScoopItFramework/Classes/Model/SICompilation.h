//
//  SICompilation.h
//  ScoopItFramework
//
//  Created by Vincent Demay on 10/06/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"


@interface SICompilation : SIModel {
    NSArray *_posts;
    int _nbPost;
    
    BOOL followed;
}
@property (nonatomic, retain) NSArray* posts;

- (id) init:(SIScoopIt*) _scoopIt;
- (id) init:(SIScoopIt*) _scoopIt withItemNumber:(int) itemNumber;
- (id) initWithFollowedType:(SIScoopIt*) _scoopIt withItemNumber:(int) itemNumber;

@end
