//
//  WKWebViewControllerEx.m
//  WKWebViewController <https://github.com/hoojack/WKWebViewController>
//
//  Created by hoojack on 2017/12/18.
//  Copyright © 2019 hoojack. All rights reserved.
//

#import "WKWebViewControllerEx.h"

static NSString* const kEstimatedProgress = @"estimatedProgress";
static NSString* const kCanGoBack = @"canGoBack";
static NSString* const kCanGoForward = @"canGoForward";
static NSString* const kContentOffset = @"contentOffset";
static NSString* const kDocumentTitle = @"title";

#pragma mark - WKWebViewNavigationBar
@interface WKWebViewNavigationBar : UIView

@property (class, readonly) CGFloat barHeight;
@property (nonatomic, weak) WKWebView* webView;
@property (nonatomic, weak) NSBundle* bundle;
@property (nonatomic, strong) UIToolbar* toolbar;
@property (nonatomic, strong) UIBarButtonItem* backbarItem;
@property (nonatomic, strong) UIBarButtonItem* forwardbarItem;
@property (nonatomic, strong) UIBarButtonItem* spacebarItem;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, assign, readonly) BOOL canGoBack;
@property (nonatomic, assign, readonly) BOOL canGoForward;
@property (nonatomic, assign) CGFloat backForwardSpace;

- (void)showToolBarIfNeeded;

@end

@implementation WKWebViewNavigationBar

+ (CGFloat)barHeight
{
    return 50.0;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil)
    {
        [self createSubviews];
    }
    
    return self;
}

- (void)createSubviews
{
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, [[self class] barHeight])];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:toolbar];
    self.toolbar = toolbar;
    
    UIBarButtonItem* backbarItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(onBackAction:)];
    backbarItem.enabled = NO;
    self.backbarItem = backbarItem;
    
    UIBarButtonItem* forwardbarItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(onForwardAction:)];
    forwardbarItem.enabled = NO;
    self.forwardbarItem = forwardbarItem;
    
    UIBarButtonItem* flexbarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* spacebarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.spacebarItem = spacebarItem;
    spacebarItem.width = 30.0;
    
    [self.toolbar setItems:@[flexbarItem, backbarItem, spacebarItem, forwardbarItem, flexbarItem]];
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle;
    
    UIImage* imageBack = [UIImage imageNamed:@"icon_nav_back" inBundle:self.bundle compatibleWithTraitCollection:nil];
    self.backbarItem.image = imageBack;
    
    UIImage* imageForward = [UIImage imageNamed:@"icon_nav_forward" inBundle:self.bundle compatibleWithTraitCollection:nil];
    self.forwardbarItem.image = imageForward;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    
    self.toolbar.tintColor = tintColor;
}

- (void)setBackForwardSpace:(CGFloat)backForwardSpace
{
    _backForwardSpace = backForwardSpace;
    
    if (_backForwardSpace > 0)
    {
        self.spacebarItem.width = _backForwardSpace;
    }
}

- (void)onBackAction:(id)sender
{
    [self.webView goBack];
}

- (void)onForwardAction:(id)sender
{
    [self.webView goForward];
}

- (void)showToolBar:(BOOL)show
{
    CGRect frame = self.frame;
    NSTimeInterval duration = 0.25;
    
    if (show == !self.hidden)
    {
        return;
    }
    
    if (show && CGRectGetMinY(frame) >= CGRectGetMaxY(self.webView.frame) - CGRectGetHeight(frame))
    {
        frame.origin.y = CGRectGetMaxY(self.webView.frame) - CGRectGetHeight(frame);
        [UIView animateWithDuration:duration animations:^
        {
            self.frame = frame;
        }
        completion:^(BOOL finished)
        {
            if (finished)
            {
                self.hidden = NO;
                [self.superview setNeedsLayout];
                [self.superview layoutIfNeeded];
            }
        }];
    }
    else if (!show && CGRectGetMinY(frame) <= CGRectGetMaxY(self.webView.frame))
    {
        frame.origin.y = CGRectGetMaxY(self.webView.frame);
        [UIView animateWithDuration:duration animations:^
        {
           self.frame = frame;
        }
        completion:^(BOOL finished)
        {
            if (finished)
            {
                self.hidden = YES;
                [self.superview setNeedsLayout];
                [self.superview layoutIfNeeded];
            }
        }];
    }
}

- (void)showToolBarIfNeeded
{
    if (self.canGoBack || self.canGoForward)
    {
        [self showToolBar:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kCanGoBack])
    {
        self.webView = object;
        
        NSNumber* canGoBack = [change objectForKey:NSKeyValueChangeNewKey];
        _canGoBack = canGoBack.boolValue;
        self.backbarItem.enabled = self.canGoBack;
        
        [self showToolBarIfNeeded];
    }
    else if ([keyPath isEqualToString:kCanGoForward])
    {
        self.webView = object;
        
        NSNumber* canGoForward = [change objectForKey:NSKeyValueChangeNewKey];
        _canGoForward = canGoForward.boolValue;
        self.forwardbarItem.enabled = self.canGoForward;
        
        [self showToolBarIfNeeded];
    }
    else if ([keyPath isEqualToString:kContentOffset])
    {
        NSValue* offsetValue = [change objectForKey:NSKeyValueChangeNewKey];
        CGPoint contentOffset = offsetValue.CGPointValue;
        
        //NSLog(@"ContentOffset:%@", NSStringFromCGPoint(contentOffset));
        
        UIScrollView* scrollView = object;
        if (!scrollView.tracking || self.webView == nil)
        {
            return;
        }
        
        if (contentOffset.y >= 0 && !CGPointEqualToPoint(self.contentOffset, contentOffset))
        {
            if (self.contentOffset.y - contentOffset.y < 0)
            {
                [self showToolBar:NO];
            }
            else
            {
                [self showToolBar:YES];
            }
            
            self.contentOffset = contentOffset;
        }
    }
}

@end

/**/

#pragma mark - WKWebViewProgressView
@interface WKWebViewProgressView : UIView

@property (class, assign, readonly) CGFloat height;
@property (nonatomic, strong) UIView* progressBar;
@property (nonatomic, assign) double progress;

@end

@implementation WKWebViewProgressView

+ (CGFloat)height
{
    return 2.5;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self createSubViews];
    }
    
    return self;
}

- (void)createSubViews
{
    UIView* progressBar = [[UIView alloc] init];
    [self addSubview:progressBar];
    self.progressBar = progressBar;
}

- (void)setProgress:(double)progress
{
    _progress = progress;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    self.progressBar.frame = CGRectMake(0, 0, CGRectGetWidth(bounds) * self.progress, CGRectGetHeight(bounds));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kEstimatedProgress])
    {
        NSNumber* newValue = [change objectForKey:NSKeyValueChangeNewKey];
        
        double progress = newValue.doubleValue;
        if (progress == 1.0) progress = 0;
        self.progress = progress;
    }
}

@end

#pragma mark - WKWebViewControllerKVOHandler

@interface WKWebViewControllerKVOHandler : NSObject

@property (nonatomic, strong) NSHashTable* observers;

@end

@implementation WKWebViewControllerKVOHandler

- (instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        _observers = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

- (void)addKVOObserver:(id)observer
{
    [self.observers addObject:observer];
}

- (void)removeAllObservers
{
    [self.observers removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kDocumentTitle] ||
        [keyPath isEqualToString:kCanGoBack] ||
        [keyPath isEqualToString:kCanGoForward] ||
        [keyPath isEqualToString:kContentOffset] ||
        [keyPath isEqualToString:kEstimatedProgress])
    {
        for (id observer in self.observers)
        {
            [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

@end

#pragma mark - WKWebViewControllerEx
@interface WKWebViewControllerEx ()

@property (nonatomic, assign) BOOL isViewAppear;
@property (nonatomic, strong) WKWebViewControllerKVOHandler* KVOHandler;
@property (nonatomic, strong) WKWebViewProgressView* progressView;
@property (nonatomic, strong) WKWebViewNavigationBar* navigationBar;
@property (nonatomic, strong) NSBundle* bundle;
@property (nonatomic, weak) UITextField* javaScriptTextInputPanelWithPrompt;

@end

@implementation WKWebViewControllerEx

+ (void)clearCache
{
    NSError* error = nil;
    NSString* cachePath = [@"~/Library/WebKit" stringByExpandingTildeInPath];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* path = [cachePath stringByAppendingPathComponent:appID];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error);
    }
    
    error = nil;
    NSString* cookiePath = [@"~/Library/Cookies" stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] removeItemAtPath:cookiePath error:&error];
    if (error != nil)
    {
        NSLog(@"%@", error);
    }
}

- (void)dealloc
{
    [self removeKVOHandler];
}

- (instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.showProgress = YES;
        self.progressColor = [UIColor orangeColor];
        
        self.showBackForwardBar = YES;
        self.backForwardBarTintColor = [UIColor blackColor];
        self.bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WKWebViewController" ofType:@"bundle"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupKVOHandler];
    [self createProgressView];
    [self createNavigationbar];
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.progressView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), [WKWebViewProgressView height]);
    
    CGFloat navigationBarHeight = [WKWebViewNavigationBar barHeight];
    if (@available(iOS 11.0, *))
    {
        navigationBarHeight += self.view.safeAreaInsets.bottom;
    }
    
    CGRect navigationBarFrame = CGRectZero;
    CGRect wkWebViewFrame = CGRectZero;
    if (self.showBackForwardBar && !self.navigationBar.hidden)
    {
        navigationBarFrame = CGRectMake(0, CGRectGetHeight(bounds) - navigationBarHeight, CGRectGetWidth(bounds), navigationBarHeight);
        wkWebViewFrame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - navigationBarHeight);
    }
    else
    {
        navigationBarFrame = CGRectMake(0, CGRectGetHeight(bounds), CGRectGetWidth(bounds), navigationBarHeight);
        wkWebViewFrame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    }
    
    self.navigationBar.frame = navigationBarFrame;
    self.wkWebView.frame = wkWebViewFrame;
}

- (void)setupKVOHandler
{
    self.KVOHandler = [[WKWebViewControllerKVOHandler alloc] init];
    [self.KVOHandler addKVOObserver:self];
    
    [self.wkWebView addObserver:self.KVOHandler forKeyPath:kDocumentTitle options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebView addObserver:self.KVOHandler forKeyPath:kEstimatedProgress options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebView addObserver:self.KVOHandler forKeyPath:kCanGoBack options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebView addObserver:self.KVOHandler forKeyPath:kCanGoForward options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebView.scrollView addObserver:self.KVOHandler forKeyPath:kContentOffset options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeKVOHandler
{
    [self.KVOHandler removeAllObservers];
    
    [self.wkWebView removeObserver:self.KVOHandler forKeyPath:kDocumentTitle];
    [self.wkWebView removeObserver:self.KVOHandler forKeyPath:kEstimatedProgress];
    [self.wkWebView removeObserver:self.KVOHandler forKeyPath:kCanGoBack];
    [self.wkWebView removeObserver:self.KVOHandler forKeyPath:kCanGoForward];
    [self.wkWebView.scrollView removeObserver:self.KVOHandler forKeyPath:kContentOffset];
}

- (void)createProgressView
{
    if (!self.showProgress)
    {
        return;
    }
    
    WKWebViewProgressView* progressView = [[WKWebViewProgressView alloc] init];
    progressView.progressBar.backgroundColor = self.progressColor;
    progressView.hidden = YES;
    [self.wkWebView.scrollView addSubview:progressView];
    self.progressView = progressView;
    [self.KVOHandler addKVOObserver:self.progressView];
}

- (void)showProgressView:(BOOL)show
{
    self.progressView.hidden = !show;
    if (show)
    {
        [self.progressView.superview bringSubviewToFront:self.progressView];
    }
}

- (void)createNavigationbar
{
    if (!self.showBackForwardBar)
    {
        return;
    }
    
    WKWebViewNavigationBar* navigationBar = [[WKWebViewNavigationBar alloc] initWithFrame:CGRectZero];
    navigationBar.bundle = self.bundle;
    navigationBar.hidden = YES;
    navigationBar.tintColor = self.backForwardBarTintColor;
    navigationBar.backForwardSpace = self.backForwardBarSpace;
    [self.view addSubview:navigationBar];
    self.navigationBar = navigationBar;
    [self.KVOHandler addKVOObserver:self.navigationBar];
}

- (void)showBackForwardBarIfNeeded
{
    if (!self.showBackForwardBar)
    {
        return;
    }
    
    [self.navigationBar showToolBarIfNeeded];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kDocumentTitle])
    {
        NSString* title = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (title.length == 0) title = self.documentTitle;
        
        self.navigationItem.title = title;
    }
}

- (void)loadResourceHtml:(NSString*)name
{
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WKWebViewController" ofType:@"bundle"]];
    NSString* htmlFile = [bundle pathForResource:name ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString* path = [bundle bundlePath];
    NSURL* baseURL = [NSURL fileURLWithPath:path];
    
    [self loadHTMLString:htmlString baseURL:baseURL];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    NSString* okTitle = [self.bundle localizedStringForKey:@"ID_OK" value:nil table:nil];
    [alertController addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    NSString* cancelTitle = [self.bundle localizedStringForKey:@"ID_CANCEL" value:nil table:nil];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        completionHandler(NO);
    }]];
    
    NSString* okTitle = [self.bundle localizedStringForKey:@"ID_OK" value:nil table:nil];
    [alertController addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        completionHandler(YES);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
    {
        weakSelf.javaScriptTextInputPanelWithPrompt = textField;
        weakSelf.javaScriptTextInputPanelWithPrompt.text = defaultText;
    }];
    
    NSString* cancelTitle = [self.bundle localizedStringForKey:@"ID_CANCEL" value:nil table:nil];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        completionHandler(nil);
    }]];
    
    NSString* okTitle = [self.bundle localizedStringForKey:@"ID_OK" value:nil table:nil];
    [alertController addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        completionHandler(weakSelf.javaScriptTextInputPanelWithPrompt.text);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [super webView:webView didStartProvisionalNavigation:navigation];
    
    [self showProgressView:YES];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [super webView:webView didFailProvisionalNavigation:navigation withError:error];
    
    [self showProgressView:NO];
    
    switch (error.code)
    {
        case NSURLErrorTimedOut:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorCannotFindHost:
        case NSURLErrorNotConnectedToInternet:
        {
            [self loadResourceHtml:@"network_error"];
        }
            break;
        default:
            break;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [super webView:webView didFinishNavigation:navigation];
    
    [self showProgressView:NO];
    
    [self showBackForwardBarIfNeeded];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL* url = navigationAction.request.URL;
    if ([url.scheme compare:@"http" options:NSCaseInsensitiveSearch] != NSOrderedSame &&
        [url.scheme compare:@"https" options:NSCaseInsensitiveSearch] != NSOrderedSame &&
        [url.scheme compare:@"file" options:NSCaseInsensitiveSearch] != NSOrderedSame)
    {
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
