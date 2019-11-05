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
   
    self.navigationItem.title = @"wkWebView";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPush:(UIButton *)sender
{
    WebViewController* vc = [[WebViewController alloc] init];
    vc.url = @"https://www.hao123.com";
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
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
