//
//  FreqHistogramControl.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "FreqHistogramControl.h"
#import <Accelerate/Accelerate.h>
#include <AudioToolbox/AudioToolbox.h>

@interface FreqHistogramControl(){
    
}

@end

@implementation FreqHistogramControl

@synthesize fourierData;
@synthesize largestMag;
@synthesize currentFreqX;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        fourierData = nil;
        largestMag = FLT_MIN;
        currentFreqX = 0;
    }
    return self;
}




-(void)drawSquareRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextFillRect(context, bounds);
    CGContextStrokeRect(context, bounds);
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawSquareRect:self.bounds fillColor:[UIColor lightGrayColor] strokeColor:[UIColor clearColor] radius:4.0 lineWidth:2.0];
    
    if(fourierData != nil){
        
        
        float binWidth = self.bounds.size.width / 256; //512/2
        float currentBinCoor = binWidth / 2;
        for(int k = 1; k < 512; k++){
            float heightRatio = fourierData[k] / largestMag;
            float screenHeight = self.bounds.size.height * heightRatio;
            //float screenHeight = fourierData[k];
            CGPoint startPoint = CGPointMake(currentBinCoor, self.bounds.size.height);
            CGPoint endPoint = CGPointMake(currentBinCoor, self.bounds.size.height - screenHeight);
            [self draw1PxStrokeForContext:context startPoint:startPoint endPoint:endPoint color:[UIColor redColor].CGColor];
            currentBinCoor += binWidth;
//            if(screenHeight > 0){
//                NSLog(@"%i Frequency: %f X: %f Y: %f", k, (k * 44100.0)/1024, currentBinCoor, screenHeight);
//            }
        }
        
    }
    
    CGPoint startPoint = CGPointMake(currentFreqX, 0);
    CGPoint endPoint = CGPointMake(currentFreqX, self.bounds.size.height);
    [self draw1PxStrokeForContext:context startPoint:startPoint endPoint:endPoint color:[UIColor blueColor].CGColor];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.delegate freqHistogramControl:self wasTouched:touches];
}


@end
