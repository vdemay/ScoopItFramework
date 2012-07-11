//
//  SISource.h
//  iCocoaInfo
//
//  Created by Vincent Demay on 01/01/01.
//  Copyright 2001 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"


@interface SISource : SIModel {
	long long lid;
	NSString* name;
	NSString* description;
	NSString* type;
	NSString* iconUrl;
	NSString* url;
}

@property (nonatomic) long long lid;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* iconUrl;
@property (nonatomic, retain) NSString* url;


-(void) getFromDictionary:(NSDictionary*) dic;

@end
