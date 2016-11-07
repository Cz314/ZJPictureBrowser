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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {      
        _gestureView = [[ZJGestureView alloc] init];
        _gestureView.frame = self.bounds;
        [self.contentView addSubview:_gestureView];
    }
    
    return self;
}


@end
