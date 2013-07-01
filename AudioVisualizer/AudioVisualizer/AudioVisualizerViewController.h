//
//  AudioVisualizerViewController.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveSampleProvider.h"
#import "AudioSlider.h"
#include <AVFoundation/AVFoundation.h>
#import "WaveformControl.h"
#import "FreqHistogramControl.h"


@interface AudioVisualizerViewController : UIViewController<WaveSampleProviderDelegate, WaveformControlDelegate, FreqHistogramControlDelegate, UIAlertViewDelegate>{
	WaveSampleProvider *wsp;
	AVPlayer *player;
	NSString *infoString;
	NSString *timeString;
	UIColor *green;
	UIColor *gray;
	UIColor *lightgray;
	UIColor *darkgray;
	UIColor *white;
	UIColor *marker;
    

}
@property CGPoint* sampleData;
@property int sampleLength;

@property (strong, nonatomic) UIButton *withoutBorderButton;

- (void) openAudioURL:(NSURL *)url;
-(void)setPlayHeadToLeftSlider;
- (void) pauseAudio;



@end
