//
//  WKWebViewController.h
//  WKWebViewController
//
//  Created by hoojack on 2017/12/18.
//  Copyright © 2017年 hoojack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Extend function name key, more infomation see getExtendJSFunction.
 */
FOUNDATION_EXPORT NSString* const WKExtendJSFunctionNameKey;

/**
 * A view controller that specializes in managing a WKWebView.
 */
@interface WKWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

/**
 * Returns the WKWebView managed by the controller object.
 */
@property (nonatomic, strong, readonly) WKWebView* wkWebView;

/**
 * The name of the message handler.
 * @discussion Function window.<messageName>.functionName(arg) for all frame.
 */
@property (nonnull, nonatomic, copy) NSString* messageName;

/**
 * The url string to which to navigate.
 */
@property (nonnull, nonatomic, copy) NSString* url;

/**
 * A title display on navigation bar, if not special, get "document.title" instead.
 */
@property (nullable, nonatomic, copy) NSString* documentTitle;

/**
 * Create NSURLRequest object with url property
 */
- (nullable NSURLRequest*)createURLRequest;

/**
 * Sets the webpage contents and base URL.
 */
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

/**
 * Returns custom cookie property array
 */
- (nullable NSArray<NSHTTPCookie*>*)getCookiesProperty;

/**
 * Returns function config for messageHandler
 
 @code
  return @[@{WKExtendJSFunctionNameKey, @"functionName1"},
           @{WKExtendJSFunctionNameKey, @"functionName2"}]
 @endcode
 eg:window.<messageName>.functionName1,  window.<messageName>.functionName2
 */
- (nullable NSArray<NSDictionary*>*)getExtendJSFunction;

/**
 * Returns custom config for window.<messageName>.configs['key'].
 */
- (nullable NSDictionary<NSString*, id>*)getCustomConfigProperty;

/**
 * Invoke Javascript function with some arguments.
 @code
 invokeJSFunction(@"functionName", @[@"str", @{"key":value}, @[@"item"], @(1)], completionHandler:completionHandler);
 @endcode
 */
- (void)invokeJSFunction:(NSString*)functionName
                    args:(NSArray*)args
       completionHandler:(void(^)(id _Nullable, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
