//
//  ViewController.m
//  ScanQRCode
//
//  Created by Apple on 2017/5/12.
//  Copyright © 2017年 qxh. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)scanAction:(id)sender {
    
    ScanViewController *scan = [[ScanViewController alloc]init];
    
    [self.navigationController pushViewController:scan animated:YES];
    
    
}




@end
