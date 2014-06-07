//
//  TFGLTraceReader.m
//  TraceFiend
//
//  Created by Chinmay Garde on 5/27/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFGLTraceReader.h"
#import "TFGLFileReadOperation.h"

@implementation TFGLTraceReader {
    NSOperationQueue *_fileReaderQueue;
}

+(instancetype) sharedReader {
    static TFGLTraceReader *reader = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reader = [[TFGLTraceReader alloc] init];
    });
    
    return reader;
}

-(instancetype) init {
    self = [super init];
    
    if (self) {
        _fileReaderQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

-(void) readFramesFromFile:(NSString *) fileName ofType:(NSString *) filetype completion:(TFGLTraceReaderCompletion) completion {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:fileName ofType:filetype]];
    
    TFGLFileReadOperation *operation = [[TFGLFileReadOperation alloc] initWithFileHandle:handle];
    operation.completion = completion;
    
    [_fileReaderQueue addOperation:operation];
}

@end
