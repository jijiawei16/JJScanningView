//
//  JJScanningView.h
//  扫描二维码
//
//  Created by 16 on 2018/7/19.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JJScanningView;

@protocol JJScanningViewDelegate <NSObject>

/**
 * 二维码扫描获取数据的回调方法
 *
 * @param metadataObjects 扫描二维码数组数据信息
 */
- (void)JJScanningViewDidOutputMetadataObjects:(NSArray *)metadataObjects;
@end
@interface JJScanningView : UIView

///代理方法
@property (nonatomic , weak) id<JJScanningViewDelegate>delegate;

/**
 * 创建控件(尽量放到viewWillAppear里面执行,在viewDidload方法中也可以,但需要做延时处理,因为控制器的layer层还没创建好,会引起崩溃问题)
 * @param frame 扫描范围
 * @param superVC 父控制器
 */
- (instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC;

/**
 * 开启二维码扫描
 */
- (void)startScan;

/**
 * 停止二维码扫描
 */
- (void)stopScan;

/**
 * 移除扫描器
 */
- (void)removeScan;
@end
