//
//  ClockDialView.h
//  OfficeManager
//
//  Created by rongwf on 2018/5/8.
//  Copyright © 2018年 rongwf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockDialView : UIView

@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat currentValue;

-(void)drawArcWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle lineWidth:(CGFloat)lineWitdth fillColor:(UIColor*)filleColor strokeColor:(UIColor*)strokeColor;

-(void)DrawScaleValueWithDivide:(NSInteger)divide;

-(void)drawScaleWithDivide:(int)divide andRemainder:(NSInteger)remainder strokeColor:(UIColor*)strokeColor filleColor:(UIColor*)fillColor scaleLineNormalWidth:(CGFloat)scaleLineNormalWidth scaleLineBigWidth:(CGFloat)scaleLineBigWidth;

- (void)refreshDashboard:(CGFloat)currentValue;

@end
