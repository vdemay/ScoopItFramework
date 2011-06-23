//
//  SISharer.m
//  ScoopItFramework
//
//  Created by Vincent Demay on 21/06/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SISharer.h"


@implementation SISharer

@synthesize sharerId, sharerName, cnxId, name, mustSpecifyShareText;

- (void) populateModel:(NSDictionary*) dic {
    [self getFromDictionary:dic];
}

- (void) getFromDictionary:(NSDictionary*) dic {
    self.sharerName = [dic objectForKey:@"sharerName"];
    self.sharerId = [dic objectForKey:@"sharerId"];
    self.cnxId = [[dic objectForKey:@"cnxId"] doubleValue];
    self.name = [dic objectForKey:@"name"];
    self.mustSpecifyShareText = [[dic objectForKey:@"mustSpecifyShareText"] boolValue];
}

@end
