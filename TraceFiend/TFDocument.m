//
//  TFDocument.m
//  TraceFiend
//
//  Created by Chinmay Garde on 5/27/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFDocument.h"
#import "TFGLTraceReader.h"
#import "TFGLFrame.h"

@interface TFDocument ()

@property (nonatomic) CGFloat framePosition;
@property (nonatomic, readwrite, strong) NSArray *frames;

@end

@implementation TFDocument {
    NSUInteger _currentFrameIndex;
}

- (NSString *)windowNibName {
    return @"TFDocument";
}

+ (BOOL)autosavesInPlace {
    return NO;
}

-(void) windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    
    [[TFGLTraceReader sharedReader] readFramesFromFile: @"Sample"
                                                ofType: @"gltrace"
                                            completion: ^(NSArray *frames) {
                                                            self.frames = frames;
                                                            self.framePosition = 0.0;
                                                        }];
}

-(void) setFrames:(NSArray *)frames {
    if (_frames == frames)
        return;
    
    _frames = frames;
    _currentFrameIndex = NSNotFound;

    // Clear old data source
    self.commandListSource.commands = nil;
    [self.commandList reloadData];
}

-(void) setFramePosition:(CGFloat)framePosition {
    if (framePosition < 0.0)
        framePosition = 0.0;

    if (framePosition > 1.0)
        framePosition = 1.0;
    
    NSUInteger frameCount = _frames.count;

    if (frameCount == 0)
        return;
    
    NSUInteger newFrameIndex = MIN(frameCount * framePosition, frameCount - 1);
    
    if (newFrameIndex == _currentFrameIndex)
        return;
    
    _currentFrameIndex = newFrameIndex;
    
    TFGLFrame *frame = _frames[_currentFrameIndex];

    self.commandListSource.commands = frame.functions;
    [self.commandList reloadData];
    
//    self.framesu
}

-(CGFloat) framePosition {
    NSUInteger frameCount = _frames.count;
    
    if (frameCount == 0 || _currentFrameIndex == NSNotFound)
        return 0.0;
    
    return (CGFloat)_currentFrameIndex / (CGFloat)frameCount;
}

-(IBAction)frameScrubberWasUpdated:(id) slider {
    if (![slider isKindOfClass:[NSSlider class]])
        return;

    self.framePosition = [slider floatValue];
}

#pragma mark - Command List Source Delegate Protocol Implementation

-(void) commandListSource:(TFCommandListSource *) source functionWasSelected:(TFGLFunction *) function {
    self.imageWell.image = function.framebufferContents;
}

@end
