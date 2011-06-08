//
//  SIModel.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 08/05/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@class SIScoopIt;

@interface SIModel : TTModel {	
	SIScoopIt* scoopIt;
}
@property (nonatomic, assign) SIScoopIt* scoopIt;

- (NSString*) generateUrl;
- (void) populateModel:(NSDictionary*) dic;

@end
