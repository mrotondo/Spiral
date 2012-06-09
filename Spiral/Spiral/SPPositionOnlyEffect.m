//
//  SPPositionOnlyEffect.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPPositionOnlyEffect.h"
#import "sourceUtil.h"
#import "ShaderProgramLoader.h"

@implementation SPPositionOnlyEffect

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"position_only"
                           withColor:NO
                          withNormal:NO
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
