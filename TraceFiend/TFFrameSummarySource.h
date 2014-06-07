//
//  TFFrameSummarySource.h
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

@import Cocoa;

#import "TFGLFrame.h"

@interface TFFrameSummarySource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) TFGLFrame *frame;

@end
