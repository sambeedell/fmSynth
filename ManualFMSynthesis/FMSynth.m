//
//  FMSynth.m
//  ManualFMSynthesis
//
//  Created by Sam Beedell on 01/20/15.
//
//  Description:
//
//
//
//
//

#import "FMSynth.h"

#define kScalingFactor 1000

@implementation FMSynth

@synthesize A_ADSR, B_ADSR, C_ADSR, D_ADSR, Z_ADSR, pitch, oscillatorA, oscillatorB, oscillatorC, oscillatorD;

- (instancetype)init
{
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ====================================================
        ToneGeneratorNote *note = [[ToneGeneratorNote alloc] init];

        // ENVELOPE DEFINITION ===================================================
        // Note:
        //
        {
            A_ADSR = [AKLinearADSREnvelope envelope];
            [A_ADSR setOptionalAttackDuration :note.A_attack];
            [A_ADSR setOptionalDecayDuration  :note.A_decay];
            [A_ADSR setOptionalSustainLevel   :note.A_sustain];
            [A_ADSR setOptionalReleaseDuration:note.A_release];
            
            B_ADSR = [AKLinearADSREnvelope envelope];
            [B_ADSR setOptionalAttackDuration :note.B_attack];
            [B_ADSR setOptionalDecayDuration  :note.B_decay];
            [B_ADSR setOptionalSustainLevel   :note.B_sustain];
            [B_ADSR setOptionalReleaseDuration:note.B_release];
            
            C_ADSR = [AKLinearADSREnvelope envelope];
            [C_ADSR setOptionalAttackDuration :note.C_attack];
            [C_ADSR setOptionalDecayDuration  :note.C_decay];
            [C_ADSR setOptionalSustainLevel   :note.C_sustain];
            [C_ADSR setOptionalReleaseDuration:note.C_release];
            
            D_ADSR = [AKLinearADSREnvelope envelope];
            [D_ADSR setOptionalAttackDuration :note.D_attack];
            [D_ADSR setOptionalDecayDuration  :note.D_decay];
            [D_ADSR setOptionalSustainLevel   :note.D_sustain];
            [D_ADSR setOptionalReleaseDuration:note.D_release];
            
            Z_ADSR = [AKADSREnvelope envelope];
            [Z_ADSR setOptionalAttackDuration :note.Z_attack];
            [Z_ADSR setOptionalDecayDuration  :note.Z_decay];
            [Z_ADSR setOptionalSustainLevel   :note.Z_sustain];
            [Z_ADSR setOptionalReleaseDuration:note.Z_release];
        }
        
        // INSTRUMENT PROPERTIES =================================================
        // Note: Output oscillator must have default amplitude value set to 0.5,
        //       therefore this is dependant on the routing algorithm.
        //
        {
            // ========================== OPERATOR A =================================
            
            _oscA_ratio = [[AKInstrumentProperty alloc] initWithValue:1
                                                              minimum:1
                                                              maximum:9];
//            [self addProperty:_oscA_ratio];
            
            _oscA_fine = [[AKInstrumentProperty alloc] initWithValue:0
                                                             minimum:0
                                                             maximum:note.frequency.value]; //ensures the highest value is a semitone above
//            [self addProperty:_oscA_fine];
            
            _oscA_amp = [[AKInstrumentProperty alloc] initWithValue:1.0
                                                            minimum:0
                                                            maximum:1];
//            [self addProperty:_oscA_amp];
            
            // ========================== OPERATOR B =================================
            _oscB_ratio = [[AKInstrumentProperty alloc] initWithValue:1
                                                              minimum:1
                                                              maximum:9];
//            [self addProperty:_oscB_ratio];
            
            _oscB_fine = [[AKInstrumentProperty alloc] initWithValue:0
                                                             minimum:0
                                                             maximum:note.frequency.value]; //ensures the highest value is a semitone above
//            [self addProperty:_oscB_fine];
            
            _oscB_amp = [[AKInstrumentProperty alloc] initWithValue:0.0
                                                            minimum:0
                                                            maximum:1];
//            [self addProperty:_oscB_amp];
            
            // ========================== OPERATOR C =================================
            _oscC_ratio = [[AKInstrumentProperty alloc] initWithValue:1
                                                              minimum:1
                                                              maximum:9];
//            [self addProperty:_oscC_ratio];
            
            _oscC_fine = [[AKInstrumentProperty alloc] initWithValue:0
                                                             minimum:0
                                                             maximum:note.frequency.value]; //ensures the highest value is a semitone above
//            [self addProperty:_oscC_fine];
            
            _oscC_amp = [[AKInstrumentProperty alloc] initWithValue:0.0
                                                            minimum:0
                                                            maximum:1];
//            [self addProperty:_oscC_amp];
            
            // ========================== OPERATOR D =================================
            _oscD_ratio = [[AKInstrumentProperty alloc] initWithValue:1
                                                              minimum:1
                                                              maximum:9];
//            [self addProperty:_oscD_ratio];
            
            _oscD_fine = [[AKInstrumentProperty alloc] initWithValue:0
                                                             minimum:0
                                                             maximum:note.frequency.value]; //ensures the highest value is a semitone above
//            [self addProperty:_oscD_fine];
            
            _oscD_amp = [[AKInstrumentProperty alloc] initWithValue:0.0
                                                            minimum:0
                                                            maximum:1];
//            [self addProperty:_oscD_amp];
            
            // ========================== FEEDBACK ==================================
            _feedback = [[AKInstrumentProperty alloc] initWithValue:0
                                                            minimum:0
                                                            maximum:5];
//            [self addProperty:_feedback];
            
            // ========================== PITCH    ==================================
            _pitchMix = [[AKInstrumentProperty alloc] initWithValue:0
                                                            minimum:0
                                                            maximum:note.frequency.value];
//            [self addProperty:_pitchMix];
            
//            _pitchInvert  = [[AKInstrumentProperty alloc] initWithValue:1 minimum:(-1) maximum:1];
//            _pitchInvert2 = [[AKInstrumentProperty alloc] initWithValue:0 minimum:0 maximum:1];
//            [self addProperty:_pitchInvert];
//            [self addProperty:_pitchInvert2];
            
            // ========================== ALGORITHM SELECTION =======================
//            _algorithm = [[AKInstrumentProperty alloc] initWithValue:2
//                                                            minimum:1
//                                                            maximum:10];
//            [self addProperty:_algorithm];
            
            // ========================== MASTER    ==================================
            _master_amp = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                              minimum:0
                                                              maximum:1];
        
        }
        
        // INSTRUMENT DEFINITION =================================================
        pitch = note.frequency;
        
        // ROUTING ALGORITHM =====================================================
//        [self setupRoutingAlgorithm:algorithm];
        // ====================== ROUTING ALGORITHM 1 ============================
        //                        D -> C -> B -> A ->
        // -----------------------------------------------------------------------
        oscillatorD = [AKOscillator oscillator];
        oscillatorD.frequency = [[pitch scaledBy:[ _oscD_ratio floor]]
                                 plus:  _oscD_fine        ];
        oscillatorD.amplitude = [[D_ADSR scaledBy: _oscD_amp] scaledBy: akp(kScalingFactor)]; //CHECK THIS SCALING FACTOR!!!!!
        //            [self connect:oscillatorD];
        
        oscillatorC = [AKOscillator oscillator];
        oscillatorC.frequency = [[[pitch scaledBy:[_oscC_ratio floor]]
                                  plus: _oscC_fine        ]
                                 plus: oscillatorD       ];
        oscillatorC.amplitude = [[C_ADSR scaledBy:_oscC_amp ] scaledBy:akp(kScalingFactor)];
        //            [self connect:oscillatorC];
        
        oscillatorB = [AKOscillator oscillator];
        oscillatorB.frequency = [[[pitch scaledBy:[_oscB_ratio floor]]
                                  plus: _oscB_fine        ]
                                 plus: oscillatorC       ];
        oscillatorB.amplitude = [[B_ADSR scaledBy:_oscB_amp ] scaledBy:akp(kScalingFactor)];
        //            [self connect:oscillatorB];
        
        oscillatorA = [AKVCOscillator oscillator];
        oscillatorA.frequency = [[[pitch scaledBy:[_oscA_ratio floor]]
                                  plus: _oscA_fine        ]
                                 plus: oscillatorB       ];
        oscillatorA.amplitude = [[A_ADSR scaledBy:_oscA_amp] scaledBy:akp(0.15)];
        
        oscillatorA.waveformType = note.waveform;
//        [AKVCOscillator waveformTypeForSquare].value;
//        oscillatorA.waveform = [AKTable standardSawtoothWave];
        
        // OUTPUT ================================================================
//        AKAudioOutput *output = [[AKAudioOutput alloc] initWithAudioSource:oscillatorA];
//        [self connect:output];
        [self setAudioOutput:[oscillatorA scaledBy:[Z_ADSR scaledBy:_master_amp]]];
        
    }
    return self;
}

//- (void)changeWaveform:(int)A B:(int)B C:(int)C D:(int)D
//{
//    [oscillatorA setOptionalFunctionTable:_waveform];
//    NSLog(@"here");
//
//}

- (void)setupRoutingAlgorithm:(int)algorithm
{
    switch (algorithm) {
        case 1:
        {
            
        }
            NSLog(@"ere we go : 1");
            break;
        case 2:
        {

        }
            NSLog(@"2");
            break;
            
        default:
            break;
    }
    }


//- (void)setupPitchEnv:(BOOL)invert
//{
//        [oscillatorA setOptionalFunctionTable:_waveform];
//        oscillatorA.waveformType = [AKVCOscillator waveformTypeForSquare];
//        oscillatorA.functionTable = [AKManager standardSawtoothWave];

//    P_ADSR = [AKADSREnvelope envelope];
//    if (invert == YES) {
//        P_ADSR = [[P_ADSR scaledBy:akp(-1)] plus:akp(1)];
//    }
//}

@end

// -----------------------------------------------------------------------------
#  pragma mark - Tone Generator Note
// -----------------------------------------------------------------------------

@implementation ToneGeneratorNote

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // NOTE PROPETIES =======================================================
        // Note:
        //
        _frequency = [self createPropertyWithValue:440 minimum:220 maximum:1000];
        
//        _waveform  = [AKTable standardSawtoothWave];
        _waveform = [self createPropertyWithValue:[AKVCOscillator waveformTypeForTriangle].value minimum:0 maximum:100];

        
        // ENVELOPE PROPETIES ===================================================
        // Note:
        //
        {
            _A_attack   = [self createPropertyWithValue:0.1 minimum:0.1  maximum:1.0];
            _A_decay    = [self createPropertyWithValue:0.1  minimum:0.0  maximum:1.0];
            _A_sustain  = [self createPropertyWithValue:2.0  minimum:0.01 maximum:2.0];
            _A_release  = [self createPropertyWithValue:0.2  minimum:0.0  maximum:1.0];
            
            _B_attack   = [[AKNoteProperty alloc] initWithValue:0.1 minimum:0.10 maximum:1.0];
            _B_decay    = [[AKNoteProperty alloc] initWithValue:0.1  minimum:0.00 maximum:1.0];
            _B_sustain  = [[AKNoteProperty alloc] initWithValue:1.0  minimum:0.01 maximum:1.0];
            _B_release  = [[AKNoteProperty alloc] initWithValue:0.2  minimum:0.00 maximum:1.0];
            
            [self addProperty:_B_attack];
            [self addProperty:_B_decay];
            [self addProperty:_B_sustain];
            [self addProperty:_B_release];
            
            _C_attack   = [[AKNoteProperty alloc] initWithValue:0.1 minimum:0.10 maximum:1.0];
            _C_decay    = [[AKNoteProperty alloc] initWithValue:0.1  minimum:0.00 maximum:1.0];
            _C_sustain  = [[AKNoteProperty alloc] initWithValue:1.0  minimum:0.01 maximum:1.0];
            _C_release  = [[AKNoteProperty alloc] initWithValue:0.2  minimum:0.00 maximum:1.0];
            
            [self addProperty:_C_attack];
            [self addProperty:_C_decay];
            [self addProperty:_C_sustain];
            [self addProperty:_C_release];
            
            _D_attack   = [[AKNoteProperty alloc] initWithValue:0.1 minimum:0.10 maximum:1.0];
            _D_decay    = [[AKNoteProperty alloc] initWithValue:0.1  minimum:0.00 maximum:1.0];
            _D_sustain  = [[AKNoteProperty alloc] initWithValue:1.0  minimum:0.01 maximum:1.0];
            _D_release  = [[AKNoteProperty alloc] initWithValue:0.2  minimum:0.00 maximum:1.0];
            
            [self addProperty:_D_attack];
            [self addProperty:_D_decay];
            [self addProperty:_D_sustain];
            [self addProperty:_D_release];
        
            _Z_attack   = [self createPropertyWithValue:0.1  minimum:0.10 maximum:1.0]; 
            _Z_decay    = [self createPropertyWithValue:0.1  minimum:0.00 maximum:1.0];
            _Z_sustain  = [self createPropertyWithValue:1.0  minimum:0.01 maximum:1.0];
            _Z_release  = [self createPropertyWithValue:0.2  minimum:0.00 maximum:1.0];
            
            _pitchInvert_plus     = [[AKNoteProperty alloc] initWithValue:0 minimum:-1 maximum:1];
            _pitchInvert_multiply = [[AKNoteProperty alloc] initWithValue:1 minimum:-1 maximum:1];
            
            [self addProperty:_pitchInvert_multiply];
            [self addProperty:_pitchInvert_plus];
        }
        
    }
    return self;
}

- (instancetype)initFrequency:(float)frequency plus:(float)plus multiply:(float)multiply //waveform:(float)waveform
{
    self = [self init];
    if (self) {
        _frequency.value = frequency;
        _pitchInvert_plus.value = plus;
        _pitchInvert_multiply.value = multiply;
//        _waveform.value = waveform;
        
    }
    return self;
}



@end
