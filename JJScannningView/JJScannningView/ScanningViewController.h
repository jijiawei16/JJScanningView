//
//  ScanningViewController.h
//  扫描二维码
//
//  Created by 16 on 2018/7/24.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^scanEnd)(NSArray *data);
@interface ScanningViewController : UIViewController

@property (nonatomic , copy) scanEnd scan;
@end
