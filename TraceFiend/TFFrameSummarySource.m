//
//  TFFrameSummarySource.m
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFFrameSummarySource.h"

@implementation TFFrameSummarySource

-(id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    return nil;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    return NO;
}

-(NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    return 0;
}

-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    
    return NO;
}

@end
