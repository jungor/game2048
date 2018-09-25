//
//  UIColor+BrightUtil.h
//  game2048
//
//  Created by Techsviewer on 2018/9/23.
//  Copyright © 2018年 jungor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor(Util)

// 加亮颜色
+ (UIColor*) lighterColor:(UIColor*)c;

// 加暗颜色
+ (UIColor*) darkerColor:(UIColor*)c;

// 根据背景颜色选用最佳文本颜色（黑/白）
// 规则：W3C的可访问性规范中的相对亮度
+ (UIColor*) textColorWithBackgroundColor:(UIColor*)c;

@end

NS_ASSUME_NONNULL_END
