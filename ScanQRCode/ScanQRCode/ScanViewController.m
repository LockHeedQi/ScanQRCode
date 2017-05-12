//
//  ScanViewController.m
//  ScanQRCode
//
//  Created by Apple on 2017/5/12.
//  Copyright © 2017年 qxh. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureDevice.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    
    NSTimer *timer;//动画的计时器
    BOOL upOrdown;//是否到达边界
    int num;

}

@property (strong,nonatomic)AVCaptureDevice *device;
@property (strong,nonatomic)AVCaptureDeviceInput *input;
@property (strong,nonatomic)AVCaptureMetadataOutput *output;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, retain) UIImageView *imageViewLine;//二维码中间的动画条

@end

@implementation ScanViewController

@synthesize imageViewLine;


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUI];
    
    
    //配置二维码扫描
    [self setScan];
}

-(void)setUI
{
    
    
    //绘制背板
    CGRect rect = CGRectMake((SCREEN_WIDTH-240)/2,144,240,240);
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGRect cropRect = rect;
    CGPathAddRect(path1, nil, self.view.bounds);
    CGPathAddRect(path1, nil, cropRect);
    [shapeLayer setFillRule:kCAFillRuleEvenOdd];
    shapeLayer.path = path1;
    shapeLayer.fillColor = [[UIColor blackColor]CGColor];
    shapeLayer.opacity = 0.5;
    [self.view.layer addSublayer:shapeLayer];
    
    
    UIImageView *backgroundImage = [[UIImageView alloc]initWithFrame:rect];
    backgroundImage.image = [UIImage imageNamed:@"scanBackground"];
    [self.view addSubview:backgroundImage];
    

    
    
    //标题
    self.title = @"扫一扫";
    

    
    UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y+240, 240, 80)];
    messageLabel.font = [UIFont systemFontOfSize:15];
    messageLabel.numberOfLines = 0;
    messageLabel.text = @"将取景框对准二维码即可自动扫描";
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:messageLabel];
    
    
    //动画
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    
    imageViewLine = [[UIImageView alloc]initWithFrame:CGRectMake(rect.origin.x, 144, 240, 7)];
    imageViewLine.image = [UIImage imageNamed:@"scanLine"];
    [self.view addSubview:imageViewLine];
    
    
    
}

//配置二维码扫描
-(void)setScan
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    
    //判断授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        
    
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的设置-隐私-相机选项中，允许APP访问您的相机。" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
        
        self.view.backgroundColor = [UIColor whiteColor];
        return;
    }
    
    
    
    //条码类型
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    //扫描区域
    [_output setRectOfInterest:CGRectMake(144/SCREEN_HEIGHT,(SCREEN_WIDTH-240)/2/SCREEN_WIDTH,240/SCREEN_HEIGHT,240/SCREEN_WIDTH)];
    //扫描面
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    //开始扫描
    [_session startRunning];
}

//二维码中间动画
-(void)animation
{
    if (upOrdown == NO) {
        num ++;
        imageViewLine.frame = CGRectMake(imageViewLine.frame.origin.x, 110+2*num, 240, 2);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        imageViewLine.frame = CGRectMake(imageViewLine.frame.origin.x, 110+2*num, 240, 2);
        if (num == 20) {
            upOrdown = NO;
        }
    }
    
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{

    if (metadataObjects.count > 0) {
        
        
        //处理扫描到的二维码
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"二维码信息:%@",metadataObject.stringValue] preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    
    [_session stopRunning];

    [timer invalidate];
         
    
}


@end
