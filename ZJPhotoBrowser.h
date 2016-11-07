//
//  ZJPhotoBrowser.h
//  
//
//  Created by Zj on 16/10/28.
//  Copyright © 2016年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^longPressScreenBlock)();

typedef enum : NSUInteger {
    photoBrowserCounterStyleLabel = 0,
    photoBrowserCounterStylePageControl = 1,
} photoBrowserCounterStyle;

@interface ZJPhotoBrowser : UIViewController

/**
 长按屏幕回调
 */
@property (nonatomic, copy) longPressScreenBlock longPressScreenBlock;

/**
 页数指示器样式
 */
@property (nonatomic, assign) photoBrowserCounterStyle photoBrowserCounterStyle;

/**
 取出正在显示的image
 */
@property (nonatomic, strong) UIImage *currentImage;

/**
 获取单例对象
 */
+ (ZJPhotoBrowser *)sharedBrowser;

/**
 显示相册

 @param urls     需要加载图片类型为NSURL的数组, 浏览器页数优先根据urls.count来确定; 若传入空, 加载imgViews的图片, 浏览器页数根据imgViews中hidden属性为NO的数量确定
 @param imgViews 被点击的imgView的数组
 @param index    数组中被点击图片的tag
 */
- (void)showPhotoBrowserWithUrls:(NSArray *)urls imgViews:(NSArray *)imgViews clickedIndex:(NSInteger)index presentedBy:(UIViewController *)presentedByVC;

/**
 判断图片浏览器是否在屏幕中
 */
- (BOOL)isPhotoBrowserVisible;

@end
