//
//  ScanningViewController.m
//  扫描二维码
//
//  Created by 16 on 2018/7/24.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "ScanningViewController.h"
#import "JJScanningView.h"

@interface ScanningViewController ()<JJScanningViewDelegate>

@end

@implementation ScanningViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    JJScanningView *scan = [[JJScanningView alloc] initWithFrame:self.view.bounds superVC:self];
    scan.delegate = self;
    [self.view addSubview:scan];
    [scan startScan];
}
- (void)viewDidLoad {
    [super viewDidLoad];

}
- (void)JJScanningViewDidOutputMetadataObjects:(NSArray *)metadataObjects
{
    self.scan(metadataObjects);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
