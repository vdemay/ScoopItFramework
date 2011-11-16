//
//  SISharer.m
//  ScoopItFramework
//
//  Created by Vincent Demay on 21/06/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import "SISharer.h"


@implementation SISharer

@synthesize sharerId, sharerName, cnxId, name, mustSpecifyShareText, specificText;

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

- (NSString*) textFragment {
    NSString *toReturn = [NSString stringWithFormat:@"{\"sharerId\"=\"%@\", \"cnxId\"=%d", self.sharerId, [[[NSNumber alloc] initWithDouble:self.cnxId] intValue]];
    if (self.specificText) {
        toReturn = [NSString stringWithFormat:@"%@,\"text\"=\"%@\"}", toReturn, self.specificText];
    } else {
        toReturn = [NSString stringWithFormat:@"%@}", toReturn, self.specificText];
    }
    return toReturn;
}

+ (NSString*) getSharerFragmentFor:(NSArray*) sharers {
    NSString *toReturn = @"[";
    
    int i=0;
    for (SISharer *sharer in sharers) {
        if (i > 0) {
            toReturn = [NSString stringWithFormat:@"%@,%@", toReturn, [sharer textFragment]];
        } else {
            //first element
            toReturn = [NSString stringWithFormat:@"%@%@", toReturn, [sharer textFragment]];
        }
        i++;
    }
    
    toReturn = [NSString stringWithFormat:@"%@]", toReturn];
    
    return toReturn;
}

@end
