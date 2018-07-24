//
//  JJScanningView.m
//  扫描二维码
//
//  Created by 16 on 2018/7/19.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJScanningView.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#define sw self.frame.size.width
#define sh self.frame.size.height
@interface JJScanningView ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

///父视图layer
@property (nonatomic, strong) CALayer *superLayer;
///二维码扫描线
@property (nonatomic, strong) UIImageView *scanningLine;
///二维码扫描时间
@property (nonatomic, strong) NSTimer *scanningTimer;
///二维码扫描相关
@property (nonatomic, strong) AVCaptureSession *session;
///二维码扫描layer层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end
@implementation JJScanningView
{
    CGFloat scanning_x;// 二维码扫描的x点
    CGFloat scanning_y;// 二维码扫描的y点
    CGFloat scanning_w;// 二维码扫描的宽度
    CGFloat outsideAlpha;// 二维码扫描外部的透明度
    UIButton *flashBtn;// 闪光灯按钮
    BOOL is_open;// 闪光灯是否开启
    
    CALayer *top_layer;// 顶部layer
    CALayer *left_layer;// 左侧layer
    UIImageView *right_imageView;// 右侧img
}
- (instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)superVC{
    
    self = [super initWithFrame:frame];
    if (self) {
        // 布局设置
        self.backgroundColor = [UIColor clearColor];
        is_open = NO;
        
        self.superLayer = superVC.view.layer;
        [self setUp];
        [self setUpScanningViewOnVC:superVC];
    }
    return self;
}
- (void)setUp
{
    scanning_x = sw*0.15;
    scanning_y = sh*0.25;
    outsideAlpha = 0.4;
    scanning_w = self.frame.size.width - 2*scanning_x;
    // 扫描内容的创建
    CALayer *centerLayer = [[CALayer alloc] init];
    CGFloat centerLayerX = scanning_x;
    CGFloat centerLayerY = scanning_y;
    CGFloat centerLayerW = scanning_w;
    CGFloat centerLayerH = centerLayerW;
    centerLayer.frame = CGRectMake(centerLayerX, centerLayerY, centerLayerW, centerLayerH);
    centerLayer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    centerLayer.borderWidth = 0.7;
    centerLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:centerLayer];
    
#pragma mark - - - 扫描外部View的创建
    // 顶部layer的创建
    top_layer = [[CALayer alloc] init];
    CGFloat top_layerX = 0;
    CGFloat top_layerY = 0;
    CGFloat top_layerW = self.frame.size.width;
    CGFloat top_layerH = scanning_y;
    top_layer.frame = CGRectMake(top_layerX, top_layerY, top_layerW, top_layerH);
    top_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:outsideAlpha].CGColor;
    [self.layer addSublayer:top_layer];
    
    // 左侧layer的创建
    left_layer = [[CALayer alloc] init];
    CGFloat left_layerX = 0;
    CGFloat left_layerY = scanning_y;
    CGFloat left_layerW = scanning_x;
    CGFloat left_layerH = centerLayerW;
    left_layer.frame = CGRectMake(left_layerX, left_layerY, left_layerW, left_layerH);
    left_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:outsideAlpha].CGColor;
    [self.layer addSublayer:left_layer];
    
    // 右侧layer的创建
    CALayer *right_layer = [[CALayer alloc] init];
    CGFloat right_layerX = CGRectGetMaxX(centerLayer.frame);
    CGFloat right_layerY = scanning_y;
    CGFloat right_layerW = scanning_x;
    CGFloat right_layerH = centerLayerW;
    right_layer.frame = CGRectMake(right_layerX, right_layerY, right_layerW, right_layerH);
    right_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:outsideAlpha].CGColor;
    [self.layer addSublayer:right_layer];
    
    // 下面layer的创建
    CALayer *bottom_layer = [[CALayer alloc] init];
    CGFloat bottom_layerX = 0;
    CGFloat bottom_layerY = CGRectGetMaxY(centerLayer.frame);
    CGFloat bottom_layerW = self.frame.size.width;
    CGFloat bottom_layerH = self.frame.size.height - bottom_layerY;
    bottom_layer.frame = CGRectMake(bottom_layerX, bottom_layerY, bottom_layerW, bottom_layerH);
    bottom_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:outsideAlpha].CGColor;
    [self.layer addSublayer:bottom_layer];
    
    // 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = CGRectGetMaxY(centerLayer.frame) + 30;
    CGFloat promptLabelW = self.frame.size.width;
    CGFloat promptLabelH = 25;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    [self addSubview:promptLabel];
    
#pragma mark - - - 扫描边角imageView的创建
    // 设置扫一扫的相关图片
    // 左上侧的image
    CGFloat margin = 7;
    
    UIImage *left_image = [UIImage imageNamed:@"左上"];
    UIImageView *left_imageView = [[UIImageView alloc] init];
    CGFloat left_imageViewX = CGRectGetMinX(centerLayer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewY = CGRectGetMinY(centerLayer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewW = left_image.size.width;
    CGFloat left_imageViewH = left_image.size.height;
    left_imageView.frame = CGRectMake(left_imageViewX, left_imageViewY, left_imageViewW, left_imageViewH);
    left_imageView.image = left_image;
    [self.superLayer addSublayer:left_imageView.layer];
    
    // 右上侧的image
    UIImage *right_image = [UIImage imageNamed:@"右上"];
    UIImageView *right_imageView = [[UIImageView alloc] init];
    CGFloat right_imageViewX = CGRectGetMaxX(centerLayer.frame) - right_image.size.width * 0.5 - margin;
    CGFloat right_imageViewY = left_imageView.frame.origin.y;
    CGFloat right_imageViewW = left_image.size.width;
    CGFloat right_imageViewH = left_image.size.height;
    right_imageView.frame = CGRectMake(right_imageViewX, right_imageViewY, right_imageViewW, right_imageViewH);
    right_imageView.image = right_image;
    [self.superLayer addSublayer:right_imageView.layer];
    
    // 左下侧的image
    UIImage *left_image_down = [UIImage imageNamed:@"左下"];
    UIImageView *left_imageView_down = [[UIImageView alloc] init];
    CGFloat left_imageView_downX = left_imageView.frame.origin.x;
    CGFloat left_imageView_downY = CGRectGetMaxY(centerLayer.frame) - left_image_down.size.width * 0.5 - margin;
    CGFloat left_imageView_downW = left_image.size.width;
    CGFloat left_imageView_downH = left_image.size.height;
    left_imageView_down.frame = CGRectMake(left_imageView_downX, left_imageView_downY, left_imageView_downW, left_imageView_downH);
    left_imageView_down.image = left_image_down;
    [self.superLayer addSublayer:left_imageView_down.layer];
    
    // 右下侧的image
    UIImage *right_image_down = [UIImage imageNamed:@"右下"];
    UIImageView *right_imageView_down = [[UIImageView alloc] init];
    CGFloat right_imageView_downX = right_imageView.frame.origin.x;
    CGFloat right_imageView_downY = left_imageView_down.frame.origin.y;
    CGFloat right_imageView_downW = left_image.size.width;
    CGFloat right_imageView_downH = left_image.size.height;
    right_imageView_down.frame = CGRectMake(right_imageView_downX, right_imageView_downY, right_imageView_downW, right_imageView_downH);
    right_imageView_down.image = right_image_down;
    [self.superLayer addSublayer:right_imageView_down.layer];
    
#pragma mark 添加闪光灯
    flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw/2-30, scanning_y+scanning_w-60, 60, 60)];
    [flashBtn addTarget:self action:@selector(flashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn setImage:[UIImage imageNamed:@"flash_close"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"flash_open"] forState:UIControlStateSelected];
    flashBtn.selected = NO;
    [self addSubview:flashBtn];
    
    self.scanningLine.frame = CGRectMake(scanning_x*0.5, scanning_y, sw-scanning_x, 12);
    [self.layer addSublayer:self.scanningLine.layer];
    [self start];
}
#pragma 是否开关闪光灯
- (void)flashBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self openFlash:sender.selected];
}
- (void)openFlash:(BOOL)open
{
    if (open) {
        
        is_open = YES;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }else {
        
        is_open = NO;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}
#pragma mark 开启动画
- (void)start
{
    [self.scanningTimer invalidate];
    self.scanningTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_scanningTimer forMode:NSRunLoopCommonModes];
}
- (void)timeAction
{
    if (_scanningLine.frame.origin.y+10 >= scanning_w+scanning_y) {
        _scanningLine.frame = CGRectMake(scanning_x*0.5, scanning_y, sw-scanning_x, 12);
    }
    __block CGRect newFrame = _scanningLine.frame;
    [UIView animateWithDuration:0.05 animations:^{
        newFrame.origin.y += 5;
        _scanningLine.frame = newFrame;
    } completion:nil];
}
#pragma mark - - - 移除定时器
- (void)removeTimer {
    [self.scanningTimer invalidate];
    self.scanningTimer = nil;
    [self.scanningLine removeFromSuperview];
    self.scanningLine = nil;
}
#pragma mark 懒加载
- (CALayer *)superLayer
{
    if (_superLayer == nil) {
        _superLayer = [[CALayer alloc] init];
    }
    return _superLayer;
}
- (UIImageView *)scanningLine
{
    if (_scanningLine == nil) {
        _scanningLine = [[UIImageView alloc] init];
        _scanningLine.image = [UIImage imageNamed:@"scanLine"];
    }
    return _scanningLine;
}
#pragma mark 二维码扫描
- (void)setUpScanningViewOnVC:(UIViewController *)superVC {
    
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建设备输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建数据输出流
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    // 3(1)创建设备输出流
    AVCaptureVideoDataOutput *VideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [VideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    // 4、设置代理：在主线程里刷新
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、创建会话对象
    _session = [[AVCaptureSession alloc] init];
    // 会话采集率: AVCaptureSessionPresetHigh
    _session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // 6、添加设备输入流到会话对象
    [_session addInput:deviceInput];
    
    // 7、添加设备输出流到会话对象
    [_session addOutput:metadataOutput];
    // 7(1)添加设备输出流到会话对象；与 3(1) 构成识别光线强弱
    [_session addOutput:VideoDataOutput];
    
    // 8、设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 9、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _videoPreviewLayer.delegate = self;
    // 保持纵横比；填充层边界
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoPreviewLayer.frame = superVC.view.layer.bounds;
    [self.superLayer insertSublayer:_videoPreviewLayer atIndex:0];
}
// 开始扫描
- (void)startScan
{
    [self start];
    [self.superLayer insertSublayer:_videoPreviewLayer atIndex:0];
    [_session startRunning];
    [self addScanningLine];
}
- (void)addScanningLine
{
    [self.scanningLine.layer removeFromSuperlayer];
    [self.layer addSublayer:self.scanningLine.layer];
}
// 结束扫描
- (void)stopScan {
    [_session stopRunning];
    [_scanningTimer invalidate];
    [self.scanningLine.layer removeFromSuperlayer];
}
- (void)removeScan {
    _session = nil;
    [_videoPreviewLayer removeFromSuperlayer];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self removeFromSuperview];
}
#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // 设置播放音效路径和震动效果
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"sound.mp3" ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  //震动
    AudioServicesPlaySystemSound(soundID); // 播放音效
    // 停止二维码扫描
    [self stopScan];
    if ([self.delegate respondsToSelector:@selector(JJScanningViewDidOutputMetadataObjects:)]) {
        [self.delegate JJScanningViewDidOutputMetadataObjects:metadataObjects];
    }
}
// 该方法必须写,要不调用声音方法会报错
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
}
#pragma mark - - - AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    // 这个方法会时时调用，但内存很稳定
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if (brightnessValue < -2) {// 根据数值来判断是否开启闪光灯
        // 添加闪光灯按钮
        flashBtn.hidden = NO;
    }else {
        if (is_open == NO) {
            flashBtn.hidden = YES;
        }
    }
}
@end
