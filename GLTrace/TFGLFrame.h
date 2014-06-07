//
//  TFGLFrame.h
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFGLFunction.h"

@interface TFGLFrame : NSObject

@property (nonatomic, readonly) NSArray *functions;

@property (nonatomic, readonly) NSTimeInterval totalWallTime;
@property (nonatomic, readonly) NSTimeInterval totalThreadTime;

@property (nonatomic, readonly) NSUInteger drawCalls;

-(instancetype) initWithFunctions:(NSArray *) functions;

@end
