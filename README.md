# ZJPictureBrowser

[![CI Status](http://img.shields.io/travis/281925019@qq.com/ZJPictureBrowser.svg?style=flat)](https://travis-ci.org/281925019@qq.com/ZJPictureBrowser)
[![Version](https://img.shields.io/cocoapods/v/ZJPictureBrowser.svg?style=flat)](http://cocoapods.org/pods/ZJPictureBrowser)
[![License](https://img.shields.io/cocoapods/l/ZJPictureBrowser.svg?style=flat)](http://cocoapods.org/pods/ZJPictureBrowser)
[![Platform](https://img.shields.io/cocoapods/p/ZJPictureBrowser.svg?style=flat)](http://cocoapods.org/pods/ZJPictureBrowser)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ZJPictureBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZJPictureBrowser'
```

## Author

Jsoul1227@hotmail.com

## License

ZJPictureBrowser is available under the MIT license. See the LICENSE file for more info.

## More Info
# 效果

仿新浪微博共享元素效果, 就不上效果图了, 为什么这么多图片浏览器了还要重复造? 因为细节, 新浪微博有长图, 打开之后滚动关闭动画过度不流畅, 微博也有图片浏览器, 双击放大之后单击关闭过度也不流畅, 另外对于有网络图片与无网络图片, 都可以很好的支持过度.

# 类说明:

##     1.ZJPictureBrowser 图片浏览器控制器(全屏日历)
### attribute:

```
longPressScreenBlock(长按照片回调)
counterStyle(图片页数指示器样式:数字、圆点)
currentImage(正在显示的图片)
```

### method:

```
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
```

##     2.ZJPictureBrowserCell 图片容器cell
##     3.ZJGestureView 图片缩放容器
##     4.ZJWaitingView 图片加载进度视图(饼状、环状)



