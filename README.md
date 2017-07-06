# 效果

仿新浪微博共享元素效果, 就不上效果图了

# 类说明:

##     1.ZJPhotoBrowser 图片浏览器控制器(全屏日历)
### attribute: 

```
longPressScreenBlock(长按照片回调)
photoBrowserCounterStyle(图片页数指示器样式:数字、圆点)
currentImage(正在显示的图片)
```

### method: 

```
/**
 快速创建对象
 */
+ (ZJPhotoBrowser *)sharedBrowser;
  
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
- (void)showPhotoBrowserWithUrls:(NSArray *)urls imgViews:(NSArray *)imgViews clickedIndex:(NSInteger)index presentedBy:(UIViewController *)presentedByVC;

/**
 判断图片浏览器是否在屏幕中
 */
- (BOOL)isPhotoBrowserVisible;
```

##     2.ZJPhotoBrowserCell 图片容器cell  
##     3.ZJGestureView 图片缩放容器
##     4.ZJWaitingView 图片加载进度视图(饼状、环状)
