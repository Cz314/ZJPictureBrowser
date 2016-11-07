//
//  ZJPhotoBrowserCell.h
//  
//
//  Created by Zj on 16/11/3.
//  Copyright © 2016年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJGestureView;

@interface ZJPhotoBrowserCell : UICollectionViewCell

/**
 内容view
 */
@property (nonatomic, strong) ZJGestureView *gestureView;

@end
