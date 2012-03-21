//
//  SIImageUploader.h
//  ScoopItFramework
//
//  Created by Vincent Demay on 12/01/12.
//  Copyright (c) 2012 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIScoopIt.h"

@protocol SIImageUploaderDelegate;

@interface SIImageUploader : NSObject {
    id<SIImageUploaderDelegate> _delegate;
}
@property (nonatomic, assign) id<SIImageUploaderDelegate> delegate;

- (void) uploadImage:(NSData*) data;

@end



@protocol SIImageUploaderDelegate <NSObject>

@optional
- (void) imageUploader:(SIImageUploader*)uploader uploadCompletedWithUrl:(NSString *) url;
- (void) imageUploader:(SIImageUploader*)uploader uploadFailedWithError:(NSString *) error;

@end
