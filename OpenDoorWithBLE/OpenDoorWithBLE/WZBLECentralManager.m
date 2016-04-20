//
//  WZBLECentralManager.m
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//

#import "WZBLECentralManager.h"

//获取蓝牙设备读写的服务UUID
#define TRANSFER_SERVICE_UUID               [CBUUID UUIDWithString:@"D973F2E0-B19E-11E2-9E96-0800200C9A66"]
//获取蓝牙设备写的特征UUID
#define TRANSFER_CHARACTERISTIC_UUID_WRITE  [CBUUID UUIDWithString:@"D973F2E2-B19E-11E2-9E96-0800200C9A66"]
//获取蓝牙设备读的特征UUID
#define TRANSFER_CHARACTERISTIC_UUID_READ   [CBUUID UUIDWithString:@"D973F2E1-B19E-11E2-9E96-0800200C9A66"]

//获取蓝牙设备mac地址的服务UUID
#define TRANSFER_SERVICE_MAC                     [CBUUID UUIDWithString:@"180A"]
//获取蓝牙设备mac地址的特征UUID
#define TRANSFER_CHARACTERISTIC_MAC              [CBUUID UUIDWithString:@"2A23"]

@implementation WZBLECentralManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 设置CBCentralManager
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        // 保存接收数据
        _writeData = [[NSMutableData alloc] init];
        _readData = [[NSMutableData alloc] init];
        
    }
    return self;
}

-(void)scanPeripheralWithResultHandle:(AccessPeripheralHandler)ahandle{
    self.handle = ahandle;
    [self scanPeripheral];
}

/** 通过制定的128位的UUID，扫描外设
 */
- (void)scanPeripheral
{
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}
/** 停止扫描
 */
- (void)stop
{
    [self.centralManager stopScan];
    NSLog(@"Scanning stoped");
}


#pragma mark - CBCentralManagerDelegate
#pragma -- 蓝牙状态的更新
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        self.handle(NO,@"找不到蓝牙");
        return;
    }
    //开始扫描
    [self scanPeripheral];
    
}
#pragma -- 发现外设蓝牙的回调方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // 过滤信号强度范围
    if (RSSI.integerValue > -15) {
        [self stop];
        self.centralManager = nil;
        
        self.handle(NO,@"找不到蓝牙设备");
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"收到信息" message:@"1.找不到蓝牙设备" preferredStyle:UIAlertControllerStyleAlert];
//        
//        [[UIApplication sharedApplication].keyWindow addSubview:alertVC.view];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"信息" message:@"1.找不到蓝牙设备" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        return;
    }
    if (RSSI.integerValue < -35) {
        [self stop];
        self.centralManager = nil;
        self.handle(NO,@"找不到蓝牙设备");
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"收到信息" message:@"2.找不到蓝牙设备" preferredStyle:UIAlertControllerStyleAlert];
//        
//        [[UIApplication sharedApplication].keyWindow addSubview:alertVC.view];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"信息" message:@"2.找不到蓝牙设备" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        return;
    }
    NSLog(@"发现外设 %@ at %@", peripheral.name, RSSI);
    
    if (self.discoveredPeripheral != peripheral) {
        self.discoveredPeripheral = peripheral;
        
        NSLog(@"连接外设 %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

#pragma -- 连接外设蓝牙失败的回调方法
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接失败 %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanUp];
    self.handle(NO,@"蓝牙连接失败");
}

#pragma -- 连接外设蓝牙成功的回调方法
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"外设已连接");
    [self stop];
    
    NSLog(@"扫描停止");
    
    [self.writeData setLength:0];
    [self.readData setLength:0];
    peripheral.delegate = self;
    //寻找特征服务
    [peripheral discoverServices:@[TRANSFER_SERVICE_UUID,TRANSFER_SERVICE_MAC]];
}
#pragma mark -- 断开外设连接的回调方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"外设已经断开");
    self.discoveredPeripheral = nil;
    self.handle(NO,@"蓝牙断开");
    //外设已经断开情况下，重新扫描
    [self scanPeripheral];
}

/** 服务被发现
 */
#pragma mark -- CBPeripheralDelegate
#pragma  -- 发现服务的回调方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanUp];
        self.handle(NO,@"找不到服务");
        return;
    }
    
    // 寻找特征
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:TRANSFER_SERVICE_UUID]) {
//            [peripheral discoverCharacteristics:@[TRANSFER_CHARACTERISTIC_UUID_READ] forService:service];
            [peripheral discoverCharacteristics:@[TRANSFER_CHARACTERISTIC_UUID_WRITE] forService:service];
        }
    }
    
//    for (CBService *service in peripheral.services) {
//        if ([service.UUID isEqual:TRANSFER_SERVICE_MAC]) {
//            [peripheral discoverCharacteristics:@[TRANSFER_CHARACTERISTIC_MAC] forService:service];
//        }
//    }
}

#pragma -- 发现特征的回调方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"发现特征错误: %@", [error localizedDescription]);
        [self cleanUp];
        self.handle(NO,@"找不到特征");
        return;
    }
   
    //向蓝牙设备发送数据
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:TRANSFER_CHARACTERISTIC_UUID_WRITE]) {
            [peripheral writeValue:_writeData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
    //读取蓝牙设备数据
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:TRANSFER_CHARACTERISTIC_UUID_READ]) {
//            //给预定的特征设置设置监听
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:TRANSFER_CHARACTERISTIC_MAC]) {
            NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
            NSMutableString *macString = [[NSMutableString alloc] init];
            [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
            [macString appendString:@":"];
            [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
            
            NSLog(@"mac地址为:%@",macString);
            
            self.handle(YES,@"获取mac地址成功");
        }
    }
}

#pragma -- 给外设的的特征发送指令后的回调方法
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    
    if (error) {
        NSLog(@"开门指令写入不成功，原因是:%@",[error localizedDescription]);
        [self cleanUp];
        self.handle(NO,@"写入不成功");
        return;
    }
    
    NSLog(@"蓝牙开门成功");
    self.handle(YES,@"写入成功");
    
}

#pragma -- 外设的的特征值发生变化，回调的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"发现特征错误:: %@", [error localizedDescription]);
        return;
    }
    
    
    NSLog(@"特征的UUID：%@",characteristic.UUID);
    self.handle(YES,@"读取成功");
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // 判断是否为数据结束(自己设置)
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        // 取消特征预定
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // 断开外设
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    // 接收数据追加到data属性中
    [self.readData appendData:characteristic.value];
    
    NSLog(@"Received: %@", stringFromData);
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"收到信息" message:stringFromData preferredStyle:UIAlertControllerStyleAlert];
    
    [[UIApplication sharedApplication].keyWindow addSubview:alertVC.view];
    
}
#pragma -- 外设的的特征状态发生变化，回调的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"特征通知状态变化错误: %@", error.localizedDescription);
    }
    
    // 如果没有特征传输过来则退出
    if (![characteristic.UUID isEqual:TRANSFER_CHARACTERISTIC_UUID_READ]) {
        return;
    }
    
    // 特征通知已经开始
    if (characteristic.isNotifying) {
        NSLog(@"特征通知已经开始 %@", characteristic);
    }
    // 特征通知已经停止
    else {
        NSLog(@"特征通知已经停止 %@", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}




/** 清除方法
 */
- (void)cleanUp
{
    // 如果没有连接则退出
    if (self.discoveredPeripheral.state == CBPeripheralStateDisconnected||
        self.discoveredPeripheral.state == CBPeripheralStateDisconnecting
        ) {
        return;
    }
    
    // 判断是否已经预定了特征
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:TRANSFER_CHARACTERISTIC_UUID_READ]) {
                        if (characteristic.isNotifying) {
                            //停止接收特征通知
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            //断开与外设连接
                            [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    //断开与外设连接
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
    
    [self stop];
    self.centralManager = nil;
    self.discoveredPeripheral = nil;
}



@end
