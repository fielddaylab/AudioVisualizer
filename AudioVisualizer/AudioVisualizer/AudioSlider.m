//
//  AudioSlider.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/21/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AudioSlider.h"

@interface AudioSlider (){
}

@end

@implementation AudioSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void) drawRoundRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidht:(CGFloat)lineWidth
{
	CGRect rrect = CGRectMake(bounds.origin.x+(lineWidth/2), bounds.origin.y+(lineWidth/2), bounds.size.width - lineWidth, bounds.size.height - lineWidth);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextRef cx = UIGraphicsGetCurrentContext();
	
	CGContextMoveToPoint(cx, minx, midy);
	CGContextAddArcToPoint(cx, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(cx, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(cx, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(cx, minx, maxy, minx, midy, radius);
	CGContextClosePath(cx);
	
	CGContextSetStrokeColorWithColor(cx, strokeColor.CGColor);
	CGContextSetFillColorWithColor(cx, fillColor.CGColor);
	CGContextDrawPath(cx, kCGPathFillStroke);
}

-(void) draw1PxStrokeForContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(CGColorRef)color{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + .5, startPoint.y + .5);
    CGContextAddLineToPoint(context, endPoint.x + .5, endPoint.y + .5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect
{
//	[self drawRoundRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) fillColor:[UIColor redColor] strokeColor:[UIColor blueColor] radius:4.0 lineWidht:2.0];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGRect rectangle = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0);
//    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 1.0, 1.0);
//    CGContextFillRect(context, rectangle);
//    CGContextStrokeRect(context, rectangle);
    
    //this draws the triangle
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    float halfWidth = self.bounds.size.width / 2.0;
    [path addLineToPoint:CGPointMake(50, 100)];
    [path addLineToPoint:CGPointMake(100, 0)];
    [path closePath];
    [[UIColor orangeColor] set];
    [path fill];
}


@end
