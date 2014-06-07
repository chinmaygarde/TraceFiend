//
//  TFDocument.h
//  TraceFiend
//
//  Created by Chinmay Garde on 5/27/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

@import Cocoa;

#import "TFCommandListSource.h"
#import "TFFrameSummarySource.h"
#import "TFTraceSummarySource.h"

@interface TFDocument : NSDocument <TFCommandListSourceDelegate>

@property (nonatomic, weak) IBOutlet TFCommandListSource *commandListSource;
@property (nonatomic, weak) IBOutlet TFFrameSummarySource *frameSummarySource;
@property (nonatomic, weak) IBOutlet TFTraceSummarySource *traceSummarySource;

@property (nonatomic, weak) IBOutlet NSImageView *imageWell;

@property (nonatomic, weak) IBOutlet NSOutlineView *commandList;
@property (nonatomic, weak) IBOutlet NSOutlineView *frameSummary;
@property (nonatomic, weak) IBOutlet NSOutlineView *traceSummary;

-(IBAction)frameScrubberWasUpdated:(id) slider;

@end
