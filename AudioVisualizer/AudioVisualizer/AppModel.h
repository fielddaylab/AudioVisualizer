//
//  AppModel.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppModel : NSObject

+ (AppModel *)sharedAppModel;

@property CGPoint* sampleData;
@property int sampleLength;
@property float playProgress;
@property float endTime;
@property int lengthInSeconds;

@property NSMutableArray *mutableFourierData;

@end
