//
//  SISearch.h
//  ScoopItFramework
//
//  Created by Vincent Demay on 18/07/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"

@interface SISearch : SIModel {
    
    NSString *_lang;
    NSString *_query;
    NSString *_type;
    
    NSArray *_users;
    NSArray *_topics;
    NSArray *_posts;
}
@property (nonatomic, retain) NSArray *user;
@property (nonatomic, retain) NSArray *topics;
@property (nonatomic, retain) NSArray *posts;

- (id) init:(SIScoopIt*) _scoopIt withSearch:(NSString*) query;
- (id) init:(SIScoopIt*) _scoopIt withSearch:(NSString *)query andLang:(NSString*) lang;
- (id) init:(SIScoopIt*) _scoopIt withSearch:(NSString *)query andLang:(NSString*) lang andType:(NSString*) type;


@end
