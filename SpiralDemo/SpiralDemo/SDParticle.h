//
//  SDParticle.h
//  SpiralDemo
//
//  Created by Mike Rotondo on 6/15/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "SPParticleManager.h"

@interface SDParticle : SPParticle

+ (GLKTextureInfo *)loadTexture;

@property (nonatomic) GLKVector3 baseScales;
@property (nonatomic) GLKVector3 basePosition;
@property (nonatomic) GLKVector4 baseColor;

@end
