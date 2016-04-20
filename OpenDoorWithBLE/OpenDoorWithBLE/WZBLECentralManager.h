//
//  WZBLECentralManager.h
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//

/*说明：
 *      手势晃动唤醒蓝牙开门的单例
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
/*   思路
 *  1.设置蓝牙中心CBCentralManager
 *  2.扫描蓝牙外设
 *  3.发现外设，连接外设
 *  4.连接外设成功，寻找相应的特征（通过UUID寻找）
 *  5.发现特征
 *  6.对相应的特征读取数据，或者写入数据
 */
//定义一个回调函数block
typedef void (^AccessPeripheralHandler)(BOOL isSuccess,NSString * errorString);

@interface WZBLECentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *writeData;
@property (strong, nonatomic) NSMutableData         *readData;

@property (copy, nonatomic) AccessPeripheralHandler handle;
//扫描蓝牙,并且返回是否成功
-(void)scanPeripheralWithResultHandle:(AccessPeripheralHandler)ahandle;
//退出蓝牙连接，并停止扫描
-(void)cleanUp;

@end
