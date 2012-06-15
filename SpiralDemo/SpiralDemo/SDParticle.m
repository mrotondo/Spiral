//
//  SDParticle.m
//  SpiralDemo
//
//  Created by Mike Rotondo on 6/15/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "SDParticle.h"

@implementation SDParticle

+ (GLKTextureInfo *)loadTexture
{
    NSError *error;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"very_very_blurry_white_circle" ofType:@"png"] options:@{} error:&error];
    if (!textureInfo)
    {
        NSLog(@"Couldn't load particle texture: %@", error);
    }
    return textureInfo;
}

@end
