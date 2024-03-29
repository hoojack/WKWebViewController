//
//  ViewController.m
//  testWKJS
//
//  Created by author on 2017/12/22.
//  Copyright © 2017年 hoojack. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.navigationItem.title = @"WKWebView";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPush:(UIButton *)sender
{
    WebViewController* vc = [[WebViewController alloc] initWithUrl:@"http://www.265.com"];
    //vc.url = @"http://www.265.com";
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onPresent:(UIButton *)sender
{
    WebViewController* vc = [[WebViewController alloc] init];
    vc.url = @"http://www.test.com/wkwebview.html";
    vc.isPresent = YES;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
