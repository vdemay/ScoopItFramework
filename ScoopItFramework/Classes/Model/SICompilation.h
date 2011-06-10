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
}
@property (nonatomic, retain) NSArray* posts;

- (id) init:(SIScoopIt*) _scoopIt;

@end
