//
//  GraphView.m
//  calculator
//
//  Created by apple apple on 12-2-12.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"
#define DEFAULT_SCALE  50
#define DEFAULT_ORIGIN_X   160
#define DEFAULT_ORIGIN_Y   208


@implementation GraphView
@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize dataSource = _dataSource;
@synthesize x = _x;

-(void)setScale:(CGFloat)scale
{
    if (_scale != scale) {
         _scale = scale;
    }
    [self setNeedsDisplay];
}

-(CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE;
    }
    return _scale;
}

-(void)setOrigin:(CGPoint)origin
{
    if (_origin.x != origin.x&&_origin.y != origin.y) {
        _origin = CGPointMake(origin.x, origin.y);
    }
    [self setNeedsDisplay];
}

-(CGPoint)origin
{
    if (!_origin.x &&!_origin.y) {
        return CGPointMake(DEFAULT_ORIGIN_X, DEFAULT_ORIGIN_Y);
    }
    else return _origin;
}


-(void)pinch:(UIPinchGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        self.scale*=gesture.scale;
        gesture.scale = 1.0;//we don't want cumulative scale,we want incremental scale,so that as it getting bigger or smaller,it's always telling me compared to the last position 
    }
}

-(void)triTap:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) 
    {
        CGPoint pt = [gesture locationInView:self];
        NSLog(@"x %f y %f",pt.x, pt.y);
        self.origin = CGPointMake(pt.x, pt.y);
    }
}

-(void)pan:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) 
    {
        CGPoint translation = [gesture translationInView:self];
        self.origin =CGPointMake(self.origin.x+translation.x, self.origin.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self];
    }
}

-(void)setup
{
    self.contentMode = UIViewContentModeRedraw;//A flag used to determine how a view lays out its content when its bounds change.if the bounds changes,redraw ourselves以上方法用于旋转视图时（bounds）改变，图像不会失真
}

-(void)awakeFromNib
{
    [self setup];
}//当加载xib时，此方法会被call,而initWithFrame则不会

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}//get initialized if someone uses alloc/initWithFrame to create us,以上方法用于旋转视图时（bounds）改变，图像不会失真


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    [[UIColor redColor] setStroke];
    CGPoint axisOrigin;
    axisOrigin = CGPointMake(self.origin.x, self.origin.y);//设置坐标原点
    
    CGRect rect1 = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGFloat pointsPerUnit = self.scale;//确定横坐标范围，即320／20＝16,从－8到＋8
    [AxesDrawer drawAxesInRect:rect1 originAtPoint:axisOrigin scale:pointsPerUnit];
    
    UIGraphicsPushContext(context);//You can use this function to save the previous graphics state and make the specified context the current context. You must balance calls to this function with matching calls to the UIGraphicsPopContext function.
        /*Special considerations for defining drawing “subroutines”
         What if you wanted to have a utility method that draws something
         You don’t want that utility method to mess up the graphics state of the calling method Use push and pop context functions.*/
    BOOL haveMovedToPoint = NO;
    
    for (CGFloat startPixel = 0; startPixel <= self.bounds.size.width; startPixel++) 
    {
        CGContextSetLineWidth(context, 2.0);
        [[UIColor blueColor] setStroke];
        CGFloat xPixelsFromCartesianOrigin = startPixel - self.origin.x;//从负半轴起画
        self.x = xPixelsFromCartesianOrigin/pointsPerUnit;//x in units,不能直接用像素点的值求y,必须用标度值，因此要除scale
        
        CGFloat yChange = [self.dataSource verticalValueForGraphView:self];//self.dataSource is GraphingViewController
        
        CGFloat yPixelsFromCartesianOrigin = yChange * pointsPerUnit;
        
        if (haveMovedToPoint == NO)
        {
            CGContextMoveToPoint(context, 0, self.origin.y-yPixelsFromCartesianOrigin);//第一步先从origin(0,0)移到起始画点
            haveMovedToPoint = YES;
        }
        CGContextAddLineToPoint(context, startPixel, self.origin.y-yPixelsFromCartesianOrigin);
    }
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}


@end
