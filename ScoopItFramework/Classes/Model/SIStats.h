//
//  SIStats.h
//  ReScoop
//
//  Created by Vincent Demay on 25/04/12.
//  Copyright (c) 2012 Goojet. All rights reserved.
//

#import "SIModel.h"

@interface SIStats : SIModel{
    long views;
    long uniqueVisitors;
    long todayViews;
    long todayUniqueVisitors;
}

@property (nonatomic) long views;
@property (nonatomic) long uniqueVisitors;
@property (nonatomic) long todayViews;
@property (nonatomic) long todayUniqueVisitors;

- (void) getFromDictionary:(NSDictionary*) dic;

@end
