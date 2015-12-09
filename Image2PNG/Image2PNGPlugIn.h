//
//  Image2PNGPlugIn.h
//  Image2PNG
//
//  Created by Shin'ichiro SUZUKI on 2015/12/09.
//  Copyright © 2015 szk-engineering. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface Image2PNGPlugIn : QCPlugIn
{
  unsigned long _index;
}
@property(assign) id<QCPlugInInputImageSource> inputImage;
@property(assign) NSString* inputPath;

@end
