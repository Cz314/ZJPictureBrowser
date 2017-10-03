//
//  ZJGestureView.h
//
//
//  Created by Zj on 16/11/4.
//  Copyright © 2016年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJGestureView : UIView

/**
 imageView的容器
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 图片
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 给imageView设置图片

 @param url         图片下载链接, 当传入为空的时候, 占位图显示到浏览器
 @param placeholder 占位图
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
