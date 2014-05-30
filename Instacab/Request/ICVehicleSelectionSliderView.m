//
//  ICVehicleSelectionSliderView.m
//  InstaCab
//
//  Created by Pavel Tisunov on 24/05/14.
//  Copyright (c) 2014 Bright Stripe. All rights reserved.
//

#import "ICVehicleSelectionSliderView.h"
#import "UIView+Positioning.h"
#import "ICImageDownloader.h"


// TODO: Когда vehicleView.count == 1 тогда поместить vehicle_picker_slider_point.png по центру и не показывать vehicle_picker_slider_background. Менять видимость при смене vehicleView.count
@implementation ICVehicleSelectionSliderView {
    NSArray *_vehicleViews;
    ICVehicleSelectionSliderButton *_button;
    UIImageView *_sliderBackgroundView;
    BOOL _shouldFixPositions;
    int _segmentWidth;
    int _selectedIndex;
    int _buttonLeftCenterBound;
    int _buttonRightCenterBound;
    CGPoint _buttonOffsetPoint;
    NSMutableArray *_labelViews;
}

NSInteger const kWidthPx = 320;
NSInteger const kTopMargin = 40;
NSInteger const kButtonSize = 48;
NSInteger const kNodeSize = 16;
NSInteger const kVehicleLabelSelectedY = 10;
NSInteger const kVehicleLabelUnselectedY = 18;
NSInteger const kNodeTapTag = 2;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 80)];
    if (self) {
        // Initialization code
        _labelViews = [[NSMutableArray alloc] init];
        _shouldFixPositions = YES;
        _selectedIndex = -1;
        
        // Add background with two nodes
        UIImage *image = [[UIImage imageNamed:@"vehicle_picker_slider_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        _sliderBackgroundView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_sliderBackgroundView];

        _button = [[ICVehicleSelectionSliderButton alloc] initWithFrame:CGRectMake(0, kTopMargin - (kButtonSize / 2) + kNodeSize / 2, kButtonSize, kButtonSize)];
        
        [_button addTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_button addTarget:self action:@selector(touchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
        
        [self addSubview:_button];
        
        // Listen for node taps
        UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nodeTapped:)];
        [self addGestureRecognizer:gest];
    }
    return self;
}

- (void)layoutSubviews {
    if (_shouldFixPositions)
    {
        _shouldFixPositions = NO;
        [self fixPositions];
    }
}

- (void)fixPositions {
    if (!_vehicleViews) return;

    _segmentWidth = (kWidthPx / _vehicleViews.count);
    int leftMargin = _segmentWidth / 2 - 8;
    _buttonLeftCenterBound = (_segmentWidth / 2);
    _buttonRightCenterBound = (kWidthPx - _segmentWidth / 2);
    
    _sliderBackgroundView.frame = CGRectMake(leftMargin, kTopMargin, kWidthPx - 2 * leftMargin, 16.0f);
    
    if (_selectedIndex >= 0) {
        [self moveButtonToIndex:_selectedIndex slowAnimation:NO];
        [self moveLabel:_selectedIndex y:kVehicleLabelSelectedY];
    }
    
    int index = 0;
    for (ICVehicleSelectionSliderLabel *label in _labelViews) {
        CGPoint pt = [self getCenterPointForIndex:index++];
        label.centerX = pt.x;
    }
}

- (void)moveButtonToIndex:(int)index slowAnimation:(BOOL)slowAnimate {
    if (_shouldFixPositions || index < 0) return;
    
    float x = index * _segmentWidth + _segmentWidth / 2 - kButtonSize / 2;
    NSTimeInterval duration = slowAnimate ? 0.2 : 0.01;
    
    [UIView animateWithDuration:duration animations:^{
        _button.x = x;
    }];
}

#pragma mark - Gestures

-(void)nodeTapped: (UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    int vehicleViewIndex = (int)(point.x / _segmentWidth);
    
    [self selectVehicleView:vehicleViewIndex slowAnimation:YES];
}

- (void)touchDown:(UIButton *)button withEvent:(UIEvent *)event {
    
}

-(void)touchUp:(UIButton *) button{
    [self moveButtonToIndex:button.centerX / _segmentWidth slowAnimation:YES];
}

// Button being dragged to the side
- (void)touchMove:(UIButton *)button withEvent:(UIEvent *)event {
    int newCenterX = [[[event allTouches] anyObject] locationInView:self].x;
    
    [self selectVehicleView:newCenterX / _segmentWidth slowAnimation:NO];
    
    if (newCenterX < _buttonLeftCenterBound) {
        newCenterX = _buttonLeftCenterBound;
    }
    else if (newCenterX > _buttonRightCenterBound) {
        newCenterX = _buttonRightCenterBound;
    }
    
    button.centerX = newCenterX;
}

#pragma mark - Properties

- (ICVehicleView *)selectedVehicleView {
    if (_selectedIndex < 0 || _selectedIndex > _vehicleViews.count) return nil;
    
    return _vehicleViews[_selectedIndex];
}

-(CGPoint)getCenterPointForIndex:(int)index {
    float x = index * _segmentWidth + _segmentWidth / 2;
    return CGPointMake(x, kTopMargin + kNodeSize / 2);
}

-(void)clearLabelViews {
    for (UILabel *label in _labelViews) {
        [label removeFromSuperview];
    }
    [_labelViews removeAllObjects];
}

-(void)clearNodeTapViews {
    for (UIView *view in self.subviews) {
        if (view.tag == kNodeTapTag)
            [view removeFromSuperview];
    }
}

- (void)updateOrderedVehicleViews:(NSArray *)vehicleViews selectedIndex:(int)selectedIndex {
    if (_vehicleViews.count != vehicleViews.count)
        _shouldFixPositions = YES;
    
    [self clearLabelViews];
    [self clearNodeTapViews];
    
    _vehicleViews = [vehicleViews copy];
    
    UIImage *sliderPointImage = [UIImage imageNamed:@"vehicle_picker_slider_point.png"];
    
    int vehicleViewsCount = _vehicleViews.count;
    for (int vehicleViewIndex = 0; ; vehicleViewIndex++)
    {
        // Redraw
        if (vehicleViewIndex >= vehicleViewsCount)
        {
            [self selectVehicleView:selectedIndex slowAnimation:NO];
            [self setNeedsLayout];
            return;
        }
        
        CGPoint centerPoint = [self getCenterPointForIndex:vehicleViewIndex];
        
        // Add middle nodes if > 2
        if ((vehicleViewIndex > 0) && (vehicleViewIndex < vehicleViewsCount - 1))
        {
            UIImageView *nodeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            nodeView.image = [UIImage imageNamed:@"vehicle_picker_slider_point"];
            nodeView.center = centerPoint;
            nodeView.tag = kNodeTapTag;
            [self insertSubview:nodeView belowSubview:_button];
        }
        
        ICVehicleView *vehicleView = (ICVehicleView *)_vehicleViews[vehicleViewIndex];
        ICVehicleSelectionSliderLabel *label = [[ICVehicleSelectionSliderLabel alloc] init];
        label.text = vehicleView.description;
        label.centerX = centerPoint.x;
        label.y = kVehicleLabelUnselectedY;
        
        [_labelViews addObject:label];
        [self addSubview:label];
    }
}

-(void)selectVehicleView:(int)index slowAnimation:(BOOL)slowAnimate {
    if (index == _selectedIndex) return;
    
    [self moveLabel:_selectedIndex y:kVehicleLabelUnselectedY];
    [self moveLabel:index y:kVehicleLabelSelectedY];
    [self moveButtonToIndex:index slowAnimation:slowAnimate];
    _selectedIndex = index;
    [self updateVehicleSliderIcon];
    
    if ([self.delegate respondsToSelector:@selector(viewChanged)]) {
        [self.delegate viewChanged];
    }
}

-(void)moveLabel:(int)index y:(int)y {
    if (index < 0 || index > _labelViews.count) return;
    
    ICVehicleSelectionSliderLabel *label = _labelViews[index];
    [UIView animateWithDuration:0.2 animations:^{
        label.y = y;
    }];
}

-(void)updateVehicleSliderIcon {
    ICVehicleView *vehicleView = _vehicleViews[_selectedIndex];
    if (!vehicleView || vehicleView.monoImages.count == 0) return;
    
    NSString *url = vehicleView.monoImage.url;
    
    [[ICImageDownloader shared] downloadImageUrl:url].then(^(UIImage *image){
        _button.icon = image;
    }).catch(^(NSError *error){
        NSHTTPURLResponse *rsp = error.userInfo[PMKURLErrorFailingURLResponseKey];
        int HTTPStatusCode = rsp.statusCode;
        NSLog(@"%@", error);
    });;
}

-(void)dealloc{
    [_button removeTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [_button removeTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [_button removeTarget:self action:@selector(touchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
}

@end
