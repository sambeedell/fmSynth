//
//  Reverb.m
//  EffectsProcessorDemo
//
//  Created by Aurelius Prochazka on 1/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Reverb.h"

@implementation Reverb

- (instancetype)initWithAudioSource:(AKStereoAudio *)audioSource
{
    self = [super init];
    if (self) {
        // Instrument Based Control
        _reverbFeedback = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                              minimum:0
                                                              maximum:1.0];
        
        _mix = [[AKInstrumentProperty alloc] initWithValue:0
                                                   minimum:0
                                                   maximum:1.0];
        
        
        AKReverb *reverb;
        reverb = [[AKReverb alloc] initWithStereoInput:audioSource];
        reverb.feedback = _reverbFeedback;
        
        AKMix *leftMix;
        leftMix = [[AKMix alloc] initWithInput1:audioSource.leftOutput
                                         input2:reverb.leftOutput
                                        balance:_mix];
        
        AKMix *rightMix;
        rightMix = [[AKMix alloc] initWithInput1:audioSource.rightOutput
                                          input2:reverb.rightOutput
                                         balance:_mix];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithLeftAudio:leftMix
                                              rightAudio:rightMix];
        [self connect:audio];
        
        // Reset Inputs
        [self resetParameter:audioSource];
    }
    return self;
}
@end
