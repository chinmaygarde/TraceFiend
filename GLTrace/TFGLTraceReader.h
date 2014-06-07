//
//  TFGLTraceReader.h
//  TraceFiend
//
//  Created by Chinmay Garde on 5/27/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TFGLTraceReaderCompletion)(NSArray *frames);

@interface TFGLTraceReader : NSObject

+(instancetype) sharedReader;

-(void) readFramesFromFile:(NSString *) fileName ofType:(NSString *) filetype completion:(TFGLTraceReaderCompletion) completion;

@end
