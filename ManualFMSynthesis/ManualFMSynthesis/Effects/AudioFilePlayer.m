//
//  AudioFilePlayer.m
//  Song Library Player Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AudioFilePlayer.h"

@implementation AudioFilePlayer

- (instancetype)init {
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    NSString *file = [[docDir stringByAppendingPathComponent:@"exported"]
                      stringByAppendingPathExtension:@"wav"];
    return [self initWithFilename:file];
}

- (instancetype)initWithFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        
        Playback *note = [[Playback alloc] init];
        
        _filePosition = [[AKInstrumentProperty alloc] initWithValue:0];
        
        AKFileInput *fileIn = [[AKFileInput alloc] initWithFilename:filename];
        fileIn.startTime = note.startTime;
        
        // Output to global effects processing
        _auxilliaryOutput = [AKStereoAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:fileIn];
        
        [self assignOutput:_filePosition to:akp(64.0/44100.0)];
    }
    return self;
}

@end

@implementation Playback

- (instancetype)init {
    self = [super init];
    if (self) {
        _startTime = [[AKNoteProperty alloc] initWithValue:0
                                                   minimum:0
                                                   maximum:100000000];
    }
    return self;
}


- (instancetype)initWithStartTime:(float)startTime {
    self = [self init];
    if (self) {
        _startTime.value = startTime;
    }
    return self;
}


@end
