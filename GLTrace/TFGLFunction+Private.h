
#import "TFGLFunction.h"
#import "TFGLArgument+Private.h"
#import "gltrace.pb.h"

@interface TFGLFunction ()

@property (nonatomic, readwrite) TFGLFunctionType type;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSArray *parameters;
@property (nonatomic, readwrite) TFGLArgument *returnValue;
@property (nonatomic, readwrite) TFGLContextID contextID;
@property (nonatomic, readwrite) NSTimeInterval callTime;
@property (nonatomic, readwrite) NSTimeInterval wallTime;
@property (nonatomic, readwrite) NSTimeInterval threadTime;

-(instancetype) initWithMessage:(android::gltrace::GLMessage) message;

@end
