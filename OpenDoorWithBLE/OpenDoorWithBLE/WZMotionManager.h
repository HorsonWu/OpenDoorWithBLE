//
//  WZMotionManager.h
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//

/*说明：
 *      手势晃动唤醒蓝牙开门的单例
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "WZBLECentralManager.h"
@interface WZMotionManager : NSObject<UIAlertViewDelegate,UIAccelerometerDelegate>
@property (strong, nonatomic)CMMotionManager *motionManager;
@property (strong, nonatomic)WZBLECentralManager *BLECentralManager;
//初始化单例
+(WZMotionManager *)shareInstance;
//开始摇晃手机
-(void)startShake;
@end
