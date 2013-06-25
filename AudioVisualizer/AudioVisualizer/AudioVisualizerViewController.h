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
#import "AudioTint.h"

@interface AudioVisualizerViewController : UIViewController<WaveSampleProviderDelegate>{
    //this is the object that constructs the audio sample
	WaveSampleProvider *wsp;
    //this is the player of the audio
	AVPlayer *player;
    //this is the current time that the audio is at
	float playProgress;
    //this is the 'info' of the song that is extracted off of the file
	NSString *infoString;
    //this is how long the audio file is
	NSString *timeString;
    //colors
	UIColor *green;
	UIColor *gray;
	UIColor *lightgray;
	UIColor *darkgray;
	UIColor *white;
	UIColor *marker;
    
    AudioSlider *leftSlider;
    AudioSlider *rightSlider;
    AudioTint *leftTint;
    AudioTint *rightTint;
    WaveformControl *wf;
    FreqHistogramControl *freq;
}
@property CGPoint* sampleData;
@property int sampleLength;

- (void) openAudioURL:(NSURL *)url;
-(void)setPlayHeadToLeftSlider;
- (void) pauseAudio;

@end
