//
//  WKWebViewControllerEx.h
//  WKWebViewController
//
//  Created by hoojack on 2017/12/18.
//  Copyright © 2019 hoojack. All rights reserved.
//

#import "WKWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewControllerEx : WKWebViewController

@property (nonatomic, assign) BOOL showProgress;
@property (nonnull, nonatomic, strong) UIColor* progressColor;

@property (nonatomic, assign) BOOL showBackForwardBar;

/**
 * Clear webview cache
 */
+ (void)clearCache;


@end

NS_ASSUME_NONNULL_END
