//
//  ZJPhotoBrowserCell.m
//  
//
//  Created by Zj on 16/11/3.
//  Copyright © 2016年 Zj. All rights reserved.
//

#import "ZJPhotoBrowserCell.h"
#import "ZJGestureView.h"

@implementation ZJPhotoBrowserCell

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _gestureView = [[ZJGestureView alloc] init];
        _gestureView.frame = self.bounds;
        [self.contentView addSubview:_gestureView];
    }
    
    return self;
}


- (void)prepareForReuse{
    [super prepareForReuse];
    
    [_gestureView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

@end
