//
//  FBDoubleSideSlider.m
//  FBDoubleSideSlider
//
//  Created by 尹健 on 16/6/16.
//  Copyright © 2016年 FenbeiTech. All rights reserved.
//

#import "FBDoubleSideSlider.h"


#define FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH 26.0f
#define FBDOUBLESIDESLIDER_SLIDER_LAYER_HEIGHT 3.0f
#define FBDOUBLESIDESLIDER_DEFALUT_FONT_SIZE 12

#define FBDOUBLESIDESLIDER_BACKGROUNDVIEW_BLANK (FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH / 2)

static CGPoint _imageViewCenterPoint;

@interface FBDoubleSideSlider()
<UIGestureRecognizerDelegate>
{
    NSArray<NSString *> *_titles;
    
    NSInteger _leftIndex;
    NSInteger _rightIndex;
    
    CGFloat _leftImageBeginX;
    CGFloat _rightImageBeginX;
    
    CGFloat _textLayerWidth;
}
@property (strong,nonatomic) UIView* backgroundView;

@property (strong,nonatomic) UIView *nonSelectView;

@property (strong,nonatomic) UIView *selectView;

@property (strong,nonatomic) UIButton *leftSlider;

@property (strong,nonatomic) UIButton *rightSlider;

@property (strong,nonatomic) NSMutableArray<CATextLayer*> *textLayers;

@property (copy,nonatomic) SliderSelectBlock block;

@end

@implementation FBDoubleSideSlider

@synthesize selectTextColor = _selectTextColor;
@synthesize nonSelectTextColor = _nonSelectTextColor;
@synthesize selectColor = _selectColor;
@synthesize nonSelectColor = _nonSelectColor;
@synthesize leftItemIndex = _leftItemIndex;
@synthesize rightItemIndex = _rightItemIndex;

#pragma mark 
#pragma mark Init
- (nonnull instancetype)initWithFrame:(CGRect)frame SectionTitles:(nonnull NSArray<NSString *> *)sectionTitles;
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        NSAssert(!(sectionTitles == nil || sectionTitles.count < 2), @"不符合title数量最小值");
        
        _titles = [sectionTitles mutableCopy];
        
        [self prepareData];
        
        [self prepareView];
        
        [self adjustAccordingSelfBounds];
    }
    
    return self;
}

- (void)prepareData
{
    _leftIndex = 0;
    _rightIndex = _titles.count - 1;
    
    _imageViewCenterPoint = CGPointMake(FBDOUBLESIDESLIDER_BACKGROUNDVIEW_BLANK, FBDOUBLESIDESLIDER_BACKGROUNDVIEW_BLANK);
}

- (void)createTextLayers
{
    NSInteger titleCount = _titles.count;
    
    NSMutableArray* layers = [[NSMutableArray alloc] initWithCapacity:titleCount];
    self.textLayers = layers;
    
    for (NSInteger index = 0; index < titleCount; index ++) {
        CATextLayer* textLayer = [self textLayer];
        textLayer.string = (NSString*)_titles[index];
        [self.backgroundView.layer addSublayer:textLayer];
        [layers addObject:textLayer];
    }
}

- (void)prepareView
{    
    [self addSubview:self.backgroundView];
    
    [self.backgroundView addSubview:self.nonSelectView];
    
    [self.backgroundView addSubview:self.selectView];
    
    [self.backgroundView addSubview:self.leftSlider];
    
    [self.backgroundView addSubview:self.rightSlider];
    
    [self createTextLayers];
}

#pragma mark
#pragma mark Public Method
- (void)setValueChangeBlock:(SliderSelectBlock)block
{
    self.block = block;
}

#pragma mark 
#pragma mark Private Method
- (CATextLayer*)textLayer
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CATextLayer* textLayer = [CATextLayer layer];
    textLayer.anchorPoint = CGPointZero;
    textLayer.contentsScale = scale;
    textLayer.fontSize = FBDOUBLESIDESLIDER_DEFALUT_FONT_SIZE;
    textLayer.alignmentMode = @"center";
    textLayer.masksToBounds = NO;
    return textLayer;
}

- (void)adjustAccordingSelfBounds
{
    if (!_titles || _titles.count == 0) {
        return;
    }
    
    [self adjustBackgroundView];
    
    [self adjustNonSelectViewFrame];
    
    [self adjustTextPostionAndBounds];
    
    [self adjustSliderPostion];
    
    [self adjustselectViewPositionAndBounds];
    
    [self adjustselectViewStartAndEnd];
    
    [self refreshFontColor];
}

- (void)adjustBackgroundView
{
    CGRect bounds = self.bounds;
    
    self.backgroundView.frame = CGRectMake(0, 0, bounds.size.width - FBDOUBLESIDESLIDER_BACKGROUNDVIEW_BLANK * 2, 55);
    self.backgroundView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

- (void)adjustTextPostionAndBounds
{
    CGFloat textLayerWidth = self.backgroundView.bounds.size.width / (_titles.count - 1);
    _textLayerWidth = textLayerWidth;
    
    CGFloat textLayerHalfWidth = textLayerWidth / 2;
    
    CGFloat y = self.leftSlider.bounds.origin.y + self.leftSlider.bounds.size.height + 2;
    
    CGFloat height = FBDOUBLESIDESLIDER_DEFALUT_FONT_SIZE + 4;
    
//    CATextLayer* leftTextLayer = [self.textLayers firstObject];
//    leftTextLayer.bounds = CGRectMake(0, 0, textLayerHalfWidth, height);
//    leftTextLayer.position = CGPointMake(0, y);
//    
//    CATextLayer* rightTextLayer = [self.textLayers lastObject];
//    rightTextLayer.bounds = CGRectMake(0, 0, textLayerHalfWidth, height);
//    rightTextLayer.position = CGPointMake(self.backgroundView.bounds.size.width - textLayerHalfWidth, y);
    
    CGFloat restTextLayerStartX = -textLayerHalfWidth;
    CGRect restTextLayerBounds = CGRectMake(0, 0, textLayerWidth, height);
    CATextLayer* tempLayer = nil;
    
    for (NSInteger index = 0; index < _titles.count; index ++) {
        tempLayer = self.textLayers[index];
        tempLayer.bounds = restTextLayerBounds;
        tempLayer.position = CGPointMake(index * textLayerWidth + restTextLayerStartX, y);
    }
}

- (void)adjustNonSelectViewFrame
{
    self.nonSelectView.frame = CGRectMake(0, (FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH - FBDOUBLESIDESLIDER_SLIDER_LAYER_HEIGHT ) / 2, self.backgroundView.bounds.size.width, FBDOUBLESIDESLIDER_SLIDER_LAYER_HEIGHT);
}

- (void)adjustSliderPostion
{
    CALayer* leftEdgeLayer = self.textLayers[_leftIndex];
    
    CGFloat leftX;
//    if (_leftIndex == 0) {
//        leftX = - FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH / 2;
//    }
//    else
//    {
        leftX = leftEdgeLayer.position.x + leftEdgeLayer.bounds.size.width / 2 - FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH / 2;
//    }
    
    self.leftSlider.frame = CGRectMake(leftX, 0, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH);
    
    CALayer* rightEdgeLayer = self.textLayers[_rightIndex];
    
    CGFloat rightX;
//    if (_rightIndex == _titles.count - 1) {
//        rightX = self.backgroundView.bounds.size.width  - FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH / 2;
//    }
//    else
//    {
        rightX = rightEdgeLayer.position.x + rightEdgeLayer.bounds.size.width / 2 - FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH / 2;
//    }
    
    self.rightSlider.frame = CGRectMake(rightX, 0, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH);
}

- (void)adjustselectViewPositionAndBounds
{
    self.selectView.frame = self.nonSelectView.frame;
}

- (void)adjustselectViewStartAndEnd
{
    CGFloat left = self.leftSlider.center.x;
    CGFloat right = self.rightSlider.center.x;
    CGRect frame = self.selectView.frame;
    frame.origin = CGPointMake(left, frame.origin.y);
    frame.size = CGSizeMake(right - left, frame.size.height);
    self.selectView.frame = frame;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self adjustAccordingSelfBounds];
}

#pragma mark 
#pragma mark Lazy Load
- (UIColor*)nonSelectColor
{
    if (!_nonSelectColor) {
        _nonSelectColor = [UIColor redColor];
    }
    
    return _nonSelectColor;
}

- (UIColor*)selectColor
{
    if (!_selectColor) {
        _selectColor = [UIColor blueColor];
    }
    
    return _selectColor;
}

- (UIView*)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    
    return _backgroundView;
}

- (UIView*)nonSelectView
{
    if (!_nonSelectView) {
        _nonSelectView = [[UIView alloc] init];
        _nonSelectView.backgroundColor = self.nonSelectColor;
    }
    
    return _nonSelectView;
}

- (UIView*)selectView
{
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = self.selectColor;
    }
    
    return _selectView;
}

- (UIButton*)leftSlider
{
    if (!_leftSlider) {
        _leftSlider = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH)];
        _leftSlider.userInteractionEnabled = YES;
        _leftSlider.backgroundColor = [UIColor clearColor];
        [_leftSlider setImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateNormal];
        [_leftSlider setImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateHighlighted];
        [_leftSlider addTarget:self action:@selector(sliderDraged:WithEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_leftSlider addTarget:self action:@selector(sliderDragEnd:) forControlEvents:UIControlEventTouchDragExit];
        [_leftSlider addTarget:self action:@selector(sliderTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_leftSlider addTarget:self action:@selector(sliderDragTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    
    return _leftSlider;
}

- (UIButton*)rightSlider
{
    if (!_rightSlider) {
        _rightSlider = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH, FBDOUBLESIDESLIDER_SELECT_IMAGE_HEIGHT_AND_WIDTH)];
        _rightSlider.userInteractionEnabled = YES;
        _rightSlider.backgroundColor = [UIColor clearColor];
        [_rightSlider setImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateNormal];
        [_rightSlider setImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateHighlighted];
        [_rightSlider addTarget:self action:@selector(sliderDraged:WithEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_rightSlider addTarget:self action:@selector(sliderDragEnd:) forControlEvents:UIControlEventTouchDragExit];
        [_rightSlider addTarget:self action:@selector(sliderTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_rightSlider addTarget:self action:@selector(sliderDragTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    
    return _rightSlider;
}

- (UIColor*)nonSelectTextColor
{
    if (!_nonSelectTextColor) {
        _nonSelectTextColor = self.nonSelectColor;
    }
    
    return _nonSelectTextColor;
}

- (UIColor*)selectTextColor
{
    if (!_selectTextColor) {
        _selectTextColor = self.selectColor;
    }
    
    return _selectTextColor;
}

#pragma mark
#pragma mark Set Get Method
- (void)setSelectTextColor:(UIColor *)selectTextColor
{
    if ([_selectTextColor isEqual:selectTextColor]) {
        return;
    }
    
    _selectTextColor = selectTextColor;
    [self refreshFontColor];
}

- (void)setNonSelectTextColor:(UIColor *)nonSelectTextColor
{
    if ([_nonSelectTextColor isEqual:nonSelectTextColor]) {
        return;
    }
    
    _nonSelectTextColor = nonSelectTextColor;
    [self refreshFontColor];
}

- (void)setSelectColor:(UIColor *)selectColor
{
    if ([_selectColor isEqual:selectColor]) {
        return;
    }
    
    _selectColor = selectColor;
    
    self.selectView.backgroundColor = _selectColor;
}

- (void)setNonSelectColor:(UIColor *)nonSelectColor
{
    if ([_nonSelectColor isEqual:nonSelectColor]) {
        return;
    }
    
    _nonSelectColor = nonSelectColor;
    
    self.nonSelectView.backgroundColor = nonSelectColor;
}

- (void)setLeftItemIndex:(NSInteger)leftItemIndex
{
    if (_leftIndex == leftItemIndex) {
        return;
    }
    
    if (leftItemIndex < 0 || (leftItemIndex > _titles.count - 1) || leftItemIndex >= _rightIndex) {
        return;
    }
    
    _leftIndex = _leftItemIndex;
    
    [self adjustSliderPostion];
    
    [self adjustselectViewPositionAndBounds];
    
    [self refreshFontColor];
}

- (void)setRightItemIndex:(NSInteger)rightItemIndex
{
    if (_rightIndex == rightItemIndex) {
        return;
    }

    if (rightItemIndex > (_titles.count - 1) || rightItemIndex < (_leftIndex + 1)) {
        return;
    }
    
    _rightIndex = rightItemIndex;
    
    [self adjustSliderPostion];
    
    [self adjustselectViewPositionAndBounds];
    
    [self refreshFontColor];
}

#pragma mark
#pragma mark Drag
- (void)sliderDraged:(UIButton*)button WithEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    
    CGPoint point = [touch locationInView:self.backgroundView];
    
    point = [self adjustMovedPoint:point withSlider:button];
    
    [self moveSliderCenter:button toPoint:point];
    
    [self adjustselectViewStartAndEnd];
    
    [self refreshFontColor];
}

- (void)sliderDragEnd:(UIButton*)button
{
    [self moveSliderToNearest:button];
    NSLog(@"Drag End");
}

- (void)sliderTouchCancel:(UIButton*)button;
{
    [self moveSliderToNearest:button];
    NSLog(@"Cancel");
}

- (void)sliderDragTouchUp:(UIButton*)button;
{
    [self moveSliderToNearest:button];
    NSLog(@"TouchUp");
 
    if (self.block) {
        self.block(_leftIndex,_rightIndex);
    }
}

- (CGPoint)adjustMovedPoint:(CGPoint)point withSlider:(UIButton*)slider
{
    CGPoint resultPoint = point;
    resultPoint.y = FBDOUBLESIDESLIDER_BACKGROUNDVIEW_BLANK;
    
    if ([slider isEqual:self.leftSlider]) {
        
        CGFloat rightEdgeCenterX = 0;
        
        NSInteger rightEdgeIndex = _rightIndex - 1;
        if (rightEdgeIndex == 0) {
            rightEdgeCenterX = 0;
        }
        else
        {
            CALayer* layer = self.textLayers[rightEdgeIndex];
            rightEdgeCenterX = layer.position.x + _textLayerWidth / 2;
        }
        
        if (resultPoint.x <= 0) {
            resultPoint.x = 0;
        }
        
        if (resultPoint.x > rightEdgeCenterX) {
            resultPoint.x = rightEdgeCenterX;
        }
        
        return resultPoint;
    }
    else
    {
        CGFloat leftEdgeCenterX = 0;
        NSInteger leftEdgeIndex = _leftIndex + 1;
        if (leftEdgeIndex == _titles.count - 1) {
            leftEdgeCenterX = self.backgroundView.bounds.size.width;
        }
        else
        {
            CALayer* layer = self.textLayers[leftEdgeIndex];
            leftEdgeCenterX = layer.position.x + _textLayerWidth / 2;
        }
        
        CGFloat maxX = self.backgroundView.bounds.size.width;
        if (resultPoint.x > maxX) {
            resultPoint.x = maxX;
        }
        
        if (resultPoint.x < leftEdgeCenterX) {
            resultPoint.x = leftEdgeCenterX;
        }
        
        return resultPoint;
    }
}

- (void)moveSliderCenter:(UIButton*)slider toPoint:(CGPoint)point
{
    slider.center = point;
}

- (void)moveSliderToNearest:(UIButton*)slider
{
    NSInteger index = [self checkNearestIndexWithCenterPoint:slider.center];
    
    if ([slider isEqual:self.leftSlider]) {
        NSInteger maxLeftIndex = _rightIndex - 1;
        if (index > maxLeftIndex) {
            index = maxLeftIndex;
        }
        
        _leftIndex = index;
    }
    else
    {
        NSInteger minRightIndex = _leftIndex + 1;
        if (index < minRightIndex) {
            index = minRightIndex;
        }
        
        _rightIndex = index;
    }
    
    [self adjustSliderPostion];
    
    [self adjustselectViewStartAndEnd];
    
    [self refreshFontColor];
}

- (NSInteger)checkNearestIndexWithCenterPoint:(CGPoint)center
{
    NSInteger centerLeftIndex = 0;
    NSInteger centerRightIndex = _titles.count - 1;

    CALayer* prevLayer;
    CALayer* nextLayer;
    CGFloat leftEdge = 0.0,rightEdge = 0;
    
    for (NSInteger index = 0; index < _titles.count - 1; index ++) {
        prevLayer = self.textLayers[index];
        nextLayer = self.textLayers[index + 1];
        
        if (index == 0) {
            leftEdge = 0;
        }
        else
        {
            leftEdge = prevLayer.position.x + _textLayerWidth / 2;
        }
        
        if ((index + 1) == _titles.count - 1) {
            rightEdge = self.nonSelectView.bounds.size.width;
        }
        else
        {
            rightEdge = nextLayer.position.x + _textLayerWidth / 2;
        }
        
        if ((leftEdge <= center.x) && (rightEdge >= center.x)) {
            centerLeftIndex = index;
            centerRightIndex = index + 1;
            break;
        }
        
    }
    
    CGFloat leftX = leftEdge;
    CGFloat rightX = rightEdge;
    CGFloat leftDistance = fabs(leftX - center.x);
    CGFloat rightDistance = fabs(rightX - center.x);
    
    
    if (leftDistance < rightDistance)
    {
        return centerLeftIndex;
    }
    else
    {
        return centerRightIndex;
    }
}

- (void)refreshFontColor
{
    
    CGFloat leftSliderCenterX = self.leftSlider.center.x;
    CGFloat rightSliderCenterX = self.rightSlider.center.x;
    
    CATextLayer* layer;
    CGFloat centerX = 0;
    
    for (NSInteger index = 0; index < self.textLayers.count; index ++) {
        
        layer = self.textLayers[index];
        
        if (index == 0) {
            centerX = 0;
        }
        else if (index == self.textLayers.count - 1)
        {
            centerX = self.nonSelectView.bounds.size.width;
        }
        else
        {
            centerX = layer.position.x + _textLayerWidth / 2;
        }
        
        if (centerX < leftSliderCenterX || centerX > rightSliderCenterX) {
            layer.foregroundColor = self.nonSelectTextColor.CGColor;
        }
        else
        {
            layer.foregroundColor = self.selectTextColor.CGColor;
        }
    }
}

@end
