//
//  SYLinkLabel.h
//  image
//
//  Created by mac on 2021/7/4.
//  Copyright © 2021 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYLinkLabel : UILabel
/// 若有值,则返回点击的图片的下标
@property (nonatomic, copy) void(^touchImageAtIndex) (NSUInteger idx);

@end

NS_ASSUME_NONNULL_END
