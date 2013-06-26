//
//  WaveformControl.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaveformControl;

@protocol WaveformControlDelegate <NSObject>

-(void)waveformControl:(WaveformControl *)waveform wasTouched:(NSSet *)touches;
-(void)clipOver;

@end

@interface WaveformControl : UIControl

@property (assign) id<WaveformControlDelegate> delegate;

@end
