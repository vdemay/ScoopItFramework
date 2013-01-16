/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import "SIDialog.h"
#import "URLParser.h"

BOOL IsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES; 
	}
#endif
	return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static NSString* kDefaultTitle = @"Connect to Scoop.it";

static CGFloat kFacebookBlue[4] = {144.0/256.0, 210.0/256.0, 0.0, 1.0};
static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
static CGFloat kBorderBlue[4] = {0.23, 0.35, 0.6, 1.0};

static CGFloat kTransitionDuration = 0.3;

static CGFloat kTitleMarginX = 8;
static CGFloat kTitleMarginY = 4;
static CGFloat kPadding = 10;
static CGFloat kBorderWidth = 10;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SIDialog

@synthesize delegate = _delegate;
@synthesize token = _token;
@synthesize verifier = _verifier;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
  CGContextBeginPath(context);
  CGContextSaveGState(context);

  if (radius == 0) {
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddRect(context, rect);
  } else {
    rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
    CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
    CGContextScaleCTM(context, radius, radius);
    float fw = CGRectGetWidth(rect) / radius;
    float fh = CGRectGetHeight(rect) / radius;
    
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
  }

  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

  if (fillColors) {
    CGContextSaveGState(context);
    CGContextSetFillColor(context, fillColors);
    if (radius) {
      [self addRoundedRectToPath:context rect:rect radius:radius];
      CGContextFillPath(context);
    } else {
      CGContextFillRect(context, rect);
    }
    CGContextRestoreGState(context);
  }
  
  CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

  CGContextSaveGState(context);
  CGContextSetStrokeColorSpace(context, space);
  CGContextSetStrokeColor(context, strokeColor);
  CGContextSetLineWidth(context, 1.0);
    
  {
    CGPoint points[] = {rect.origin.x+0.5, rect.origin.y-0.5,
      rect.origin.x+rect.size.width, rect.origin.y-0.5};
    CGContextStrokeLineSegments(context, points, 2);
  }
  {
    CGPoint points[] = {rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5,
      rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5};
    CGContextStrokeLineSegments(context, points, 2);
  }
  {
    CGPoint points[] = {rect.origin.x+rect.size.width-0.5, rect.origin.y,
      rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height};
    CGContextStrokeLineSegments(context, points, 2);
  }
  {
    CGPoint points[] = {rect.origin.x+0.5, rect.origin.y,
      rect.origin.x+0.5, rect.origin.y+rect.size.height};
    CGContextStrokeLineSegments(context, points, 2);
  }
  
  CGContextRestoreGState(context);

  CGColorSpaceRelease(space);
}

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
  if (orientation == _orientation) {
    return NO;
  } else {
    return orientation == UIDeviceOrientationLandscapeLeft
      || orientation == UIDeviceOrientationLandscapeRight
      || orientation == UIDeviceOrientationPortrait
      || orientation == UIDeviceOrientationPortraitUpsideDown;
  }
}

- (CGAffineTransform)transformForOrientation {
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(M_PI*1.5);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(M_PI/2);
  } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformMakeRotation(-M_PI);
  } else {
    return CGAffineTransformIdentity;
  }
}

- (void)sizeToFitOrientation:(BOOL)transform {
  if (transform) {
    self.transform = CGAffineTransformIdentity;
  }

  CGRect frame = [UIScreen mainScreen].applicationFrame;
  CGPoint center = CGPointMake(
    frame.origin.x + ceil(frame.size.width/2),
    frame.origin.y + ceil(frame.size.height/2));

  CGFloat scale_factor = 1.0f;
	
  if (IsDeviceIPad()) {
    // On the iPad the dialog's dimensions should only be 60% of the screen's
    scale_factor = 0.6f;
  }

  CGFloat width = floor(scale_factor * frame.size.width) - kPadding * 2;
  CGFloat height = floor(scale_factor * frame.size.height) - kPadding * 2;

  _orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    self.frame = CGRectMake(kPadding, kPadding, height, width);
  } else {
    self.frame = CGRectMake(kPadding, kPadding, width, height);
  }
  self.center = center;

  if (transform) {
    self.transform = [self transformForOrientation];
  }
}

- (void)updateWebOrientation {
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    [_webView stringByEvaluatingJavaScriptFromString:
      @"document.body.setAttribute('orientation', 90);"];
  } else {
    [_webView stringByEvaluatingJavaScriptFromString:
      @"document.body.removeAttribute('orientation');"];
  }
}

- (void)bounce1AnimationStopped {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:kTransitionDuration/2];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
  self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
  [UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:kTransitionDuration/2];
  self.transform = [self transformForOrientation];
  [UIView commitAnimations];
}

- (void)addObservers {
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(deviceOrientationDidChange:)
    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIKeyboardWillShowNotification" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)postDismissCleanup {
    _webView.delegate = nil;
    [_webView release];
    _webView = nil;
    [self removeObservers];
    [self removeFromSuperview];
}

- (void)dismiss:(BOOL)animated {
  [self dialogWillDisappear];

  [_loadingURL release];
  _loadingURL = nil;
  
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
    self.alpha = 0;
    [UIView commitAnimations];
  } else {
    [self postDismissCleanup];
  }
}

- (void)cancel {
  [self dismissWithSuccess:NO animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
    self = [super initWithFrame:CGRectZero];
  if (self) {
    _delegate = nil;
    _loadingURL = nil;
    _orientation = UIDeviceOrientationUnknown;
    _showingKeyboard = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentMode = UIViewContentModeRedraw;
    
    UIImage* iconImage = [UIImage imageNamed:@"it_white.png"];
    UIImage* closeImage = [UIImage imageNamed:@"close.png"];
    
    _iconView = [[UIImageView alloc] initWithImage:iconImage];
    [self addSubview:_iconView];
    
    UIColor* color = [UIColor colorWithRed:167.0/255 green:184.0/255 blue:216.0/255 alpha:1];
    _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_closeButton setImage:closeImage forState:UIControlStateNormal];
    [_closeButton setTitleColor:color forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(cancel)
      forControlEvents:UIControlEventTouchUpInside];
	if ([_closeButton respondsToSelector:@selector(titleLabel)]) {
		_closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	} else { // This triggers a deprecation warning but at least it will work on OS 2.x
		_closeButton.font = [UIFont boldSystemFontOfSize:12];
	}
	_closeButton.showsTouchWhenHighlighted = YES;
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
      | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_closeButton];
    
    CGFloat titleLabelFontSize = (IsDeviceIPad() ? 18 : 14);
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.text = kDefaultTitle;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
      | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_titleLabel];
        
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_webView];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
      UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.autoresizingMask =
      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
      | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_spinner];
  }
  return self;
}

- (void)dealloc {
  _webView.delegate = nil;
  [_webView release];
  [_spinner release];
  [_titleLabel release];
  [_iconView release];
  [_closeButton release];
  [_loadingURL release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  CGRect grayRect = CGRectOffset(rect, -0.5, -0.5);
  [self drawRect:grayRect fill:kBorderGray radius:10];

  CGRect headerRect = CGRectMake(
    ceil(rect.origin.x + kBorderWidth), ceil(rect.origin.y + kBorderWidth),
    rect.size.width - kBorderWidth*2, _titleLabel.frame.size.height);
  [self drawRect:headerRect fill:kFacebookBlue radius:0];
  [self strokeLines:headerRect stroke:kBorderBlue];

  CGRect webRect = CGRectMake(
    ceil(rect.origin.x + kBorderWidth), headerRect.origin.y + headerRect.size.height,
    rect.size.width - kBorderWidth*2, _webView.frame.size.height+1);
  [self strokeLines:webRect stroke:kBorderBlack];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
    navigationType:(UIWebViewNavigationType)navigationType {
	NSURL* url = request.URL;
    NSLog([url absoluteString]);
  if ([[url absoluteString] hasPrefix:@"http://si.ok"]) {
	[self dialogDidSucceed:url];
    return NO;
  } /*else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    if ([_delegate respondsToSelector:@selector(dialog:shouldOpenURLInExternalBrowser:)]) {
      if (![_delegate dialog:self shouldOpenURLInExternalBrowser:url]) {
        return NO;
      }
    }
    
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
  }*/
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [_spinner stopAnimating];
  _spinner.hidden = YES;
  
  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  [self updateWebOrientation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
    [self getErrors:error];
  if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
    [self dismissWithError:error animated:YES];
  }
}
-(void)getErrors:(NSError *)error {
    if (!error)
        return;
    
    NSLog(@"Failed to %@", [error localizedDescription]);
   /* NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors && [detailedErrors count] > 0) 
    {
        for(NSError* detailedError in detailedErrors) 
        {
            NSLog(@"DetailedError: %@", [detailedError userInfo]);
        }
    }
    else
    {
        NSLog(@"%@", [error userInfo]);
    }*/
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
  UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (!_showingKeyboard && [self shouldRotateToOrientation:orientation]) {
    [self updateWebOrientation];

    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [self sizeToFitOrientation:YES];
    [UIView commitAnimations];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
  if (IsDeviceIPad()) {
    // On the iPad the screen is large enough that we don't need to 
    // resize the dialog to accomodate the keyboard popping up
    return;
  }

  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    _webView.frame = CGRectInset(_webView.frame,
      -(kPadding + kBorderWidth),
      -(kPadding + kBorderWidth) - _titleLabel.frame.size.height);
  }

  _showingKeyboard = YES;
}

- (void)keyboardWillHide:(NSNotification*)notification {
  if (IsDeviceIPad()) {
    return;
  }
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    _webView.frame = CGRectInset(_webView.frame,
      kPadding + kBorderWidth,
      kPadding + kBorderWidth + _titleLabel.frame.size.height);
  }

  _showingKeyboard = NO;
}
 
///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString*)title {
  return _titleLabel.text;
}

- (void)setTitle:(NSString*)title {
  _titleLabel.text = title;
}

- (void)show {
  [self load];
  [self sizeToFitOrientation:NO];

  CGFloat innerWidth = self.frame.size.width - (kBorderWidth+1)*2;  
  [_iconView sizeToFit];
  [_titleLabel sizeToFit];
  [_closeButton sizeToFit];

  _titleLabel.frame = CGRectMake(
    kBorderWidth + kTitleMarginX + _iconView.frame.size.width + kTitleMarginX,
    kBorderWidth,
    innerWidth - (_titleLabel.frame.size.height + _iconView.frame.size.width + kTitleMarginX*2),
    _titleLabel.frame.size.height + kTitleMarginY*2);
  
  _iconView.frame = CGRectMake(
    kBorderWidth + kTitleMarginX,
    kBorderWidth + floor(_titleLabel.frame.size.height/2 - _iconView.frame.size.height/2),
    _iconView.frame.size.width,
    _iconView.frame.size.height);

  _closeButton.frame = CGRectMake(
    self.frame.size.width - (_titleLabel.frame.size.height + kBorderWidth),
    kBorderWidth,
    _titleLabel.frame.size.height,
    _titleLabel.frame.size.height);
  
  _webView.frame = CGRectMake(
    kBorderWidth+1,
    kBorderWidth + _titleLabel.frame.size.height,
    innerWidth,
    self.frame.size.height - (_titleLabel.frame.size.height + 1 + kBorderWidth*2));

  [_spinner sizeToFit];
  [_spinner startAnimating];
  _spinner.center = _webView.center;

  UIWindow* window = [UIApplication sharedApplication].keyWindow;
  if (!window) {
    window = [[UIApplication sharedApplication].windows objectAtIndex:0];
  }
  [window addSubview:self];

  [self dialogWillAppear];
    
  self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:kTransitionDuration/1.5];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
  self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
  [UIView commitAnimations];

  [self addObservers];
}

- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated {
  if (success) {
    if ([_delegate respondsToSelector:@selector(dialogDidSucceed:)]) {
      [_delegate dialogDidSucceed:self];
    }
  } else {
    if ([_delegate respondsToSelector:@selector(dialogDidCancel:)]) {
      [_delegate dialogDidCancel:self];
    }
  }

  [self dismiss:animated];
}

- (void)dismissWithError:(NSError*)error animated:(BOOL)animated {
  if ([_delegate respondsToSelector:@selector(dialog:didFailWithError:)]) {
    [_delegate dialog:self didFailWithError:error];
  }

  [self dismiss:animated];
}

- (void)load {
  // Intended for subclasses to override
}

- (void)loadURL:(NSString*)url {
  [_loadingURL release];
  _loadingURL = [[NSURL URLWithString:url] retain];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
  [request setCachePolicy:NSURLCacheStorageNotAllowed];
  [_webView loadRequest:request];
}

- (void)dialogWillAppear {
}

- (void)dialogWillDisappear {
}

- (void)dialogDidSucceed:(NSURL*)url {
	URLParser *parser = [[[URLParser alloc] initWithURLString:[url absoluteString]] autorelease];
	NSString *oauth_token = [parser valueForVariable:@"oauth_token"];
	self.token = oauth_token;
	NSLog(@"%@", oauth_token); 
	NSString *oauth_verifier = [parser valueForVariable:@"oauth_verifier"];
	self.verifier = oauth_verifier;
	NSLog(@"%@", oauth_verifier); 

	[self dismissWithSuccess:YES animated:YES];
}

@end
