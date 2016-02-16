//
//  Reverb.h
//  EffectsProcessorDemo
//
//  Created by Aurelius Prochazka on 1/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface Reverb : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *reverbFeedback;
@property (nonatomic, strong) AKInstrumentProperty *mix;

- (instancetype)initWithAudioSource:(AKStereoAudio *)audioSource;

@end
