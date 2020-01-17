//
//  WebViewController.m
//  testWKJS
//
//  Created by hoojack on 2018/1/7.
//  Copyright © 2018年 hoojack. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)dealloc
{
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        self.messageName = @"wkTestObject";
        
        self.progressColor = [UIColor orangeColor];
        self.backForwardBarTintColor = [UIColor orangeColor];
        self.backForwardBarSpace = 60.0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (@available(iOS 9.0, *))
    {
        self.wkWebView.allowsLinkPreview = NO;
    }
    
    UIBarButtonItem* closeBarItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_close"] style:UIBarButtonItemStylePlain target:self action:@selector(onCloseAction:)];
    self.navigationItem.leftBarButtonItem = closeBarItem;
    
    UIBarButtonItem* refreshBarItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefreshAction:)];
    UIBarButtonItem* clearBarItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onClearAction:)];
    
    self.navigationItem.rightBarButtonItems = @[refreshBarItem, clearBarItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action
- (void)onCloseAction:(id)sender
{
    if (self.isPresent)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onClearAction:(id)sender
{
    [[self class] clearCache];
}

- (void)onRefreshAction:(id)sender
{
    [self.wkWebView reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [super webView:webView didFinishNavigation:navigation];
    
    // Invoke JSFunction
    NSArray* args = @[@"str", @(123), @[@"a", @"b"], @{@"key1":@"value", @"key2":@(1)}];
    [self invokeJSFunction:@"testJSFunction" args:args completionHandler:^(id _Nullable response, NSError * _Nullable error)
    {
        NSLog(@"%@", response);
    }];
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKFrameInfo* targetFrame = navigationAction.targetFrame;
    if (!targetFrame.isMainFrame)
    {
        WebViewController* controller = [[WebViewController alloc] init];
        controller.url = navigationAction.request.URL.absoluteString;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    return nil;
}


- (NSArray<NSHTTPCookie*> *)getCookiesProperty
{
    NSMutableArray* cookies = [NSMutableArray array];
    
    NSMutableDictionary* cookiePropM = [NSMutableDictionary dictionary];
    [cookiePropM setObject:@"A1_Name" forKey:NSHTTPCookieName];
    [cookiePropM setObject:@"A1_Value" forKey:NSHTTPCookieValue];
    [cookiePropM setObject:@".test.com" forKey:NSHTTPCookieDomain];
    [cookiePropM setObject:@"/" forKey:NSHTTPCookiePath];
    //[cookiePropM setObject:@(60) forKey:NSHTTPCookieMaximumAge];
    NSHTTPCookie* cookieA = [NSHTTPCookie cookieWithProperties:cookiePropM];
    [cookies addObject:cookieA];
    
    cookiePropM = [NSMutableDictionary dictionary];
    [cookiePropM setObject:@"A2_Name" forKey:NSHTTPCookieName];
    [cookiePropM setObject:@"A2_Value" forKey:NSHTTPCookieValue];
    [cookiePropM setObject:@".test.com" forKey:NSHTTPCookieDomain];
    [cookiePropM setObject:@"/" forKey:NSHTTPCookiePath];
    [cookiePropM setObject:@(86400) forKey:NSHTTPCookieMaximumAge];
    NSHTTPCookie* cookieB = [NSHTTPCookie cookieWithProperties:cookiePropM];
    [cookies addObject:cookieB];
    
    return [cookies copy];
}

- (NSArray<NSDictionary *> *)getExtendJSFunction
{
    NSArray* extend = [super getExtendJSFunction];
    NSMutableArray* arrayM = [NSMutableArray arrayWithArray:extend];
    [arrayM addObject:@{WKExtendJSFunctionNameKey:@"testFunc"}];
    [arrayM addObject:@{WKExtendJSFunctionNameKey:@"testFunc2"}];
    [arrayM addObject:@{WKExtendJSFunctionNameKey:@"testFunc3"}];
    [arrayM addObject:@{WKExtendJSFunctionNameKey:@"testFunc4"}];
    
    return arrayM;
}

- (NSDictionary<NSString *,id> *)getCustomConfigProperty
{
    NSMutableDictionary* config = [NSMutableDictionary dictionary];
    
    [config setObject:@"1.0.0.1" forKey:@"version"];
    [config setObject:@"iOS" forKey:@"platform"];
    [config setObject:@(1) forKey:@"wkwebview"];
    [config setObject:@{@"a" : @"a1"} forKey:@"dictProp"];
    [config setObject:@[@"a", @"b"] forKey:@"arrayProp"];
    
    return [config copy];
}

#pragma mark - Functions
- (id)testFunc:(id)argument
{
    NSLog(@"%@", argument);
    
    return @"retval";
}

- (id)testFunc2:(id)argument
{
    NSLog(@"%@", argument);
    
    return nil;
}

- (id)testFunc3:(id)argument
{
    return @[@"1", @"2", @3];
}

- (id)testFunc4
{
    return @"12345678";
}

@end
