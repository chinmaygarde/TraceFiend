//
//  TFFrameSummarySource.m
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFFrameSummarySource.h"

@interface TFSummaryItemModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *children;

@end

@implementation TFSummaryItemModel

@end

@implementation TFFrameSummarySource {
    NSArray *_models;
}

-(void) setFrame:(TFGLFrame *)frame {
    if (_frame == frame)
        return;
    
    _frame = frame;
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    
    // Frame Summary
    TFSummaryItemModel *frameSummary = [[TFSummaryItemModel alloc] init];
    frameSummary.title = @"Frame Summary";
    frameSummary.children = @[
                              [NSString stringWithFormat:@"Total Calls: %ld", frame.functions.count],
                              [NSString stringWithFormat:@"Draw Calls: %ld", frame.drawCalls],
                              [NSString stringWithFormat:@"Active Contexts: %ld", frame.activeContexts],
                              ];
    [models addObject:frameSummary];
    
    _models = models;
}

-(id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
        return _models[index];

    if ([item isKindOfClass:[TFSummaryItemModel class]])
        return [item children][index];
    
    return nil;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item isKindOfClass:[TFSummaryItemModel class]];
}

-(NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return _models.count;
    
    if ([item isKindOfClass:[TFSummaryItemModel class]])
        return [item children].count;
    
    return 0;
}

-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[TFSummaryItemModel class]])
        return [item title];
    
    if ([item isKindOfClass:[NSString class]])
        return item;
    
    return nil;
}

@end
