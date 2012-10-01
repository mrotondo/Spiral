//
//  SPParticleEffect.h
//  Creatura
//
//  Created by Mike Rotondo on 5/19/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPEffect.h"

typedef struct _ParticleVertexStruct {
    GLKVector4 position;
    GLKVector4 color;
    // We don't store texture here because it is the same for every particle
} ParticleVertexStruct;

@interface SPParticleEffect : SPEffect

@property (nonatomic, strong) GLKEffectPropertyTexture *texture;

@end
