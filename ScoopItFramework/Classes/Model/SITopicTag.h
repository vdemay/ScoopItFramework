//
//  SIPost.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//


#import "SIModel.h"

@interface SITopicTag : SIModel {
    NSString *tag;
    int count;
}
@property (nonatomic) int count;
@property (nonatomic, retain) NSString* tag;


- (void) getFromDictionary:(NSDictionary*) dic;

@end
