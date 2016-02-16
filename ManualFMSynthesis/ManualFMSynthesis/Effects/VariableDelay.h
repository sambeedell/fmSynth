//
//  VariableDelay.h
//  EffectsProcessorDemo
//
//  Created by Aurelius Prochazka on 1/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface VariableDelay : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *delayTime;
@property (nonatomic, strong) AKInstrumentProperty *mix;

@property (readonly) AKStereoAudio *auxilliaryOutput;

- (instancetype)initWithAudioSource:(AKStereoAudio *)audioSource;

@end
