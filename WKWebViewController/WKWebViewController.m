//
//  WKWebViewController.m
//  WKWebViewController <https://github.com/hoojack/WKWebViewController>
//
//  Created by hoojack on 2017/12/18.
//  Copyright © 2017年 hoojack. All rights reserved.
//

#import "WKWebViewController.h"

#pragma mark - WKWebViewScriptHandlerObject
@interface WKWebViewScriptHandlerObject : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id <WKScriptMessageHandler> delegate;

@end

@implementation WKWebViewScriptHandlerObject

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)])
    {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

NSString* const WKExtendJSFunctionNameKey = @"name";

/**/
#pragma mark - WKWebViewController
@interface WKWebViewController ()

@property (nonatomic, strong) WKWebView* wkWebView;
@property (nonatomic, assign) BOOL isViewAppear;

@end

@implementation WKWebViewController

- (instancetype)init
{
    return [self initWithUrl:@""];
}

- (instancetype)initWithUrl:(NSString*)url
{
    self = [super init];
    if (self != nil)
    {
        self.messageName = @"_WKWebview_";
        self.url = url;
    }
    
    return self;
}

- (void)dealloc
{
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:self.messageName];
    [self.wkWebView.configuration.userContentController removeAllUserScripts];
    
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self createWKWebView];
    [self loadURL:[NSURL URLWithString:self.url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.wkWebView.frame = bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewAppear = NO;
}

- (void)createWKWebView
{
    WKWebViewScriptHandlerObject* webViewScriptHandlerObject = [[WKWebViewScriptHandlerObject alloc] init];
    webViewScriptHandlerObject.delegate = self;
    
    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:webViewScriptHandlerObject name:self.messageName];
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    config.allowsInlineMediaPlayback = YES;
    config.mediaPlaybackRequiresUserAction = NO;
    
    WKPreferences* preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
    
    WKWebView* wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    wkWebView.UIDelegate = self;
    wkWebView.navigationDelegate = self;
    [self.view addSubview:wkWebView];
    self.wkWebView = wkWebView;
    
    if (@available(iOS 11.0, *))
    {
        self.wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (NSArray<NSHTTPCookie*>*)getCookiesProperty
{
    return @[];
}

- (void)setupCookiesWithWebView:(WKWebView*)webView
{
    NSArray<NSHTTPCookie*>* cookiesProperty = [self getCookiesProperty];
    NSString* cookies = @"";
    WKUserContentController* userContentController = webView.configuration.userContentController;
    
    for (NSHTTPCookie* cookie in cookiesProperty)
    {
        NSString* name = cookie.name;
        NSString* value = cookie.value;
        NSString* domain = cookie.domain;
        NSString* path = cookie.path;
        NSDate* expiresDate = cookie.expiresDate;
        
        if (name.length == 0 || value.length == 0)
        {
            continue;
        }
        
        cookies = [NSString stringWithFormat:@"document.cookie='%@=%@", name, value];
        
        if (domain.length > 0)
        {
            cookies = [cookies stringByAppendingFormat:@";domain=%@", domain];
        }
        
        if (path.length > 0)
        {
            cookies = [cookies stringByAppendingFormat:@";path=%@", path];
        }
        
        if (expiresDate != nil)
        {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss 'GMT'";
            formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            
            NSString* dateString = [formatter stringFromDate:expiresDate];
            cookies = [cookies stringByAppendingFormat:@";expires=%@", dateString];
        }
        
        cookies = [cookies stringByAppendingString:@";'"];
        
        WKUserScript* userScript = [[WKUserScript alloc] initWithSource:cookies injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:userScript];
    }
}

- (void)setupCustomRequestHeader:(NSMutableURLRequest*)request
{
    NSArray<NSHTTPCookie*>* cookies = [self getCookiesProperty];
    NSArray<NSHTTPCookie*>* matchedCookies = [cookies filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSHTTPCookie*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings)
    {
        if ([request.URL.host rangeOfString:evaluatedObject.domain options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            return YES;
        }
        
        return NO;
    }]];
    
    if (matchedCookies.count == 0)
    {
        return;
    }
    NSDictionary<NSString*, NSString*>* requestHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:matchedCookies];
    for (NSString* key in requestHeaders)
    {
        NSString* value = [requestHeaders objectForKey:key];
        [request addValue:value forHTTPHeaderField:key];
    }
}

- (NSURLRequest *)createURLRequestWithURL:(NSURL*)url
{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:self.cachePolicy timeoutInterval:self.timeoutInterval];
    
    return request;
}

- (void)loadURL:(NSURL*)url
{
    NSURLRequest* urlRequest = [self createURLRequestWithURL:url];
    [self loadRequest:urlRequest];
}

- (void)loadRequest:(NSURLRequest*)request
{
    [self setupUserScriptWithWebView:self.wkWebView];
    
    NSMutableURLRequest* requestM = [request mutableCopy];
    
    [self setupCustomRequestHeader:requestM];
    
    [self.wkWebView loadRequest:[requestM copy]];
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    [self.wkWebView loadHTMLString:string baseURL:baseURL];
}

- (void)reload
{
    [self loadURL:self.wkWebView.URL];
}

#pragma mark - JSConfig
#define _JS_STR(str) #str
static NSString* JSConfigSource = @_JS_STR(
;(function(w){
    w.#OBJECTNAME# = {
        postMessage:function(name, args) {
            var arr = [].slice.call(args), cbkey = null;
            if (arr.length > 0) {
                var cb = arr[arr.length - 1];
                if (typeof cb === 'function') {
                    arr.pop();
                    cbkey = (new Date().getTime()).toString();
                    this.callbacks[cbkey] = cb;
                }
            }
            var msg = {'name':name, 'args':arr};
            if (cbkey != null) msg['callback'] = cbkey;
            w.webkit.messageHandlers.#OBJECTNAME#.postMessage(msg);
        },
        extend:function() {
            var target = this, length = arguments.length, arg;
            for (var i = 0; i < length; i++) {
                arg = arguments[i];
                for (var name in arg) {
                    target[name] = arg[name];
                }
            }
            return target;
        },
        callbacks:{},
        callback:function(key, data) {
            var cb = this.callbacks[key], retval = null;
            if (typeof cb === 'function') {
                retval = cb(data);
                delete this.callback[key];
            }
            return retval;
        },
        configs:{},
        setConfig:function(arg) {
            var target = this;
            for (var name in arg) {
                target.configs[name] = arg[name];
            }
        }
    };
    w.document.addEventListener('DOMContentLoaded', function(e) {
        w.#OBJECTNAME#.domContentLoaded();
    });
    w.addEventListener('error', function(e) {
        w.#OBJECTNAME#.logError(e.message, e.filename, e.lineno);
    });
    if (w.console.log) {
        w.console.log = function(m) {
            w.#OBJECTNAME#.logInfo(m);
        }
    }
})(window););
static NSString* JSExtendSource = @_JS_STR(
{ #FUNCNAME#:function() {
    this.postMessage('#FUNCNAME#', arguments);
}});
static NSString* JSCallbackSource = @_JS_STR(
    window.#OBJECTNAME#.callback('%@', %@);
);
#undef _JS_STR

- (void)setMainJSFunction:(WKWebView*)webView
{
    NSString* JSSource = [JSConfigSource stringByReplacingOccurrencesOfString:@"#OBJECTNAME#" withString:self.messageName];
    WKUserScript* userScript = [[WKUserScript alloc] initWithSource:JSSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [webView.configuration.userContentController addUserScript:userScript];
}

- (NSArray<NSDictionary*>*)getExtendJSFunction
{
    return @[];
}

- (NSArray<NSDictionary*>*)getExtendJSFunctionInternal
{
    return @[@{WKExtendJSFunctionNameKey:@"logError"},
             @{WKExtendJSFunctionNameKey:@"logInfo"},
             @{WKExtendJSFunctionNameKey:@"domContentLoaded"}];
}

- (NSDictionary<NSString *,id> *)getCustomConfigProperty
{
    return @{};
}

- (void)setExtendJSFunction:(WKWebView*)webView
{
    NSArray<NSDictionary*>* functionsExtend = [self getExtendJSFunction];
    NSArray<NSDictionary*>* functionsInternal = [self getExtendJSFunctionInternal];
    
    NSMutableArray<NSDictionary*>* functionsM = [NSMutableArray arrayWithArray:functionsInternal];
    [functionsM addObjectsFromArray:functionsExtend];
    
    NSString* JSExtend = @"";
    for (NSDictionary* func in functionsM)
    {
        NSString* funcName = [func objectForKey:WKExtendJSFunctionNameKey];
        NSString* JSConfig = [JSExtendSource stringByReplacingOccurrencesOfString:@"#FUNCNAME#" withString:funcName];
        
        JSExtend = [JSExtend stringByAppendingString:[JSConfig stringByAppendingString:@","]];
    }
    
    if (JSExtend.length > 0)
    {
        JSExtend = [JSExtend stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        NSString* JSSource = [NSString stringWithFormat:@"%@.extend(%@);", self.messageName, JSExtend];
        WKUserScript* userScript = [[WKUserScript alloc] initWithSource:JSSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [webView.configuration.userContentController addUserScript:userScript];
    }
}

- (void)setCustomConfig:(WKWebView*)webView
{
    NSDictionary<NSString*, id>* configProp = [self getCustomConfigProperty];
    
    if (configProp.count > 0)
    {
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:configProp options:kNilOptions error:&error];
        if (data != nil && error == nil)
        {
            NSString* configJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString* JSSource = [NSString stringWithFormat:@"%@.setConfig(%@);", self.messageName, configJSON];
            WKUserScript* userScript = [[WKUserScript alloc] initWithSource:JSSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:userScript];
        }
    }
}

- (void)setupUserScriptWithWebView:(WKWebView*)wkWebView
{
    [wkWebView.configuration.userContentController removeAllUserScripts];
    
    [self setupCookiesWithWebView:wkWebView];
    
    [self setMainJSFunction:wkWebView];
    
    [self setExtendJSFunction:wkWebView];
    
    [self setCustomConfig:wkWebView];
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo* targetFrame = navigationAction.targetFrame;
    if (!targetFrame.isMainFrame)
    {
        [self loadRequest:navigationAction.request];
    }
    
    return nil;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (!self.isViewAppear)
    {
        return;
    }
    
    NSString* name = message.name;
    id body = message.body;
    
    if ([name isEqualToString:self.messageName] && [body isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* bodyDict = (NSDictionary*)body;
        NSString* func = [bodyDict objectForKey:@"name"];
        NSArray* args = [bodyDict objectForKey:@"args"];
        NSString* callback = [bodyDict objectForKey:@"callback"];
        if (args.count > 0) func = [func stringByAppendingString:@":"];
        SEL selector = NSSelectorFromString(func);
        NSMethodSignature* sig = [self methodSignatureForSelector:selector];
        if (sig != nil)
        {
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
            invocation.target = self;
            invocation.selector = selector;
            if (args.count > 0)
            {
               [invocation setArgument:(void*)&args atIndex:2];
            }
            [invocation invoke];
            
            if (callback.length > 0)
            {
                [self invokeJSCallback:invocation callback:callback];
            }
        }
        else
        {
            NSAssert(0, @"Unable to find ‘%@’ implementation", func);
        }
    }
    else
    {
        NSLog(@"%@", body);
    }
}

- (NSString*)argumentToString:(id)anObject
{
    NSString* retStr = @"null";
    if ([anObject isKindOfClass:[NSString class]])
    {
        retStr = [NSString stringWithFormat:@"'%@'", anObject];
    }
    else if ([anObject isKindOfClass:[NSNumber class]])
    {
        retStr = [NSString stringWithFormat:@"%@", anObject];
    }
    else if ([anObject isKindOfClass:[NSArray class]] ||
             [anObject isKindOfClass:[NSDictionary class]])
    {
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:anObject options:kNilOptions error:&error];
        if (error == nil)
        {
            NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            retStr = [NSString stringWithFormat:@"%@", dataString];
            retStr = [retStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        }
    }
    
    return retStr;
}

- (void)invokeJSCallback:(NSInvocation*)invocation callback:(NSString*)callback
{
    void* retPtr = NULL;
    const char* retType = invocation.methodSignature.methodReturnType;
    if (strcmp(retType, @encode(id)) == 0)
    {
        [invocation getReturnValue:&retPtr];
    }
    id retVal = (__bridge id)retPtr;
    NSString* retStr = [self argumentToString:retVal];
    NSString* JSCallbackFormat = [JSCallbackSource stringByReplacingOccurrencesOfString:@"#OBJECTNAME#" withString:self.messageName];
    NSString* JSCallback = [NSString stringWithFormat:JSCallbackFormat, callback, retStr];
    [self.wkWebView evaluateJavaScript:JSCallback completionHandler:^(id _Nullable response, NSError * _Nullable error)
    {
         NSLog(@"%@, %@", response, error);
    }];
}

- (void)invokeJSFunction:(NSString*)functionName
                    args:(NSArray*)args
       completionHandler:(void(^)(id _Nullable response, NSError * _Nullable error))completionHandler
{
    NSMutableArray<NSString*>* argsM = [NSMutableArray array];
    for (id arg in args)
    {
        NSString* argStr = [self argumentToString:arg];
        [argsM addObject:argStr];
    }
    
    NSString* jsSource = [NSString stringWithFormat:@"%@(", functionName];
    for (NSString* argStr in argsM)
    {
        jsSource = [jsSource stringByAppendingFormat:@"%@,", argStr];
    }
    
    jsSource = [jsSource stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    jsSource = [jsSource stringByAppendingString:@");"];
    
    [self.wkWebView evaluateJavaScript:jsSource completionHandler:completionHandler];
}

#pragma mark - Internal Function
- (void)logError:(id)arguments
{
    NSLog(@"Error:%@", arguments);
}

- (void)logInfo:(id)arguments
{
    NSLog(@"console.log:%@", arguments);
}

- (void)domContentLoaded
{
    NSLog(@"domContentLoaded");
}

@end
