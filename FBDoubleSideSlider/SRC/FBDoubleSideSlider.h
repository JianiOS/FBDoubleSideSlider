//
//  FBDoubleSideSlider.h
//  FBDoubleSideSlider
//
//  Created by 尹健 on 16/6/16.
//  Copyright © 2016年 FenbeiTech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SliderSelectBlock)(NSInteger min,NSInteger max);

@interface FBDoubleSideSlider : UIView

- (nonnull instancetype)initWithFrame:(CGRect)frame SectionTitles:(nonnull NSArray<NSString *> *)sectionTitles;

@property (nullable,strong,nonatomic) UIColor *selectTextColor;

@property (nullable,strong,nonatomic) UIColor *nonSelectTextColor;

@property (nullable,strong,nonatomic) UIColor *nonSelectColor;

@property (nullable,strong,nonatomic) UIColor *selectColor;

@property (assign,nonatomic) NSInteger leftItemIndex;

@property (assign,nonatomic) NSInteger rightItemIndex;

- (void)setValueChangeBlock:(SliderSelectBlock)block;

@end
