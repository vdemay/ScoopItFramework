//
//  SIImageUploader.m
//  ScoopItFramework
//
//  Created by Vincent Demay on 12/01/12.
//  Copyright (c) 2012 Goojet. All rights reserved.
//

#import "SIImageUploader.h"
#import "OAuthConsumer.h"
#import "NSString+SBJSON.h"

@implementation SIImageUploader

@synthesize delegate = _delegate;

- (void) uploadImage:(NSData*) data {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[SIScoopIt shared].key
													secret:[SIScoopIt shared].secret];
	
	NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/1/upload", BASE_URL]];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:_url
																   consumer:consumer
																	  token:[SIScoopIt shared].accessToken
																	  realm:nil   // our service provider doesn't specify a realm
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[request setHTTPMethod:@"POST"];
    
    NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"test.bin\"\r\n\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:data];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:postBody];
    
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(upload:didFinishWithData:)
				  didFailSelector:@selector(upload:didFailWithError:)];
    
    TT_RELEASE_SAFELY(consumer);
    TT_RELEASE_SAFELY(request);
    TT_RELEASE_SAFELY(fetcher);
}

- (void) upload:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    if (_delegate) {
        
        TTDASSERT([data isKindOfClass:[NSData class]]);
        NSDictionary* response = nil;
        if ([data isKindOfClass:[NSData class]]) {
            NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            response = [json JSONValue];
            TT_RELEASE_SAFELY(json);
        }
        if (response) {
            if ([response objectForKey:@"image"]) {
                if ([_delegate respondsToSelector:@selector(imageUploader:uploadCompletedWithUrl:)]) {
                    [_delegate imageUploader:self uploadCompletedWithUrl:[response objectForKey:@"image"]];
                }
            } else if ([response objectForKey:@"error"]) {
                if ([_delegate respondsToSelector:@selector(imageUploader:uploadFailedWithError:)]) {
                    [_delegate imageUploader:self uploadFailedWithError:[response objectForKey:@"error"]];
                }
            }
        } else {
            //error
            if ([_delegate respondsToSelector:@selector(imageUploader:uploadFailedWithError:)]) {
                [_delegate imageUploader:self uploadFailedWithError:@"Unknown error"];
            }
        }
    }
}


- (void) upload:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(imageUploader:uploadFailedWithError:)]) {
        [_delegate imageUploader:self uploadFailedWithError:error.localizedDescription];
    }
}

@end
