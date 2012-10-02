//
//  SPParticleEffect.h
//  Creatura
//
//  Created by Mike Rotondo on 5/19/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPEffect.h"
#import "SPParticleEffect.h"

// We don't subclass SPParticleEffect because the way we init effects doesn't handle subclassing well (YET)
@interface SPSoftParticleEffect : SPEffect

@property (nonatomic, strong) GLKEffectPropertyTexture *texture;
@property (nonatomic, strong) GLKEffectPropertyTexture *sceneDepthTexture;
@property (nonatomic) GLKVector2 viewportSize;
@property (nonatomic) GLKVector2 cameraRange;

@end
