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
        self.messageName = @"wkTestObject";
        self.showProgress = YES;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.wkWebView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
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

- (id)testFunc4:(id)argument
{
    return @"12345678";
}

@end
