//
//  DataSource.h
//  YJSScrollMenu
//
//  Created by Yan. on 2017/7/4.
//  Copyright © 2017年 Yan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJSScrollMenu/YJSScrollMenu.h"

@interface DataSource : NSObject<YJSDataProtocol>

/**
 显示文本
 */
@property (strong, nonatomic) NSString *itemTitle;

/**
 显示图片, 可以为NSURL， NSString， UIImage
 */
@property (strong, nonatomic) id itemImage;

/**
 占位图片
 */
@property (strong, nonatomic) UIImage *itemPlaceholder;


@end
