//
//  KUIView.m
//  MTCALayerAnimation
//
//  Created by mtt0150 on 15/9/6.
//  Copyright (c) 2015年 MT. All rights reserved.
//

#import "KUIView.h"
#import "KCALayer.h"
@interface KUIView ()
@property (strong, nonatomic) CALayer *tempLayer;
@end
@implementation KUIView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        KCALayer *layer = [KCALayer layer];
        layer.bounds = CGRectMake(0, 0, 10, 20);
        layer.position = CGPointMake(50, 150);
        //调用KCALayer的drawInContext:方法绘制图层
        [layer setNeedsDisplay];
        layer.contents = (id)[UIImage imageNamed:[[NSBundle mainBundle] pathForResource:@"petal.png" ofType:nil]].CGImage;
        
        [self.layer addSublayer:layer];
        self.tempLayer = layer;
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    NSLog(@"----->%@",UIGraphicsGetCurrentContext());
    [super drawRect:rect];
}
//绘制根图层，调用UIview的[super draw:inContext]，如果不是用super，而是用self会一直循环占用内存，最后程序崩溃
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    // uiview-drawlayer incontext:<CGContext 0x7fdb2043c7e0>
    NSLog(@"uiview-drawlayer incontext:%@",ctx);
    [super drawLayer:layer inContext:ctx];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //调用动画组，同时产生旋转和飘落的效果
    [self animationGroup];
}
- (void)animationGroup{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    //初始化一个基础动画
    CABasicAnimation *rotationAnimation = [self rotationAnimation];
    CAKeyframeAnimation *curveAnimation = [self curveAnimation];
    animationGroup.animations = @[rotationAnimation,
                                  curveAnimation
                                  ];
    animationGroup.duration = 8;
    animationGroup.beginTime = CACurrentMediaTime() + 2;
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.delegate = self;
    [self.tempLayer addAnimation:animationGroup forKey:@"animationGroup"];

}
//这个关键帧动画用来实现曲线的效果
- (CAKeyframeAnimation *)curveAnimation{
    CAKeyframeAnimation *curveAnimation = [CAKeyframeAnimation animation];
    curveAnimation.keyPath = @"position";
    CGPoint endPoint = CGPointMake(55, 400);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.tempLayer.position.x, self.tempLayer.position.y);
    CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, endPoint.x, endPoint.y);
    curveAnimation.path = path;
    CGPathRelease(path);
    [curveAnimation setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"curve-endPoint"];
    return curveAnimation;
    
}
//这个基础动画实现旋转的效果
- (CABasicAnimation *)rotationAnimation{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animation];
    CGFloat toValue = M_PI_2 * 3;
    rotationAnimation.keyPath = @"transform.rotation.z";
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI_2 * 3];
    rotationAnimation.autoreverses = YES;
    //这是为了在旋转动画执行完毕之后旋转的动画不会在layer上移除，而属性值position的改变放在动画结束之后去改变
    rotationAnimation.removedOnCompletion = NO;
    [rotationAnimation setValue:[NSNumber numberWithFloat:toValue] forKey:@"rotation-toValue"];
    return rotationAnimation;
}
#pragma mark -animationGroupDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        //取出动画组
        CAAnimationGroup *animationGroup = (CAAnimationGroup *)anim;
        CABasicAnimation *rotationAnimation = animationGroup.animations[0];
        CAKeyframeAnimation *curveAnimation = animationGroup.animations[1];
        //取消rotation和position的隐式动画
        //用到动画事务
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.tempLayer.position = [[curveAnimation valueForKey:@"curve-endPoint"] CGPointValue];
        //赋值transform的旋转属性，transform里面有三个属性，分别是旋转rotation，平移translation以及缩放scale，都有相应的3D变化函数设置
        self.tempLayer.transform = CATransform3DMakeRotation([[rotationAnimation valueForKey:@"rotation-toValue"] floatValue], 0, 0, 1);
        [CATransaction commit];
    }
}
#pragma mark -cycle
////暂停动画
//- (void)pauseAnimation{
//    //获取指定图层的媒体时间
//    CFTimeInterval currentTime = [self.tempLayer convertTime:CACurrentMediaTime() fromLayer:nil];
//    NSLog(@"pause1:%f",CACurrentMediaTime());
//    NSLog(@"pause2:%f",currentTime);
//    //设置时间偏移
//    self.tempLayer.timeOffset = currentTime;
//    self.tempLayer.speed = 0;
//}
//
////恢复动画
//
//- (void)resumeAnimation{
//    CFTimeInterval beginTime = CACurrentMediaTime() - self.tempLayer.timeOffset;
//    NSLog(@"resume1:%f",CACurrentMediaTime());
//    NSLog(@"resume2:%f",self.tempLayer.timeOffset);
//    self.tempLayer.beginTime = beginTime;
//    self.tempLayer.speed = 1.0;
//    //假如不把时间便宜设置为0，那么当开始时间开始重新执行动画的时候，会马上将时间再次偏移，直接跳过动画
//    self.tempLayer.timeOffset = 0;
//}
//设置开启基础动画，让花瓣沿着你的点击位置进行飘动
@end
