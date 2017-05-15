//
//  ZJPhotoBrowser.m
//  
//
//  Created by Zj on 16/10/28.
//  Copyright © 2016年 Zj. All rights reserved.
//

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenKeyWindow [UIApplication sharedApplication].keyWindow
#define photoPadding 10
#define durationTime 0.35
#define screenScale screenWidth / screenHeight

#import "ZJPhotoBrowser.h"
#import "ZJPhotoBrowserCell.h"
#import "ZJGestureView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ZJExtension.h"

@interface ZJPhotoBrowser () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UILabel *conuterLabel;
@property (nonatomic, strong) UIPageControl *conuterPageControl;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imgViews;

@end

@implementation ZJPhotoBrowser{
    NSArray *_zoomOutRectArray;
    NSArray *_urls;
    UIViewController *_presentedByVC;
    NSInteger _currentIndex;
    NSInteger _visibleImgViewCount;
    BOOL _isGestureViewChanged;
    UITapGestureRecognizer *_singleTap;
    UITapGestureRecognizer *_doubleTap;
}

//单例类的静态实例对象，因对象需要唯一性，故只能是static类型
static ZJPhotoBrowser *sharedBrowser = nil;

- (void)showPhotoBrowserWithUrls:(NSArray *)urls imgViews:(NSArray *)imgViews clickedIndex:(NSInteger)index presentedBy:(UIViewController *)presentedByVC;{
    _currentIndex = index;
    _urls = urls;
    _presentedByVC = presentedByVC;
    self.imgViews = imgViews;
    
    if (!_urls.count) { //若没传入图片, 则计算imgViews中没有隐藏的图片个数
        _visibleImgViewCount = 0;
        for (UIImageView *imgView in imgViews) {
            if (![imgView isHidden]) {
                _visibleImgViewCount++;
            }
        }
    }
    
    [self.collectionView reloadData];

    [self show];
    //显示放大动画
    [self performZoomInAnimation];
}


- (void)reloadDataWithUrls:(NSArray *)urlsArray{
    _urls = urlsArray;
    
    [self.collectionView reloadData];
    [self setCounterWithTag:_currentIndex totalCount:MAX(_urls.count, _visibleImgViewCount)];
}


- (BOOL)isPhotoBrowserVisible{
    return (sharedBrowser.isViewLoaded && sharedBrowser.view.window);
}


- (UIImage *)currentImage{
    ZJPhotoBrowserCell *cell = [_collectionView.visibleCells firstObject];
    return cell.gestureView.imageView.image;
}


#pragma mark ---parivate---
- (instancetype)init{
    if (self = [super init]) {
        self.photoBrowserCounterStyle = photoBrowserCounterStyleLabel;
        self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.view.backgroundColor = [UIColor blackColor];
        _isGestureViewChanged = NO;
        
        [self prepared];
    }
    return self;
}


- (void)prepared{
    [self createColloctionView];
    
    //监听单击屏幕
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapScreen)];
    [self.view addGestureRecognizer:_singleTap];
    
    //监听双击屏幕(会使单击反应变慢)
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapScreen:)];
    _doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:_doubleTap];
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
    
    //监听长按屏幕
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressScreen:)];
    longPress.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:longPress];
}


//在设置原有ImgViews图片时计算出所有图片弹出时动画目标frame的数组
- (void)setImgViews:(NSArray *)imgViews{
    _imgViews = imgViews;
    
    NSMutableArray *tempArray = [NSMutableArray array];
    CGRect zoomOutRect;
    NSInteger i = 0;
    for (UIImageView *imgView in imgViews) {
        zoomOutRect = [imgView.superview convertRect:imgView.frame toView:screenKeyWindow];
        
        [tempArray addObject:[NSValue valueWithCGRect:zoomOutRect]];
        i++;
    }
    
    
    if (tempArray.count < _urls.count) {
        NSInteger maxJ = _urls.count - tempArray.count;
        for (NSInteger j = 0; j < maxJ; j++) {
            if (tempArray.count <= _currentIndex) {
                [tempArray insertObject:[NSValue valueWithCGRect:CGRectZero] atIndex:0];
            } else {
                [tempArray addObject:[NSValue valueWithCGRect:CGRectZero]];
            }
        }
    }
    
    _zoomOutRectArray = [tempArray copy];
}


- (void)createColloctionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.minimumLineSpacing = photoPadding;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = NO; //有间距不能自动分页, 需重写scrollview的代理方法
    _collectionView.bounces = NO;
    
    [_collectionView registerClass:[ZJPhotoBrowserCell class] forCellWithReuseIdentifier:@"reUsedCell"];
    
    [self.view addSubview:_collectionView];
}


- (UILabel *)conuterLabel{
    if (!_conuterLabel) {
        _conuterLabel = [[UILabel alloc] init];
        _conuterLabel.frame = CGRectMake(0, 0, screenWidth, 60);
        _conuterLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        _conuterLabel.textColor = [UIColor whiteColor];
        _conuterLabel.shadowOffset = CGSizeMake(0, 1);
        _conuterLabel.shadowColor = [UIColor grayColor];
        
        UIColor *shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        CAGradientLayer *shadow = [CAGradientLayer layer];  // 设置渐变阴影背景效果
        shadow.frame = _conuterLabel.bounds;
        shadow.colors = [NSArray arrayWithObjects:
                         (id)shadowColor.CGColor,
                         (id)[[UIColor clearColor] CGColor], nil];
        [_conuterLabel.layer insertSublayer:shadow atIndex:0];
        
        [self.view addSubview:_conuterLabel];
    }
    return _conuterLabel;
}


- (UIPageControl *)conuterPageControl{
    if (!_conuterPageControl) {
        _conuterPageControl = [[UIPageControl alloc] init];
        _conuterPageControl.userInteractionEnabled = NO;
        CGPoint center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 20);
        _conuterPageControl.center = center;
        
        [self.view addSubview:_conuterPageControl];
    }
    return _conuterPageControl;
}


- (void)setCounterWithTag:(NSInteger)tag totalCount:(NSInteger)count{
    switch (_photoBrowserCounterStyle) {
        case photoBrowserCounterStyleLabel:
            
            if (count == 1) {
                self.conuterLabel.text = nil;
            } else {
                //创建富文本, 调整字间距
                NSString *text = [NSString stringWithFormat:@"%li/%li", (long)tag + 1, (long)count];
                
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.alignment = NSTextAlignmentCenter;
                
                NSMutableDictionary *attribute = [NSMutableDictionary dictionary];
                attribute[NSParagraphStyleAttributeName] = paragraphStyle;
                attribute[NSKernAttributeName] = @2;
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attribute];
                
                self.conuterLabel.attributedText = attributedString;
            }
            break;
            
        case photoBrowserCounterStylePageControl:
            
            if (count == 1) {
                self.conuterPageControl.hidden = YES;
            } else {
                self.conuterPageControl.hidden = NO;
                self.conuterPageControl.numberOfPages = count;
                self.conuterPageControl.currentPage = tag;
            }
            break;
    }
}


- (void)singleTapScreen{
    _singleTap.enabled = NO;
    _doubleTap.enabled = NO;
    
    [self doubleTapScreen:nil];
    
    if (_isGestureViewChanged) { //代表没有放大也没有滚动
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            
            [self performZoomOutAnimation];
        });
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
        
        [self performZoomOutAnimation];
    }
}


- (void)doubleTapScreen:(UITapGestureRecognizer *)doubleTap{
    _singleTap.enabled = NO;
    _doubleTap.enabled = NO;
    
    CGPoint doubleTapPoint;
    
    if (doubleTap) { //若doubleTap传入值不为nil(不是singleTapScreen调用)时
        doubleTapPoint = [doubleTap locationInView:self.view];
    }
    
    ZJPhotoBrowserCell *cell = [self.collectionView.visibleCells firstObject];
    UIScrollView *scrollView = cell.gestureView.scrollView;
    
    if (scrollView.zoomScale == 1) { //判断现在是否处于缩放状态, 若不处于缩放状态则还原
        if (!doubleTap) return; //若处于未缩放状态, 但由singleTapScreen调用(传入nil) 则不缩放
        
        CGFloat zoomW = screenWidth / MIN(scrollView.maximumZoomScale, 2);
        CGFloat zoomH = screenHeight / MIN(scrollView.maximumZoomScale, 2);
        CGFloat zoomX = doubleTapPoint.x - zoomW / 2  + scrollView.contentOffset.x;
        CGFloat zoomY = doubleTapPoint.y - zoomH / 2  + scrollView.contentOffset.y;
        CGRect zoomRect = CGRectMake(zoomX, zoomY, zoomW, zoomH);
        
        _isGestureViewChanged = YES; //记录GestureView已经改变

        [cell.gestureView.scrollView zoomToRect:zoomRect animated:YES];
    } else {
        _isGestureViewChanged = scrollView.contentOffset.y != 0; //若还原后, 且scrollView未滚动, 则GestureView未改变
       
        [scrollView setZoomScale:1.0f animated:YES];
    }
    
    //防止用户连续点击
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _singleTap.enabled = YES;
        _doubleTap.enabled = YES;
    });
}


- (void)longPressScreen:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.longPressScreenBlock) {
            self.longPressScreenBlock();
        }
    }
}


- (void)show{
    self.view.hidden = YES; //先加载, 在放大动画的同时可以下载图片, 缩放完了再显示
    
    [_presentedByVC presentViewController:self animated:NO completion:^{
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];

    CGFloat offsetY = _currentIndex * (screenWidth + photoPadding);
    self.collectionView.contentOffset = CGPointMake(offsetY, 0);
    
    [self setCounterWithTag:_currentIndex totalCount:MAX(_urls.count, _visibleImgViewCount)];
}


#pragma mark ---animation---
- (void)performZoomInAnimation{
    
    //1.获取图片
    UIImageView *thumbnailPicView = _imgViews.count > _currentIndex ? _imgViews[_currentIndex] : [_imgViews lastObject];
    CGSize imgSize = thumbnailPicView.image.size;
    CGFloat imgScale = imgSize.width/imgSize.height;
    
    //2.复制图片
    UIImageView *imgViewCopy = [[UIImageView alloc] init];
    imgViewCopy.contentMode = thumbnailPicView.contentMode;
    imgViewCopy.clipsToBounds = YES;
    imgViewCopy.image = thumbnailPicView.image;
    
    imgViewCopy.frame = [thumbnailPicView.superview convertRect:thumbnailPicView.frame toView:screenKeyWindow];
    
    //3.按照图片本身的长宽比算出imgViewCopy的的bounds以及center
    CGPoint center;
    CGRect rect = imgViewCopy.bounds;
    rect.size.width = screenWidth;
    rect.size.height = rect.size.width * (1 / imgScale);
    if (imgScale >= screenScale) {//当图片的宽高比大于屏幕的宽高比时, 图片不是长图
        center = self.view.center;
    } else { //图片为长图时
        center = CGPointMake(screenWidth / 2, rect.size.height / 2);
    }
    //将bounds及center转换为frame
    CGRect zoomInRect = CGRectMake(center.x - rect.size.width / 2, center.y - rect.size.height / 2, rect.size.width, rect.size.height);
    
    //4.动画
    [self animateImageView:imgViewCopy toRect:zoomInRect];
    
}


- (void)performZoomOutAnimation{
    //0.恢复状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    //1.获取图片
    ZJPhotoBrowserCell *cell = [self.collectionView.visibleCells firstObject];
    UIImageView *imgView = cell.gestureView.imageView;
    CGSize imgSize = imgView.image.size;
    CGFloat imgScale = imgSize.width/imgSize.height; //获取图片的宽高比
    
    //2.复制图片
    UIImageView *imgViewCopy = [[UIImageView alloc] init];
    imgViewCopy.contentMode = UIViewContentModeScaleAspectFill;
    imgViewCopy.clipsToBounds = YES;
    imgViewCopy.image = imgView.image;

    //3.按照cell中图片的size设置图片的frame
    CGRect rect = imgViewCopy.bounds;
    rect.size.width = screenWidth;
    rect.size.height = rect.size.width * (1 / imgScale);
    //要根据scrollview滚动的距离算出真实中心点
    CGPoint scrollCenter = CGPointMake(imgView.center.x - cell.gestureView.scrollView.contentOffset.x, imgView.center.y - cell.gestureView.scrollView.contentOffset.y);
    imgViewCopy.center = scrollCenter;
    imgViewCopy.bounds = rect;

    //4.动画
    [self animateImageView:imgViewCopy toRect:[_zoomOutRectArray[_currentIndex] CGRectValue]];
    
    //5.重置scrollView
    [cell.gestureView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}


- (void)animateImageView:(UIImageView *)imgView toRect:(CGRect)destinRect{
    
    //1.设置蒙板
    UIView *cover = [[UIView alloc] initWithFrame:screenKeyWindow.bounds];
    cover.backgroundColor = [UIColor blackColor];
    [screenKeyWindow addSubview:cover];
    
    //2.添加图片
    [cover addSubview:imgView];
    
    //3.判断是放大还是缩小图片
    BOOL isZoomIn = destinRect.size.height > imgView.frame.size.height;
   
    UIImageView *thumbnailPicView = _imgViews.count > _currentIndex ? _imgViews[_currentIndex] : [_imgViews lastObject];
    
    //4.动画之前隐藏小图
    if (thumbnailPicView.tag != _currentIndex && !isZoomIn) {
        //5.动画
        [UIView animateWithDuration:durationTime animations:^{
            imgView.alpha = 0;
            //淡出
            cover.backgroundColor = [UIColor clearColor];
            
        } completion:^(BOOL finished) {
            _singleTap.enabled = YES;
            _doubleTap.enabled = YES;
            
            [cover removeFromSuperview];
        }];
    } else {
        thumbnailPicView.hidden = YES;
        //5.动画
        [UIView animateWithDuration:durationTime animations:^{
            imgView.frame = destinRect;
            //        //淡出
            if (!isZoomIn) {
                cover.backgroundColor = [UIColor clearColor];
            }
            
        } completion:^(BOOL finished) {
            _singleTap.enabled = YES;
            _doubleTap.enabled = YES;
            
            [cover removeFromSuperview];
            //恢复小图
            thumbnailPicView.hidden = NO;
            if (isZoomIn) { //图片放大完显示view
                self.view.hidden = NO;
            }
        }];
    }
}


#pragma mark ---UICollectionViewDelegate---
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MAX(_urls.count, _visibleImgViewCount);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  
    ZJPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reUsedCell" forIndexPath:indexPath];
 
    UIImageView *thumbnailPicView;
    if (indexPath.row < _imgViews.count) {
        thumbnailPicView = _imgViews[indexPath.row];                  //取出原缩略图
    } else {
        thumbnailPicView = [[UIImageView alloc] initWithImage:[UIImage createImageWithColor:[UIColor blackColor]]];
    }

    //设置图片, 并显示下载进度图
    if (_urls.count) {
        if ([_urls[indexPath.row] isEqualToString:@"noImg"]) {
            [cell.gestureView setImageWithURL:nil placeholderImage:thumbnailPicView.image];
        } else {
            NSURL *url = [_urls[indexPath.row] isKindOfClass:[NSString class]] ? [NSURL URLWithString:_urls[indexPath.row]] : _urls[indexPath.row];
            [cell.gestureView setImageWithURL:url placeholderImage:thumbnailPicView.image];
        }
    } else {
        [cell.gestureView setImageWithURL:nil placeholderImage:thumbnailPicView.image];
    }

    return cell;
}


#pragma mark ---UIScrollViewDelegate---
//因为item之间有间距, 需重写scrollView代理方法, 手动分页, 并计算出代码
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    float pageWidth = self.collectionView.frame.size.width + photoPadding; // width + space
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset)
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
    else
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;

    if (newTargetOffset < 0)
        newTargetOffset = 0;
    else if (newTargetOffset > scrollView.contentSize.width)
        newTargetOffset = scrollView.contentSize.width;
    
    targetContentOffset->x = currentOffset;
    
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
    
    //设置当前页码
    _currentIndex = newTargetOffset / pageWidth;
    [self setCounterWithTag:_currentIndex totalCount:MAX(_urls.count, _visibleImgViewCount)];
}


#pragma mark ---单例对象的实现---
/**
 单例模式对外的唯一接口，用到的dispatch_once函数在一个应用程序内只会执行一次，且dispatch_once能确保线程安全
 */
+ (ZJPhotoBrowser *)sharedBrowser{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedBrowser == nil) {
            sharedBrowser = [[self alloc] init];
        }
    });
    return sharedBrowser;
}


/**
 覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedBrowser == nil) {
            sharedBrowser = [super allocWithZone:zone];
        }
    });
    return sharedBrowser;
}


//覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
- (id)copy{
    return self;
}


//覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
- (id)mutableCopy{
    return self;
}

@end
