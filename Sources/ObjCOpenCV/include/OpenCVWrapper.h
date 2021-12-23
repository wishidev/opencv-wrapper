#import <Foundation/Foundation.h>

@class UIImage;

@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;
+ (UIImage *)processImage:(UIImage *)image;

@end
