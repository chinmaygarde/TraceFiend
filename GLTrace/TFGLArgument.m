//
//  TFGLArgument.m
//  TraceFiend
//
//  Created by Chinmay Garde on 5/31/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFGLArgument+Private.h"

@implementation TFGLArgument

@end

NSString *NSStringFromTFGLArgumentType(TFGLArgumentType type) {
    switch (type) {
        case TFGLArgumentType_UNKNOWN:
            return @"unknown";
        case TFGLArgumentType_VOID:
            return @"GLvoid";
        case TFGLArgumentType_CHAR:
            return @"GLchar";
        case TFGLArgumentType_BYTE:
            return @"GLbyte";
        case TFGLArgumentType_INT:
            return @"GLint";
        case TFGLArgumentType_FLOAT:
            return @"GLfloat";
        case TFGLArgumentType_BOOL:
            return @"GLboolean";
        case TFGLArgumentType_ENUM:
            return @"GLenum";
        case TFGLArgumentType_INT64:
            return @"GLint64";
    }
    
    return @"unknown";
}
