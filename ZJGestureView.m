//
//  ZJGestureView.m
//  
//
//  Created by Zj on 16/11/4.
//  Copyright © 2016年 Zj. All rights reserved.
//
#define ZJScreenWidth [UIScreen mainScreen].bounds.size.width
#define ZJScreenHeight [UIScreen mainScreen].bounds.size.height
#define ZJScreenScale ZJScreenWidth / ZJScreenHeight

#import "ZJGestureView.h"
#import "UIImageView+WebCache.h"
#import "ZJWaitingView.h"

@interface ZJGestureView() <UIScrollViewDelegate>
@property (nonatomic, strong) ZJWaitingView *watingView;
@end

@implementation ZJGestureView{
    CGFloat _absoluteScale;
    CGFloat _lastScale;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self createScrollView];
        
        [self createImageView];
    }
    return self;
}


- (ZJWaitingView *)watingView{
    if (!_watingView) {
        _watingView = [[ZJWaitingView alloc] init];
        _watingView.center = self.center;
        _watingView.bounds = CGRectMake(0, 0, 35, 35);
        self.watingView.mode = ZJWaitingViewModePie;
    }
    return _watingView;
}


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    
    CGSize imgSize = placeholder.size;                                      //获取缩略图图片size
    CGFloat imgScale = imgSize.width/imgSize.height;                        //计算图片宽高比, 用于判断是否是长图

    if (imgScale >= ZJScreenScale) {//不是长图
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _scrollView.contentSize = _imageView.frame.size;
    } else {//长图

        CGSize size = CGSizeMake(ZJScreenWidth, ZJScreenWidth * (1/imgScale));

        _imageView.frame = CGRectMake(0, 0, size.width, size.height);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;          //必须设置, 否则会有时候图像显示不正确
        
        _scrollView.contentSize = size;
    }
    
    if (url) {
        [_imageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            [self addSubview:self.watingView];
            
            if (expectedSize) {
                double process = receivedSize * 1.0/ expectedSize;
                self.watingView.progress = process;
            } else {
                self.watingView.progress = 1.0;
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (error) {
                [self showError];
            } else {
                //根据下载下来的图片计算出来最大缩放大小
                if (imgScale >= ZJScreenScale) {//不是长图
                    _scrollView.maximumZoomScale = MAX(image.size.width / ZJScreenWidth, 1.2);
                } else {//长图
                    _scrollView.maximumZoomScale = MAX(image.size.height / ZJScreenHeight, 1.2);
                }
            }
        }];
    } else { //若没传入url 则根据占位图显示图片
        _imageView.image = placeholder;
        if (imgScale >= ZJScreenScale) {//不是长图
            _scrollView.maximumZoomScale = MAX(placeholder.size.width / ZJScreenWidth, 1.2);
        } else {//长图
            _scrollView.maximumZoomScale = MAX(placeholder.size.height / ZJScreenHeight, 1.2);
        }
    }
}


//显示图片加载失败
- (void)showError{
    
    [self.watingView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.bounds = CGRectMake(0, 0, 160, 30);
    label.center = self.center;
    label.text = @"图片加载失败";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0;
    
    [self addSubview:label];
    
    [UIView animateWithDuration:0.8 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.8 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}


- (void)createScrollView{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;

    [self addSubview:_scrollView];
}


- (void)createImageView{
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_scrollView addSubview:_imageView];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

@end
