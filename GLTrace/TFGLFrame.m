//
//  TFGLFrame.m
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFGLFrame.h"
#import "TFGLFunction.h"

@implementation TFGLFrame

-(instancetype) initWithFunctions:(NSArray *) functions {
    self = [super init];
    
    if (self) {
        _functions = functions;
        
        for (TFGLFunction *function in functions) {
            _totalThreadTime += function.threadTime;
            _totalWallTime += function.wallTime;
            
            switch (function.type) {
                case TFGLFunction_glDrawArrays:
                case TFGLFunction_glDrawArraysInstanced:
                case TFGLFunction_glDrawElements:
                case TFGLFunction_glDrawElementsInstanced:
                    _drawCalls ++;
                    break;
                default:
                    break;
            }
        }
    }
    
    return self;
}

@end
