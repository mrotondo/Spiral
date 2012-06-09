//
//  SPGLKitHelper.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/8/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPGLKitHelper.h"

@implementation SPGLKitHelper

+ (GLKVector2)randomGLKVector2
{
    return GLKVector2Make((arc4random() / (float)0x100000000), 
                          (arc4random() / (float)0x100000000));
}
+ (GLKVector3)randomGLKVector3
{
    return GLKVector3Make((arc4random() / (float)0x100000000),
                          (arc4random() / (float)0x100000000),
                          (arc4random() / (float)0x100000000));
}
+ (GLKVector4)randomGLKVector4
{
    return GLKVector4Make((arc4random() / (float)0x100000000),
                          (arc4random() / (float)0x100000000),
                          (arc4random() / (float)0x100000000),
                          (arc4random() / (float)0x100000000));
}

@end
