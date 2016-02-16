//
//  ViewController.m
//  ManualFMSynthesis
//
//  Created by Sam Beedell on 01/20/15.
//
//  Description:
//  This class controls all of the UI objects on the view and passes their
//  notifications to the conductor class.
//
//
//

#import "ViewController.h"
#import "Conductor.h"

#define kNumDefaults 5 //the number of default settings

@interface ViewController () {
    // Conductor object
    Conductor *conductor;
    
    // These integers are used for the waveform switching and routing algorithms graphics
    int oscD;
    int oscC;
    int oscB;
    int oscA;
    int algorithm;
    // This integer is used to change the octave range of the virtual keyboard
    int octaveIndex;

    // This array stores the updated UI object states to be passed ot the conductor
    NSArray *waveform;
    // This array stores the waveform images
    NSArray *waveformImages;
    
}

@end

@implementation ViewController

#pragma mark Initialisation

//-----------------------------------------------------------------------------
//	init function
//-----------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create background image - locked rotation for this version
    // auto-scale is not neccessary for this application. It will interfere with the upcoming integration of the interaction system. A seperate UI will be designed for this application if it is desired to work for iPhone
    UIImage *image = [UIImage imageNamed:@"BG.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    backgroundImageView.frame = self.view.bounds;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];

    // Initialize envelope array
    envADSR = [NSMutableArray array];
    for (NSInteger i = 0; i < (kNumEnvParam); i+=4)
    // these objects will be replaced later but must represent the default envelope states defined by AKADSREnvelope
    {
        [envADSR insertObject:_sliderZ_attack  atIndex:i];
        [envADSR insertObject:_sliderZ_decay   atIndex:i+1];
        [envADSR insertObject:_sliderZ_sustain atIndex:i+2];
        [envADSR insertObject:_sliderZ_release atIndex:i+3];
    }

    // Initialize tableView data, this contains the current array of presets
    _tableData = [[NSMutableArray alloc] initWithObjects:@"Init", @"Bell", @"Wood-drum", @"Brass", @"Bass", @"Bass 2", @"Woodwind", @"Metallic Slap", @"Glass Pad", nil];
    playlistKey = (int)_tableData.count; //init to the total amount of default presets so they never get over written, have to change this value to below this value to set default presets. when the product is complete, this variable becomes irrelevant because we do not want the user to overwrite any of these presets. (variable  starts at 0.)
    // a later version of the NSUserDefaults functionality would include deleting presets, or the ability to overwrite previously saved presets??
    // Customize the tableView visually
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tintColor = [UIColor whiteColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:0.0/255.0 green:84.0/255.0 blue:142.0/255.0 alpha:1.0]; //ocean
    
    // Init the UI objects
    [self initKnobs];
    [self initSliders];

    // Init varibales
    total = 0; //used for testing latency
    oscD = 0;
    oscC = 0;
    oscB = 0;
    oscA = 0;
    octaveIndex = 4;
    algorithm = 1;
    waveform = @[@0,@0];
    waveformImages = @[[UIImage imageNamed:@"OSC_SIN.png"],
                       [UIImage imageNamed:@"OSC_TRI.png"],
                       [UIImage imageNamed:@"OSC_SQR.png"],
                       [UIImage imageNamed:@"OSC_SAW.png"]];
    
    //Initilize the conductor
    conductor = [[Conductor alloc] init];
    [conductor octaveUpdate:octaveIndex];
    // Load the init preset where all objects are at their default state.
    [self load:0];
    _octaveLabel.text = [[NSString alloc] initWithFormat:@"C%d",octaveIndex];
}

//-----------------------------------------------------------------------------
//	init custom rotary knobs
//-----------------------------------------------------------------------------
- (void)initKnobs
{//check selectors and default values!
    //the default values must match the instrument property definition
    self.oscA_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscA_ratio.scalingFactor = 1.5;
    self.oscA_ratio.maximumValue = 9.0f;
    self.oscA_ratio.minimumValue = 1.0f;
    self.oscA_ratio.value = 1.0f;
    self.oscA_ratio.defaultValue = self.oscA_ratio.value;
    self.oscA_ratio.resetsToDefault = YES;
    self.oscA_ratio.backgroundColor = [UIColor clearColor];
    [self.oscA_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscA_ratio addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscA_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscA_fine.scalingFactor = 0.25;
    self.oscA_fine.maximumValue = 1.0f;
    self.oscA_fine.minimumValue = -1.0f;
    self.oscA_fine.value = 0.0f;
    self.oscA_fine.defaultValue = self.oscA_fine.value;
    self.oscA_fine.resetsToDefault = YES;
    self.oscA_fine.backgroundColor = [UIColor clearColor];
    [self.oscA_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscA_fine addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscA_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscA_amp.scalingFactor = 1.5;
    self.oscA_amp.maximumValue = 1.0f;
    self.oscA_amp.minimumValue = 0.0f;
    self.oscA_amp.value = 0.5f;
    self.oscA_amp.defaultValue = self.oscA_amp.value;
    self.oscA_amp.resetsToDefault = YES;
    self.oscA_amp.backgroundColor = [UIColor clearColor];
    [self.oscA_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscA_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscB_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscB_ratio.scalingFactor = 1.5;
    self.oscB_ratio.maximumValue = 9.0f;
    self.oscB_ratio.minimumValue = 1.0f;
    self.oscB_ratio.value = 1.0f;
    self.oscB_ratio.defaultValue = self.oscB_ratio.value;
    self.oscB_ratio.resetsToDefault = YES;
    self.oscB_ratio.backgroundColor = [UIColor clearColor];
    [self.oscB_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscB_ratio addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscB_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscB_fine.scalingFactor = 0.25;
    self.oscB_fine.maximumValue = 1.0f;
    self.oscB_fine.minimumValue = -1.0f;
    self.oscB_fine.value = 0.0f;
    self.oscB_fine.defaultValue = self.oscB_fine.value;
    self.oscB_fine.resetsToDefault = YES;
    self.oscB_fine.backgroundColor = [UIColor clearColor];
    [self.oscB_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscB_fine addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscB_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscB_amp.scalingFactor = 1.5;
    self.oscB_amp.maximumValue = 1.0f;
    self.oscB_amp.minimumValue = 0.0f;
    self.oscB_amp.value = 0.5f;
    self.oscB_amp.defaultValue = self.oscB_amp.value;
    self.oscB_amp.resetsToDefault = YES;
    self.oscB_amp.backgroundColor = [UIColor clearColor];
    [self.oscB_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscB_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscC_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscC_ratio.scalingFactor = 1.5;
    self.oscC_ratio.maximumValue = 9.0f;
    self.oscC_ratio.minimumValue = 1.0f;
    self.oscC_ratio.value = 1.0f;
    self.oscC_ratio.defaultValue = self.oscC_ratio.value;
    self.oscC_ratio.resetsToDefault = YES;
    self.oscC_ratio.backgroundColor = [UIColor clearColor];
    [self.oscC_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscC_ratio addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscC_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscC_fine.scalingFactor = 0.25;
    self.oscC_fine.maximumValue = 1.0f;
    self.oscC_fine.minimumValue = -1.0f;
    self.oscC_fine.value = 0.0f;
    self.oscC_fine.defaultValue = self.oscC_fine.value;
    self.oscC_fine.resetsToDefault = YES;
    self.oscC_fine.backgroundColor = [UIColor clearColor];
    [self.oscC_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscC_fine addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscC_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscC_amp.scalingFactor = 1.5;
    self.oscC_amp.maximumValue = 1.0f;
    self.oscC_amp.minimumValue = 0.0f;
    self.oscC_amp.value = 0.5f;
    self.oscC_amp.defaultValue = self.oscC_amp.value;
    self.oscC_amp.resetsToDefault = YES;
    self.oscC_amp.backgroundColor = [UIColor clearColor];
    [self.oscC_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscC_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscD_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscD_ratio.scalingFactor = 1.5;
    self.oscD_ratio.maximumValue = 9.0f;
    self.oscD_ratio.minimumValue = 1.0f;
    self.oscD_ratio.value = 1.0f;
    self.oscD_ratio.defaultValue = self.oscD_ratio.value;
    self.oscD_ratio.resetsToDefault = YES;
    self.oscD_ratio.backgroundColor = [UIColor clearColor];
    [self.oscD_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscD_ratio addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscD_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscD_fine.scalingFactor = 0.25;
    self.oscD_fine.maximumValue = 1.0f;
    self.oscD_fine.minimumValue = -1.0f;
    self.oscD_fine.value = 0.0f;
    self.oscD_fine.defaultValue = self.oscD_fine.value;
    self.oscD_fine.resetsToDefault = YES;
    self.oscD_fine.backgroundColor = [UIColor clearColor];
    [self.oscD_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscD_fine addTarget:self action:@selector(frequencyChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscD_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscD_amp.scalingFactor = 1.5;
    self.oscD_amp.maximumValue = 1.0f;
    self.oscD_amp.minimumValue = 0.0f;
    self.oscD_amp.value = 0.5f;
    self.oscD_amp.defaultValue = self.oscD_amp.value;
    self.oscD_amp.resetsToDefault = YES;
    self.oscD_amp.backgroundColor = [UIColor clearColor];
    [self.oscD_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscD_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.master_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.master_amp.scalingFactor = 1.5;
    self.master_amp.maximumValue = 1.0f;
    self.master_amp.minimumValue = 0.0f;
    self.master_amp.value = 0.5f;         //this must match the instrument property definition
    self.master_amp.defaultValue = self.master_amp.value;
    self.master_amp.resetsToDefault = YES;
    self.master_amp.backgroundColor = [UIColor clearColor];
    [self.master_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.master_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.filter_cutoff.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.filter_cutoff.scalingFactor = 1.5;
    self.filter_cutoff.maximumValue = 1.0f;
    self.filter_cutoff.minimumValue = 0.0f;
    self.filter_cutoff.value = 0.5f;         //this must match the instrument property definition
    self.filter_cutoff.defaultValue = self.filter_cutoff.value;
    self.filter_cutoff.resetsToDefault = YES;
    self.filter_cutoff.backgroundColor = [UIColor clearColor];
    [self.filter_cutoff setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_25x25"] forState:UIControlStateNormal];
    
    self.filter_res.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.filter_res.scalingFactor = 1.5;
    self.filter_res.maximumValue = 1.0f;
    self.filter_res.minimumValue = 0.0f;
    self.filter_res.value = 0.5f;         //this must match the instrument property definition
    self.filter_res.defaultValue = self.filter_res.value;
    self.filter_res.resetsToDefault = YES;
    self.filter_res.backgroundColor = [UIColor clearColor];
    [self.filter_res setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_25x25"] forState:UIControlStateNormal];
}

//-----------------------------------------------------------------------------
//	init custom sliders
//-----------------------------------------------------------------------------
- (void)initSliders
{
    // Rotate to make sliders vertical
    CGAffineTransform rotate180 = CGAffineTransformMakeRotation(-M_PI * 0.5);
    // Load images of custom slider
    UIImage *thumbImage = [UIImage imageNamed:@"thumbSlider_23x23.png"];
    UIImage *minImage = [UIImage imageNamed:@"minSlider_23x.png"];
    UIImage *maxImage = [UIImage imageNamed:@"maxSlider_23x.png"];

// ------------------ A ------------------
    [_sliderA_attack  setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderA_attack  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderA_attack  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderA_attack  setTransform:rotate180];
    [_sliderA_decay   setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderA_decay   setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderA_decay   setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderA_decay   setTransform:rotate180];
    [_sliderA_sustain setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderA_sustain setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderA_sustain setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderA_sustain setTransform:rotate180];
    [_sliderA_release setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderA_release setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderA_release setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderA_release setTransform:rotate180];
    
// ------------------ B ------------------
    [_sliderB_attack  setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderB_attack  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderB_attack  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderB_attack  setTransform:rotate180];
    [_sliderB_decay   setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderB_decay   setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderB_decay   setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderB_decay   setTransform:rotate180];
    [_sliderB_sustain setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderB_sustain setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderB_sustain setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderB_sustain setTransform:rotate180];
    [_sliderB_release setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderB_release setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderB_release setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderB_release setTransform:rotate180];
    
// ------------------ C ------------------
    [_sliderC_attack  setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderC_attack  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderC_attack  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderC_attack  setTransform:rotate180];
    [_sliderC_decay   setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderC_decay   setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderC_decay   setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderC_decay   setTransform:rotate180];
    [_sliderC_sustain setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderC_sustain setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderC_sustain setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderC_sustain setTransform:rotate180];
    [_sliderC_release setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderC_release setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderC_release setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderC_release setTransform:rotate180];
    
// ------------------ D ------------------
    [_sliderD_attack  setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderD_attack  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderD_attack  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderD_attack  setTransform:rotate180];
    [_sliderD_decay   setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderD_decay   setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderD_decay   setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderD_decay   setTransform:rotate180];
    [_sliderD_sustain setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderD_sustain setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderD_sustain setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderD_sustain setTransform:rotate180];
    [_sliderD_release setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderD_release setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderD_release setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderD_release setTransform:rotate180];
    
// ------------------ MASTER ---------------
    [_sliderZ_attack  setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderZ_attack  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderZ_attack  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderZ_attack  setTransform:rotate180];
    [_sliderZ_decay   setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderZ_decay   setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderZ_decay   setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderZ_decay   setTransform:rotate180];
    [_sliderZ_sustain setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderZ_sustain setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderZ_sustain setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderZ_sustain setTransform:rotate180];
    [_sliderZ_release setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderZ_release setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderZ_release setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderZ_release setTransform:rotate180];

    thumbImage = nil;
    maxImage = nil;
    minImage = nil;
}

#pragma mark IBAction methods

//-----------------------------------------------------------------------------
//	algorithm buttons pressed
//-----------------------------------------------------------------------------
- (IBAction)algorithmChanged:(UIButton *)sender
{
    // sender 1 -> 8
    algorithm += sender.tag;
    if (algorithm >= 8) {algorithm = 8;}
    if (algorithm <= 1) {algorithm = 1;}
    [self algorithmUpdate];
}

//-----------------------------------------------------------------------------
//	on/off, fixed and waveform switching buttons pressed
//-----------------------------------------------------------------------------
- (IBAction)switchButton:(UIButton *)sender
{
    UIImage *image;
    switch (sender.tag) {
        case 0: //oscA_on
        {
            //Toggle current state and save
            self.oscA_on.selected = !self.oscA_on.selected;
            
            // Fade the UI object using the 'alpha' property and disable the user interaction.
            [self amplitudeChanged];
                
        break;
        }
        case 1: //oscA_fixed
        {
            //Toggle current state and save
            self.oscA_fixed.selected = !self.oscA_fixed.selected;
            
            break;
        }
        case 2: //oscA_up
        {
            oscA += 1;
            if (oscA >= 3) { oscA = 3; }
            self.oscA_osc.image = waveformImages[oscA];
            // Update Conductor
            waveform = @[@1,[NSNumber numberWithInt:oscA]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 3: //oscA_down
        {
            oscA -= 1;
            if (oscA <= 0) { oscA = 0; }
            self.oscA_osc.image = waveformImages[oscA];
            //Update Conductor
            waveform = @[@1,[NSNumber numberWithInt:oscA]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 4: //oscB_on
        {
            //Toggle current state and save
            self.oscB_on.selected = !self.oscB_on.selected;
            
            // Fade the UI object using the 'alpha' property and disable the user interaction.
            [self amplitudeChanged];
            
            break;
        }
        case 5: //oscB_fixed
        {
            //Toggle current state and save
            self.oscB_fixed.selected = !self.oscB_fixed.selected;
            
            break;
        }
        case 6: //oscB_up
        {
            oscB += 1;
            if (oscB >= 3) { oscB = 3; }
            self.oscB_osc.image = waveformImages[oscB];
//
            waveform = @[@2,[NSNumber numberWithInt:oscB]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 7: //oscB_down
        {
            oscB -= 1;
            if (oscB <= 0) { oscB = 0; }
            self.oscB_osc.image = waveformImages[oscB];
//
            waveform = @[@2,[NSNumber numberWithInt:oscB]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 8: //oscC_on
        {
            //Toggle current state and save
            self.oscC_on.selected = !self.oscC_on.selected;
            
            // Fade the UI object using the 'alpha' property and disable the user interaction.
            [self amplitudeChanged];
            
            break;
        }
        case 9: //oscC_fixed
        {
            //Toggle current state and save
            self.oscC_fixed.selected = !self.oscC_fixed.selected;

            break;
        }
        case 10: //oscC_up
        {
            oscC += 1;
            if (oscC >= 3) { oscC = 3; }
            self.oscC_osc.image = waveformImages[oscC];
            
            waveform = @[@3,[NSNumber numberWithInt:oscC]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 11: //oscC_down
        {
            oscC -= 1;
            if (oscC <= 0) { oscC = 0; }
            self.oscC_osc.image = waveformImages[oscC];
            
            waveform = @[@3,[NSNumber numberWithInt:oscC]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 12: //oscD_on
        {
            //Toggle current state and save
            self.oscD_on.selected = !self.oscD_on.selected;
            
            // Fade the UI object using the 'alpha' property and disable the user interaction.
            [self amplitudeChanged];
            
            break;
        }
        case 13: //oscD_fixed
        {
            //Toggle current state and save
            self.oscD_fixed.selected = !self.oscD_fixed.selected;
            
            break;
        }
        case 14: //oscD_up
        {
            oscD += 1;
            if (oscD >= 3) { oscD = 3; }
            self.oscD_osc.image = waveformImages[oscD];
            
            waveform = @[@4,[NSNumber numberWithInt:oscD]];
            [conductor waveformUpdate:waveform];
            break;
        }
        case 15: //oscD_down
        {
            oscD -= 1;
            if (oscD <= 0) { oscD = 0; }
            self.oscD_osc.image = waveformImages[oscD];
            
            waveform = @[@4,[NSNumber numberWithInt:oscD]];
            [conductor waveformUpdate:waveform];
            break;
        }
            
        default:
            break;
    }
    image = nil;
}

//-----------------------------------------------------------------------------
//	octave range buttons pressed
//-----------------------------------------------------------------------------
- (IBAction)octaveStepperChanged:(UIButton *)sender
{
    // octave range = 1 - 7
    octaveIndex += sender.tag;
    if (octaveIndex >= 8) {octaveIndex = 7;}
    if (octaveIndex <= 0) {octaveIndex = 1;}
    _octaveLabel.text = [[NSString alloc] initWithFormat:@"C%d",octaveIndex];
    [conductor octaveUpdate:octaveIndex];
}

//-----------------------------------------------------------------------------
//	fine / ratio parameters changed
//-----------------------------------------------------------------------------
- (IBAction)frequencyChanged
{
    index = 1; // Operator A
    [conductor frequencyUpdate:index
                         ratio:self.oscA_ratio.value
                          fine:self.oscA_fine.value];
    _oscA_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscA_ratio.value)+self.oscA_fine.value];
    
    index = 2; // Operator B
    [conductor frequencyUpdate:index
                         ratio:self.oscB_ratio.value
                          fine:self.oscB_fine.value];
    _oscB_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscB_ratio.value)+self.oscB_fine.value];

    index = 3; // Operator C
    [conductor frequencyUpdate:index
                         ratio:self.oscC_ratio.value
                          fine:self.oscC_fine.value];
    _oscC_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscC_ratio.value)+self.oscC_fine.value];

    index = 4; // Operator D
    [conductor frequencyUpdate:index
                         ratio:self.oscD_ratio.value
                          fine:self.oscD_fine.value];
    _oscD_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscD_ratio.value)+self.oscD_fine.value];
}

//-----------------------------------------------------------------------------
//	amplitude parameters changed
//-----------------------------------------------------------------------------
- (IBAction)amplitudeChanged
{
    // If the operator is switched on the the conductor recieves the amplitude update from the GUI
    // If the operator is off, the conductor recieves 0 and the UI objects fade transparency
    // The UI objects must have their user interaction diabled also.
    //
    // Should the opertor be deallocated when turned of also? This may improve performance
    
    // ------------------------------------------------
    // Operator A
    // ------------------------------------------------
    if (!self.oscA_on.selected) {
        [conductor amplitudeUpdate:1 value:0];
        self.oscA_amp.userInteractionEnabled   = NO;
        self.oscA_ratio.userInteractionEnabled = NO;
        self.oscA_fine.userInteractionEnabled  = NO;
        self.sliderA_attack.userInteractionEnabled = NO;
        self.sliderA_decay.userInteractionEnabled = NO;
        self.sliderA_sustain.userInteractionEnabled = NO;
        self.sliderA_release.userInteractionEnabled = NO;
        self.oscA_osc.alpha = 0.8;
        self.oscA_amp.alpha   = 0.8;
        self.oscA_ratio.alpha = 0.8;
        self.oscA_fine.alpha  = 0.8;
        self.oscA_value.alpha = 0.6;
        self.sliderA_attack.alpha  = 0.8;
        self.sliderA_decay.alpha   = 0.8;
        self.sliderA_sustain.alpha = 0.8;
        self.sliderA_release.alpha = 0.8;
    } else {
        [conductor amplitudeUpdate:1
                             value:self.oscA_amp.value];
        if (self.oscA_on.selected) {
            self.oscA_amp.userInteractionEnabled   = YES;
            self.oscA_ratio.userInteractionEnabled = YES;
            self.oscA_fine.userInteractionEnabled  = YES;
            self.sliderA_attack.userInteractionEnabled = YES;
            self.sliderA_decay.userInteractionEnabled = YES;
            self.sliderA_sustain.userInteractionEnabled = YES;
            self.sliderA_release.userInteractionEnabled = YES;
            self.oscA_osc.alpha = 1;
            self.oscA_amp.alpha   = 1;
            self.oscA_ratio.alpha = 1;
            self.oscA_fine.alpha  = 1;
            self.oscA_value.alpha = 1;
            self.sliderA_attack.alpha  = 1;
            self.sliderA_decay.alpha   = 1;
            self.sliderA_sustain.alpha = 1;
            self.sliderA_release.alpha = 1;
        }
    }
    // ------------------------------------------------
    // Operator B
    // ------------------------------------------------
    if (!self.oscB_on.selected) {
        [conductor amplitudeUpdate:2 value:0];
        self.oscB_amp.userInteractionEnabled = NO;
        self.oscB_ratio.userInteractionEnabled = NO;
        self.oscB_fine.userInteractionEnabled  = NO;
        self.sliderB_attack.userInteractionEnabled = NO;
        self.sliderB_decay.userInteractionEnabled = NO;
        self.sliderB_sustain.userInteractionEnabled = NO;
        self.sliderB_release.userInteractionEnabled = NO;
        self.oscB_osc.alpha = 0.8;
        self.oscB_amp.alpha   = 0.8;
        self.oscB_ratio.alpha = 0.8;
        self.oscB_fine.alpha  = 0.8;
        self.oscB_value.alpha = 0.6;
        self.sliderB_attack.alpha  = 0.8;
        self.sliderB_decay.alpha   = 0.8;
        self.sliderB_sustain.alpha = 0.8;
        self.sliderB_release.alpha = 0.8;
    } else {
        [conductor amplitudeUpdate:2
                             value:self.oscB_amp.value];
        if (self.oscB_on.selected) {
            self.oscB_amp.userInteractionEnabled = YES;
            self.oscB_ratio.userInteractionEnabled = YES;
            self.oscB_fine.userInteractionEnabled  = YES;
            self.sliderB_attack.userInteractionEnabled = YES;
            self.sliderB_decay.userInteractionEnabled = YES;
            self.sliderB_sustain.userInteractionEnabled = YES;
            self.sliderB_release.userInteractionEnabled = YES;
            self.oscB_osc.alpha = 1;
            self.oscB_amp.alpha   = 1;
            self.oscB_ratio.alpha = 1;
            self.oscB_fine.alpha  = 1;
            self.oscB_value.alpha = 1;
            self.sliderB_attack.alpha  = 1;
            self.sliderB_decay.alpha   = 1;
            self.sliderB_sustain.alpha = 1;
            self.sliderB_release.alpha = 1;
        }
    }
    // ------------------------------------------------
    // Operator C
    // ------------------------------------------------
    if (!self.oscC_on.selected) {
        [conductor amplitudeUpdate:3 value:0];
        self.oscC_amp.userInteractionEnabled = NO;
        self.oscC_ratio.userInteractionEnabled = NO;
        self.oscC_fine.userInteractionEnabled  = NO;
        self.sliderC_attack.userInteractionEnabled = NO;
        self.sliderC_decay.userInteractionEnabled = NO;
        self.sliderC_sustain.userInteractionEnabled = NO;
        self.sliderC_release.userInteractionEnabled = NO;
        self.oscC_osc.alpha = 0.8;
        self.oscC_amp.alpha   = 0.8;
        self.oscC_ratio.alpha = 0.8;
        self.oscC_fine.alpha  = 0.8;
        self.oscC_value.alpha = 0.6;
        self.sliderC_attack.alpha  = 0.8;
        self.sliderC_decay.alpha   = 0.8;
        self.sliderC_sustain.alpha = 0.8;
        self.sliderC_release.alpha = 0.8;
    } else {
        [conductor amplitudeUpdate:3
                             value:self.oscC_amp.value];
        if (self.oscC_on.selected) {
            self.oscC_amp.userInteractionEnabled = YES;
            self.oscC_ratio.userInteractionEnabled = YES;
            self.oscC_fine.userInteractionEnabled  = YES;
            self.sliderC_attack.userInteractionEnabled = YES;
            self.sliderC_decay.userInteractionEnabled = YES;
            self.sliderC_sustain.userInteractionEnabled = YES;
            self.sliderC_release.userInteractionEnabled = YES;
            self.oscC_osc.alpha = 1;
            self.oscC_amp.alpha   = 1;
            self.oscC_ratio.alpha = 1;
            self.oscC_fine.alpha  = 1;
            self.oscC_value.alpha = 1;
            self.sliderC_attack.alpha  = 1;
            self.sliderC_decay.alpha   = 1;
            self.sliderC_sustain.alpha = 1;
            self.sliderC_release.alpha = 1;
        }
    }
    // ------------------------------------------------
    // Operator D
    // ------------------------------------------------
    if (!self.oscD_on.selected) {
        [conductor amplitudeUpdate:4 value:0];
        self.oscD_amp.userInteractionEnabled = NO;
        self.oscD_ratio.userInteractionEnabled = NO;
        self.oscD_fine.userInteractionEnabled  = NO;
        self.sliderD_attack.userInteractionEnabled = NO;
        self.sliderD_decay.userInteractionEnabled = NO;
        self.sliderD_sustain.userInteractionEnabled = NO;
        self.sliderD_release.userInteractionEnabled = NO;
        self.oscD_osc.alpha = 0.8;
        self.oscD_amp.alpha   = 0.8;
        self.oscD_ratio.alpha = 0.8;
        self.oscD_fine.alpha  = 0.8;
        self.oscD_value.alpha = 0.6;
        self.sliderD_attack.alpha  = 0.8;
        self.sliderD_decay.alpha   = 0.8;
        self.sliderD_sustain.alpha = 0.8;
        self.sliderD_release.alpha = 0.8;
    } else {
        [conductor amplitudeUpdate:4
                             value:self.oscD_amp.value];
        if (self.oscD_on.selected) {
            self.oscD_amp.userInteractionEnabled = YES;
            self.oscD_ratio.userInteractionEnabled = YES;
            self.oscD_fine.userInteractionEnabled  = YES;
            self.sliderD_attack.userInteractionEnabled = YES;
            self.sliderD_decay.userInteractionEnabled = YES;
            self.sliderD_sustain.userInteractionEnabled = YES;
            self.sliderD_release.userInteractionEnabled = YES;
            self.oscD_osc.alpha = 1;
            self.oscD_amp.alpha   = 1;
            self.oscD_ratio.alpha = 1;
            self.oscD_fine.alpha  = 1;
            self.oscD_value.alpha = 1;
            self.sliderD_attack.alpha  = 1;
            self.sliderD_decay.alpha   = 1;
            self.sliderD_sustain.alpha = 1;
            self.sliderD_release.alpha = 1;
        }
    }
    [conductor amplitudeUpdate:5 value:self.master_amp.value];
}

//-----------------------------------------------------------------------------
//	envelope parameters changed
//-----------------------------------------------------------------------------
- (IBAction)envelopeChanged:(UISlider *)sender
{
    NSInteger kIndex = [sender tag];
    // Update the array storing the envelope pointer to their current state
    [envADSR replaceObjectAtIndex:kIndex withObject:sender];
    // Envelope parameters are note based so this array gets sent ot the conductor
    // when a note is pressed.
}

#pragma mark UI update from NSUserDefaults

//-----------------------------------------------------------------------------
//	update waveform
//-----------------------------------------------------------------------------
- (void)waveformUpdate
{
    // Update Conductor
    waveform = @[@1,[NSNumber numberWithInt:oscA]];
    [conductor waveformUpdate:waveform];
    waveform = @[@2,[NSNumber numberWithInt:oscB]];
    [conductor waveformUpdate:waveform];
    waveform = @[@3,[NSNumber numberWithInt:oscC]];
    [conductor waveformUpdate:waveform];
    waveform = @[@4,[NSNumber numberWithInt:oscD]];
    [conductor waveformUpdate:waveform];
    // Update UI
    self.oscA_osc.image = waveformImages[oscA];
    self.oscB_osc.image = waveformImages[oscB];
    self.oscC_osc.image = waveformImages[oscC];
    self.oscD_osc.image = waveformImages[oscD];
}

//-----------------------------------------------------------------------------
//	update routing algorithm
//-----------------------------------------------------------------------------
- (void)algorithmUpdate
{
    // Update UI
    [_algorithmImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"algorithm%d.png",algorithm]]];
    _algorithmLabel.text = [[NSString alloc] initWithFormat:@"%d",algorithm];
    // Update conductor
    [conductor setupRoutingAlgorithms:algorithm];
}

//-----------------------------------------------------------------------------
//	update everything - used for loading presets
//-----------------------------------------------------------------------------
- (void)updateAllParameters
{
    [self algorithmUpdate];
    [self waveformUpdate];
    [self frequencyChanged];
    [self amplitudeChanged];
    
    for (int x; x<kNumEnvParam; x++) {
        [self envelopeChanged:[envADSR objectAtIndex:x]];
    }
}

#pragma mark Conductor communication methods

//-----------------------------------------------------------------------------
//	key pressed method
//-----------------------------------------------------------------------------
- (IBAction)keyPressed:(id)sender
{
    // Take the key tag from the virtual key UI object
    UILabel *key = (UILabel *)sender;
    NSInteger kIndex = [key tag];
    [key setHighlighted:YES]; // change its image to highlighted
    
//    // Print how long it took from the first touch to this method
//    NSTimeInterval latest = [[NSDate date] timeIntervalSince1970];
//    float time = latest - currentTime;
//    NSLog(@"keyPressed: %f", time);
    
    // Tell the conductor to play the note
    [conductor play:kIndex
               ADSR:envADSR];
    
    // Print how long it took from the first touch to hear an audible output
//    NSTimeInterval latest = [[NSDate date] timeIntervalSince1970];
//    float time = latest - currentTime;
//    NSLog(@"noteOn    : %f", time);
//    total += time;
}

//-----------------------------------------------------------------------------
//	key released method
//-----------------------------------------------------------------------------
- (IBAction)keyReleased:(id)sender
{
    // Take the key tag from the virtual key UI object
    UILabel *key = (UILabel *)sender;
    NSInteger kIndex = [key tag];
    [key setHighlighted:NO]; // change its image back to not-highlighted

    // Tell the conductor to release the note
    [conductor release:kIndex];
}

#pragma mark UIResponde methods used for custom touch handling
/*
//-----------------------------------------------------------------------------
//	touchesBegan
//-----------------------------------------------------------------------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Get the time of the touch
//    currentTime = [[NSDate date] timeIntervalSince1970];
    
    // Find where the touch is on the screen and which virtual key that represents
    // That UI object then gets sent to the keyPressed method to talk to the conductor
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        
        if(CGRectContainsPoint(_C1.frame, location) && !CGRectContainsPoint(_C1s.frame, location))
        {
            [self keyPressed:_C1];  //C1
        }
        if(CGRectContainsPoint(_C1s.frame, location))
        {
            [self keyPressed:_C1s]; //C1#
        }
        if(CGRectContainsPoint(_D1.frame, location) && !CGRectContainsPoint(_C1s.frame, location) && !CGRectContainsPoint(_D1s.frame, location))
        {
            [self keyPressed:_D1];  //D1
        }
        if(CGRectContainsPoint(_D1s.frame, location))
        {
            [self keyPressed:_D1s]; //D1#
        }
        if(CGRectContainsPoint(_E1.frame, location) && !CGRectContainsPoint(_D1s.frame, location))
        {
            [self keyPressed:_E1];  //E1
        }
        if(CGRectContainsPoint(_F1.frame, location) && !CGRectContainsPoint(_F1s.frame, location))
        {
            [self keyPressed:_F1];  //F1
        }
        if(CGRectContainsPoint(_F1s.frame, location))
        {
            [self keyPressed:_F1s]; //F1#
        }
        if(CGRectContainsPoint(_G1.frame, location) && !CGRectContainsPoint(_F1s.frame, location) && !CGRectContainsPoint(_G1s.frame, location))
        {
            [self keyPressed:_G1];  //G1
        }
        if(CGRectContainsPoint(_G1s.frame, location))
        {
            [self keyPressed:_G1s]; //G1#
        }
        if(CGRectContainsPoint(_A1.frame, location) && !CGRectContainsPoint(_G1s.frame, location) && !CGRectContainsPoint(_A1s.frame, location))
        {
            [self keyPressed:_A1];  //A1
        }
        if(CGRectContainsPoint(_A1s.frame, location))
        {
            [self keyPressed:_A1s]; //A1#
        }
        if(CGRectContainsPoint(_B1.frame, location) && !CGRectContainsPoint(_A1s.frame, location))
        {
            [self keyPressed:_B1];  //B1
        }
        if(CGRectContainsPoint(_C2.frame, location) && !CGRectContainsPoint(_C2s.frame, location))
        {
            [self keyPressed:_C2];  //C2
        }
        if(CGRectContainsPoint(_C2s.frame, location))
        {
            [self keyPressed:_C2s]; //C2#
        }
        if(CGRectContainsPoint(_D2.frame, location) && !CGRectContainsPoint(_C2s.frame, location) && !CGRectContainsPoint(_D2s.frame, location))
        {
            [self keyPressed:_D2];  //D2
        }
        if(CGRectContainsPoint(_D2s.frame, location))
        {
            [self keyPressed:_D2s]; //D2#
        }
        if(CGRectContainsPoint(_E2.frame, location) && !CGRectContainsPoint(_D2s.frame, location))
        {
            [self keyPressed:_E2];  //E2
        }
    }
}
//-----------------------------------------------------------------------------
//	touchesMoved
//-----------------------------------------------------------------------------

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Find where the touch is on the screen and which virtual key that represents
    // If its left a virtual key then send the UI object to the keyReleased method
    // IF its entered another virtual key, send the UI object to the keyPressed method
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        CGPoint prevlocation = [touch previousLocationInView:self.view];
        
        if(!CGRectContainsPoint(_C1.frame, location) | CGRectContainsPoint(_C1s.frame, location))
        {
            [self keyReleased:_C1];
            
        }
        if(!CGRectContainsPoint(_C1.frame, prevlocation) && CGRectContainsPoint(_C1.frame, location))
        {
            [self keyPressed:_C1];
            
        }
        if(!CGRectContainsPoint(_C1s.frame, location))
        {
            [self keyReleased:_C1s];
            
        } else if(!CGRectContainsPoint(_C1s.frame, prevlocation) && CGRectContainsPoint(_C1s.frame, location))
        {
            [self keyPressed:_C1s];
            
        }
        if(!CGRectContainsPoint(_D1.frame, location))
        {
            [self keyReleased:_D1];
            
        } else if(!CGRectContainsPoint(_D1.frame, prevlocation) && CGRectContainsPoint(_D1.frame, location))
        {
            [self keyPressed:_D1];
            
        }
        if(!CGRectContainsPoint(_D1s.frame, location))
        {
            [self keyReleased:_D1s];
            
        } else if(!CGRectContainsPoint(_D1s.frame, prevlocation) && CGRectContainsPoint(_D1s.frame, location))
        {
            [self keyPressed:_D1s];
            
        }
        if(!CGRectContainsPoint(_E1.frame, location))
        {
            [self keyReleased:_E1];
            
        }else if(!CGRectContainsPoint(_E1.frame, prevlocation) && CGRectContainsPoint(_E1.frame, location))
        {
            [self keyPressed:_E1];
            
        }
        if(!CGRectContainsPoint(_F1.frame, location))
        {
            [self keyReleased:_F1];
            
        } else if(!CGRectContainsPoint(_F1.frame, prevlocation) && CGRectContainsPoint(_F1.frame, location))
        {
            [self keyPressed:_F1];
            
        }
        if(!CGRectContainsPoint(_F1s.frame, location))
        {
            [self keyReleased:_F1s];
            
        } else if(!CGRectContainsPoint(_F1s.frame, prevlocation) && CGRectContainsPoint(_F1s.frame, location))
        {
            [self keyPressed:_F1s];
            
        }
        if(!CGRectContainsPoint(_G1.frame, location))
        {
            [self keyReleased:_G1];
            
        } else if(!CGRectContainsPoint(_G1.frame, prevlocation) && CGRectContainsPoint(_G1.frame, location))
        {
            [self keyPressed:_G1];
            
        }
        if(!CGRectContainsPoint(_G1s.frame, location))
        {
            [self keyReleased:_G1s];
            
        } else if(!CGRectContainsPoint(_G1s.frame, prevlocation) && CGRectContainsPoint(_G1s.frame, location))
        {
            [self keyPressed:_G1s];
            
        }
        if(!CGRectContainsPoint(_A1.frame, location))
        {
            [self keyReleased:_A1];
            
        }else if(!CGRectContainsPoint(_A1.frame, prevlocation) && CGRectContainsPoint(_A1.frame, location))
        {
            [self keyPressed:_A1];
            
        }
        if(!CGRectContainsPoint(_A1s.frame, location))
        {
            [self keyReleased:_A1s];
            
        } else if(!CGRectContainsPoint(_A1s.frame, prevlocation) && CGRectContainsPoint(_A1s.frame, location))
        {
            [self keyPressed:_A1s];
            
        }
        if(!CGRectContainsPoint(_B1.frame, location))
        {
            [self keyReleased:_B1];
            
        }else if(!CGRectContainsPoint(_B1.frame, prevlocation) && CGRectContainsPoint(_B1.frame, location))
        {
            [self keyPressed:_B1];
            
        }
        if(!CGRectContainsPoint(_C2.frame, location) | CGRectContainsPoint(_C2s.frame, location))
        {
            [self keyReleased:_C2];
            
        }
        if(!CGRectContainsPoint(_C2.frame, prevlocation) && CGRectContainsPoint(_C2.frame, location))
        {
            [self keyPressed:_C2];
            
        }
        if(!CGRectContainsPoint(_C2s.frame, location))
        {
            [self keyReleased:_C2s];
            
        } else if(!CGRectContainsPoint(_C2s.frame, prevlocation) && CGRectContainsPoint(_C2s.frame, location))
        {
            [self keyPressed:_C2s];
            
        }
        if(!CGRectContainsPoint(_D2.frame, location))
        {
            [self keyReleased:_D2];
            
        } else if(!CGRectContainsPoint(_D2.frame, prevlocation) && CGRectContainsPoint(_D2.frame, location))
        {
            [self keyPressed:_D2];
            
        }
        if(!CGRectContainsPoint(_D2s.frame, location))
        {
            [self keyReleased:_D2s];
            
        } else if(!CGRectContainsPoint(_D2s.frame, prevlocation) && CGRectContainsPoint(_D2s.frame, location))
        {
            [self keyPressed:_D2s];
            
        }
        if(!CGRectContainsPoint(_E2.frame, location))
        {
            [self keyReleased:_E2];
            
        }else if(!CGRectContainsPoint(_E2.frame, prevlocation) && CGRectContainsPoint(_E2.frame, location))
        {
            [self keyPressed:_E2];
            
        }
        
    }
    
}

//-----------------------------------------------------------------------------
//	touchesEnded
//-----------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Find where the touch is on the screen and which virtual key that represents
    // That UI object then gets sent to the keyReleased method to talk to the conductor
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        
        if(CGRectContainsPoint(_C1.frame, location) )
        {
            [self keyReleased:_C1];
        }
        if(CGRectContainsPoint(_C1s.frame, location) )
        {
            [self keyReleased:_C1s];
        }
        if(CGRectContainsPoint(_D1.frame, location) )
        {
            [self keyReleased:_D1];
        }
        if(CGRectContainsPoint(_D1s.frame, location) )
        {
            [self keyReleased:_D1s];
        }
        if(CGRectContainsPoint(_E1.frame, location) )
        {
            [self keyReleased:_E1];
        }
        if(CGRectContainsPoint(_F1.frame, location) )
        {
            [self keyReleased:_F1];
        }
        if(CGRectContainsPoint(_F1s.frame, location) )
        {
            [self keyReleased:_F1s];
        }
        if(CGRectContainsPoint(_G1.frame, location) )
        {
            [self keyReleased:_G1];
        }
        if(CGRectContainsPoint(_G1s.frame, location) )
        {
            [self keyReleased:_G1s];
        }
        if(CGRectContainsPoint(_A1.frame, location) )
        {
            [self keyReleased:_A1];
        }
        if(CGRectContainsPoint(_A1s.frame, location) )
        {
            [self keyReleased:_A1s];
        }
        if(CGRectContainsPoint(_B1.frame, location) )
        {
            [self keyReleased:_B1];
        }
        if(CGRectContainsPoint(_C2.frame, location) )
        {
            [self keyReleased:_C2];
        }
        if(CGRectContainsPoint(_C2s.frame, location) )
        {
            [self keyReleased:_C2s];
        }
        if(CGRectContainsPoint(_D2.frame, location) )
        {
            [self keyReleased:_D2];
        }
        if(CGRectContainsPoint(_D2s.frame, location) )
        {
            [self keyReleased:_D2s];
        }
        if(CGRectContainsPoint(_E2.frame, location) )
        {
            [self keyReleased:_E2];
        }
        
    }
}
*/


#pragma mark Save and Load specific methods

//-----------------------------------------------------------------------------
//	save button pressed - UIAlertView pops up
//-----------------------------------------------------------------------------
- (IBAction)save:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save preset..." message:@"Please enter a name for your preset" delegate:self cancelButtonTitle:@"Save" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;

    presetName = [alert textFieldAtIndex:0];
    presetName.clearButtonMode = UITextFieldViewModeWhileEditing;
    presetName.keyboardType = UIKeyboardTypeAlphabet;
    presetName.keyboardAppearance = UIKeyboardAppearanceAlert;
    presetName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    presetName.autocapitalizationType = UITextAutocorrectionTypeNo;
    [alert show];
}

//-----------------------------------------------------------------------------
//	alert view delegate function
//
//  The user must type in a name for their preset or cancel.
//  By pressing save the UI states will be stored into NSUserDefaults
//-----------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int indexData = (int)_tableData.count;

    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Save"]) {
        if ([presetName.text length] != 0) {
            [_tableData insertObject:presetName.text atIndex:indexData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexData inSection:0];
            // Insert into tableView
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView endUpdates];
        }
        
        // Save the data to NSUserDefaults...
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        
        [defaults setBool:self.oscA_on.selected     forKey:[[NSString alloc] initWithFormat:@"oscA_on%d",playlistKey]];
        [defaults setBool:self.oscA_fixed.selected  forKey:[[NSString alloc] initWithFormat:@"oscA_fixed%d",playlistKey]];
        [defaults setBool:self.oscB_on.selected     forKey:[[NSString alloc] initWithFormat:@"oscB_on%d",playlistKey]];
        [defaults setBool:self.oscB_fixed.selected  forKey:[[NSString alloc] initWithFormat:@"oscB_fixed%d",playlistKey]];
        [defaults setBool:self.oscC_on.selected     forKey:[[NSString alloc] initWithFormat:@"oscC_on%d",playlistKey]];
        [defaults setBool:self.oscC_fixed.selected  forKey:[[NSString alloc] initWithFormat:@"oscC_fixed%d",playlistKey]];
        [defaults setBool:self.oscD_on.selected     forKey:[[NSString alloc] initWithFormat:@"oscD_on%d",playlistKey]];
        [defaults setBool:self.oscD_fixed.selected  forKey:[[NSString alloc] initWithFormat:@"oscD_fixed%d",playlistKey]];
        
        [defaults setFloat:self.oscA_ratio.value    forKey:[[NSString alloc] initWithFormat:@"oscA_ratio%d",playlistKey]];
        [defaults setFloat:self.oscA_fine.value     forKey:[[NSString alloc] initWithFormat:@"oscA_fine%d",playlistKey]];
        [defaults setFloat:self.oscA_amp.value      forKey:[[NSString alloc] initWithFormat:@"oscA_amp%d",playlistKey]];
        [defaults setFloat:self.oscB_ratio.value    forKey:[[NSString alloc] initWithFormat:@"oscB_ratio%d",playlistKey]];
        [defaults setFloat:self.oscB_fine.value     forKey:[[NSString alloc] initWithFormat:@"oscB_fine%d",playlistKey]];
        [defaults setFloat:self.oscB_amp.value      forKey:[[NSString alloc] initWithFormat:@"oscB_amp%d",playlistKey]];
        [defaults setFloat:self.oscC_ratio.value    forKey:[[NSString alloc] initWithFormat:@"oscC_ratio%d",playlistKey]];
        [defaults setFloat:self.oscC_fine.value     forKey:[[NSString alloc] initWithFormat:@"oscC_fine%d",playlistKey]];
        [defaults setFloat:self.oscC_amp.value      forKey:[[NSString alloc] initWithFormat:@"oscC_amp%d",playlistKey]];
        [defaults setFloat:self.oscD_ratio.value    forKey:[[NSString alloc] initWithFormat:@"oscD_ratio%d",playlistKey]];
        [defaults setFloat:self.oscD_fine.value     forKey:[[NSString alloc] initWithFormat:@"oscD_fine%d",playlistKey]];
        [defaults setFloat:self.oscD_amp.value      forKey:[[NSString alloc] initWithFormat:@"oscD_amp%d",playlistKey]];
        
        [defaults setFloat:self.master_amp.value      forKey:[[NSString alloc] initWithFormat:@"master_amp%d",playlistKey]];

        [defaults setFloat:_sliderA_attack.value    forKey:[[NSString alloc] initWithFormat:@"sliderA_attack%d",playlistKey]];
        [defaults setFloat:_sliderA_decay.value     forKey:[[NSString alloc] initWithFormat:@"sliderA_decay%d",playlistKey]];
        [defaults setFloat:_sliderA_sustain.value   forKey:[[NSString alloc] initWithFormat:@"sliderA_sustain%d",playlistKey]];
        [defaults setFloat:_sliderA_release.value   forKey:[[NSString alloc] initWithFormat:@"sliderA_release%d",playlistKey]];
        [defaults setFloat:_sliderB_attack.value    forKey:[[NSString alloc] initWithFormat:@"sliderB_attack%d",playlistKey]];
        [defaults setFloat:_sliderB_decay.value     forKey:[[NSString alloc] initWithFormat:@"sliderB_decay%d",playlistKey]];
        [defaults setFloat:_sliderB_sustain.value   forKey:[[NSString alloc] initWithFormat:@"sliderB_sustain%d",playlistKey]];
        [defaults setFloat:_sliderB_release.value   forKey:[[NSString alloc] initWithFormat:@"sliderB_release%d",playlistKey]];
        [defaults setFloat:_sliderC_attack.value    forKey:[[NSString alloc] initWithFormat:@"sliderC_attack%d",playlistKey]];
        [defaults setFloat:_sliderC_decay.value     forKey:[[NSString alloc] initWithFormat:@"sliderC_decay%d",playlistKey]];
        [defaults setFloat:_sliderC_sustain.value   forKey:[[NSString alloc] initWithFormat:@"sliderC_sustain%d",playlistKey]];
        [defaults setFloat:_sliderC_release.value   forKey:[[NSString alloc] initWithFormat:@"sliderC_release%d",playlistKey]];
        [defaults setFloat:_sliderD_attack.value    forKey:[[NSString alloc] initWithFormat:@"sliderD_attack%d",playlistKey]];
        [defaults setFloat:_sliderD_decay.value     forKey:[[NSString alloc] initWithFormat:@"sliderD_decay%d",playlistKey]];
        [defaults setFloat:_sliderD_sustain.value   forKey:[[NSString alloc] initWithFormat:@"sliderD_sustain%d",playlistKey]];
        [defaults setFloat:_sliderD_release.value   forKey:[[NSString alloc] initWithFormat:@"sliderD_release%d",playlistKey]];
        [defaults setFloat:_sliderZ_attack.value    forKey:[[NSString alloc] initWithFormat:@"sliderZ_attack%d",playlistKey]];
        [defaults setFloat:_sliderZ_decay.value     forKey:[[NSString alloc] initWithFormat:@"sliderZ_decay%d",playlistKey]];
        [defaults setFloat:_sliderZ_sustain.value   forKey:[[NSString alloc] initWithFormat:@"sliderZ_sustain%d",playlistKey]];
        [defaults setFloat:_sliderZ_release.value   forKey:[[NSString alloc] initWithFormat:@"sliderZ_release%d",playlistKey]];
        
        [defaults setInteger:algorithm forKey:[[NSString alloc] initWithFormat:@"algorithm%d",playlistKey]];
        
        [defaults setInteger:oscA forKey:[[NSString alloc] initWithFormat:@"oscA_waveform%d",playlistKey]];
        [defaults setInteger:oscB forKey:[[NSString alloc] initWithFormat:@"oscB_waveform%d",playlistKey]];
        [defaults setInteger:oscC forKey:[[NSString alloc] initWithFormat:@"oscC_waveform%d",playlistKey]];
        [defaults setInteger:oscD forKey:[[NSString alloc] initWithFormat:@"oscD_waveform%d",playlistKey]];
        
        // When the user re-opens the application, playlistKey must be saved so that if the user saves another preset it doesnt overwrite any of their previously saved sounds
        
        playlistKey++;
        [defaults setInteger:(playlistKey + 1) forKey:[[NSString alloc] initWithFormat:@"playlistKey"]];
        
        [defaults synchronize];
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(
                                                            NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *folder = [path objectAtIndex:0];
        NSLog(@"Your NSUserDefaults are stored in this folder: %@/Preferences", folder);
        NSLog(@"Data saved: %d", playlistKey - 1);
        
    }
    else NSLog(@"Data cancelled");
}

//-----------------------------------------------------------------------------
//	load button pressed
//-----------------------------------------------------------------------------
- (IBAction)load:(id)sender
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int playlistIndex = (int)_tableView.indexPathForSelectedRow.item;
    NSLog(@"playlistIndex: %ld", (long)playlistIndex);
    
    // Update the UI elements with the saved data
    self.oscA_on.selected    = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscA_on%d",playlistIndex]];
    self.oscA_fixed.selected = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscA_fixed%d",playlistIndex]];
    self.oscB_on.selected    = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscB_on%d",playlistIndex]];
    self.oscB_fixed.selected = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscB_fixed%d",playlistIndex]];
    self.oscC_on.selected    = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscC_on%d",playlistIndex]];
    self.oscC_fixed.selected = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscC_fixed%d",playlistIndex]];
    self.oscD_on.selected    = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscD_on%d",playlistIndex]];
    self.oscD_fixed.selected = [defaults boolForKey:[[NSString alloc] initWithFormat:@"oscD_fixed%d",playlistIndex]];
    
    self.oscA_ratio.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscA_ratio%d",playlistIndex]];
    self.oscA_fine.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscA_fine%d",playlistIndex]];
    self.oscA_amp.value      = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscA_amp%d",playlistIndex]];
    self.oscB_ratio.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscB_ratio%d",playlistIndex]];
    self.oscB_fine.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscB_fine%d",playlistIndex]];
    self.oscB_amp.value      = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscB_amp%d",playlistIndex]];
    self.oscC_ratio.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscC_ratio%d",playlistIndex]];
    self.oscC_fine.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscC_fine%d",playlistIndex]];
    self.oscC_amp.value      = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscC_amp%d",playlistIndex]];
    self.oscD_ratio.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscD_ratio%d",playlistIndex]];
    self.oscD_fine.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscD_fine%d",playlistIndex]];
    self.oscD_amp.value      = [defaults floatForKey:[[NSString alloc] initWithFormat:@"oscD_amp%d",playlistIndex]];
    
    self.master_amp.value      = [defaults floatForKey:[[NSString alloc] initWithFormat:@"master_amp%d",playlistIndex]];
    
    _sliderA_attack.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderA_attack%d",playlistIndex]];
    _sliderA_decay.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderA_decay%d",playlistIndex]];
    _sliderA_sustain.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderA_sustain%d",playlistIndex]];
    _sliderA_release.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderA_release%d",playlistIndex]];
    _sliderB_attack.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderB_attack%d",playlistIndex]];
    _sliderB_decay.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderB_decay%d",playlistIndex]];
    _sliderB_sustain.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderB_sustain%d",playlistIndex]];
    _sliderB_release.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderB_release%d",playlistIndex]];
    _sliderC_attack.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderC_attack%d",playlistIndex]];
    _sliderC_decay.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderC_decay%d",playlistIndex]];
    _sliderC_sustain.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderC_sustain%d",playlistIndex]];
    _sliderC_release.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderC_release%d",playlistIndex]];
    _sliderD_attack.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderD_attack%d",playlistIndex]];
    _sliderD_decay.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderD_decay%d",playlistIndex]];
    _sliderD_sustain.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderD_sustain%d",playlistIndex]];
    _sliderD_release.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderD_release%d",playlistIndex]];
    _sliderZ_attack.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderZ_attack%d",playlistIndex]];
    _sliderZ_decay.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderZ_decay%d",playlistIndex]];
    _sliderZ_sustain.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderZ_sustain%d",playlistIndex]];
    _sliderZ_release.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderZ_release%d",playlistIndex]];

    algorithm   = (int)[defaults integerForKey:[[NSString alloc] initWithFormat:@"algorithm%d",playlistIndex]];
    
    oscA = (int)[defaults integerForKey:[[NSString alloc] initWithFormat:@"oscA_waveform%d",playlistIndex]];
    oscB = (int)[defaults integerForKey:[[NSString alloc] initWithFormat:@"oscB_waveform%d",playlistIndex]];
    oscC = (int)[defaults integerForKey:[[NSString alloc] initWithFormat:@"oscC_waveform%d",playlistIndex]];
    oscD = (int)[defaults integerForKey:[[NSString alloc] initWithFormat:@"oscD_waveform%d",playlistIndex]];

    // Not quite working yet...
//    playlistKey = [defaults integerForKey:[[NSString alloc] initWithFormat:@"playlistKey"]];
//    NSLog(@"key : %d", (int)[defaults integerForKey:[[NSString alloc] initWithFormat:@"playlistKey"]]);
    
    [self updateAllParameters];

    NSLog(@"Data loaded");
}

//-----------------------------------------------------------------------------
//	table view delegate functions
//-----------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//-----------------------------------------------------------------------------
//	table view delegate functions
//-----------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

//-----------------------------------------------------------------------------
//	table view delegate functions
//-----------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_tableData objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
    cell.textColor = [UIColor whiteColor];

    return cell;
}

//-----------------------------------------------------------------------------
//	utility function
//-----------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
