//
//  SISharer.h
//  ScoopItFramework
//
//  Created by Vincent Demay on 21/06/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"


@interface SISharer : SIModel {
    NSString *sharerName;
    NSString *sharerId;
    double cnxId;
    NSString *name;
    BOOL mustSpecifyShareText;
}
@property (nonatomic, retain) NSString *sharerName;
@property (nonatomic, retain) NSString *sharerId;
@property (nonatomic) double cnxId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL mustSpecifyShareText;

- (void) getFromDictionary:(NSDictionary*) dic;

@end