//
//  Image2PNGPlugIn.m
//  Image2PNG
//
//  Created by Shin'ichiro SUZUKI on 2015/12/09.
//  Copyright © 2015 szk-engineering. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "Image2PNGPlugIn.h"

#define	kQCPlugIn_Name				@"Image2PNG"
#define	kQCPlugIn_Description		@"Export Image as Portable Network Graphics(PNG)"

@implementation Image2PNGPlugIn

@dynamic inputImage, inputPath;

+ (NSDictionary *)attributes
{
  // Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
  return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
  if ([key isEqualToString:@"inputImage"]) {
    return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey, nil];
  }
  if ([key isEqualToString:@"inputPath"]) {
    return [NSDictionary dictionaryWithObjectsAndKeys:@"Destination Path", QCPortAttributeNameKey, @"~/Desktop", QCPortAttributeDefaultValueKey, nil];
  }
  return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
  // Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
  return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode
{
  // Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
  return kQCPlugInTimeModeNone;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    //
  }
  return self;
}

@end

@implementation Image2PNGPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
  // Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
  // Return NO in case of fatal failure (this will prevent rendering of the composition to start).
  _index = 0;
  return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
  // Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
  /*
   Called by Quartz Composer whenever the plug-in instance needs to execute.
   Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
   Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
   
   The OpenGL context for rendering can be accessed and defined for CGL macros using:
   CGLContextObj cgl_ctx = [context CGLContextObj];
   */
  id<QCPlugInInputImageSource> qcImage = self.inputImage;
  NSString* pixelFormat;
  CGColorSpaceRef colorSpace;
  CGDataProviderRef dataProvider;
  CGImageRef cgImage;
  CGImageDestinationRef imageDestination;
  NSURL* fileURL;
  BOOL success;
  
  if (![self didValueForInputKeyChange:@"inputImage"] || !qcImage || ![self.inputPath length]) {
    return YES;
  }
  
  colorSpace = [qcImage imageColorSpace];
  if(CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) {
    pixelFormat = QCPlugInPixelFormatI8;
  }
  else if(CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) {
#if __BIG_ENDIAN__
    pixelFormat = QCPlugInPixelFormatARGB8;
#else
    pixelFormat = QCPlugInPixelFormatBGRA8;
#endif
  } else {
    return NO;
  }
  
  if (![qcImage lockBufferRepresentationWithPixelFormat:pixelFormat colorSpace:colorSpace forBounds:[qcImage imageBounds]]) {
    return NO;
  }
  
  dataProvider = CGDataProviderCreateWithData(NULL, [qcImage bufferBaseAddress], [qcImage bufferPixelsHigh] * [qcImage bufferBytesPerRow], NULL);
  cgImage = CGImageCreate([qcImage bufferPixelsWide], [qcImage bufferPixelsHigh], 8, (pixelFormat == QCPlugInPixelFormatI8 ? 8 : 32), [qcImage bufferBytesPerRow], colorSpace, (pixelFormat == QCPlugInPixelFormatI8 ? 0 : kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host), dataProvider, NULL, false, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  if(cgImage == NULL) {
    [qcImage unlockBufferRepresentation];
    return NO;
  }
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
  fileURL = [NSURL fileURLWithPath:[[self.inputPath stringByStandardizingPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%05lu.png", [formatter stringFromDate:[NSDate date]], ++_index]]];
  imageDestination = (fileURL ? CGImageDestinationCreateWithURL((CFURLRef)fileURL, kUTTypePNG, 1, NULL) : NULL);
  if(imageDestination == NULL) {
    CGImageRelease(cgImage);
    [qcImage unlockBufferRepresentation];
    return NO;
  }
  CGImageDestinationAddImage(imageDestination, cgImage, NULL);
  success = CGImageDestinationFinalize(imageDestination);
  CFRelease(imageDestination);
  
  CGImageRelease(cgImage);
  [qcImage unlockBufferRepresentation];
  
  return success;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
  // Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
  // Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
