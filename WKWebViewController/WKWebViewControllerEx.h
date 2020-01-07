//
//  WKWebViewControllerEx.h
//  WKWebViewController <https://github.com/hoojack/WKWebViewController>
//
//  Created by hoojack on 2017/12/18.
//  Copyright © 2019 hoojack. All rights reserved.
//

#import "WKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewControllerEx : WKWebViewController

/**
 * Show or hide progressBar
 */
@property (nonatomic, assign) BOOL showProgress;
/**
 * ProgressBar Color
 */
@property (nonnull, nonatomic, strong) UIColor* progressColor;

/**
 * Show or hide backForward bar
 */
@property (nonatomic, assign) BOOL showBackForwardBar;
/**
 * Back forwardbar tintColor
 */
@property (nonnull, nonatomic, strong) UIColor* backForwardBarTintColor;
/**
 * Back forward item space
 */
@property (nonatomic, assign) CGFloat backForwardBarSpace;

/**
 * A title display on navigation bar, if not special, get "document.title" instead.
 */
@property (nullable, nonatomic, copy) NSString* documentTitle;

/**
 * Load html from bundle
 */
- (void)loadResourceHtml:(NSString*)name;

/**
 * Clear webview cache
 */
+ (void)clearCache;


@end

NS_ASSUME_NONNULL_END
