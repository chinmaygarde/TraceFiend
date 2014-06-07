//
//  TFCommandListSource.m
//  TraceFiend
//
//  Created by Chinmay Garde on 6/1/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFCommandListSource.h"

@implementation TFCommandListSource

-(id) outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil)
        return _commands[index];
    
    if ([item isKindOfClass:[TFGLFunction class]]) {
        TFGLFunction *function = item;
        switch (index) {
            case 0 /* Arguments */:
                return function.parameters;
            case 1 /* Return Values */:
                return function.returnValue;
            default:
                break;
        }
    }
    
    return nil;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[TFGLFunction class]])
        return YES;
        
    return NO;
}

-(NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return _commands.count;
 
    if ([item isKindOfClass:[TFGLFunction class]])
        return ((TFGLFunction *)item).returnValue ? 2 : 1;
    
    return 0;
}

-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *columnIdentifier = tableColumn.identifier;
    

    if ([columnIdentifier isEqualToString:@"Function"]) {
        if ([item isKindOfClass:[TFGLFunction class]])
            return [item name];
        
        if ([item isKindOfClass:[TFGLArgument class]])
            return NSStringFromTFGLArgumentType(((TFGLArgument *)item).type);
    }
    
    if ([columnIdentifier isEqualToString:@"WallTime"] && ([item isKindOfClass:[TFGLFunction class]]))
        return @([item wallTime] * 1000.0);
    
    if ([columnIdentifier isEqualToString:@"ThreadTime"] && ([item isKindOfClass:[TFGLFunction class]]))
        return @([item threadTime] * 1000.0);
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    if ([item isKindOfClass:[TFGLFunction class]]) {
        [self.delegate commandListSource:self functionWasSelected:item];
    }
    
    return YES;
}

@end
