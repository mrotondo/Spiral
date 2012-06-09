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
    GLKVector2 texCoord;
} ParticleVertexStruct;

@interface SPParticleEffect : SPEffect

@property (nonatomic, strong) GLKEffectPropertyTexture *texture;

@end
