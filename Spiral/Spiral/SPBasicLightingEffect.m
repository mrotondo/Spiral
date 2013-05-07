//
//  SPBasicLightingEffect.m
//  Spiral
//
//  Created by Michael Rotondo on 5/6/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

#import "SPBasicLightingEffect.h"
#import "sourceUtil.h"
#import "ShaderProgramLoader.h"

@implementation SPBasicLightingEffect

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"basic_lighting"
                           withColor:YES
                          withNormal:YES
                        withTexCoord:NO];
    if (self)
    {
    }
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];
}

@end
