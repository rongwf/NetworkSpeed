//
//  ClockDialView.m
//  OfficeManager
//
//  Created by rongwf on 2018/5/8.
//  Copyright © 2018年 rongwf. All rights reserved.
//

#import "ClockDialView.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#define KAngleToradian(angle) (M_PI / 180.0 * (angle))

#define Calculate_radius ((self.bounds.size.height>self.bounds.size.width)?(self.bounds.size.width*0.5-self.lineWidth):(self.bounds.size.height*0.5-self.lineWidth))

#define LuCenter CGPointMake(self.center.x-self.frame.origin.x, self.center.y-self.frame.origin.y)

@interface ClockDialView ()

/**
 *  圆盘开始角度
 */
@property(nonatomic,assign)CGFloat startAngle;
/**
 *  圆盘结束角度
 */
@property(nonatomic,assign)CGFloat endAngle;
/**
 *  圆盘总共弧度弧度
 */
@property(nonatomic,assign)CGFloat arcAngle;
/**
 *  线宽
 */
@property(nonatomic,assign)CGFloat lineWidth;
/**
 *  刻度值长度
 */
@property(nonatomic,assign)CGFloat scaleValueRadiusWidth;
/**
 *  速度表半径
 */
@property(nonatomic,assign)CGFloat arcRadius;
/**
 *  刻度半径
 */
@property(nonatomic,assign)CGFloat scaleRadius;
/**
 *  刻度值半径
 */
@property(nonatomic,assign)CGFloat scaleValueRadius;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) CAShapeLayer *insideProgressLayer;

@property (nonatomic, strong) NSMutableArray *layerArray;

@property (nonatomic, strong) NSMutableArray *textArray;

@property (nonatomic, strong) UIImageView *innerCursorImageView;

@property (nonatomic, assign) int divide;

@end

@implementation ClockDialView

- (NSMutableArray *)layerArray {
    if (!_layerArray) {
        _layerArray = [NSMutableArray arrayWithCapacity:100];
    }
    return _layerArray;
}

- (NSMutableArray *)textArray {
    if (!_textArray) {
        _textArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _textArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.backgroundColor = RGBA(255, 255, 255, 0.33);
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.layer.masksToBounds = YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

/**
 *  画弧度
 *
 *  @param startAngle  开始角度
 *  @param endAngle    结束角度
 *  @param lineWitdth  线宽
 *  @param filleColor  扇形填充颜色
 *  @param strokeColor 弧线颜色
 */
-(void)drawArcWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle lineWidth:(CGFloat)lineWitdth fillColor:(UIColor*)filleColor strokeColor:(UIColor*)strokeColor {
    //保存弧线宽度,开始角度，结束角度
    self.lineWidth = lineWitdth;
    self.startAngle = startAngle;
    self.endAngle = endAngle;
    self.arcAngle = endAngle - startAngle;
    self.arcRadius = Calculate_radius;
    self.scaleRadius = self.arcRadius - 15;
    self.scaleValueRadius = self.scaleRadius - self.lineWidth;
    
    [self addSubview:self.innerCursorImageView];
    
    UIBezierPath *outArc=[UIBezierPath bezierPathWithArcCenter:LuCenter radius:self.arcRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer* shapeLayer=[CAShapeLayer layer];
    shapeLayer.lineWidth=lineWitdth;
    shapeLayer.fillColor=filleColor.CGColor;
    shapeLayer.strokeColor=strokeColor.CGColor;
    shapeLayer.path=outArc.CGPath;
    shapeLayer.lineCap=kCALineCapRound;
    [self.layer addSublayer:shapeLayer];
    
    UIBezierPath *insideArc=[UIBezierPath bezierPathWithArcCenter:LuCenter radius:self.arcRadius - 5 startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer* insideShapeLayer=[CAShapeLayer layer];
    insideShapeLayer.lineWidth=lineWitdth;
    insideShapeLayer.fillColor=filleColor.CGColor;
    insideShapeLayer.strokeColor=strokeColor.CGColor;
    insideShapeLayer.path=insideArc.CGPath;
    insideShapeLayer.lineCap=kCALineCapRound;
    [self.layer addSublayer:insideShapeLayer];
}

/**
 *  画刻度
 *
 *  @param divide      刻度几等分
 *  @param remainder   刻度数
 *  @param strokeColor 轮廓填充颜色
 *  @param fillColor   刻度颜色
 */
-(void)drawScaleWithDivide:(int)divide andRemainder:(NSInteger)remainder strokeColor:(UIColor*)strokeColor filleColor:(UIColor*)fillColor scaleLineNormalWidth:(CGFloat)scaleLineNormalWidth scaleLineBigWidth:(CGFloat)scaleLineBigWidth{
    self.divide = divide;
    CGFloat perAngle = self.arcAngle / divide;
    for (NSInteger i = 0; i<= divide; i++) {
        //我们需要计算出每段弧线的起始角度和结束角度
        CGFloat startAngel = (self.startAngle+ perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/5;
        
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:LuCenter radius:self.scaleRadius startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.fillColor = [UIColor clearColor].CGColor;
        if((remainder!=0)&&(i % remainder) == 0) {
            perLayer.strokeColor = strokeColor.CGColor;
            perLayer.lineWidth   = scaleLineBigWidth;
            
        }else{
            perLayer.strokeColor = strokeColor.CGColor;;
            perLayer.lineWidth   = scaleLineNormalWidth;
            
        }
        
        perLayer.path = tickPath.CGPath;
        [self.layer addSublayer:perLayer];
        
    }
}

/**
 *  画刻度值，逆时针设定label的值，将整个仪表切分为N份，每次递增仪表盘弧度的N分之1
 *
 *  @param divide 刻度值几等分
 */
-(void)DrawScaleValueWithDivide:(NSInteger)divide{
    CGFloat textAngel =self.arcAngle/divide;
    if (divide==0) {
        return;
    }
    for (NSUInteger i = 0; i <= divide; i++) {
        CGPoint point = [self calculateTextPositonWithArcCenter:LuCenter Angle:-(self.endAngle-textAngel*i)];
        NSString *tickText = [NSString stringWithFormat:@"%ld",(divide - i)*10/divide];
        //默认label的大小23 * 14
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(point.x - 8, point.y - 7, 30, 14)];
        text.text = tickText;
        text.font = [UIFont systemFontOfSize:14.f];
        text.textColor = RGBA(255, 255, 255, 0.33);
        text.textAlignment = NSTextAlignmentLeft;
        [self.textArray addObject:text];
        [self addSubview:text];
    }
}
//默认计算半径-10,计算label的坐标
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center Angle:(CGFloat)angel {
    CGFloat x = (self.scaleValueRadius - 15)* cosf(angel);
    CGFloat y = (self.scaleValueRadius - 15)* sinf(angel);
    return CGPointMake(center.x + x, center.y - y);
}

- (void)refreshDashboard:(CGFloat)currentValue {
    // 控制范围
    if (currentValue > self.maxValue) {
        currentValue = self.maxValue;
    }
    if (currentValue <= self.minValue) {
        currentValue = self.minValue;
    }
    
    if (self.progressLayer) {
        [self.progressLayer removeFromSuperlayer];
    }
    if (self.insideProgressLayer) {
        [self.insideProgressLayer removeFromSuperlayer];
    }
    
    if (self.layerArray.count > 0) {
        for (CAShapeLayer *layer in self.layerArray) {
            [layer removeFromSuperlayer];
        }
        [self.layerArray removeAllObjects];
    }
    
    // 百分比
    CGFloat percent = (currentValue - self.minValue) / (self.maxValue - self.minValue);

    // 当前角度
    CGFloat currentAngle = self.startAngle + (fabs(self.endAngle - self.startAngle) * percent);
    
    
    
    CGFloat imageCurrentAngle = M_PI_4*5+(M_PI*3/2 * percent);
    
    // 前景弧形绘制
    [self dashboardDrawPercent:percent startAngle:self.startAngle endAngle:currentAngle imageCurrentAngle:imageCurrentAngle currentValue:currentValue];
}

- (void)dashboardDrawPercent:(CGFloat)percent startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle imageCurrentAngle:(CGFloat)imageCurrentAngle currentValue:(CGFloat)currentValue {
    
    UIBezierPath *progressPath  = [UIBezierPath bezierPathWithArcCenter:LuCenter radius:self.arcRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    self.progressLayer = progressLayer;
    progressLayer.lineWidth = self.lineWidth;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    progressLayer.path = progressPath.CGPath;
    progressLayer.lineCap=kCALineCapRound;
    [self.layer addSublayer:progressLayer];
    
    UIBezierPath *insideProgressPath  = [UIBezierPath bezierPathWithArcCenter:LuCenter radius:self.arcRadius - 5 startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *insideProgressLayer = [CAShapeLayer layer];
    self.insideProgressLayer = insideProgressLayer;
    insideProgressLayer.lineWidth = self.lineWidth+0.25f;
    insideProgressLayer.fillColor = [UIColor clearColor].CGColor;
    insideProgressLayer.strokeColor = [UIColor whiteColor].CGColor;
    insideProgressLayer.path = insideProgressPath.CGPath;
    insideProgressLayer.lineCap=kCALineCapRound;
    [self.layer addSublayer:insideProgressLayer];
    
    
    CGFloat perAngle=self.arcAngle/100;
        int j = self.divide * percent;
    //我们需要计算出每段弧线的起始角度和结束角度
    for (NSInteger i = 0; i<= j; i++) {
        CGFloat startAngel = (startAngle+ perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/5;
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:LuCenter radius:self.scaleRadius startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.fillColor = [UIColor clearColor].CGColor;
        if((i % 10) == 0) {
            perLayer.strokeColor = [UIColor whiteColor].CGColor;
            perLayer.lineWidth   = 10;
            
        }else{
            perLayer.strokeColor = [UIColor whiteColor].CGColor;
            perLayer.lineWidth   = 5;
            
        }
        
        perLayer.path = tickPath.CGPath;
        [self.layerArray addObject:perLayer];
        [self.layer addSublayer:perLayer];
        
    }
    
    for (UILabel *textLabel in self.textArray) {
        if (currentValue > [textLabel.text floatValue]) {
            textLabel.textColor = [UIColor whiteColor];
        } else {
            textLabel.textColor = RGBA(255, 255, 255, 0.33);
        }
    }
    
    [self setAnchorPoint:CGPointMake(0.5, 0.82) forView:_innerCursorImageView];
    _innerCursorImageView.transform = CGAffineTransformMakeRotation(imageCurrentAngle);
}

- (UIImageView *)innerCursorImageView {
    if (!_innerCursorImageView) {
        UIImageView *innerCursorImageView = [[UIImageView alloc] init];
        innerCursorImageView.image = [UIImage imageNamed:@"指针"];
        innerCursorImageView.frame = CGRectMake(self.bounds.size.width / 2 - 10, Calculate_radius - 125, innerCursorImageView.image.size.width * 0.5, innerCursorImageView.image.size.height * 0.5);
        // 旋转成和仪表盘角度一致
        [self setAnchorPoint:CGPointMake(0.5, 0.816993) forView:innerCursorImageView];//因为layer位置会发生变化，需要重新设置
        innerCursorImageView.transform = CGAffineTransformMakeRotation(M_PI);//图片绕某一点旋转
        _innerCursorImageView = innerCursorImageView;
    }
    return _innerCursorImageView;
}

#pragma mark 重新设置图片的frame，保证图片不发生位移
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

@end
