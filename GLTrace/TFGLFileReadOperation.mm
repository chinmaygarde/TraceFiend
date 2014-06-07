//
//  TFGLFileReadOperation.m
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFGLFileReadOperation.h"
#import "TFGLFunction+Private.h"
#import "TFGLFrame.h"

#import "gltrace.pb.h"
#include <google/protobuf/message_lite.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl.h>

using namespace android::gltrace;
using namespace std;
using namespace google::protobuf::io;

@interface TFGLFileReadOperation ()

@property (nonatomic, readwrite) NSFileHandle *fileHandle;

@end

@implementation TFGLFileReadOperation {
    NSMutableArray *_frames;
}

-(instancetype) initWithFileHandle:(NSFileHandle *) handle {
    self = [super init];
    
    if (self) {
        _fileHandle = handle;
        _frames = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) fireCompletionCallbacks {
    if (_completion == NULL)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _completion(_frames);
    });
}

-(void) main {
    if (_fileHandle == nil) {
        [self fireCompletionCallbacks];
        return;
    }
    
    ZeroCopyInputStream *inputStream = new FileInputStream(_fileHandle.fileDescriptor);
    CodedInputStream *codedStream = new CodedInputStream(inputStream);
    
    uint32_t value = 0;
    
    NSMutableArray *frameCommands = [[NSMutableArray alloc] init];
    
    while (codedStream->ReadLittleEndian32(&value)) {

        if (self.isCancelled)
            break;
        
        NTOHL(value);
        
        if (value == 0)
            continue;
        
        void *buffer = calloc(value, sizeof(char));
        
        if (codedStream->ReadRaw(buffer, value)) {
            GLMessage message;
            
            if (message.ParseFromArray(buffer, value)) {
                TFGLFunction *function = [[TFGLFunction alloc] initWithMessage:message];
                [frameCommands addObject:function];
                
                // FIXME: This needs to be configurable
                if (function.type == TFGLFunction_eglSwapBuffers) {
                    [_frames addObject:[[TFGLFrame alloc] initWithFunctions:frameCommands]];
                    frameCommands = [[NSMutableArray alloc] init];
                }
            }
        }
        
        free(buffer);
    }
    
    [self fireCompletionCallbacks];
    
    delete codedStream;
    delete inputStream;
}

@end
