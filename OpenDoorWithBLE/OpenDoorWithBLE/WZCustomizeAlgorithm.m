//
//  WZCustomizeAlgorithm.m
//  OpenDoorWithBLE
//
//  Created by HorsonWu on 16/4/19.
//  Copyright © 2016年 elovega. All rights reserved.
//

#import "WZCustomizeAlgorithm.h"

@implementation WZCustomizeAlgorithm
-(NSString *)generateMac:(NSString *)string{
    NSArray *array = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j",
                       @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t",
                       @"u", @"v", @"w", @"x", @"y", @"z", @"0", @"1", @"2", @"3",
                       @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D",
                       @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                       @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X",
                       @"Y", @"Z"];
    
    NSString * str=@"";
    
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    for(int i = 0; i < 6; i++){
        
        NSString *str1 = [string substringWithRange:NSMakeRange(i*4, 4)];
        
        NSLog(@"第%d次获取到的str1：%@",i,str1);
        //将获取到字符串转化为16进制格式（）
        int x = [self hexIntFromString:str1 withGarrisonType:16];
        NSLog(@"x:%d",x);
        if (i > 0) {
            str = [NSString stringWithFormat:@"%@%@",str,@":"];
        }
        NSLog(@"处理后的：%@",array[x % 0x3e]);
        
        str = [NSString stringWithFormat:@"%@%@",str,[self toHexString:array[x % 0x3e]]];
        
    }
    NSLog(@"返回的字符串：%@",str);
    return str.uppercaseString;
}


//把普通的字符串转化为固定的进制的ascii码值
- (int)hexIntFromString:(NSString *)string withGarrisonType:(int)type{
    int result = 0 ;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < string.length; i++) {
        NSString *str1 = [NSString stringWithFormat:@"%C",[string characterAtIndex:i]];
        
        if ([str1 isEqualToString:@"a"]) {
            str1 = @"10";
        }
        if ([str1 isEqualToString:@"b"]) {
            str1 = @"11";
        }
        if ([str1 isEqualToString:@"c"]) {
            str1 = @"12";
        }
        if ([str1 isEqualToString:@"d"]) {
            str1 = @"13";
        }
        if ([str1 isEqualToString:@"e"]) {
            str1 = @"14";
        }
        if ([str1 isEqualToString:@"f"]) {
            str1 = @"15";
        }
        [array addObject:str1];
    }
    
    for(int i= 0;i<array.count;i++){
        result = result + [array[i]intValue]*(pow(16.0,(int)(array.count-1-i)));
    }
    
    return result;
}


-(NSString *)toHexString:(NSString *)string{
    NSString *str = @"";
    
    for (int i = 0; i< string.length; i++) {
        
        int ch = [string characterAtIndex:i];
        
        NSString *str1 = [self transAsciiToHex:ch];
        
        str = [NSString stringWithFormat:@"%@%@",str,str1];
    }
    
    return str;
}

- (NSString *)transAsciiToHex:(int) asciiCode{
    NSString *string=@"";
    
    int n = asciiCode / 16;
    int e = asciiCode % 16;
    
    if (n > 16) {
        [self transAsciiToHex : n];
    }else{
        if (n >= 10) {
            string = [self transToEn:n withString:string];
        }else if(n > 0){
            string = [string stringByAppendingFormat:@"%d",n];
        }
    }
    
    if (e >= 10) {
        string = [self transToEn:e withString:string];
    }else{
        string = [string stringByAppendingFormat:@"%d",e];
    }
    return string;
}

- (NSString *)transToEn:(int) e withString:(NSString *)string{
    
    switch (e) {
        case 10:
            string = [string stringByAppendingString:@"A"];
            break;
            
        case 11:
            string = [string stringByAppendingString:@"B"];
            break;
            
        case 12:
            string = [string stringByAppendingString:@"C"];
            break;
            
        case 13:
            string = [string stringByAppendingString:@"D"];
            break;
            
        case 14:
            string = [string stringByAppendingString:@"E"];
            break;
            
        case 15:
            string = [string stringByAppendingString:@"F"];
            break;
            
        default:
            break;
    }
    return string;
}

@end
