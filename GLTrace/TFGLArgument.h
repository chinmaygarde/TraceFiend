//
//  TFGLArgument.h
//  TraceFiend
//
//  Created by Chinmay Garde on 5/31/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TFGLArgumentType) {
    TFGLArgumentType_UNKNOWN = 0,
    TFGLArgumentType_VOID  = 1, // GLvoid
    TFGLArgumentType_CHAR  = 2, // GLchar
    TFGLArgumentType_BYTE  = 3, // GLbyte, GLubyte
    TFGLArgumentType_INT   = 4, // GLbitfield, GLshort, GLint, GLsizei, GLushort, GLuint, GLfixed
    TFGLArgumentType_FLOAT = 5, // GLfloat, GLclampf
    TFGLArgumentType_BOOL  = 6, // GLboolean
    TFGLArgumentType_ENUM  = 7, // GLenum
    TFGLArgumentType_INT64 = 8, // GLint64, GLuint64
};

@interface TFGLArgument : NSObject

@property (nonatomic, readonly) TFGLArgumentType type;

@property (nonatomic, readonly) NSArray *data;

@end

NSString *NSStringFromTFGLArgumentType(TFGLArgumentType type);
