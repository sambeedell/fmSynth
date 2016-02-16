//
//  EffectsProcessor.m
//  ManualFMSynthesis
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//  Adapted by Sam Beedell
//
//  Description:
//  This class contains the signal processing obejcts used for this synthesiser
//  Using AudioKit: http://audiokit.io
//
//

#import "EffectsProcessor.h"

@implementation EffectsProcessor

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT CONTROL ==================================================
//        _cutoff    = [self createPropertyWithValue:10   minimum:20 maximum:20000];
//        _resonance = [self createPropertyWithValue:0.5   minimum:0  maximum:1.0];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKReverb *eff = [[AKReverb alloc] initWithInput:audioSource feedback:akp(0.7) cutoffFrequency:akp(4000) ];
        
//        AKMoogLadder *eff = [[AKMoogLadder alloc] initWithInput:audioSource cutoffFrequency:akp(100) resonance:akp(0.5)]; // Doesnt work?
        
//        AKMultitapDelay *eff = [AKMultitapDelay delayWithInput:audioSource firstEchoTime:akp(0.2) firstEchoGain:akp(0.5)]; // Only a single delay, no feedback?
        
//        AKHighPassFilter *eff = [[AKHighPassFilter alloc] initWithInput:audioSource cutoffFrequency:akp(10000)]; // Doesn't work?
        
        
        // AUDIO OUTPUT ========================================================
//        AKAudioOutput *audio;
//        audio = [[AKAudioOutput alloc] initWithAudioSource:audioSource];
//        [self connect:audio]; //Doesnt seem to help?
//
//        [self assignOutput:_auxilliaryOutput to:eff];
        [self setAudioOutput:eff];
 
        // RESET INPUTS ========================================================
        [self resetParameter:audioSource];
    }
    return self;
}

@end
