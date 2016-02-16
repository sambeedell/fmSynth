//
//  Operator.m
//  ManualFMSynthesis
//
//  Created by Sam Beedell on 01/20/15.
//
//  Description:
//  This class contains all the associated features required for an FM operator
//  Using AudioKit: http://audiokit.io
//
//

#import "Operator.h"

@implementation Operator

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note
        OperatorNote *note = [[OperatorNote alloc] init];
        
        // Instrument Properties
        _ratio = [self createPropertyWithValue:1  minimum: 1 maximum:9];
        _fine  = [self createPropertyWithValue:0  minimum:-1 maximum:1]; // MAX = 1 OCTAVE UP
        _amp   = [self createPropertyWithValue:0  minimum: 0 maximum:2];
        
        // Master Operations
        _masterAmp = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
        _masterEnv = [AKLinearADSREnvelope envelope];
        _masterEnv.attackDuration  = note._attackZ;
        _masterEnv.decayDuration   = note._decayZ;
        _masterEnv.sustainLevel    = note._sustainZ;
        _masterEnv.releaseDuration = note._releaseZ;
        
        // Envelope
        _env = [AKLinearADSREnvelope envelope];

        // Oscillator
        _osc = [AKOscillator oscillator];
        _osc.frequency = [note.frequency scaledBy:[[_ratio floor] plus:_fine]];
        _osc.amplitude = [_env scaledBy:_amp];
        
        
        // Output to global effects processing
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:_osc];
    }
    return self;
}

@end

@implementation OperatorNote // Routed in the conductor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:440 minimum:20 maximum:20000];
//        self.duration.value = 1; // Used for testing
        
        // Waveform Properties
//        _waveformA = [self createPropertyWithValue:[AKVCOscillator waveformTypeForTriangle].value minimum:0 maximum:100];
//        _waveformB = [self createPropertyWithValue:[AKVCOscillator waveformTypeForTriangle].value minimum:0 maximum:100];
//        _waveformC = [self createPropertyWithValue:[AKVCOscillator waveformTypeForTriangle].value minimum:0 maximum:100];
//        _waveformD = [self createPropertyWithValue:[AKVCOscillator waveformTypeForTriangle].value minimum:0 maximum:100];
        
        // Envelope Properties
        // Not the best way to initialise these properties as it isnt parameterisable
        __attackA  = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __decayA   = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __sustainA = [self createPropertyWithValue:0.5 minimum:0.01 maximum:2];
        __releaseA = [self createPropertyWithValue:1.0 minimum:0.01 maximum:1];
        
        __attackB  = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __decayB   = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __sustainB = [self createPropertyWithValue:0.5 minimum:0.01 maximum:2];
        __releaseB = [self createPropertyWithValue:1.0 minimum:0.01 maximum:1];

        __attackC  = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __decayC   = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __sustainC = [self createPropertyWithValue:0.5 minimum:0.01 maximum:2];
        __releaseC = [self createPropertyWithValue:1.0 minimum:0.01 maximum:1];
        
        __attackD  = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __decayD   = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __sustainD = [self createPropertyWithValue:0.5 minimum:0.01 maximum:2];
        __releaseD = [self createPropertyWithValue:1.0 minimum:0.01 maximum:1];
        
        __attackZ  = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __decayZ   = [self createPropertyWithValue:0.1 minimum:0.01 maximum:1];
        __sustainZ = [self createPropertyWithValue:0.5 minimum:0.01 maximum:2];
        __releaseZ = [self createPropertyWithValue:1.0 minimum:0.01 maximum:1];
    }
    return self;
}



@end

