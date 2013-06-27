//
//  FreqHistogramControl.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "FreqHistogramControl.h"
#import "AppModel.h"
#import <Accelerate/Accelerate.h>

@interface FreqHistogramControl(){

}

@end

@implementation FreqHistogramControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(COMPLEX_SPLIT)computeFFTForData:(float *)data{
    
    int bufferFrames = 1024;
    int bufferLog2 = round(log2(bufferFrames));
    FFTSetup fftSetup = vDSP_create_fftsetup(bufferLog2, kFFTRadix2);
    float outReal[bufferFrames / 2];
    float outImaginary[bufferFrames / 2];
    COMPLEX_SPLIT out = { .realp = outReal, .imagp = outImaginary };
    vDSP_ctoz((COMPLEX *)&data[0], 2, &out, 1, bufferFrames / 2);
    vDSP_fft_zrip(fftSetup, &out, 1, bufferLog2, FFT_FORWARD);
    
    //print out data
    for(int i = 1; i < bufferFrames / 2; i++){
        float frequency = (i * 44100.0)/bufferFrames;
        float magnitude = sqrtf((out.realp[i] * out.realp[i]) + (out.imagp[i] * out.imagp[i]));
        float magnitudeDB = 10 * log10(out.realp[i] * out.realp[i] + (out.imagp[i] * out.imagp[i]));
        NSLog(@"Bin %i: Magnitude: %f Magnitude DB: %f  Frequency: %f Hz", i, magnitude, magnitudeDB, frequency);
    }
    return out;
}

-(void)drawSquareRect:(CGRect)bounds fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextFillRect(context, bounds);
    CGContextStrokeRect(context, bounds);
}

-(float *)constructRawData:(CGPoint *)sampleData sampleLength:(int)sampleLength{
    float *data = malloc(sizeof(float) * sampleLength);
    for(int i = 0; i < sampleLength; i++){
        data[i] = sampleData[i].y;
        //NSLog(@"Raw Data at %i: %f", i, data[i]);
    }
    return data;
}

- (void)drawRect:(CGRect)rect
{
    [self drawSquareRect:self.bounds fillColor:[UIColor lightGrayColor] strokeColor:[UIColor clearColor] radius:4.0 lineWidth:2.0];
    
    if([AppModel sharedAppModel].sampleLength > 0){
        float *data = [self constructRawData:[AppModel sharedAppModel].sampleData sampleLength:[AppModel sharedAppModel].sampleLength];
        [self computeFFTForData:data];
    }
    
    
    
}

@end
