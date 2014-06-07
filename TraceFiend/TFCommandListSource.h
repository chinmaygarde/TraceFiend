//
//  TFCommandListSource.h
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

@import Cocoa;
#import "TFGLFunction.h"

@class TFCommandListSource;
@protocol TFCommandListSourceDelegate <NSObject>

@required
-(void) commandListSource:(TFCommandListSource *) source functionWasSelected:(TFGLFunction *) function;

@end

@interface TFCommandListSource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, weak) IBOutlet id<TFCommandListSourceDelegate> delegate;
@property (nonatomic, strong) NSArray *commands;

@end
