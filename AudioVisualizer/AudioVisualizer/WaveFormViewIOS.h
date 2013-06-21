//
//  WaveFormView.h
//  WaveFormTest
//
//  Created by Gyetván András on 7/11/12.
//  Copyright (c) 2012 DroidZONE. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>
#import "WaveSampleProvider.h"
#import "WaveSampleProviderDelegate.h"
#import "AudioSlider.h"

@interface WaveFormViewIOS : UIControl<WaveSampleProviderDelegate>
{
   //this sets the loading spinner when the audio is loading
	UIActivityIndicatorView *progress;
    //this is the data of the waveform i.e. the 'peaks' and 'valleys'
	CGPoint* sampleData;
    //this is the length of the audio sample
	int sampleLength;
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
}

@property CGPoint* sampleData;
@property int sampleLength;

//- (void) openAudio:(NSString *)path;
- (void) openAudioURL:(NSURL *)url;
-(void)printSampleData:(CGPoint *)mySampleData forSampleLength:(int)mySampleLength;

@end
