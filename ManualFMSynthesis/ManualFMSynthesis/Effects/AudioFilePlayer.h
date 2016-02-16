//
//  AudioFilePlayer.h
//  Song Library Player Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface AudioFilePlayer : AKInstrument

// Audio outlet for global effects processing
@property (readonly) AKStereoAudio *auxilliaryOutput;
@property (readonly) AKInstrumentProperty *filePosition;

- (instancetype)initWithFilename:(NSString *)filename;

@end

@interface Playback : AKNote

@property AKNoteProperty *startTime;

- (instancetype)initWithStartTime:(float)startTime;

@end