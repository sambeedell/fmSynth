//
//  VariableDelay.m
//  EffectsProcessorDemo
//
//  Created by Aurelius Prochazka on 1/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "VariableDelay.h"

@implementation VariableDelay

- (instancetype)initWithAudioSource:(AKStereoAudio *)audioSource
{
    self = [super init];
    if (self) {
        
        // Instrument Based Control
        _delayTime = [self createPropertyWithValue:0 minimum:0 maximum:1.0];
        _mix       = [self createPropertyWithValue:0 minimum:0 maximum:0.5];
        
        // Instrument Definition
        AKVariableDelay *leftDelay = [AKVariableDelay delayWithInput:audioSource.leftOutput];
        leftDelay.delayTime = _delayTime;
        [self connect:leftDelay];
        
        AKVariableDelay *rightDelay = [AKVariableDelay delayWithInput:audioSource.rightOutput];
        rightDelay.delayTime = _delayTime;
        [self connect:rightDelay];
        
        AKMix *leftMix = [[AKMix alloc] initWithInput1:audioSource.leftOutput
                                                input2:leftDelay
                                               balance:_mix];
        
        AKMix *rightMix = [[AKMix alloc] initWithInput1:audioSource.rightOutput
                                                 input2:rightDelay
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
