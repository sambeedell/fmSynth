//
//  ViewController.h
//  ManualFMSynthesis
//
//  Created by Nicholas Arner on 1/28/15.
//  Copyright (c) 2015 Nicholas Arner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHRotaryKnob.h"

#define kNumEnv 5
#define kNumEnvParam kNumEnv*4

@interface ViewController : UIViewController{
    int index; //Used for defining which operator (A,B,C or D) has been changed.
    NSMutableArray *envADSR[kNumEnvParam];
    NSMutableDictionary *storedData;
    UITextField *presetName;
    int playlistKey;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *tableData;

//Keyboard Properties
@property (strong, nonatomic) IBOutlet UIImageView *C1;
@property (strong, nonatomic) IBOutlet UIImageView *C1s;
@property (strong, nonatomic) IBOutlet UIImageView *D1;
@property (strong, nonatomic) IBOutlet UIImageView *D1s;
@property (strong, nonatomic) IBOutlet UIImageView *E1;
@property (strong, nonatomic) IBOutlet UIImageView *F1;
@property (strong, nonatomic) IBOutlet UIImageView *F1s;
@property (strong, nonatomic) IBOutlet UIImageView *G1;
@property (strong, nonatomic) IBOutlet UIImageView *G1s;
@property (strong, nonatomic) IBOutlet UIImageView *A1;
@property (strong, nonatomic) IBOutlet UIImageView *A1s;
@property (strong, nonatomic) IBOutlet UIImageView *B1;
@property (strong, nonatomic) IBOutlet UIImageView *C2;

//Oscillator Parameters
@property (weak, nonatomic) IBOutlet UIButton       *oscA_on;       //0
@property (weak, nonatomic) IBOutlet UIButton       *oscA_fixed;    //1
@property (weak, nonatomic) IBOutlet UIButton       *oscA_up;       //2
@property (weak, nonatomic) IBOutlet UIButton       *oscA_down;     //3
@property (weak, nonatomic) IBOutlet UIImageView    *oscA_osc;      //4
@property (weak, nonatomic) IBOutlet UIButton       *oscB_on;       //5
@property (weak, nonatomic) IBOutlet UIButton       *oscB_fixed;    //6
@property (weak, nonatomic) IBOutlet UIButton       *oscB_up;       //7
@property (weak, nonatomic) IBOutlet UIButton       *oscB_down;     //8
@property (weak, nonatomic) IBOutlet UIImageView    *oscB_osc;      //9
@property (weak, nonatomic) IBOutlet UIButton       *oscC_on;       //10
@property (weak, nonatomic) IBOutlet UIButton       *oscC_fixed;    //11
@property (weak, nonatomic) IBOutlet UIButton       *oscC_up;       //12
@property (weak, nonatomic) IBOutlet UIButton       *oscC_down;     //13
@property (weak, nonatomic) IBOutlet UIImageView    *oscC_osc;      //14
@property (weak, nonatomic) IBOutlet UIButton       *oscD_on;       //15
@property (weak, nonatomic) IBOutlet UIButton       *oscD_fixed;    //16
@property (weak, nonatomic) IBOutlet UIButton       *oscD_up;       //17
@property (weak, nonatomic) IBOutlet UIButton       *oscD_down;     //18
@property (weak, nonatomic) IBOutlet UIImageView    *oscD_osc;      //19

@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscA_ratio;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscA_fine;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscA_amp;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscB_ratio;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscB_fine;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscB_amp;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscC_ratio;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscC_fine;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscC_amp;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscD_ratio;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscD_fine;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *oscD_amp;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *feedback;
@property (nonatomic, weak) IBOutlet MHRotaryKnob *p_mix;

@property (strong, nonatomic) IBOutlet UILabel *oscA_value;
@property (strong, nonatomic) IBOutlet UILabel *oscB_value;
@property (strong, nonatomic) IBOutlet UILabel *oscC_value;
@property (strong, nonatomic) IBOutlet UILabel *oscD_value;
@property (strong, nonatomic) IBOutlet UIButton *p_invert;

//Envelope Parameters
@property (nonatomic, weak) IBOutlet UISlider *sliderA_attack;
@property (nonatomic, weak) IBOutlet UISlider *sliderA_decay;
@property (nonatomic, weak) IBOutlet UISlider *sliderA_sustain;
@property (nonatomic, weak) IBOutlet UISlider *sliderA_release;
@property (nonatomic, weak) IBOutlet UISlider *sliderB_attack;
@property (nonatomic, weak) IBOutlet UISlider *sliderB_decay;
@property (nonatomic, weak) IBOutlet UISlider *sliderB_sustain;
@property (nonatomic, weak) IBOutlet UISlider *sliderB_release;
@property (nonatomic, weak) IBOutlet UISlider *sliderC_attack;
@property (nonatomic, weak) IBOutlet UISlider *sliderC_decay;
@property (nonatomic, weak) IBOutlet UISlider *sliderC_sustain;
@property (nonatomic, weak) IBOutlet UISlider *sliderC_release;
@property (nonatomic, weak) IBOutlet UISlider *sliderD_attack;
@property (nonatomic, weak) IBOutlet UISlider *sliderD_decay;
@property (nonatomic, weak) IBOutlet UISlider *sliderD_sustain;
@property (nonatomic, weak) IBOutlet UISlider *sliderD_release;
@property (nonatomic, weak) IBOutlet UISlider *sliderP_attack;
@property (nonatomic, weak) IBOutlet UISlider *sliderP_decay;
@property (nonatomic, weak) IBOutlet UISlider *sliderP_sustain;
@property (nonatomic, weak) IBOutlet UISlider *sliderP_release;



@end