//
//  Operator.h
//  TestSynth
//
//  Created by Sam Beedell on 09/04/2015.
//  Copyright (c) 2015 morekid. All rights reserved.
//

#import "AKFoundation.h"

@interface Operator : AKInstrument
@property (nonatomic, strong) AKOscillator *osc;

@property (nonatomic, strong) AKInstrumentProperty *ratio;
@property (nonatomic, strong) AKInstrumentProperty *fine;
@property (nonatomic, strong) AKInstrumentProperty *amp;
@property (nonatomic, strong) AKLinearADSREnvelope *env;
@property (nonatomic, strong) AKLinearADSREnvelope *masterEnv;
@property (nonatomic, strong) AKInstrumentProperty *masterAmp;

@property (readonly) AKAudio *auxilliaryOutput;
@end

@interface OperatorNote : AKNote
@property (nonatomic, strong) AKNoteProperty *frequency;

@property (nonatomic, strong) AKNoteProperty *waveformA;
@property (nonatomic, strong) AKNoteProperty *waveformB;
@property (nonatomic, strong) AKNoteProperty *waveformC;
@property (nonatomic, strong) AKNoteProperty *waveformD;
@property (nonatomic, strong) AKNoteProperty *_attackA;
@property (nonatomic, strong) AKNoteProperty *_decayA;
@property (nonatomic, strong) AKNoteProperty *_sustainA;
@property (nonatomic, strong) AKNoteProperty *_releaseA;
@property (nonatomic, strong) AKNoteProperty *_attackB;
@property (nonatomic, strong) AKNoteProperty *_decayB;
@property (nonatomic, strong) AKNoteProperty *_sustainB;
@property (nonatomic, strong) AKNoteProperty *_releaseB;
@property (nonatomic, strong) AKNoteProperty *_attackC;
@property (nonatomic, strong) AKNoteProperty *_decayC;
@property (nonatomic, strong) AKNoteProperty *_sustainC;
@property (nonatomic, strong) AKNoteProperty *_releaseC;
@property (nonatomic, strong) AKNoteProperty *_attackD;
@property (nonatomic, strong) AKNoteProperty *_decayD;
@property (nonatomic, strong) AKNoteProperty *_sustainD;
@property (nonatomic, strong) AKNoteProperty *_releaseD;
@property (nonatomic, strong) AKNoteProperty *_attackZ;
@property (nonatomic, strong) AKNoteProperty *_decayZ;
@property (nonatomic, strong) AKNoteProperty *_sustainZ;
@property (nonatomic, strong) AKNoteProperty *_releaseZ;



@end
