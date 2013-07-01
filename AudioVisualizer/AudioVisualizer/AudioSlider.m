//
//  AudioSlider.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/21/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AudioSlider.h"

#define TRIANGLE_HEIGHT 15

@interface AudioSlider (){
}

@end

@implementation AudioSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
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
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, startPoint.x + .5, startPoint.y + .5);
    CGContextAddLineToPoint(context, endPoint.x + .5, endPoint.y + .5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

-(void)drawTriangleForContext:(CGContextRef)context width:(float)width height:(float)height color:(UIColor *)color{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    float halfWidth = width / 2.0;
    [path addLineToPoint:CGPointMake(halfWidth, height)];
    [path addLineToPoint:CGPointMake(width, 0)];
    [path closePath];
    [color set];
    [path fill];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw the two triangles
    CGContextSaveGState(context);
    [self drawTriangleForContext:context width:self.bounds.size.width height:TRIANGLE_HEIGHT color:[UIColor orangeColor]];
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    [self drawTriangleForContext:context width:self.bounds.size.width height:TRIANGLE_HEIGHT color:[UIColor orangeColor]];
    CGContextRestoreGState(context);
    
    CGPoint startPoint = CGPointMake((self.bounds.size.width / 2.0) - 0.5, TRIANGLE_HEIGHT);
    CGPoint endPoint = CGPointMake((self.bounds.size.width / 2.0) - 0.5, self.bounds.size.height - TRIANGLE_HEIGHT);
    [self draw1PxStrokeForContext:context startPoint:startPoint endPoint:endPoint color:[UIColor blackColor].CGColor];
    
}


@end
