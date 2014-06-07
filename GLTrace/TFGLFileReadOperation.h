//
//  TFGLFileReadOperation.h
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFGLTraceReader.h"

@interface TFGLFileReadOperation : NSOperation

@property (nonatomic, readonly) NSFileHandle *fileHandle;
@property (nonatomic, readonly) NSArray *frames;
@property (nonatomic, strong) TFGLTraceReaderCompletion completion;

-(instancetype) initWithFileHandle:(NSFileHandle *) handle;

@end
