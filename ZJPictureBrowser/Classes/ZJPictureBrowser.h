//
//  ZJPictureBrowser.h
//  
//
//  Created by Zj on 16/10/28.
//  Copyright © 2016年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^longPressScreenBlock)();

typedef enum : NSUInteger {
    pictureBrowserCounterStyleLabel = 0,
    pictureBrowserCounterStylePageControl = 1,
} pictureBrowserCounterStyle;

@interface ZJPictureBrowser : UIViewController

/**
 长按屏幕回调
 */
@property (nonatomic, copy) longPressScreenBlock longPressBlock;

/**
 页数指示器样式
 */
@property (nonatomic, assign) pictureBrowserCounterStyle counterStyle;

/**
 取出正在显示的image
 */
@property (nonatomic, strong) UIImage *currentImage;

/**
 快速创建对象
 */
+ (instancetype)browser;

/**
 传入urls的数组重新加载数据
 */
- (void)reloadDataWithUrls:(NSArray *)urlsArray;

/**
 显示相册

 @param urls     需要加载图片类型为NSURL的数组, 浏览器页数优先根据urls.count来确定; 若传入空, 加载imgViews的图片, 浏览器页数根据imgViews中hidden属性为NO的数量确定
 @param imgViews 被点击的imgView的数组
 @param index    数组中被点击图片的tag
 */
- (void)showPictureBrowserWithUrls:(NSArray *)urls imgViews:(NSArray *)imgViews clickedIndex:(NSInteger)index presentedBy:(UIViewController *)presentedByVC;

/**
 判断图片浏览器是否在屏幕中
 */
- (BOOL)isPictureBrowserVisible;

@end
