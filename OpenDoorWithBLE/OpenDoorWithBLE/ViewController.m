//
//  ViewController.m
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//

#import "ViewController.h"
#import "WZMotionManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[WZMotionManager shareInstance] startShake];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
