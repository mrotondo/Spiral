//
//  SPColorOnlyEffect.m
//  SpringDudes
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPColorOnlyEffect.h"
#import "ShaderProgramLoader.h"

@implementation SPColorOnlyEffect

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"color_only"
                           withColor:YES
                          withNormal:NO
                        withTexCoord:NO];
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];
}

@end
