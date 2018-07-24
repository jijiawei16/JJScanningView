//
//  ViewController.m
//  JJScannningView
//
//  Created by 16 on 2018/7/24.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "ViewController.h"
#import "ScanningViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    UILabel *show;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    [btn setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.layer.borderWidth = 1;
    [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    show = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, 200, 300)];
    show.textAlignment = NSTextAlignmentCenter;
    show.textColor = [UIColor lightGrayColor];
    show.numberOfLines = 0;
    show.text = @"展示二维码扫描信息";
    [self.view addSubview:show];
    
}
- (void)btn
{
    ScanningViewController *scanVC = [[ScanningViewController alloc] init];
    scanVC.scan = ^(NSArray *data) {
        show.text = [NSString stringWithFormat:@"%@",data[0]];
    };
    [self presentViewController:scanVC animated:YES completion:nil];
}

@end

