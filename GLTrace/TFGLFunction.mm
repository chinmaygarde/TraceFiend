//
//  TFGLFunction.m
//  TraceFiend
//
//  Created by Chinmay Garde on 5/30/14.
//  Copyright (c) 2014 Chinmay Garde. All rights reserved.
//

#import "TFGLFunction+Private.h"

extern "C" {
    #import "lzf.h"
}

#define NanoSecondsToTimeInterval(x) ((NSTimeInterval)(x) / 1000000000.0)

using namespace android::gltrace;

static inline TFGLArgument *TFGLArgumentFromDataType(const GLMessage_DataType& arg) {
    NSMutableArray *argumentData = [[NSMutableArray alloc] init];
    
    switch (arg.type()) {
        case GLMessage_DataType_Type_VOID:
            break;
        case GLMessage_DataType_Type_CHAR:
            
            for (auto it = arg.charvalue().begin(); it != arg.charvalue().end(); ++it) {
                [argumentData addObject:@((*it).c_str())];
            }
            
            break;
        case GLMessage_DataType_Type_BYTE:
            
            for (auto it = arg.rawbytes().begin(); it != arg.rawbytes().end(); ++it) {
                [argumentData addObject:[NSData dataWithBytes:(*it).data() length:(*it).length()]];
            }
            
            break;
        case GLMessage_DataType_Type_INT:
            
            for (auto it = arg.intvalue().begin(); it != arg.intvalue().end(); ++it) {
                [argumentData addObject:@((*it))];
            }
            
            break;
        case GLMessage_DataType_Type_FLOAT:
            
            for (auto it = arg.floatvalue().begin(); it != arg.floatvalue().end(); ++it) {
                [argumentData addObject:@((*it))];
            }
            
            break;
        case GLMessage_DataType_Type_BOOL:
            
            for (auto it = arg.boolvalue().begin(); it != arg.boolvalue().end(); ++it) {
                [argumentData addObject:@((*it))];
            }
            
            break;
        case GLMessage_DataType_Type_INT64:
            
            for (auto it = arg.int64value().begin(); it != arg.int64value().end(); ++it) {
                [argumentData addObject:@((*it))];
            }
            
            break;
        case GLMessage_DataType_Type_ENUM:
        default:
            break;
    }
    
    TFGLArgument *argument = [[TFGLArgument alloc] init];
    argument.type = arg.type();
    argument.data = argumentData;
    
    return argument;
}

@implementation TFGLFunction

-(instancetype) initWithMessage:(android::gltrace::GLMessage) message {
    self = [self init];
    
    if (self) {
        
        _contextID = message.context_id();
        _type = message.function();
        _callTime = NanoSecondsToTimeInterval(message.start_time());
        _wallTime = NanoSecondsToTimeInterval(message.duration());
        _threadTime = NanoSecondsToTimeInterval(message.threadtime());
        
        NSMutableArray *functionArguments = [[NSMutableArray alloc] init];
        int argsCount = message.args_size();
        
        for (int i = 0; i < argsCount; i ++)
            [functionArguments addObject:TFGLArgumentFromDataType(message.args(i))];
        
        _parameters = functionArguments;
        
        if (message.has_returnvalue())
            _returnValue = TFGLArgumentFromDataType(message.returnvalue());
        
        if (message.has_fb()) {
            
            NSSize decompressedDataDimensions = NSMakeSize(message.fb().width(), message.fb().height());
            unsigned int decompressedDataSize = decompressedDataDimensions.width * decompressedDataDimensions.height * 4;

            void *decompressedData = calloc(decompressedDataSize, sizeof(char));
            
            std::string contentString = message.fb().contents(0);

            unsigned int decompressionResult = lzf_decompress(static_cast<const char *>(contentString.data()),
                                                              static_cast<unsigned int>(contentString.length()),
                                                              decompressedData,
                                                              decompressedDataSize);
            
            NSAssert(decompressionResult == decompressedDataSize, @"The size of the decompressed data must be as expected");
            
            if (decompressionResult != 0) {
                CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

                CGContextRef context = CGBitmapContextCreate(decompressedData,
                                                             decompressedDataDimensions.width,
                                                             decompressedDataDimensions.height,
                                                             8,
                                                             4 * decompressedDataDimensions.width,
                                                             colorspace,
                                                             kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
                CGColorSpaceRelease(colorspace);
                
                CGImageRef image = CGBitmapContextCreateImage(context);
                
                _framebufferContents = [[NSImage alloc] initWithCGImage:image size:decompressedDataDimensions];
                
                CGImageRelease(image);
                
                CGContextRelease(context);
            }
            
            
            free(decompressedData);
        }
        
    }
    
    return self;
}

-(NSString *) name {
    
    switch (_type) {
        case TFGLFunction_glActiveTexture:                           return @"glActiveTexture";
        case TFGLFunction_glAlphaFunc:                               return @"glAlphaFunc";
        case TFGLFunction_glAlphaFuncx:                              return @"glAlphaFuncx";
        case TFGLFunction_glAlphaFuncxOES:                           return @"glAlphaFuncxOES";
        case TFGLFunction_glAttachShader:                            return @"glAttachShader";
        case TFGLFunction_glBeginPerfMonitorAMD:                     return @"glBeginPerfMonitorAMD";
        case TFGLFunction_glBindAttribLocation:                      return @"glBindAttribLocation";
        case TFGLFunction_glBindBuffer:                              return @"glBindBuffer";
        case TFGLFunction_glBindFramebuffer:                         return @"glBindFramebuffer";
        case TFGLFunction_glBindFramebufferOES:                      return @"glBindFramebufferOES";
        case TFGLFunction_glBindRenderbuffer:                        return @"glBindRenderbuffer";
        case TFGLFunction_glBindRenderbufferOES:                     return @"glBindRenderbufferOES";
        case TFGLFunction_glBindTexture:                             return @"glBindTexture";
        case TFGLFunction_glBindVertexArrayOES:                      return @"glBindVertexArrayOES";
        case TFGLFunction_glBlendColor:                              return @"glBlendColor";
        case TFGLFunction_glBlendEquation:                           return @"glBlendEquation";
        case TFGLFunction_glBlendEquationOES:                        return @"glBlendEquationOES";
        case TFGLFunction_glBlendEquationSeparate:                   return @"glBlendEquationSeparate";
        case TFGLFunction_glBlendEquationSeparateOES:                return @"glBlendEquationSeparateOES";
        case TFGLFunction_glBlendFunc:                               return @"glBlendFunc";
        case TFGLFunction_glBlendFuncSeparate:                       return @"glBlendFuncSeparate";
        case TFGLFunction_glBlendFuncSeparateOES:                    return @"glBlendFuncSeparateOES";
        case TFGLFunction_glBufferData:                              return @"glBufferData";
        case TFGLFunction_glBufferSubData:                           return @"glBufferSubData";
        case TFGLFunction_glCheckFramebufferStatus:                  return @"glCheckFramebufferStatus";
        case TFGLFunction_glCheckFramebufferStatusOES:               return @"glCheckFramebufferStatusOES";
        case TFGLFunction_glClearColor:                              return @"glClearColor";
        case TFGLFunction_glClearColorx:                             return @"glClearColorx";
        case TFGLFunction_glClearColorxOES:                          return @"glClearColorxOES";
        case TFGLFunction_glClearDepthf:                             return @"glClearDepthf";
        case TFGLFunction_glClearDepthfOES:                          return @"glClearDepthfOES";
        case TFGLFunction_glClearDepthx:                             return @"glClearDepthx";
        case TFGLFunction_glClearDepthxOES:                          return @"glClearDepthxOES";
        case TFGLFunction_glClear:                                   return @"glClear";
        case TFGLFunction_glClearStencil:                            return @"glClearStencil";
        case TFGLFunction_glClientActiveTexture:                     return @"glClientActiveTexture";
        case TFGLFunction_glClipPlanef:                              return @"glClipPlanef";
        case TFGLFunction_glClipPlanefIMG:                           return @"glClipPlanefIMG";
        case TFGLFunction_glClipPlanefOES:                           return @"glClipPlanefOES";
        case TFGLFunction_glClipPlanex:                              return @"glClipPlanex";
        case TFGLFunction_glClipPlanexIMG:                           return @"glClipPlanexIMG";
        case TFGLFunction_glClipPlanexOES:                           return @"glClipPlanexOES";
        case TFGLFunction_glColor4f:                                 return @"glColor4f";
        case TFGLFunction_glColor4ub:                                return @"glColor4ub";
        case TFGLFunction_glColor4x:                                 return @"glColor4x";
        case TFGLFunction_glColor4xOES:                              return @"glColor4xOES";
        case TFGLFunction_glColorMask:                               return @"glColorMask";
        case TFGLFunction_glColorPointer:                            return @"glColorPointer";
        case TFGLFunction_glCompileShader:                           return @"glCompileShader";
        case TFGLFunction_glCompressedTexImage2D:                    return @"glCompressedTexImage2D";
        case TFGLFunction_glCompressedTexImage3DOES:                 return @"glCompressedTexImage3DOES";
        case TFGLFunction_glCompressedTexSubImage2D:                 return @"glCompressedTexSubImage2D";
        case TFGLFunction_glCompressedTexSubImage3DOES:              return @"glCompressedTexSubImage3DOES";
        case TFGLFunction_glCopyTexImage2D:                          return @"glCopyTexImage2D";
        case TFGLFunction_glCopyTexSubImage2D:                       return @"glCopyTexSubImage2D";
        case TFGLFunction_glCopyTexSubImage3DOES:                    return @"glCopyTexSubImage3DOES";
        case TFGLFunction_glCoverageMaskNV:                          return @"glCoverageMaskNV";
        case TFGLFunction_glCoverageOperationNV:                     return @"glCoverageOperationNV";
        case TFGLFunction_glCreateProgram:                           return @"glCreateProgram";
        case TFGLFunction_glCreateShader:                            return @"glCreateShader";
        case TFGLFunction_glCullFace:                                return @"glCullFace";
        case TFGLFunction_glCurrentPaletteMatrixOES:                 return @"glCurrentPaletteMatrixOES";
        case TFGLFunction_glDeleteBuffers:                           return @"glDeleteBuffers";
        case TFGLFunction_glDeleteFencesNV:                          return @"glDeleteFencesNV";
        case TFGLFunction_glDeleteFramebuffers:                      return @"glDeleteFramebuffers";
        case TFGLFunction_glDeleteFramebuffersOES:                   return @"glDeleteFramebuffersOES";
        case TFGLFunction_glDeletePerfMonitorsAMD:                   return @"glDeletePerfMonitorsAMD";
        case TFGLFunction_glDeleteProgram:                           return @"glDeleteProgram";
        case TFGLFunction_glDeleteRenderbuffers:                     return @"glDeleteRenderbuffers";
        case TFGLFunction_glDeleteRenderbuffersOES:                  return @"glDeleteRenderbuffersOES";
        case TFGLFunction_glDeleteShader:                            return @"glDeleteShader";
        case TFGLFunction_glDeleteTextures:                          return @"glDeleteTextures";
        case TFGLFunction_glDeleteVertexArraysOES:                   return @"glDeleteVertexArraysOES";
        case TFGLFunction_glDepthFunc:                               return @"glDepthFunc";
        case TFGLFunction_glDepthMask:                               return @"glDepthMask";
        case TFGLFunction_glDepthRangef:                             return @"glDepthRangef";
        case TFGLFunction_glDepthRangefOES:                          return @"glDepthRangefOES";
        case TFGLFunction_glDepthRangex:                             return @"glDepthRangex";
        case TFGLFunction_glDepthRangexOES:                          return @"glDepthRangexOES";
        case TFGLFunction_glDetachShader:                            return @"glDetachShader";
        case TFGLFunction_glDisableClientState:                      return @"glDisableClientState";
        case TFGLFunction_glDisableDriverControlQCOM:                return @"glDisableDriverControlQCOM";
        case TFGLFunction_glDisable:                                 return @"glDisable";
        case TFGLFunction_glDisableVertexAttribArray:                return @"glDisableVertexAttribArray";
        case TFGLFunction_glDiscardFramebufferEXT:                   return @"glDiscardFramebufferEXT";
        case TFGLFunction_glDrawArrays:                              return @"glDrawArrays";
        case TFGLFunction_glDrawElements:                            return @"glDrawElements";
        case TFGLFunction_glDrawTexfOES:                             return @"glDrawTexfOES";
        case TFGLFunction_glDrawTexfvOES:                            return @"glDrawTexfvOES";
        case TFGLFunction_glDrawTexiOES:                             return @"glDrawTexiOES";
        case TFGLFunction_glDrawTexivOES:                            return @"glDrawTexivOES";
        case TFGLFunction_glDrawTexsOES:                             return @"glDrawTexsOES";
        case TFGLFunction_glDrawTexsvOES:                            return @"glDrawTexsvOES";
        case TFGLFunction_glDrawTexxOES:                             return @"glDrawTexxOES";
        case TFGLFunction_glDrawTexxvOES:                            return @"glDrawTexxvOES";
        case TFGLFunction_glEGLImageTargetRenderbufferStorageOES:    return @"glEGLImageTargetRenderbufferStorageOES";
        case TFGLFunction_glEGLImageTargetTexture2DOES:              return @"glEGLImageTargetTexture2DOES";
        case TFGLFunction_glEnableClientState:                       return @"glEnableClientState";
        case TFGLFunction_glEnableDriverControlQCOM:                 return @"glEnableDriverControlQCOM";
        case TFGLFunction_glEnable:                                  return @"glEnable";
        case TFGLFunction_glEnableVertexAttribArray:                 return @"glEnableVertexAttribArray";
        case TFGLFunction_glEndPerfMonitorAMD:                       return @"glEndPerfMonitorAMD";
        case TFGLFunction_glEndTilingQCOM:                           return @"glEndTilingQCOM";
        case TFGLFunction_glExtGetBufferPointervQCOM:                return @"glExtGetBufferPointervQCOM";
        case TFGLFunction_glExtGetBuffersQCOM:                       return @"glExtGetBuffersQCOM";
        case TFGLFunction_glExtGetFramebuffersQCOM:                  return @"glExtGetFramebuffersQCOM";
        case TFGLFunction_glExtGetProgramBinarySourceQCOM:           return @"glExtGetProgramBinarySourceQCOM";
        case TFGLFunction_glExtGetProgramsQCOM:                      return @"glExtGetProgramsQCOM";
        case TFGLFunction_glExtGetRenderbuffersQCOM:                 return @"glExtGetRenderbuffersQCOM";
        case TFGLFunction_glExtGetShadersQCOM:                       return @"glExtGetShadersQCOM";
        case TFGLFunction_glExtGetTexLevelParameterivQCOM:           return @"glExtGetTexLevelParameterivQCOM";
        case TFGLFunction_glExtGetTexSubImageQCOM:                   return @"glExtGetTexSubImageQCOM";
        case TFGLFunction_glExtGetTexturesQCOM:                      return @"glExtGetTexturesQCOM";
        case TFGLFunction_glExtIsProgramBinaryQCOM:                  return @"glExtIsProgramBinaryQCOM";
        case TFGLFunction_glExtTexObjectStateOverrideiQCOM:          return @"glExtTexObjectStateOverrideiQCOM";
        case TFGLFunction_glFinishFenceNV:                           return @"glFinishFenceNV";
        case TFGLFunction_glFinish:                                  return @"glFinish";
        case TFGLFunction_glFlush:                                   return @"glFlush";
        case TFGLFunction_glFogf:                                    return @"glFogf";
        case TFGLFunction_glFogfv:                                   return @"glFogfv";
        case TFGLFunction_glFogx:                                    return @"glFogx";
        case TFGLFunction_glFogxOES:                                 return @"glFogxOES";
        case TFGLFunction_glFogxv:                                   return @"glFogxv";
        case TFGLFunction_glFogxvOES:                                return @"glFogxvOES";
        case TFGLFunction_glFramebufferRenderbuffer:                 return @"glFramebufferRenderbuffer";
        case TFGLFunction_glFramebufferRenderbufferOES:              return @"glFramebufferRenderbufferOES";
        case TFGLFunction_glFramebufferTexture2D:                    return @"glFramebufferTexture2D";
        case TFGLFunction_glFramebufferTexture2DMultisampleIMG:      return @"glFramebufferTexture2DMultisampleIMG";
        case TFGLFunction_glFramebufferTexture2DOES:                 return @"glFramebufferTexture2DOES";
        case TFGLFunction_glFramebufferTexture3DOES:                 return @"glFramebufferTexture3DOES";
        case TFGLFunction_glFrontFace:                               return @"glFrontFace";
        case TFGLFunction_glFrustumf:                                return @"glFrustumf";
        case TFGLFunction_glFrustumfOES:                             return @"glFrustumfOES";
        case TFGLFunction_glFrustumx:                                return @"glFrustumx";
        case TFGLFunction_glFrustumxOES:                             return @"glFrustumxOES";
        case TFGLFunction_glGenBuffers:                              return @"glGenBuffers";
        case TFGLFunction_glGenerateMipmap:                          return @"glGenerateMipmap";
        case TFGLFunction_glGenerateMipmapOES:                       return @"glGenerateMipmapOES";
        case TFGLFunction_glGenFencesNV:                             return @"glGenFencesNV";
        case TFGLFunction_glGenFramebuffers:                         return @"glGenFramebuffers";
        case TFGLFunction_glGenFramebuffersOES:                      return @"glGenFramebuffersOES";
        case TFGLFunction_glGenPerfMonitorsAMD:                      return @"glGenPerfMonitorsAMD";
        case TFGLFunction_glGenRenderbuffers:                        return @"glGenRenderbuffers";
        case TFGLFunction_glGenRenderbuffersOES:                     return @"glGenRenderbuffersOES";
        case TFGLFunction_glGenTextures:                             return @"glGenTextures";
        case TFGLFunction_glGenVertexArraysOES:                      return @"glGenVertexArraysOES";
        case TFGLFunction_glGetActiveAttrib:                         return @"glGetActiveAttrib";
        case TFGLFunction_glGetActiveUniform:                        return @"glGetActiveUniform";
        case TFGLFunction_glGetAttachedShaders:                      return @"glGetAttachedShaders";
        case TFGLFunction_glGetAttribLocation:                       return @"glGetAttribLocation";
        case TFGLFunction_glGetBooleanv:                             return @"glGetBooleanv";
        case TFGLFunction_glGetBufferParameteriv:                    return @"glGetBufferParameteriv";
        case TFGLFunction_glGetBufferPointervOES:                    return @"glGetBufferPointervOES";
        case TFGLFunction_glGetClipPlanef:                           return @"glGetClipPlanef";
        case TFGLFunction_glGetClipPlanefOES:                        return @"glGetClipPlanefOES";
        case TFGLFunction_glGetClipPlanex:                           return @"glGetClipPlanex";
        case TFGLFunction_glGetClipPlanexOES:                        return @"glGetClipPlanexOES";
        case TFGLFunction_glGetDriverControlsQCOM:                   return @"glGetDriverControlsQCOM";
        case TFGLFunction_glGetDriverControlStringQCOM:              return @"glGetDriverControlStringQCOM";
        case TFGLFunction_glGetError:                                return @"glGetError";
        case TFGLFunction_glGetFenceivNV:                            return @"glGetFenceivNV";
        case TFGLFunction_glGetFixedv:                               return @"glGetFixedv";
        case TFGLFunction_glGetFixedvOES:                            return @"glGetFixedvOES";
        case TFGLFunction_glGetFloatv:                               return @"glGetFloatv";
        case TFGLFunction_glGetFramebufferAttachmentParameteriv:     return @"glGetFramebufferAttachmentParameteriv";
        case TFGLFunction_glGetFramebufferAttachmentParameterivOES:  return @"glGetFramebufferAttachmentParameterivOES";
        case TFGLFunction_glGetIntegerv:                             return @"glGetIntegerv";
        case TFGLFunction_glGetLightfv:                              return @"glGetLightfv";
        case TFGLFunction_glGetLightxv:                              return @"glGetLightxv";
        case TFGLFunction_glGetLightxvOES:                           return @"glGetLightxvOES";
        case TFGLFunction_glGetMaterialfv:                           return @"glGetMaterialfv";
        case TFGLFunction_glGetMaterialxv:                           return @"glGetMaterialxv";
        case TFGLFunction_glGetMaterialxvOES:                        return @"glGetMaterialxvOES";
        case TFGLFunction_glGetPerfMonitorCounterDataAMD:            return @"glGetPerfMonitorCounterDataAMD";
        case TFGLFunction_glGetPerfMonitorCounterInfoAMD:            return @"glGetPerfMonitorCounterInfoAMD";
        case TFGLFunction_glGetPerfMonitorCountersAMD:               return @"glGetPerfMonitorCountersAMD";
        case TFGLFunction_glGetPerfMonitorCounterStringAMD:          return @"glGetPerfMonitorCounterStringAMD";
        case TFGLFunction_glGetPerfMonitorGroupsAMD:                 return @"glGetPerfMonitorGroupsAMD";
        case TFGLFunction_glGetPerfMonitorGroupStringAMD:            return @"glGetPerfMonitorGroupStringAMD";
        case TFGLFunction_glGetPointerv:                             return @"glGetPointerv";
        case TFGLFunction_glGetProgramBinaryOES:                     return @"glGetProgramBinaryOES";
        case TFGLFunction_glGetProgramInfoLog:                       return @"glGetProgramInfoLog";
        case TFGLFunction_glGetProgramiv:                            return @"glGetProgramiv";
        case TFGLFunction_glGetRenderbufferParameteriv:              return @"glGetRenderbufferParameteriv";
        case TFGLFunction_glGetRenderbufferParameterivOES:           return @"glGetRenderbufferParameterivOES";
        case TFGLFunction_glGetShaderInfoLog:                        return @"glGetShaderInfoLog";
        case TFGLFunction_glGetShaderiv:                             return @"glGetShaderiv";
        case TFGLFunction_glGetShaderPrecisionFormat:                return @"glGetShaderPrecisionFormat";
        case TFGLFunction_glGetShaderSource:                         return @"glGetShaderSource";
        case TFGLFunction_glGetString:                               return @"glGetString";
        case TFGLFunction_glGetTexEnvfv:                             return @"glGetTexEnvfv";
        case TFGLFunction_glGetTexEnviv:                             return @"glGetTexEnviv";
        case TFGLFunction_glGetTexEnvxv:                             return @"glGetTexEnvxv";
        case TFGLFunction_glGetTexEnvxvOES:                          return @"glGetTexEnvxvOES";
        case TFGLFunction_glGetTexGenfvOES:                          return @"glGetTexGenfvOES";
        case TFGLFunction_glGetTexGenivOES:                          return @"glGetTexGenivOES";
        case TFGLFunction_glGetTexGenxvOES:                          return @"glGetTexGenxvOES";
        case TFGLFunction_glGetTexParameterfv:                       return @"glGetTexParameterfv";
        case TFGLFunction_glGetTexParameteriv:                       return @"glGetTexParameteriv";
        case TFGLFunction_glGetTexParameterxv:                       return @"glGetTexParameterxv";
        case TFGLFunction_glGetTexParameterxvOES:                    return @"glGetTexParameterxvOES";
        case TFGLFunction_glGetUniformfv:                            return @"glGetUniformfv";
        case TFGLFunction_glGetUniformiv:                            return @"glGetUniformiv";
        case TFGLFunction_glGetUniformLocation:                      return @"glGetUniformLocation";
        case TFGLFunction_glGetVertexAttribfv:                       return @"glGetVertexAttribfv";
        case TFGLFunction_glGetVertexAttribiv:                       return @"glGetVertexAttribiv";
        case TFGLFunction_glGetVertexAttribPointerv:                 return @"glGetVertexAttribPointerv";
        case TFGLFunction_glHint:                                    return @"glHint";
        case TFGLFunction_glIsBuffer:                                return @"glIsBuffer";
        case TFGLFunction_glIsEnabled:                               return @"glIsEnabled";
        case TFGLFunction_glIsFenceNV:                               return @"glIsFenceNV";
        case TFGLFunction_glIsFramebuffer:                           return @"glIsFramebuffer";
        case TFGLFunction_glIsFramebufferOES:                        return @"glIsFramebufferOES";
        case TFGLFunction_glIsProgram:                               return @"glIsProgram";
        case TFGLFunction_glIsRenderbuffer:                          return @"glIsRenderbuffer";
        case TFGLFunction_glIsRenderbufferOES:                       return @"glIsRenderbufferOES";
        case TFGLFunction_glIsShader:                                return @"glIsShader";
        case TFGLFunction_glIsTexture:                               return @"glIsTexture";
        case TFGLFunction_glIsVertexArrayOES:                        return @"glIsVertexArrayOES";
        case TFGLFunction_glLightf:                                  return @"glLightf";
        case TFGLFunction_glLightfv:                                 return @"glLightfv";
        case TFGLFunction_glLightModelf:                             return @"glLightModelf";
        case TFGLFunction_glLightModelfv:                            return @"glLightModelfv";
        case TFGLFunction_glLightModelx:                             return @"glLightModelx";
        case TFGLFunction_glLightModelxOES:                          return @"glLightModelxOES";
        case TFGLFunction_glLightModelxv:                            return @"glLightModelxv";
        case TFGLFunction_glLightModelxvOES:                         return @"glLightModelxvOES";
        case TFGLFunction_glLightx:                                  return @"glLightx";
        case TFGLFunction_glLightxOES:                               return @"glLightxOES";
        case TFGLFunction_glLightxv:                                 return @"glLightxv";
        case TFGLFunction_glLightxvOES:                              return @"glLightxvOES";
        case TFGLFunction_glLineWidth:                               return @"glLineWidth";
        case TFGLFunction_glLineWidthx:                              return @"glLineWidthx";
        case TFGLFunction_glLineWidthxOES:                           return @"glLineWidthxOES";
        case TFGLFunction_glLinkProgram:                             return @"glLinkProgram";
        case TFGLFunction_glLoadIdentity:                            return @"glLoadIdentity";
        case TFGLFunction_glLoadMatrixf:                             return @"glLoadMatrixf";
        case TFGLFunction_glLoadMatrixx:                             return @"glLoadMatrixx";
        case TFGLFunction_glLoadMatrixxOES:                          return @"glLoadMatrixxOES";
        case TFGLFunction_glLoadPaletteFromModelViewMatrixOES:       return @"glLoadPaletteFromModelViewMatrixOES";
        case TFGLFunction_glLogicOp:                                 return @"glLogicOp";
        case TFGLFunction_glMapBufferOES:                            return @"glMapBufferOES";
        case TFGLFunction_glMaterialf:                               return @"glMaterialf";
        case TFGLFunction_glMaterialfv:                              return @"glMaterialfv";
        case TFGLFunction_glMaterialx:                               return @"glMaterialx";
        case TFGLFunction_glMaterialxOES:                            return @"glMaterialxOES";
        case TFGLFunction_glMaterialxv:                              return @"glMaterialxv";
        case TFGLFunction_glMaterialxvOES:                           return @"glMaterialxvOES";
        case TFGLFunction_glMatrixIndexPointerOES:                   return @"glMatrixIndexPointerOES";
        case TFGLFunction_glMatrixMode:                              return @"glMatrixMode";
        case TFGLFunction_glMultiDrawArraysEXT:                      return @"glMultiDrawArraysEXT";
        case TFGLFunction_glMultiDrawElementsEXT:                    return @"glMultiDrawElementsEXT";
        case TFGLFunction_glMultiTexCoord4f:                         return @"glMultiTexCoord4f";
        case TFGLFunction_glMultiTexCoord4x:                         return @"glMultiTexCoord4x";
        case TFGLFunction_glMultiTexCoord4xOES:                      return @"glMultiTexCoord4xOES";
        case TFGLFunction_glMultMatrixf:                             return @"glMultMatrixf";
        case TFGLFunction_glMultMatrixx:                             return @"glMultMatrixx";
        case TFGLFunction_glMultMatrixxOES:                          return @"glMultMatrixxOES";
        case TFGLFunction_glNormal3f:                                return @"glNormal3f";
        case TFGLFunction_glNormal3x:                                return @"glNormal3x";
        case TFGLFunction_glNormal3xOES:                             return @"glNormal3xOES";
        case TFGLFunction_glNormalPointer:                           return @"glNormalPointer";
        case TFGLFunction_glOrthof:                                  return @"glOrthof";
        case TFGLFunction_glOrthofOES:                               return @"glOrthofOES";
        case TFGLFunction_glOrthox:                                  return @"glOrthox";
        case TFGLFunction_glOrthoxOES:                               return @"glOrthoxOES";
        case TFGLFunction_glPixelStorei:                             return @"glPixelStorei";
        case TFGLFunction_glPointParameterf:                         return @"glPointParameterf";
        case TFGLFunction_glPointParameterfv:                        return @"glPointParameterfv";
        case TFGLFunction_glPointParameterx:                         return @"glPointParameterx";
        case TFGLFunction_glPointParameterxOES:                      return @"glPointParameterxOES";
        case TFGLFunction_glPointParameterxv:                        return @"glPointParameterxv";
        case TFGLFunction_glPointParameterxvOES:                     return @"glPointParameterxvOES";
        case TFGLFunction_glPointSize:                               return @"glPointSize";
        case TFGLFunction_glPointSizePointerOES:                     return @"glPointSizePointerOES";
        case TFGLFunction_glPointSizex:                              return @"glPointSizex";
        case TFGLFunction_glPointSizexOES:                           return @"glPointSizexOES";
        case TFGLFunction_glPolygonOffset:                           return @"glPolygonOffset";
        case TFGLFunction_glPolygonOffsetx:                          return @"glPolygonOffsetx";
        case TFGLFunction_glPolygonOffsetxOES:                       return @"glPolygonOffsetxOES";
        case TFGLFunction_glPopMatrix:                               return @"glPopMatrix";
        case TFGLFunction_glProgramBinaryOES:                        return @"glProgramBinaryOES";
        case TFGLFunction_glPushMatrix:                              return @"glPushMatrix";
        case TFGLFunction_glQueryMatrixxOES:                         return @"glQueryMatrixxOES";
        case TFGLFunction_glReadPixels:                              return @"glReadPixels";
        case TFGLFunction_glReleaseShaderCompiler:                   return @"glReleaseShaderCompiler";
        case TFGLFunction_glRenderbufferStorage:                     return @"glRenderbufferStorage";
        case TFGLFunction_glRenderbufferStorageMultisampleIMG:       return @"glRenderbufferStorageMultisampleIMG";
        case TFGLFunction_glRenderbufferStorageOES:                  return @"glRenderbufferStorageOES";
        case TFGLFunction_glRotatef:                                 return @"glRotatef";
        case TFGLFunction_glRotatex:                                 return @"glRotatex";
        case TFGLFunction_glRotatexOES:                              return @"glRotatexOES";
        case TFGLFunction_glSampleCoverage:                          return @"glSampleCoverage";
        case TFGLFunction_glSampleCoveragex:                         return @"glSampleCoveragex";
        case TFGLFunction_glSampleCoveragexOES:                      return @"glSampleCoveragexOES";
        case TFGLFunction_glScalef:                                  return @"glScalef";
        case TFGLFunction_glScalex:                                  return @"glScalex";
        case TFGLFunction_glScalexOES:                               return @"glScalexOES";
        case TFGLFunction_glScissor:                                 return @"glScissor";
        case TFGLFunction_glSelectPerfMonitorCountersAMD:            return @"glSelectPerfMonitorCountersAMD";
        case TFGLFunction_glSetFenceNV:                              return @"glSetFenceNV";
        case TFGLFunction_glShadeModel:                              return @"glShadeModel";
        case TFGLFunction_glShaderBinary:                            return @"glShaderBinary";
        case TFGLFunction_glShaderSource:                            return @"glShaderSource";
        case TFGLFunction_glStartTilingQCOM:                         return @"glStartTilingQCOM";
        case TFGLFunction_glStencilFunc:                             return @"glStencilFunc";
        case TFGLFunction_glStencilFuncSeparate:                     return @"glStencilFuncSeparate";
        case TFGLFunction_glStencilMask:                             return @"glStencilMask";
        case TFGLFunction_glStencilMaskSeparate:                     return @"glStencilMaskSeparate";
        case TFGLFunction_glStencilOp:                               return @"glStencilOp";
        case TFGLFunction_glStencilOpSeparate:                       return @"glStencilOpSeparate";
        case TFGLFunction_glTestFenceNV:                             return @"glTestFenceNV";
        case TFGLFunction_glTexCoordPointer:                         return @"glTexCoordPointer";
        case TFGLFunction_glTexEnvf:                                 return @"glTexEnvf";
        case TFGLFunction_glTexEnvfv:                                return @"glTexEnvfv";
        case TFGLFunction_glTexEnvi:                                 return @"glTexEnvi";
        case TFGLFunction_glTexEnviv:                                return @"glTexEnviv";
        case TFGLFunction_glTexEnvx:                                 return @"glTexEnvx";
        case TFGLFunction_glTexEnvxOES:                              return @"glTexEnvxOES";
        case TFGLFunction_glTexEnvxv:                                return @"glTexEnvxv";
        case TFGLFunction_glTexEnvxvOES:                             return @"glTexEnvxvOES";
        case TFGLFunction_glTexGenfOES:                              return @"glTexGenfOES";
        case TFGLFunction_glTexGenfvOES:                             return @"glTexGenfvOES";
        case TFGLFunction_glTexGeniOES:                              return @"glTexGeniOES";
        case TFGLFunction_glTexGenivOES:                             return @"glTexGenivOES";
        case TFGLFunction_glTexGenxOES:                              return @"glTexGenxOES";
        case TFGLFunction_glTexGenxvOES:                             return @"glTexGenxvOES";
        case TFGLFunction_glTexImage2D:                              return @"glTexImage2D";
        case TFGLFunction_glTexImage3DOES:                           return @"glTexImage3DOES";
        case TFGLFunction_glTexParameterf:                           return @"glTexParameterf";
        case TFGLFunction_glTexParameterfv:                          return @"glTexParameterfv";
        case TFGLFunction_glTexParameteri:                           return @"glTexParameteri";
        case TFGLFunction_glTexParameteriv:                          return @"glTexParameteriv";
        case TFGLFunction_glTexParameterx:                           return @"glTexParameterx";
        case TFGLFunction_glTexParameterxOES:                        return @"glTexParameterxOES";
        case TFGLFunction_glTexParameterxv:                          return @"glTexParameterxv";
        case TFGLFunction_glTexParameterxvOES:                       return @"glTexParameterxvOES";
        case TFGLFunction_glTexSubImage2D:                           return @"glTexSubImage2D";
        case TFGLFunction_glTexSubImage3DOES:                        return @"glTexSubImage3DOES";
        case TFGLFunction_glTranslatef:                              return @"glTranslatef";
        case TFGLFunction_glTranslatex:                              return @"glTranslatex";
        case TFGLFunction_glTranslatexOES:                           return @"glTranslatexOES";
        case TFGLFunction_glUniform1f:                               return @"glUniform1f";
        case TFGLFunction_glUniform1fv:                              return @"glUniform1fv";
        case TFGLFunction_glUniform1i:                               return @"glUniform1i";
        case TFGLFunction_glUniform1iv:                              return @"glUniform1iv";
        case TFGLFunction_glUniform2f:                               return @"glUniform2f";
        case TFGLFunction_glUniform2fv:                              return @"glUniform2fv";
        case TFGLFunction_glUniform2i:                               return @"glUniform2i";
        case TFGLFunction_glUniform2iv:                              return @"glUniform2iv";
        case TFGLFunction_glUniform3f:                               return @"glUniform3f";
        case TFGLFunction_glUniform3fv:                              return @"glUniform3fv";
        case TFGLFunction_glUniform3i:                               return @"glUniform3i";
        case TFGLFunction_glUniform3iv:                              return @"glUniform3iv";
        case TFGLFunction_glUniform4f:                               return @"glUniform4f";
        case TFGLFunction_glUniform4fv:                              return @"glUniform4fv";
        case TFGLFunction_glUniform4i:                               return @"glUniform4i";
        case TFGLFunction_glUniform4iv:                              return @"glUniform4iv";
        case TFGLFunction_glUniformMatrix2fv:                        return @"glUniformMatrix2fv";
        case TFGLFunction_glUniformMatrix3fv:                        return @"glUniformMatrix3fv";
        case TFGLFunction_glUniformMatrix4fv:                        return @"glUniformMatrix4fv";
        case TFGLFunction_glUnmapBufferOES:                          return @"glUnmapBufferOES";
        case TFGLFunction_glUseProgram:                              return @"glUseProgram";
        case TFGLFunction_glValidateProgram:                         return @"glValidateProgram";
        case TFGLFunction_glVertexAttrib1f:                          return @"glVertexAttrib1f";
        case TFGLFunction_glVertexAttrib1fv:                         return @"glVertexAttrib1fv";
        case TFGLFunction_glVertexAttrib2f:                          return @"glVertexAttrib2f";
        case TFGLFunction_glVertexAttrib2fv:                         return @"glVertexAttrib2fv";
        case TFGLFunction_glVertexAttrib3f:                          return @"glVertexAttrib3f";
        case TFGLFunction_glVertexAttrib3fv:                         return @"glVertexAttrib3fv";
        case TFGLFunction_glVertexAttrib4f:                          return @"glVertexAttrib4f";
        case TFGLFunction_glVertexAttrib4fv:                         return @"glVertexAttrib4fv";
        case TFGLFunction_glVertexAttribPointer:                     return @"glVertexAttribPointer";
        case TFGLFunction_glVertexPointer:                           return @"glVertexPointer";
        case TFGLFunction_glViewport:                                return @"glViewport";
        case TFGLFunction_glWeightPointerOES:                        return @"glWeightPointerOES";
        case TFGLFunction_glReadBuffer:                              return @"glReadBuffer";
        case TFGLFunction_glDrawRangeElements:                       return @"glDrawRangeElements";
        case TFGLFunction_glTexImage3D:                              return @"glTexImage3D";
        case TFGLFunction_glTexSubImage3D:                           return @"glTexSubImage3D";
        case TFGLFunction_glCopyTexSubImage3D:                       return @"glCopyTexSubImage3D";
        case TFGLFunction_glCompressedTexImage3D:                    return @"glCompressedTexImage3D";
        case TFGLFunction_glCompressedTexSubImage3D:                 return @"glCompressedTexSubImage3D";
        case TFGLFunction_glGenQueries:                              return @"glGenQueries";
        case TFGLFunction_glDeleteQueries:                           return @"glDeleteQueries";
        case TFGLFunction_glIsQuery:                                 return @"glIsQuery";
        case TFGLFunction_glBeginQuery:                              return @"glBeginQuery";
        case TFGLFunction_glEndQuery:                                return @"glEndQuery";
        case TFGLFunction_glGetQueryiv:                              return @"glGetQueryiv";
        case TFGLFunction_glGetQueryObjectuiv:                       return @"glGetQueryObjectuiv";
        case TFGLFunction_glUnmapBuffer:                             return @"glUnmapBuffer";
        case TFGLFunction_glGetBufferPointerv:                       return @"glGetBufferPointerv";
        case TFGLFunction_glDrawBuffers:                             return @"glDrawBuffers";
        case TFGLFunction_glUniformMatrix2x3fv:                      return @"glUniformMatrix2x3fv";
        case TFGLFunction_glUniformMatrix3x2fv:                      return @"glUniformMatrix3x2fv";
        case TFGLFunction_glUniformMatrix2x4fv:                      return @"glUniformMatrix2x4fv";
        case TFGLFunction_glUniformMatrix4x2fv:                      return @"glUniformMatrix4x2fv";
        case TFGLFunction_glUniformMatrix3x4fv:                      return @"glUniformMatrix3x4fv";
        case TFGLFunction_glUniformMatrix4x3fv:                      return @"glUniformMatrix4x3fv";
        case TFGLFunction_glBlitFramebuffer:                         return @"glBlitFramebuffer";
        case TFGLFunction_glRenderbufferStorageMultisample:          return @"glRenderbufferStorageMultisample";
        case TFGLFunction_glFramebufferTextureLayer:                 return @"glFramebufferTextureLayer";
        case TFGLFunction_glMapBufferRange:                          return @"glMapBufferRange";
        case TFGLFunction_glFlushMappedBufferRange:                  return @"glFlushMappedBufferRange";
        case TFGLFunction_glBindVertexArray:                         return @"glBindVertexArray";
        case TFGLFunction_glDeleteVertexArrays:                      return @"glDeleteVertexArrays";
        case TFGLFunction_glGenVertexArrays:                         return @"glGenVertexArrays";
        case TFGLFunction_glIsVertexArray:                           return @"glIsVertexArray";
        case TFGLFunction_glGetIntegeri_v:                           return @"glGetIntegeri_v";
        case TFGLFunction_glBeginTransformFeedback:                  return @"glBeginTransformFeedback";
        case TFGLFunction_glEndTransformFeedback:                    return @"glEndTransformFeedback";
        case TFGLFunction_glBindBufferRange:                         return @"glBindBufferRange";
        case TFGLFunction_glBindBufferBase:                          return @"glBindBufferBase";
        case TFGLFunction_glTransformFeedbackVaryings:               return @"glTransformFeedbackVaryings";
        case TFGLFunction_glGetTransformFeedbackVarying:             return @"glGetTransformFeedbackVarying";
        case TFGLFunction_glVertexAttribIPointer:                    return @"glVertexAttribIPointer";
        case TFGLFunction_glGetVertexAttribIiv:                      return @"glGetVertexAttribIiv";
        case TFGLFunction_glGetVertexAttribIuiv:                     return @"glGetVertexAttribIuiv";
        case TFGLFunction_glVertexAttribI4i:                         return @"glVertexAttribI4i";
        case TFGLFunction_glVertexAttribI4ui:                        return @"glVertexAttribI4ui";
        case TFGLFunction_glVertexAttribI4iv:                        return @"glVertexAttribI4iv";
        case TFGLFunction_glVertexAttribI4uiv:                       return @"glVertexAttribI4uiv";
        case TFGLFunction_glGetUniformuiv:                           return @"glGetUniformuiv";
        case TFGLFunction_glGetFragDataLocation:                     return @"glGetFragDataLocation";
        case TFGLFunction_glUniform1ui:                              return @"glUniform1ui";
        case TFGLFunction_glUniform2ui:                              return @"glUniform2ui";
        case TFGLFunction_glUniform3ui:                              return @"glUniform3ui";
        case TFGLFunction_glUniform4ui:                              return @"glUniform4ui";
        case TFGLFunction_glUniform1uiv:                             return @"glUniform1uiv";
        case TFGLFunction_glUniform2uiv:                             return @"glUniform2uiv";
        case TFGLFunction_glUniform3uiv:                             return @"glUniform3uiv";
        case TFGLFunction_glUniform4uiv:                             return @"glUniform4uiv";
        case TFGLFunction_glClearBufferiv:                           return @"glClearBufferiv";
        case TFGLFunction_glClearBufferuiv:                          return @"glClearBufferuiv";
        case TFGLFunction_glClearBufferfv:                           return @"glClearBufferfv";
        case TFGLFunction_glClearBufferfi:                           return @"glClearBufferfi";
        case TFGLFunction_glGetStringi:                              return @"glGetStringi";
        case TFGLFunction_glCopyBufferSubData:                       return @"glCopyBufferSubData";
        case TFGLFunction_glGetUniformIndices:                       return @"glGetUniformIndices";
        case TFGLFunction_glGetActiveUniformsiv:                     return @"glGetActiveUniformsiv";
        case TFGLFunction_glGetUniformBlockIndex:                    return @"glGetUniformBlockIndex";
        case TFGLFunction_glGetActiveUniformBlockiv:                 return @"glGetActiveUniformBlockiv";
        case TFGLFunction_glGetActiveUniformBlockName:               return @"glGetActiveUniformBlockName";
        case TFGLFunction_glUniformBlockBinding:                     return @"glUniformBlockBinding";
        case TFGLFunction_glDrawArraysInstanced:                     return @"glDrawArraysInstanced";
        case TFGLFunction_glDrawElementsInstanced:                   return @"glDrawElementsInstanced";
        case TFGLFunction_glFenceSync:                               return @"glFenceSync";
        case TFGLFunction_glIsSync:                                  return @"glIsSync";
        case TFGLFunction_glDeleteSync:                              return @"glDeleteSync";
        case TFGLFunction_glClientWaitSync:                          return @"glClientWaitSync";
        case TFGLFunction_glWaitSync:                                return @"glWaitSync";
        case TFGLFunction_glGetInteger64v:                           return @"glGetInteger64v";
        case TFGLFunction_glGetSynciv:                               return @"glGetSynciv";
        case TFGLFunction_glGetInteger64i_v:                         return @"glGetInteger64i_v";
        case TFGLFunction_glGetBufferParameteri64v:                  return @"glGetBufferParameteri64v";
        case TFGLFunction_glGenSamplers:                             return @"glGenSamplers";
        case TFGLFunction_glDeleteSamplers:                          return @"glDeleteSamplers";
        case TFGLFunction_glIsSampler:                               return @"glIsSampler";
        case TFGLFunction_glBindSampler:                             return @"glBindSampler";
        case TFGLFunction_glSamplerParameteri:                       return @"glSamplerParameteri";
        case TFGLFunction_glSamplerParameteriv:                      return @"glSamplerParameteriv";
        case TFGLFunction_glSamplerParameterf:                       return @"glSamplerParameterf";
        case TFGLFunction_glSamplerParameterfv:                      return @"glSamplerParameterfv";
        case TFGLFunction_glGetSamplerParameteriv:                   return @"glGetSamplerParameteriv";
        case TFGLFunction_glGetSamplerParameterfv:                   return @"glGetSamplerParameterfv";
        case TFGLFunction_glVertexAttribDivisor:                     return @"glVertexAttribDivisor";
        case TFGLFunction_glBindTransformFeedback:                   return @"glBindTransformFeedback";
        case TFGLFunction_glDeleteTransformFeedbacks:                return @"glDeleteTransformFeedbacks";
        case TFGLFunction_glGenTransformFeedbacks:                   return @"glGenTransformFeedbacks";
        case TFGLFunction_glIsTransformFeedback:                     return @"glIsTransformFeedback";
        case TFGLFunction_glPauseTransformFeedback:                  return @"glPauseTransformFeedback";
        case TFGLFunction_glResumeTransformFeedback:                 return @"glResumeTransformFeedback";
        case TFGLFunction_glGetProgramBinary:                        return @"glGetProgramBinary";
        case TFGLFunction_glProgramBinary:                           return @"glProgramBinary";
        case TFGLFunction_glProgramParameteri:                       return @"glProgramParameteri";
        case TFGLFunction_glInvalidateFramebuffer:                   return @"glInvalidateFramebuffer";
        case TFGLFunction_glInvalidateSubFramebuffer:                return @"glInvalidateSubFramebuffer";
        case TFGLFunction_glTexStorage2D:                            return @"glTexStorage2D";
        case TFGLFunction_glTexStorage3D:                            return @"glTexStorage3D";
        case TFGLFunction_glGetInternalformativ:                     return @"glGetInternalformativ";
        case TFGLFunction_glActiveShaderProgramEXT:                  return @"glActiveShaderProgramEXT";
        case TFGLFunction_glAlphaFuncQCOM:                           return @"glAlphaFuncQCOM";
        case TFGLFunction_glBeginQueryEXT:                           return @"glBeginQueryEXT";
        case TFGLFunction_glBindProgramPipelineEXT:                  return @"glBindProgramPipelineEXT";
        case TFGLFunction_glBlitFramebufferANGLE:                    return @"glBlitFramebufferANGLE";
        case TFGLFunction_glCreateShaderProgramvEXT:                 return @"glCreateShaderProgramvEXT";
        case TFGLFunction_glDeleteProgramPipelinesEXT:               return @"glDeleteProgramPipelinesEXT";
        case TFGLFunction_glDeleteQueriesEXT:                        return @"glDeleteQueriesEXT";
        case TFGLFunction_glDrawBuffersNV:                           return @"glDrawBuffersNV";
        case TFGLFunction_glEndQueryEXT:                             return @"glEndQueryEXT";
        case TFGLFunction_glFramebufferTexture2DMultisampleEXT:      return @"glFramebufferTexture2DMultisampleEXT";
        case TFGLFunction_glGenProgramPipelinesEXT:                  return @"glGenProgramPipelinesEXT";
        case TFGLFunction_glGenQueriesEXT:                           return @"glGenQueriesEXT";
        case TFGLFunction_glGetGraphicsResetStatusEXT:               return @"glGetGraphicsResetStatusEXT";
        case TFGLFunction_glGetObjectLabelEXT:                       return @"glGetObjectLabelEXT";
        case TFGLFunction_glGetProgramPipelineInfoLogEXT:            return @"glGetProgramPipelineInfoLogEXT";
        case TFGLFunction_glGetProgramPipelineivEXT:                 return @"glGetProgramPipelineivEXT";
        case TFGLFunction_glGetQueryObjectuivEXT:                    return @"glGetQueryObjectuivEXT";
        case TFGLFunction_glGetQueryivEXT:                           return @"glGetQueryivEXT";
        case TFGLFunction_glGetnUniformfvEXT:                        return @"glGetnUniformEXT";
        case TFGLFunction_glInsertEventMarkerEXT:                    return @"glInsertEventMarkerEXT";
        case TFGLFunction_glIsProgramPipelineEXT:                    return @"glIsProgramPipelineEXT";
        case TFGLFunction_glIsQueryEXT:                              return @"glIsQueryEXT";
        case TFGLFunction_glLabelObjectEXT:                          return @"glLabelObjectEXT";
        case TFGLFunction_glPopGroupMarkerEXT:                       return @"glPopGroupMarkerEXT";
        case TFGLFunction_glProgramParameteriEXT:                    return @"glProgramParameteriEXT";
        case TFGLFunction_glProgramUniform1fEXT:                     return @"glProgramUniform1fEXT";
        case TFGLFunction_glProgramUniform1fvEXT:                    return @"glProgramUniform1fvEXT";
        case TFGLFunction_glProgramUniform1iEXT:                     return @"glProgramUniform1iEXT";
        case TFGLFunction_glProgramUniform1ivEXT:                    return @"glProgramUniform1ivEXT";
        case TFGLFunction_glProgramUniform2fEXT:                     return @"glProgramUniform2fEXT";
        case TFGLFunction_glProgramUniform2fvEXT:                    return @"glProgramUniform2fvEXT";
        case TFGLFunction_glProgramUniform2iEXT:                     return @"glProgramUniform2iEXT";
        case TFGLFunction_glProgramUniform2ivEXT:                    return @"glProgramUniform2ivEXT";
        case TFGLFunction_glProgramUniform3fEXT:                     return @"glProgramUniform3fEXT";
        case TFGLFunction_glProgramUniform3fvEXT:                    return @"glProgramUniform3fvEXT";
        case TFGLFunction_glProgramUniform3iEXT:                     return @"glProgramUniform3iEXT";
        case TFGLFunction_glProgramUniform3ivEXT:                    return @"glProgramUniform3ivEXT";
        case TFGLFunction_glProgramUniform4fEXT:                     return @"glProgramUniform4fEXT";
        case TFGLFunction_glProgramUniform4fvEXT:                    return @"glProgramUniform4fvEXT";
        case TFGLFunction_glProgramUniform4iEXT:                     return @"glProgramUniform4iEXT";
        case TFGLFunction_glProgramUniform4ivEXT:                    return @"glProgramUniform4ivEXT";
        case TFGLFunction_glProgramUniformMatrix2fvEXT:              return @"glProgramUniformMatrix2fvEXT";
        case TFGLFunction_glProgramUniformMatrix3fvEXT:              return @"glProgramUniformMatrix3fvEXT";
        case TFGLFunction_glProgramUniformMatrix4fvEXT:              return @"glProgramUniformMatrix4fvEXT";
        case TFGLFunction_glPushGroupMarkerEXT:                      return @"glPushGroupMarkerEXT";
        case TFGLFunction_glReadBufferNV:                            return @"glReadBufferNV";
        case TFGLFunction_glReadnPixelsEXT:                          return @"glReadnPixelsEXT";
        case TFGLFunction_glRenderbufferStorageMultisampleANGLE:     return @"glRenderbufferStorageMultisampleANGLE";
        case TFGLFunction_glRenderbufferStorageMultisampleAPPLE:     return @"glRenderbufferStorageMultisampleAPPLE";
        case TFGLFunction_glRenderbufferStorageMultisampleEXT:       return @"glRenderbufferStorageMultisampleEXT";
        case TFGLFunction_glResolveMultisampleFramebufferAPPLE:      return @"glResolveMultisampleFramebufferAPPLE";
        case TFGLFunction_glTexStorage1DEXT:                         return @"glTexStorage1DEXT";
        case TFGLFunction_glTexStorage2DEXT:                         return @"glTexStorage2DEXT";
        case TFGLFunction_glTexStorage3DEXT:                         return @"glTexStorage3DEXT";
        case TFGLFunction_glTextureStorage1DEXT:                     return @"glTextureStorage1DEXT";
        case TFGLFunction_glTextureStorage2DEXT:                     return @"glTextureStorage2DEXT";
        case TFGLFunction_glTextureStorage3DEXT:                     return @"glTextureStorage3DEXT";
        case TFGLFunction_glUseProgramStagesEXT:                     return @"glUseProgramStagesEXT";
        case TFGLFunction_glValidateProgramPipelineEXT:              return @"glValidateProgramPipelineEXT";
        case TFGLFunction_eglGetDisplay:                             return @"eglGetDisplay";
        case TFGLFunction_eglInitialize:                             return @"eglInitialize";
        case TFGLFunction_eglTerminate:                              return @"eglTerminate";
        case TFGLFunction_eglGetConfigs:                             return @"eglGetConfigs";
        case TFGLFunction_eglChooseConfig:                           return @"eglChooseConfig";
        case TFGLFunction_eglGetConfigAttrib:                        return @"eglGetConfigAttrib";
        case TFGLFunction_eglCreateWindowSurface:                    return @"eglCreateWindowSurface";
        case TFGLFunction_eglCreatePixmapSurface:                    return @"eglCreatePixmapSurface";
        case TFGLFunction_eglCreatePbufferSurface:                   return @"eglCreatePbufferSurface";
        case TFGLFunction_eglDestroySurface:                         return @"eglDestroySurface";
        case TFGLFunction_eglQuerySurface:                           return @"eglQuerySurface";
        case TFGLFunction_eglCreateContext:                          return @"eglCreateContext";
        case TFGLFunction_eglDestroyContext:                         return @"eglDestroyContext";
        case TFGLFunction_eglMakeCurrent:                            return @"eglMakeCurrent";
        case TFGLFunction_eglGetCurrentContext:                      return @"eglGetCurrentContext";
        case TFGLFunction_eglGetCurrentSurface:                      return @"eglGetCurrentSurface";
        case TFGLFunction_eglGetCurrentDisplay:                      return @"eglGetCurrentDisplay";
        case TFGLFunction_eglQueryContext:                           return @"eglQueryContext";
        case TFGLFunction_eglWaitGL:                                 return @"eglWaitGL";
        case TFGLFunction_eglWaitNative:                             return @"eglWaitNative";
        case TFGLFunction_eglSwapBuffers:                            return @"eglSwapBuffers";
        case TFGLFunction_eglCopyBuffers:                            return @"eglCopyBuffers";
        case TFGLFunction_eglGetError:                               return @"eglGetError";
        case TFGLFunction_eglQueryString:                            return @"eglQueryString";
        case TFGLFunction_eglGetProcAddress:                         return @"eglGetProcAddress";
        case TFGLFunction_eglSurfaceAttrib:                          return @"eglSurfaceAttrib";
        case TFGLFunction_eglBindTexImage:                           return @"eglBindTexImage";
        case TFGLFunction_eglReleaseTexImage:                        return @"eglReleaseTexImage";
        case TFGLFunction_eglSwapInterval:                           return @"eglSwapInterval";
        case TFGLFunction_eglBindAPI:                                return @"eglBindAPI";
        case TFGLFunction_eglQueryAPI:                               return @"eglQueryAPI";
        case TFGLFunction_eglWaitClient:                             return @"eglWaitClient";
        case TFGLFunction_eglReleaseThread:                          return @"eglReleaseThread";
        case TFGLFunction_eglCreatePbufferFromClientBuffer:          return @"eglCreatePbufferFromClientBuffer";
        case TFGLFunction_eglLockSurfaceKHR:                         return @"eglLockSurfaceKHR";
        case TFGLFunction_eglUnlockSurfaceKHR:                       return @"eglUnlockSurfaceKHR";
        case TFGLFunction_eglCreateImageKHR:                         return @"eglCreateImageKHR";
        case TFGLFunction_eglDestroyImageKHR:                        return @"eglDestroyImageKHR";
        case TFGLFunction_eglCreateSyncKHR:                          return @"eglCreateSyncKHR";
        case TFGLFunction_eglDestroySyncKHR:                         return @"eglDestroySyncKHR";
        case TFGLFunction_eglClientWaitSyncKHR:                      return @"eglClientWaitSyncKHR";
        case TFGLFunction_eglGetSyncAttribKHR:                       return @"eglGetSyncAttribKHR";
        case TFGLFunction_eglSetSwapRectangleANDROID:                return @"eglSetSwapRectangleANDROID";
        case TFGLFunction_eglGetRenderBufferANDROID:                 return @"eglGetRenderBufferANDROID";
        case TFGLFunction_eglGetSystemTimeFrequencyNV:               return @"eglGetSystemTimeFrequencyNV";
        case TFGLFunction_eglGetSystemTimeNV:                        return @"eglGetSystemTimeNV";
        case TFGLFunction_invalid:                                   return @"invalid";
        case TFGLFunction_glVertexAttribPointerData:                 return @"glVertexAttribPointerData";
    }

    return @"Unknown";
}

@end
