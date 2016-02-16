//
//  FMSynth.h
//  ManualFMSynthesis
//
//  Created by Sam Beedell on 01/20/15.
//
//

#import "AKFoundation.h"

@interface FMSynth : AKInstrument
//{
//    @public
//    float pitchInvert_plus;
//    float pitchInvert_multiply;
//}

// ENVELOPE DEFINITION
@property AKLinearADSREnvelope *A_ADSR;
@property AKLinearADSREnvelope *B_ADSR;
@property AKLinearADSREnvelope *C_ADSR;
@property AKLinearADSREnvelope *D_ADSR;
@property AKADSREnvelope       *Z_ADSR; //master envelope

@property (nonatomic, strong) AKNoteProperty *pitch;

// INSTRUMENT PROPERTIES
// A
@property (nonatomic, strong) AKVCOscillator *oscillatorA;
@property AKInstrumentProperty *oscA_ratio;
@property AKInstrumentProperty *oscA_fine;
@property AKInstrumentProperty *oscA_amp;
// B
@property (nonatomic, strong) AKOscillator *oscillatorB;
@property AKInstrumentProperty *oscB_ratio;
@property AKInstrumentProperty *oscB_fine;
@property AKInstrumentProperty *oscB_amp;
// C
@property (nonatomic, strong) AKOscillator *oscillatorC;
@property AKInstrumentProperty *oscC_ratio;
@property AKInstrumentProperty *oscC_fine;
@property AKInstrumentProperty *oscC_amp;
// D
@property (nonatomic, strong) AKOscillator *oscillatorD;
@property AKInstrumentProperty *oscD_ratio;
@property AKInstrumentProperty *oscD_fine;
@property AKInstrumentProperty *oscD_amp;
//Feedback
@property AKInstrumentProperty *feedback;

@property AKInstrumentProperty *pitchMix;
@property AKInstrumentProperty *algorithm;

@property AKInstrumentProperty *master_amp;


@property (nonatomic, strong) AKTable *waveformTest;

//- (instancetype)init:(int)algorithm;

//- (void)changeWaveform:(int)A B:(int)B C:(int)C D:(int)D;
//- (void)setupPitchEnv:(BOOL)invert;
- (void)setupRoutingAlgorithm:(int)algorithm;

@end

// -----------------------------------------------------------------------------
#  pragma mark - Tone Generator Note
// -----------------------------------------------------------------------------

@interface ToneGeneratorNote : AKNote
//just the frequency is an AKNoteProperty because it is not shared and is dependant on the key pressed by the user
@property (nonatomic, strong) AKNoteProperty *frequency;
//@property (nonatomic, strong) AKFunctionTable *waveform;

// ENVELOPE PROPERTIES
@property (nonatomic, strong) AKNoteProperty *A_attack;
@property (nonatomic, strong) AKNoteProperty *A_decay;
@property (nonatomic, strong) AKNoteProperty *A_sustain;
@property (nonatomic, strong) AKNoteProperty *A_release;

@property (nonatomic, strong) AKNoteProperty *B_attack;
@property (nonatomic, strong) AKNoteProperty *B_decay;
@property (nonatomic, strong) AKNoteProperty *B_sustain;
@property (nonatomic, strong) AKNoteProperty *B_release;

@property (nonatomic, strong) AKNoteProperty *C_attack;
@property (nonatomic, strong) AKNoteProperty *C_decay;
@property (nonatomic, strong) AKNoteProperty *C_sustain;
@property (nonatomic, strong) AKNoteProperty *C_release;

@property (nonatomic, strong) AKNoteProperty *D_attack;
@property (nonatomic, strong) AKNoteProperty *D_decay;
@property (nonatomic, strong) AKNoteProperty *D_sustain;
@property (nonatomic, strong) AKNoteProperty *D_release;

@property (nonatomic, strong) AKNoteProperty *Z_attack;
@property (nonatomic, strong) AKNoteProperty *Z_decay;
@property (nonatomic, strong) AKNoteProperty *Z_sustain;
@property (nonatomic, strong) AKNoteProperty *Z_release;
@property (nonatomic, strong) AKNoteProperty *pitchInvert_plus;
@property (nonatomic, strong) AKNoteProperty *pitchInvert_multiply;


@property (nonatomic, strong) AKNoteProperty *waveform;


//- (instancetype)initFrequency:(float)frequency;
- (instancetype)initFrequency:(float)frequency plus:(float)plus multiply:(float)multiply;
//- (instancetype)initFrequency:(float)frequency plus:(float)plus multiply:(float)multiply waveform:(float)waveform;

@end