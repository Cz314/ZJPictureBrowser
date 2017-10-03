//
//  ZJWaitingView.h
// 
//
//  Created by Zj on 16/11/4.
//  Copyright © 2016年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ZJWaitingViewModeLoop, // 环形
    ZJWaitingViewModePie // 饼型
} ZJWaitingViewMode;

@interface ZJWaitingView : UIView

/**
 传入process属性, 自动显示进度条
 */
@property (nonatomic, assign) CGFloat progress;

/**
 传入进度条样式, 默认为环形
 */
@property (nonatomic, assign) ZJWaitingViewMode mode;

@end
