//
//  WaveformControl.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "WaveformControl.h"
#import "AppModel.h"

@interface WaveformControl (Private)

- (void) drawRoundRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidht:(CGFloat)lineWidth;

@end

@implementation WaveformControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Touch Handling
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"WaveformControl was touched");
//	UITouch *touch = [touches anyObject];
//	CGPoint local_point = [touch locationInView:self];
//	CGRect wr = [self waveRect];
//    //	wr.size.width = (wr.size.width - 12);
//    //	wr.origin.x = wr.origin.x + 6;
//	if(CGRectContainsPoint(wr,local_point) && player != nil) {
//        CGFloat x = local_point.x - wr.origin.x;
//        float sel = x / wr.size.width;
//        Float64 duration = CMTimeGetSeconds(player.currentItem.duration);
//        float timeSelected = duration * sel;
//        CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
//        [player seekToTime:tm];
//        //NSLog(@"Clicked time : %f",timeSelected);
//	}
}

- (CGRect) waveRect
{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
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


- (void)drawRect:(CGRect)rect
{
    CGContextRef cx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(cx);
	
	CGContextSetFillColorWithColor(cx, [UIColor clearColor].CGColor);
	CGContextFillRect(cx, self.bounds);
	
    //drawing weird white background behind gray background
	[self drawRoundRect:self.bounds fillColor:[UIColor whiteColor] strokeColor:[UIColor clearColor] radius:8.0 lineWidht:2.0];
	
    //	CGRect playRect = [self playRect];
    //	[self drawRoundRect:playRect fillColor:white strokeColor:darkgray radius:4.0 lineWidht:2.0];
	
	CGRect waveRect = [self waveRect];
	[self drawRoundRect:waveRect fillColor:[UIColor lightGrayColor] strokeColor:[UIColor clearColor] radius:4.0 lineWidht:2.0];
	
    //	CGRect statusRect = [self statusRect];
    //	[self drawRoundRect:statusRect fillColor:lightgray strokeColor:darkgray radius:4.0 lineWidht:2.0];
	
	if([AppModel sharedAppModel].sampleLength > 0) {
        //draw setup
        //		if(player.rate == 0.0) {
        //			[self drawPlay];
        //		} else {
        //			[self drawPause];
        //		}
		CGMutablePathRef halfPath = CGPathCreateMutable();
		CGPathAddLines( halfPath, NULL,[AppModel sharedAppModel].sampleData, [AppModel sharedAppModel].sampleLength); // magic!
		
		CGMutablePathRef path = CGPathCreateMutable();
		
		double xscale = (CGRectGetWidth(waveRect)) / (float)[AppModel sharedAppModel].sampleLength;
		// Transform to fit the waveform ([0,1] range) into the vertical space
		// ([halfHeight,height] range)
		double halfHeight = floor( CGRectGetHeight(waveRect) / 2.0 );//waveRect.size.height / 2.0;
		CGAffineTransform xf = CGAffineTransformIdentity;
		xf = CGAffineTransformTranslate( xf, waveRect.origin.x, halfHeight + waveRect.origin.y);
		xf = CGAffineTransformScale( xf, xscale, -(halfHeight) );
        //xf = CGAffineTransformScale(xf, xscale, -120);
		CGPathAddPath( path, &xf, halfPath );
		
		// Transform to fit the waveform ([0,1] range) into the vertical space
		// ([0,halfHeight] range), flipping the Y axis
		xf = CGAffineTransformIdentity;
		xf = CGAffineTransformTranslate( xf, waveRect.origin.x, halfHeight + waveRect.origin.y);
		xf = CGAffineTransformScale( xf, xscale, (halfHeight));
		CGPathAddPath( path, &xf, halfPath );
		
		CGPathRelease( halfPath ); // clean up!
		// Now, path contains the full waveform path.
		CGContextRef cx = UIGraphicsGetCurrentContext();
		
		//[darkgray set];
        [[UIColor lightGrayColor] set];
		CGContextAddPath(cx, path);
		CGContextStrokePath(cx);
		
		// gauge draw
		//if(playProgress > 0.0) {
        CGRect clipRect = waveRect;
        //clipRect.size.width = (clipRect.size.width - 12) * playProgress;
        //            clipRect.size.width = (clipRect.size.width - 12);
        //			clipRect.origin.x = clipRect.origin.x + 6;
        CGContextClipToRect(cx,clipRect);
        
        [[UIColor whiteColor] setFill];
        CGContextAddPath(cx, path);
        CGContextFillPath(cx);
        CGContextClipToRect(cx,waveRect);
        [[UIColor lightGrayColor] set];
        CGContextAddPath(cx, path);
        CGContextStrokePath(cx);
		//}
		CGPathRelease(path); // clean up!
        
        //draw a line where the current playhead is
//        float currentPointX = (wave.size.width) * playProgress;
//        CGPoint startPoint = CGPointMake(currentPointX, 0);
//        CGPoint endPoint = CGPointMake(currentPointX, self.bounds.size.height);
//        [self draw1PxStrokeForContext:context startPoint:startPoint endPoint:endPoint color:[UIColor redColor].CGColor];
        
        //check to see if the playhead should stop
        //this also needs to reset the play button
        //BAD
//        if(currentPointX >= rightSlider.center.x){
//            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"StopAudio" object:nil userInfo:nil]];
//        }
        
        
	}
	[[UIColor clearColor] setFill];
	CGContextRestoreGState(cx);
}


@end
