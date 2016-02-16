//
//  MoogLadder.m
//  EffectsProcessorDemo
//
//  Created by Aurelius Prochazka on 1/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "MoogLadder.h"

@implementation MoogLadder

- (instancetype)initWithAudioSource:(AKStereoAudio *)audioSource
{
    self = [super init];
    if (self) {
        
        // Instrument Based Control
        _cutoffFrequency = [self createPropertyWithValue:1000 minimum:0 maximum:20000];
        _resonance       = [self createPropertyWithValue:0.5  minimum:0 maximum:0.99];
        _mix             = [self createPropertyWithValue:0    minimum:0 maximum:1.0];
        
        // Instrument Definition
        AKMoogLadder *leftMoogLadder = [AKMoogLadder filterWithInput:audioSource.leftOutput];
        leftMoogLadder.cutoffFrequency = _cutoffFrequency;
        leftMoogLadder.resonance = _resonance;
        [self connect:leftMoogLadder];
        
        AKMoogLadder *rightMoogLadder = [AKMoogLadder filterWithInput:audioSource.rightOutput];
        rightMoogLadder.cutoffFrequency = _cutoffFrequency;
        rightMoogLadder.resonance = _resonance;
        [self connect:rightMoogLadder];
        
        AKMix *leftMix = [[AKMix alloc] initWithInput1:audioSource.leftOutput
                                                input2:leftMoogLadder
                                               balance:_mix];
        
        AKMix *rightMix = [[AKMix alloc] initWithInput1:audioSource.rightOutput
                                                 input2:rightMoogLadder
                                                balance:_mix];
        
        // Output to global effects processing
        _auxilliaryOutput = [AKStereoAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:[[AKStereoAudio alloc] initWithLeftAudio:leftMix
                                                                              rightAudio:rightMix]];
        
        // Reset Inputs
        [self resetParameter:audioSource];
    }
    return self;
}
@end
