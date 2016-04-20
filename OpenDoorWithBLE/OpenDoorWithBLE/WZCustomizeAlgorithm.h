//
//  WZCustomizeAlgorithm.h
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//
/*说明：
 *      对蓝牙的mac进行加密处理的算法
 */
#import <Foundation/Foundation.h>

@interface WZCustomizeAlgorithm : NSObject
//传进蓝牙的32位的UUID，返回加密后的UUID
-(NSString *)generateMac:(NSString *)string;
@end
