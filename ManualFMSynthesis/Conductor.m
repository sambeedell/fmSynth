//
//  Conductor.m
//  ManualFMSynthesis
//
//  Created by Sam Beedell on 01/20/15.
//
//  Description:
//  This class is the model of the system. It communicates directly with the instrumnet class and view controller.
//  The note and instrumnet properties are controlled here.
//  Using AudioKit: http://audiokit.io
//
//

#import "Conductor.h"
#import "AKTools.h"
#import "FMSynth.h"
#import "Operator.h"
#import "EffectsProcessor.h"

#define kNumKeys 17
#define kScalingFactor 1000
#define kNumVoices 5

@implementation Conductor
{
    // Operator object
    Operator *opA;
    Operator *opB;
    Operator *opC;
    Operator *opD;
    // Operator Note object
    OperatorNote *note;
    // Effects class object
    EffectsProcessor *effects;

    // Array used to update the frequencies available
    NSArray *frequencies;
    NSMutableArray *currentFrequencies;
    // Dictionary used to store the currently playing 'note' objects
    NSMutableDictionary *currentNotes;
    // Dictionary used to store the states of the UI objects to communicate with the operator instances
    NSMutableDictionary *currentSettings;
    // Used to store the AKTable waveforms available
    NSArray *waveforms;
    // Used to check if a note is playing
    BOOL isPlaying;
}

#pragma mark Initialisation

//-----------------------------------------------------------------------------
//	init function
//-----------------------------------------------------------------------------
- (instancetype)init
{
    self = [super init];
    if (self) {
        // Read from the .txt file containing all audible frequencies, seperated by an return
        NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"frequencies" ofType: @"txt"] usedEncoding:nil error:nil];
        frequencies = [content componentsSeparatedByString:@"\n"];
        currentFrequencies = [NSMutableArray arrayWithCapacity:kNumKeys];
        for (int i = 0; i < kNumKeys; i++) {
            // Populate the currentFrequencies array
            [currentFrequencies insertObject:frequencies[i] atIndex:i];
        }
        
        // Initialise the dictionaries
        currentNotes    = [NSMutableDictionary dictionaryWithCapacity:kNumVoices]; // this can be used to limit to voices of the keyboard thus saving processing power
        currentSettings = [NSMutableDictionary dictionary];
        
        // The standard square wave goes from -1 to 1 producing a clicking sound
        AKTable *square = [AKTable standardSquareWave];
        // but scaling to just below 1 works fine
        // [square scaleBy:0.99999]; // This breaks the system
        AKTable *triangle = [AKTable standardTriangleWave];
        AKTable *sawtooth = [AKTable standardSawtoothWave];
        //AKTable *sine = [AKTable standardSineWave]; // This also breaks the system
        waveforms = @[@0, triangle, square, sawtooth]; // '@0' (index 0) should be *sine

        // Init variables
        isPlaying = NO;
        //Update octave range of the virtual keyboard
        [self octaveUpdate:3];
        // Init the 'note' object
        note = [[OperatorNote alloc] init];
    }
    return self;
}

#pragma mark Routing Algorithms

//-----------------------------------------------------------------------------
//	Routing Algorithms function
//-----------------------------------------------------------------------------
- (void)setupRoutingAlgorithms:(int)algorithm
{
    NSLog(@"Loading algorithms...");
    // Re-initialise the operator objects
    opA = [[Operator alloc] init];
    opB = [[Operator alloc] init];
    opC = [[Operator alloc] init];
    opD = [[Operator alloc] init];
    
    //Envelopes
    opA.env.attackDuration  = note._attackA;
    opA.env.decayDuration   = note._decayA;
    opA.env.sustainLevel    = note._sustainA;
    opA.env.releaseDuration = note._releaseA;
    
    opB.env.attackDuration  = note._attackB;
    opB.env.decayDuration   = note._decayB;
    opB.env.sustainLevel    = note._sustainB;
    opB.env.releaseDuration = note._releaseB;
    
    opC.env.attackDuration  = note._attackC;
    opC.env.decayDuration   = note._decayC;
    opC.env.sustainLevel    = note._sustainC;
    opC.env.releaseDuration = note._releaseC;
    
    opD.env.attackDuration  = note._attackD;
    opD.env.decayDuration   = note._decayD;
    opD.env.sustainLevel    = note._sustainD;
    opD.env.releaseDuration = note._releaseD;
    
    //Waveforms Test
//    opB.osc.waveform = [AKTable standardTriangleWave];
    
    
    // BUG
    // The algorithm switching bug occurs if you press to switch twice, no sound is produced until you press a key then press the algorithm switch button ONCE.
    
    
    switch (algorithm) {
        case 1: {
            // ====================== ROUTING ALGORITHM 1 ============================
            //                        D -> C -> B -> A ->
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
           
            opC.osc.frequency = [opC.osc.frequency plus:opD.osc];
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opB.osc.frequency = [opB.osc.frequency plus:opC.osc];
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opA.osc.frequency = [opA.osc.frequency plus:opB.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
//            opA.osc.frequency = [opA.osc.frequency plus:opA.osc]; // self-oscillation -> breaks the system
            
//            effects = [[EffectsProcessor alloc] initWithAudioSource:opA.auxilliaryOutput];
            
            [opA setAudioOutput:[opA.osc scaledBy:[opA.masterEnv scaledBy: opA.masterAmp]]];
            
            
            NSLog(@"1");
        }
            break;
        case 2: {
            // ====================== ROUTING ALGORITHM 2 ============================
            //                        D -> B -> A ->
            //                          C -^
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opB.osc.frequency = [[opB.osc.frequency plus:opD.osc] plus:opC.osc];
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opA.osc.frequency = [opA.osc.frequency plus:opB.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            effects = [[EffectsProcessor alloc] initWithAudioSource:opA.auxilliaryOutput];
            [opA setAudioOutput:[opA.osc scaledBy:[opA.masterEnv scaledBy: opA.masterAmp] ]];
            NSLog(@"2");
        }
            break;
        case 3: {
            // ====================== ROUTING ALGORITHM 3 ============================
            //                             D -> A ->
            //                          C -> B -^
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opB.osc.frequency = [opB.osc.frequency plus:opC.osc];
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opA.osc.frequency = [[opA.osc.frequency plus:opB.osc] plus:opB.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            effects = [[EffectsProcessor alloc] initWithAudioSource:opA.auxilliaryOutput];
            [opA setAudioOutput:[opA.osc scaledBy:[opA.masterEnv scaledBy: opA.masterAmp] ]];
            NSLog(@"3");
            
        }
            break;
        case 4: {
            // ====================== ROUTING ALGORITHM 4 ============================
            //                             B -> A ->
            //                          D -> C -^
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.frequency = [opC.osc.frequency plus:opD.osc];
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opA.osc.frequency = [[opA.osc.frequency plus:opB.osc] plus:opC.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            effects = [[EffectsProcessor alloc] initWithAudioSource:opA.auxilliaryOutput];
            [opA setAudioOutput:[opA.osc scaledBy:[opA.masterEnv scaledBy: opA.masterAmp] ]];
            NSLog(@"4");
            
        }
            break;
        case 5: {
            // ====================== ROUTING ALGORITHM 5 ============================
            //                             D -> C ->
            //                             B -> A ->
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.frequency = [opC.osc.frequency plus:opD.osc];
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(0.25)];
            opC.amp.value = 0.5;
            
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opA.osc.frequency = [opA.osc.frequency plus:opB.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            effects = [[EffectsProcessor alloc] initWithAudioSource:[opC.auxilliaryOutput plus:opA.auxilliaryOutput]];
            
            AKSum *sum = [[AKSum alloc] initWithFirstInput:opC.osc secondInput:opA.osc];
            [opA setAudioOutput:[sum scaledBy:[opA.masterEnv scaledBy: opA.masterAmp] ]];
            NSLog(@"5");
            
        }
            break;
        case 6: {
            // ====================== ROUTING ALGORITHM 6 ============================
            //                             D -> C ->
            //                              \-> B ->
            //                               \> A ->
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.frequency = [opC.osc.frequency plus:opD.osc];
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(0.25)];
            opC.amp.value = 0.5;
            
            opB.osc.frequency = [opB.osc.frequency plus:opD.osc];
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(0.25)];
            opB.amp.value = 0.5;
            
            opA.osc.frequency = [opA.osc.frequency plus:opD.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            AKSum *sum = [[AKSum alloc] initWithInputs:opA.osc, opB.osc, opC.osc, nil];
            [opA setAudioOutput:[sum scaledBy:[opA.masterEnv scaledBy: opA.masterAmp]]];
            NSLog(@"6");
            
        }
            break;
        case 7: {
            // ====================== ROUTING ALGORITHM 7 ============================
            //                             D -> C ->
            //                                  B ->
            //                                  A ->
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.frequency = [opC.osc.frequency plus:opD.osc];
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(0.25)];
            opC.amp.value = 0.5;
            
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(0.25)];
            opB.amp.value = 0.5;
            
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            AKSum *sum = [[AKSum alloc] initWithInputs:opA.osc, opB.osc, opC.osc, nil];
            
            [opA setAudioOutput:[sum scaledBy:[opA.masterEnv scaledBy: opA.masterAmp] ]];
            NSLog(@"7");
            
        }
            break;
        case 8: {
            // ====================== ROUTING ALGORITHM 8 ============================
            //                              D ->
            //                              C ->
            //                              B ->
            //                              A ->
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(0.25)];
            opD.amp.value = 0.5;
            
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(0.25)];
            opC.amp.value = 0.5;
            
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(0.25)];
            opB.amp.value = 0.5;
            
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
//            AKSum *sum = [[AKSum alloc] initWithInputs:opA.osc, opB.osc, opC.osc, opD.osc, nil];
//            [opA setAudioOutput:[sum scaledBy:[opA.masterEnv scaledBy: opA.masterAmp] ]];
            [opA setAudioOutput:opA.osc];
            [opB setAudioOutput:opB.osc];
            [opC setAudioOutput:opC.osc];
            [opD setAudioOutput:opD.osc];
            
            
            NSLog(@"8");
            
        }
            break;
            
        default:{
            // ====================== ROUTING ALGORITHM 1 ============================
            //                        D -> C -> B -> A ->
            // -----------------------------------------------------------------------
            opD.osc.amplitude = [opD.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opC.osc.frequency = [opC.osc.frequency plus:opD.osc];
            opC.osc.amplitude = [opC.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opB.osc.frequency = [opB.osc.frequency plus:opC.osc];
            opB.osc.amplitude = [opB.osc.amplitude scaledBy: akp(kScalingFactor)];
            
            opA.osc.frequency = [opA.osc.frequency plus:opB.osc];
            opA.osc.amplitude = [opA.osc.amplitude scaledBy: akp(0.25)];
            opA.amp.value = 0.5;
            
            [opA setAudioOutput:opA.osc];
        }
            break;
    }

    //Add each operator to the orchestra
    [AKOrchestra addInstrument:opA];
    [AKOrchestra addInstrument:opB];
    [AKOrchestra addInstrument:opC];
    [AKOrchestra addInstrument:opD];
    
    // Init the effects class, this shouldn't really go here...
    effects = [[EffectsProcessor alloc] initWithAudioSource:opA.auxilliaryOutput];
    [AKOrchestra addInstrument:effects];
//    [effects start]; //Mute the effects for now
    
    NSLog(@"Done!");
    
    // Align the instrument with the current UI settings
    [self instrumentUpdate];
}

#pragma mark Update settings from UI

//-----------------------------------------------------------------------------
//	octave range
//-----------------------------------------------------------------------------
- (void)octaveUpdate:(int)octave
{
    // Update the octave range of the virtual keyboard
    int start = octave * 12;
    for (int i = 0; i < kNumKeys; i++) {
        [currentFrequencies replaceObjectAtIndex:i withObject:frequencies[start+i]];
    }
}

//-----------------------------------------------------------------------------
//	waveform update
//
//  Not quite working yet... Firstly the waveforms array does not hold the correct
//  waveforms (see 'init' function) and I don't think that 'updateInstrument:'
//  method works?
//-----------------------------------------------------------------------------
- (void)waveformUpdate:(NSArray *)updateWaveform
{
    NSInteger value    = [[updateWaveform objectAtIndex:1] integerValue];
    switch ([[updateWaveform objectAtIndex:0] integerValue])
    {
        case 1:     // @"A"
        {
            opA.osc.waveform = waveforms[value];
            [AKOrchestra updateInstrument:opA];
        }
            break;
        case 2:     // @"B"
        {
            opB.osc.waveform = waveforms[value];
            [AKOrchestra updateInstrument:opB];
        }
            break;
        case 3:     // @"C"
        {
            opC.osc.waveform = waveforms[value];
            [AKOrchestra updateInstrument:opC];
        }
            break;
        case 4:     // @"D"
        {
            opD.osc.waveform = waveforms[value];
            [AKOrchestra updateInstrument:opD];
        }
            break;
        default:
            break;
    }
    
    if (isPlaying) [opA restart]; // need to check if a key is pressed to restart the instrument

}

//-----------------------------------------------------------------------------
//  update frequency parameters - fine and ratio
//-----------------------------------------------------------------------------
- (void)frequencyUpdate:(int)index ratio:(float)ratio fine:(float)fine
{
    switch (index) {
        case 1: //Operator A
            [currentSettings setObject:[NSNumber numberWithFloat:ratio] forKey:@"opA.ratio"];
            [currentSettings setObject:[NSNumber numberWithFloat:fine]  forKey:@"opA.fine"];
            break;
        case 2: //Operator B
            [currentSettings setObject:[NSNumber numberWithFloat:ratio] forKey:@"opB.ratio"];
            [currentSettings setObject:[NSNumber numberWithFloat:fine]  forKey:@"opB.fine"];
            break;
        case 3: //Operator C
            [currentSettings setObject:[NSNumber numberWithFloat:ratio] forKey:@"opC.ratio"];
            [currentSettings setObject:[NSNumber numberWithFloat:fine]  forKey:@"opC.fine"];
            break;
        case 4: //Operator D
            [currentSettings setObject:[NSNumber numberWithFloat:ratio] forKey:@"opD.ratio"];
            [currentSettings setObject:[NSNumber numberWithFloat:fine]  forKey:@"opD.fine"];
            break;
            
        default:
            break;
    }
    [self instrumentUpdate];
}

//-----------------------------------------------------------------------------
//  update amplitude parameters
//-----------------------------------------------------------------------------
- (void)amplitudeUpdate:(int)index value:(float)sender
{
    switch (index) {
        case 1: //Operator A
            [currentSettings setObject:[NSNumber numberWithFloat:sender] forKey:@"opA.amp"];
            break;
        case 2: //Operator B
            [currentSettings setObject:[NSNumber numberWithFloat:sender] forKey:@"opB.amp"];
            break;
        case 3: //Operator C
            [currentSettings setObject:[NSNumber numberWithFloat:sender] forKey:@"opC.amp"];
            break;
        case 4: //Operator D
            [currentSettings setObject:[NSNumber numberWithFloat:sender] forKey:@"opD.amp"];
            break;
        case 5: //Master
            opA.masterAmp.value = sender;
            break;
        default:
            break;
    }
    [self instrumentUpdate];
}

//-----------------------------------------------------------------------------
//  update all parameters
//
//  when tested on other computers, this function seemed to not cause any errors
//  or warnings but not sound is audible?
//-----------------------------------------------------------------------------
- (void)instrumentUpdate
{
    //this should use the same methodlogy stated in the 'updateAllParameters' method in the ViewController class.
    // then when a single object is changed, all the other object dont also have to update.
    
    opA.ratio.value = [[currentSettings objectForKey:@"opA.ratio"] floatValue];
    opB.ratio.value = [[currentSettings objectForKey:@"opB.ratio"] floatValue];
    opC.ratio.value = [[currentSettings objectForKey:@"opC.ratio"] floatValue];
    opD.ratio.value = [[currentSettings objectForKey:@"opD.ratio"] floatValue];
    
    opA.fine.value = [[currentSettings objectForKey:@"opA.fine"] floatValue];
    opB.fine.value = [[currentSettings objectForKey:@"opB.fine"] floatValue];
    opC.fine.value = [[currentSettings objectForKey:@"opC.fine"] floatValue];
    opD.fine.value = [[currentSettings objectForKey:@"opD.fine"] floatValue];
    
    opA.amp.value = [[currentSettings objectForKey:@"opA.amp"] floatValue];
    opB.amp.value = [[currentSettings objectForKey:@"opB.amp"] floatValue];
    opC.amp.value = [[currentSettings objectForKey:@"opC.amp"] floatValue];
    opD.amp.value = [[currentSettings objectForKey:@"opD.amp"] floatValue];
}

#pragma mark Play / Release note functions

//-----------------------------------------------------------------------------
//	play
//-----------------------------------------------------------------------------
- (void)play:(NSInteger)updateKey ADSR:(NSMutableArray *)ADSR
{
    if (currentNotes.count == kNumVoices) {
        return;
    }
    note = [[OperatorNote alloc] init];
    
    // Set the frequency property of 'note'
    note.frequency.value = [[currentFrequencies objectAtIndex:updateKey] floatValue];
    
    {
    // A
        // Attack
        [AKTools setProperty:note._attackA   withSlider:[ADSR objectAtIndex:0]];
        // Decay
        [AKTools setProperty:note._decayA    withSlider:[ADSR objectAtIndex:1]];
        // Sustain
        [AKTools setProperty:note._sustainA  withSlider:[ADSR objectAtIndex:2]];
        // Release
        [AKTools setProperty:note._releaseA  withSlider:[ADSR objectAtIndex:3]];
    // B
        // Attack
        [AKTools setProperty:note._attackB   withSlider:[ADSR objectAtIndex:4]];
        // Decay
        [AKTools setProperty:note._decayB    withSlider:[ADSR objectAtIndex:5]];
        // Sustain
        [AKTools setProperty:note._sustainB  withSlider:[ADSR objectAtIndex:6]];
        // Release
        [AKTools setProperty:note._releaseB  withSlider:[ADSR objectAtIndex:7]];
    // C
        // Attack
        [AKTools setProperty:note._attackC   withSlider:[ADSR objectAtIndex:8]];
        // Decay
        [AKTools setProperty:note._decayC    withSlider:[ADSR objectAtIndex:9]];
        // Sustain
        [AKTools setProperty:note._sustainC  withSlider:[ADSR objectAtIndex:10]];
        // Release
        [AKTools setProperty:note._releaseC  withSlider:[ADSR objectAtIndex:11]];
    // D
        // Attack
        [AKTools setProperty:note._attackD    withSlider:[ADSR objectAtIndex:12]];
        // Decay
        [AKTools setProperty:note._decayD    withSlider:[ADSR objectAtIndex:13]];
        // Sustain
        [AKTools setProperty:note._sustainD  withSlider:[ADSR objectAtIndex:14]];
        // Release
        [AKTools setProperty:note._releaseD  withSlider:[ADSR objectAtIndex:15]];
    // MASTER
        // Attack
        [AKTools setProperty:note._attackZ   withSlider:[ADSR objectAtIndex:16]];
        // Decay
        [AKTools setProperty:note._decayZ    withSlider:[ADSR objectAtIndex:17]];
        // Sustain
        [AKTools setProperty:note._sustainZ  withSlider:[ADSR objectAtIndex:18]];
        // Release
        [AKTools setProperty:note._releaseZ  withSlider:[ADSR objectAtIndex:19]];
    }
    
    // BUG
    // Why does only one note have the ability to play all four operators? This single note is even sent directly to opeartor A...
    [opA playNote:note];
    
    // Save the note to an array
    [currentNotes setObject:note forKey:[NSNumber numberWithInt:(int)updateKey]];
    // Change state
    isPlaying = YES;
}

//-----------------------------------------------------------------------------
//	release
//-----------------------------------------------------------------------------
- (void)release:(NSInteger)stopKey
{
    //Get the key note instance
    OperatorNote *noteToRelease = [currentNotes objectForKey:[NSNumber numberWithInt:(int)stopKey]];
    // Stop the note
//    [noteToRelease stop];
    [opA stopNote:noteToRelease];
//    [opB stopNote:noteToRelease]; //this isnt needed to stop the note? Just for opA works
    // Remove the note from the array
    [currentNotes removeObjectForKey:[NSNumber numberWithInt:(int)stopKey]];
    // Change state
    isPlaying = NO;
}


@end
