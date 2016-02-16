//
//  MoogLadder.h
//  EffectsProcessorDemo
//
//  Created by Aurelius Prochazka on 1/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface MoogLadder : AKInstrument

@property (readonly) AKStereoAudio *auxilliaryOutput;

@property (nonatomic, strong) AKInstrumentProperty *cutoffFrequency;
@property (nonatomic, strong) AKInstrumentProperty *resonance;
@property (nonatomic, strong) AKInstrumentProperty *mix;

- (instancetype)initWithAudioSource:(AKStereoAudio *)audioSource;

@end
