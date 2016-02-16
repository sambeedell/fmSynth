//
//  ViewController.m
//  ManualFMSynthesis
//
//  Created by Nicholas Arner on 1/28/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

#import "ViewController.h"
#import "Conductor.h"

#define kNumDefaults 5 //the number of default settings

@interface ViewController () {
    Conductor *conductor;
    
    int oscD;
    int oscC;
    int oscB;
    int oscA;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create background image - locked rotation for this version
    // currently doesnt feature auto scale and rotation
    UIImage *image = [UIImage imageNamed:@"BG.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    backgroundImageView.frame = self.view.bounds;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];

    // Initialize array
    *envADSR = [NSMutableArray array];
    for (NSInteger i = 0; i < (kNumEnvParam); i++)
    //this is purely for initialization purposes, this object will be replaced later
    {[*envADSR addObject:_sliderA_attack];}
    
    // Initialize tableView data, this will need to be updated with a default set of presets
    _tableData = [[NSMutableArray alloc] initWithObjects:@"Empty", @"Empty", @"Empty", nil];
    // Customize the tableView
    self.tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:146.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    // Init the UI objects
    [self initKnobs];
    [self initSliders];
    
    // Init global varibales
    oscD = 0;
    oscC = 0;
    oscB = 0;
    oscA = 0;
    playlistKey = 0;
    
    //Initilize the conductor
    conductor = [[Conductor alloc] init];
}

- (void)initKnobs
{//check selectors and default values!
    self.oscA_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscA_ratio.scalingFactor = 1.5;
    self.oscA_ratio.maximumValue = 1.0f;
    self.oscA_ratio.minimumValue = 0.0f;
    self.oscA_ratio.value = 0.0f;
    self.oscA_ratio.defaultValue = self.oscA_ratio.value;
    self.oscA_ratio.resetsToDefault = YES;
    self.oscA_ratio.backgroundColor = [UIColor clearColor];
    [self.oscA_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscA_ratio addTarget:self action:@selector(frequencyAChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscA_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscA_fine.scalingFactor = 1.5;
    self.oscA_fine.maximumValue = 1.0f;
    self.oscA_fine.minimumValue = 0.0f;
    self.oscA_fine.value = 0.0f;
    self.oscA_fine.defaultValue = self.oscA_fine.value;
    self.oscA_fine.resetsToDefault = YES;
    self.oscA_fine.backgroundColor = [UIColor clearColor];
    [self.oscA_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscA_fine addTarget:self action:@selector(frequencyAChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscA_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscA_amp.scalingFactor = 1.5;
    self.oscA_amp.maximumValue = 1.0f;
    self.oscA_amp.minimumValue = 0.0f;
    self.oscA_amp.value = 0.5f;     //this must match the instrument property definition
    self.oscA_amp.defaultValue = self.oscA_amp.value;
    self.oscA_amp.resetsToDefault = YES;
    self.oscA_amp.backgroundColor = [UIColor clearColor];
    [self.oscA_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscA_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscB_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscB_ratio.scalingFactor = 1.5;
    self.oscB_ratio.maximumValue = 10.0f;
    self.oscB_ratio.minimumValue = 0.0f;
    self.oscB_ratio.value = 0.0f;
    self.oscB_ratio.defaultValue = self.oscB_ratio.value;
    self.oscB_ratio.resetsToDefault = YES;
    self.oscB_ratio.backgroundColor = [UIColor clearColor];
    [self.oscB_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscB_ratio addTarget:self action:@selector(frequencyBChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscB_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscB_fine.scalingFactor = 1.5;
    self.oscB_fine.maximumValue = 1.0f;
    self.oscB_fine.minimumValue = 0.0f;
    self.oscB_fine.value = 0.0f;
    self.oscB_fine.defaultValue = self.oscB_fine.value;
    self.oscB_fine.resetsToDefault = YES;
    self.oscB_fine.backgroundColor = [UIColor clearColor];
    [self.oscB_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscB_fine addTarget:self action:@selector(frequencyBChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscB_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscB_amp.scalingFactor = 1.5;
    self.oscB_amp.maximumValue = 1.0f;
    self.oscB_amp.minimumValue = 0.0f;
    self.oscB_amp.value = 0.0f;     //this must match the instrument property definition
    self.oscB_amp.defaultValue = self.oscB_amp.value;
    self.oscB_amp.resetsToDefault = YES;
    self.oscB_amp.backgroundColor = [UIColor clearColor];
    [self.oscB_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscB_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscC_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscC_ratio.scalingFactor = 1.5;
    self.oscC_ratio.maximumValue = 1.0f;
    self.oscC_ratio.minimumValue = 0.0f;
    self.oscC_ratio.value = 0.0f;
    self.oscC_ratio.defaultValue = self.oscC_ratio.value;
    self.oscC_ratio.resetsToDefault = YES;
    self.oscC_ratio.backgroundColor = [UIColor clearColor];
    [self.oscC_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscC_ratio addTarget:self action:@selector(frequencyCChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscC_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscC_fine.scalingFactor = 1.5;
    self.oscC_fine.maximumValue = 1.0f;
    self.oscC_fine.minimumValue = 0.0f;
    self.oscC_fine.value = 0.0f;
    self.oscC_fine.defaultValue = self.oscC_fine.value;
    self.oscC_fine.resetsToDefault = YES;
    self.oscC_fine.backgroundColor = [UIColor clearColor];
    [self.oscC_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscC_fine addTarget:self action:@selector(frequencyCChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscC_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscC_amp.scalingFactor = 1.5;
    self.oscC_amp.maximumValue = 1.0f;
    self.oscC_amp.minimumValue = 0.0f;
    self.oscC_amp.value = 0.0f;     //this must match the instrument property definition
    self.oscC_amp.defaultValue = self.oscC_amp.value;
    self.oscC_amp.resetsToDefault = YES;
    self.oscC_amp.backgroundColor = [UIColor clearColor];
    [self.oscC_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscC_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscD_ratio.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscD_ratio.scalingFactor = 1.5;
    self.oscD_ratio.maximumValue = 10.0f;
    self.oscD_ratio.minimumValue = 0.0f;
    self.oscD_ratio.value = 0.0f;
    self.oscD_ratio.defaultValue = self.oscD_ratio.value;
    self.oscD_ratio.resetsToDefault = YES;
    self.oscD_ratio.backgroundColor = [UIColor clearColor];
    [self.oscD_ratio setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscD_ratio addTarget:self action:@selector(frequencyDChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscD_fine.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscD_fine.scalingFactor = 1.5;
    self.oscD_fine.maximumValue = 1.0f;
    self.oscD_fine.minimumValue = 0.0f;
    self.oscD_fine.value = 0.0f;
    self.oscD_fine.defaultValue = self.oscD_fine.value;
    self.oscD_fine.resetsToDefault = YES;
    self.oscD_fine.backgroundColor = [UIColor clearColor];
    [self.oscD_fine setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscD_fine addTarget:self action:@selector(frequencyDChanged) forControlEvents:UIControlEventValueChanged];
    
    self.oscD_amp.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.oscD_amp.scalingFactor = 1.5;
    self.oscD_amp.maximumValue = 1.0f;
    self.oscD_amp.minimumValue = 0.0f;
    self.oscD_amp.value = 0.0f;         //this must match the instrument property definition
    self.oscD_amp.defaultValue = self.oscD_amp.value;
    self.oscD_amp.resetsToDefault = YES;
    self.oscD_amp.backgroundColor = [UIColor clearColor];
    [self.oscD_amp setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.oscD_amp addTarget:self action:@selector(amplitudeChanged) forControlEvents:UIControlEventValueChanged];
    
    self.feedback.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.feedback.scalingFactor = 1.5;
    self.feedback.maximumValue = 1.0f;
    self.feedback.minimumValue = 0.0f;
    self.feedback.value = 0.0f;         //this must match the instrument property definition
    self.feedback.defaultValue = self.feedback.value;
    self.feedback.resetsToDefault = YES;
    self.feedback.backgroundColor = [UIColor clearColor];
    [self.feedback setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.feedback addTarget:self action:@selector(feedbackChanged) forControlEvents:UIControlEventValueChanged];
    
    self.p_mix.interactionStyle = MHRotaryKnobInteractionStyleSliderVertical;
    self.p_mix.scalingFactor = 1.5;
    self.p_mix.maximumValue = 1.0f;
    self.p_mix.minimumValue = 0.0f;
    self.p_mix.value = 0.0f;         //this must match the instrument property definition
    self.p_mix.defaultValue = self.p_mix.value;
    self.p_mix.resetsToDefault = YES;
    self.p_mix.backgroundColor = [UIColor clearColor];
    [self.p_mix setKnobImage:[UIImage imageNamed:@"rotatyKnobTungsten_50x50"] forState:UIControlStateNormal];
    [self.p_mix addTarget:self action:@selector(pitchEnvChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)initSliders
{
    CGAffineTransform rotate180 = CGAffineTransformMakeRotation(-M_PI * 0.5);
    
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
    
// ------------------ PITCH---------------
    [_sliderP_attack  setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderP_attack  setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderP_attack  setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderP_attack  setTransform:rotate180];
    [_sliderP_decay   setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderP_decay   setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderP_decay   setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderP_decay   setTransform:rotate180];
    [_sliderP_sustain setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderP_sustain setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderP_sustain setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderP_sustain setTransform:rotate180];
    [_sliderP_release setThumbImage:thumbImage forState:UIControlStateNormal];
    [_sliderP_release setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_sliderP_release setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_sliderP_release setTransform:rotate180];

    thumbImage = nil;
    maxImage = nil;
    minImage = nil;
}

- (IBAction)switchButton:(UIButton *)sender
{
    UIImage *image;
    switch (sender.tag) {
        case 0: //oscA_on
        {
            //Toggle current state and save
            self.oscA_on.selected = !self.oscA_on.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 1: //oscA_fixed
        {
            //Toggle current state and save
            self.oscA_fixed.selected = !self.oscA_fixed.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 2: //oscA_up
        {
            //Toggle current state and save
            self.oscA_up.selected = !self.oscA_up.selected;
            
            if (oscA == 2 | oscA == 3) {
                oscA = 3;
                image = [UIImage imageNamed:@"OSC_SAW.png"];
            } else if (oscA == 1){
                oscA = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            } else if (oscA == 0){
                oscA = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            }
            [conductor waveformUpdate:oscA];
            self.oscA_osc.image = image;
            break;
        }
        case 3: //oscA_down
        {
            //Toggle current state and save
            self.oscA_down.selected = !self.oscA_down.selected;
            
            if (oscA == 1 | oscA == 0) {
                oscA = 0;
                image = [UIImage imageNamed:@"OSC_SIN.png"];
            } else if (oscA == 2){
                oscA = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            } else if (oscA == 3){
                oscA = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            }
            self.oscA_osc.image = image;
            [conductor waveformUpdate:oscA];
            break;
        }
        case 4: //oscB_on
        {
            //Toggle current state and save
            self.oscB_on.selected = !self.oscB_on.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 5: //oscB_fixed
        {
            //Toggle current state and save
            self.oscB_fixed.selected = !self.oscB_fixed.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 6: //oscB_up
        {
            //Toggle current state and save
            self.oscB_up.selected = !self.oscB_up.selected;
            
            if (oscB == 2 | oscB == 3) {
                oscB = 3;
                image = [UIImage imageNamed:@"OSC_SAW.png"];
            } else if (oscB == 1){
                oscB = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            } else if (oscB == 0){
                oscB = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            }
            self.oscB_osc.image = image;
            [conductor waveformUpdate:oscB];
            break;
        }
        case 7: //oscB_down
        {
            //Toggle current state and save
            self.oscB_down.selected = !self.oscB_down.selected;
            
            if (oscB == 1 | oscB == 0) {
                oscB = 0;
                image = [UIImage imageNamed:@"OSC_SIN.png"];
            } else if (oscB == 2){
                oscB = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            } else if (oscB == 3){
                oscB = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            }
            self.oscB_osc.image = image;
            [conductor waveformUpdate:oscB];
            break;
        }
        case 8: //oscC_on
        {
            //Toggle current state and save
            self.oscC_on.selected = !self.oscC_on.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 9: //oscC_fixed
        {
            //Toggle current state and save
            self.oscC_fixed.selected = !self.oscC_fixed.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 10: //oscC_up
        {
            //Toggle current state and save
            self.oscC_up.selected = !self.oscC_up.selected;
            
            if (oscC == 2 | oscC == 3) {
                oscC = 3;
                image = [UIImage imageNamed:@"OSC_SAW.png"];
            } else if (oscC == 1){
                oscC = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            } else if (oscC == 0){
                oscC = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            }
            self.oscC_osc.image = image;
            break;
        }
        case 11: //oscC_down
        {
            //Toggle current state and save
            self.oscC_down.selected = !self.oscC_down.selected;
            
            if (oscC == 1 | oscC == 0) {
                oscC = 0;
                image = [UIImage imageNamed:@"OSC_SIN.png"];
            } else if (oscC == 2){
                oscC = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            } else if (oscC == 3){
                oscC = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            }
            self.oscC_osc.image = image;
            break;
        }
        case 12: //oscD_on
        {
            //Toggle current state and save
            self.oscD_on.selected = !self.oscD_on.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 13: //oscD_fixed
        {
            //Toggle current state and save
            self.oscD_fixed.selected = !self.oscD_fixed.selected;
            
            /**
             The rest of your method goes here.
             */
            break;
        }
        case 14: //oscD_up
        {
            //Toggle current state and save
            self.oscD_up.selected = !self.oscD_up.selected;
            
            if (oscD == 2 | oscD == 3) {
                oscD = 3;
                image = [UIImage imageNamed:@"OSC_SAW.png"];
            } else if (oscD == 1){
                oscD = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            } else if (oscD == 0){
                oscD = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            }
            self.oscD_osc.image = image;
            break;
        }
        case 15: //oscD_down
        {
            //Toggle current state and save
            self.oscD_down.selected = !self.oscD_down.selected;
            
            if (oscD == 1 | oscD == 0) {
                oscD = 0;
                image = [UIImage imageNamed:@"OSC_SIN.png"];
            } else if (oscD == 2){
                oscD = 1;
                image = [UIImage imageNamed:@"OSC_TRI.png"];
            } else if (oscD == 3){
                oscD = 2;
                image = [UIImage imageNamed:@"OSC_SQR.png"];
            }
            self.oscD_osc.image = image;
            break;
        }
            
        default:
            break;
    }
    image = nil;
}

- (IBAction)frequencyAChanged
{
    index = 1;
    [conductor frequencyUpdate:index
                         ratio:self.oscA_ratio
                          fine:self.oscA_fine];
    _oscA_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscA_ratio.value*9)+self.oscA_fine.value];
}

- (IBAction)frequencyBChanged
{
    index = 2;
    [conductor frequencyUpdate:index
                         ratio:self.oscB_ratio
                          fine:self.oscB_fine];
    _oscB_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscB_ratio.value*9)+self.oscB_fine.value];
}

- (IBAction)frequencyCChanged
{
    index = 3;
    [conductor frequencyUpdate:index
                         ratio:self.oscC_ratio
                          fine:self.oscC_fine];
    _oscC_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscC_ratio.value*9)+self.oscC_fine.value];
}

- (IBAction)frequencyDChanged
{
    index = 4;
    [conductor frequencyUpdate:index
                         ratio:self.oscD_ratio
                          fine:self.oscD_fine];
    _oscD_value.text = [[NSString alloc] initWithFormat:@"%.3f",(int)(self.oscD_ratio.value*9)+self.oscD_fine.value];
}

- (IBAction)amplitudeChanged
{
    index = 1;
    [conductor amplitudeUpdate:index
                        sender:self.oscA_amp];
    index = 2;
    [conductor amplitudeUpdate:index
                        sender:self.oscB_amp];
    index = 3;
    [conductor amplitudeUpdate:index
                        sender:self.oscC_amp];
    index = 4;
    [conductor amplitudeUpdate:index
                        sender:self.oscD_amp];

}

- (IBAction)feedbackChanged
{
    [conductor feedbackUpdate:self.feedback];
    
}

- (IBAction)pitchEnvChanged
{
    [conductor effectEnvUpdate:self.p_mix
                        invert:self.p_invert.selected];
}

- (IBAction)envelopeChanged:(UISlider *)sender
{
    NSInteger kIndex = [sender tag];
    [*envADSR replaceObjectAtIndex:kIndex withObject:sender];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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
        
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
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
    }
}

- (void)updateAllParameters
{
    [self frequencyAChanged];
    [self frequencyBChanged];
    [self frequencyCChanged];
    [self frequencyDChanged];
    [self amplitudeChanged];
    [self feedbackChanged];
    [self pitchEnvChanged];
    
    for (int x; x<kNumEnvParam; x++) {
        [self envelopeChanged:[*envADSR objectAtIndex:x]];
    }
}


- (IBAction)invertPressed:(UIButton *)sender {
    //Toggle current state and save
    self.p_invert.selected = !self.p_invert.selected;
    [self pitchEnvChanged];
 
}


- (void)keyPressed:(id)sender {
    UILabel *key = (UILabel *)sender;
    NSInteger kIndex = [key tag];
    [key setHighlighted:YES];
    
    [conductor play:kIndex
               ADSR:*envADSR];
}

- (void)keyReleased:(id)sender
{
    UILabel *key = (UILabel *)sender;
    NSInteger kIndex = [key tag];
    [key setHighlighted:NO];
//    if ((kIndex == 1) || (kIndex == 3) || (kIndex == 6) || (kIndex == 8) || (kIndex == 10)) {
//        [key setBackgroundColor:[UIColor blackColor]];
//    } else {
//        [key setBackgroundColor:[UIColor whiteColor]];
//    }
    [conductor release:kIndex];
}

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Save"]) {
        if ([presetName.text length] != 0) {
            [_tableData insertObject:presetName.text atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            // Insert into tableView
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView endUpdates];
        }
        
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
        [defaults setFloat:_sliderP_attack.value    forKey:[[NSString alloc] initWithFormat:@"sliderP_attack%d",playlistKey]];
        [defaults setFloat:_sliderP_decay.value     forKey:[[NSString alloc] initWithFormat:@"sliderP_decay%d",playlistKey]];
        [defaults setFloat:_sliderP_sustain.value   forKey:[[NSString alloc] initWithFormat:@"sliderP_sustain%d",playlistKey]];
        [defaults setFloat:_sliderP_release.value   forKey:[[NSString alloc] initWithFormat:@"sliderP_release%d",playlistKey]];

        [defaults synchronize];
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(
                                                            NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *folder = [path objectAtIndex:0];
        NSLog(@"Your NSUserDefaults are stored in this folder: %@/Preferences", folder);
    }
    NSLog(@"Data saved");
    playlistKey++;
}

- (IBAction)load:(id)sender
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger playlistIndex = _tableView.indexPathForSelectedRow.item;
    
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
    _sliderP_attack.value    = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderP_attack%d",playlistIndex]];
    _sliderP_decay.value     = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderP_decay%d",playlistIndex]];
    _sliderP_sustain.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderP_sustain%d",playlistIndex]];
    _sliderP_release.value   = [defaults floatForKey:[[NSString alloc] initWithFormat:@"sliderP_release%d",playlistIndex]];

    [self updateAllParameters];

    NSLog(@"Data loaded");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_tableData objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
    cell.textColor = [UIColor colorWithRed:255.0/255.0 green:146.0/255.0 blue:51.0/255.0 alpha:1.0];

    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
