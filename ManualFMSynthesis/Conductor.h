//
//  Conductor.h
//  ManualFMSynthesis
//
//  Created by Sam Beedell on 01/20/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AKFoundation.h"

@interface Conductor : NSObject{
}

// Functions needed to communicate with the view controller
- (void)play:(NSInteger)key ADSR:(NSMutableArray *)envA;
- (void)release:(NSInteger)key;
- (void)frequencyUpdate:(int)index ratio:(float)ratio fine:(float)fine;
- (void)amplitudeUpdate:(int)index value:(float)sender;
- (void)octaveUpdate:(int)octave;
- (void)waveformUpdate:(NSArray *)updateWaveform;
- (void)setupRoutingAlgorithms:(int)algorithm;

@end
