//
//  WZMotionManager.m
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//

#import "WZMotionManager.h"

@implementation WZMotionManager
+(WZMotionManager *)shareInstance{
    static WZMotionManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WZMotionManager alloc]init];
        _sharedInstance.motionManager = [CMMotionManager new];
        _sharedInstance.motionManager.accelerometerUpdateInterval = 0.1;
        
    });
    return _sharedInstance;
}

-(void)startShake{
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init]
                                                 withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                                     if (error) {
                                                         [self.motionManager stopAccelerometerUpdates];
                                                     }
                                                     else
                                                     {
                                                         //综合3个方向的加速度
                                                         double accelerameter =sqrt( pow(accelerometerData.acceleration.x , 2 ) + pow(accelerometerData.acceleration.y , 2 ) + pow(accelerometerData.acceleration.z , 2) );
                                                         //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
                                                         if (accelerameter>2.3f) {
                                                             //立即停止更新加速仪（很重要！）
                                                             [self.motionManager stopAccelerometerUpdates];
                                                              NSLog(@"开始寻找蓝牙设备");
                                                             self.BLECentralManager = [[WZBLECentralManager alloc]init];
                                                             [self.BLECentralManager scanPeripheralWithResultHandle:^(BOOL isSuccess, NSString *errorString) {
                                                                 if (isSuccess) {
                                                                     
                                                                     [self.motionManager startAccelerometerUpdates];
                                                                 }else{
                                                                     
                                                                     
                                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"信息" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                                                     [alert show];

                                                                     [self.motionManager startAccelerometerUpdates];
                                                                 }
                                                             }];
                                                         }
                                                     }
                                                 }];
    }
    
}
-(void)dealloc{
    [self.BLECentralManager cleanUp];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
    self.BLECentralManager = nil;
    self.motionManager = nil;
}
@end
