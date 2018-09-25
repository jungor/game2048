//
//  UIColor+BrightUtil.m
//  game2048
//
//  Created by Techsviewer on 2018/9/23.
//  Copyright © 2018年 jungor. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor(Util)



+ (nonnull UIColor *)darkerColor:(nonnull UIColor *)c { 
    CGFloat h, s, b, a;
    if ([c getHue:&h saturation:&s brightness:&b alpha:&a]) {
        s = s * 0.75;
        return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
    } else {
        return c;
    }
}

+ (nonnull UIColor *)lighterColor:(nonnull UIColor *)c { 
    CGFloat h, s, b, a;
    if ([c getHue:&h saturation:&s brightness:&b alpha:&a]) {
        s = MIN(s * 1.3, 1.0);
        return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
    } else {
        return c;
    }
}

// 根据背景颜色画与黑色和白色的对比度来决定最佳前景色（黑/白）
// 以下公式来自W3C:
// 相对亮度L https://www.w3.org/TR/WCAG/#dfn-relative-luminance
// 对比度r https://www.w3.org/TR/WCAG/#dfn-contrast-ratio
+ (nonnull UIColor *)textColorWithBackgroundColor:(nonnull UIColor *)c {
    CGFloat r, g, b, a, L;
    CGFloat *cs[3] = {&r, &g, &b};
    // 计算相对亮度
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        for (int i = 0; i < 3; i++) {
//            *cs[i] /= 255.0;
            if (*cs[i] <= 0.03928) {
                *cs[i] = *cs[i] / 12.92;
            } else {
                *cs[i] = pow(((*cs[i]+0.055)/1.055), 2.4);
            }
        }
        L = 0.2126 * *cs[0] + 0.7152 * *cs[1] + 0.0722 * *cs[2];
        // 比较背景色跟黑色(相对亮度L为0)的对比度和跟白色(相对亮度L为1)的对比度
        // TODO: 化简表达式
        if ((L+0.05)/(0+0.05) > (1+0.05)/(L+0.05)) {
            return [UIColor blackColor];
        } else {
            return [UIColor whiteColor];
        }
    } else {
        return [UIColor whiteColor];
    }
}

@end
