//
//  AppModel.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AppModel.h"

@implementation AppModel

@synthesize sampleData;
@synthesize sampleLength;
@synthesize playProgress;
@synthesize endTime;
@synthesize mutableFourierData;
@synthesize lengthInSeconds;

+ (id)sharedAppModel
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}



@end
