//
//  SPTextureOnlyEffect.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEffect.h"

typedef struct _texCoordVertexStruct {
    GLKVector3 position;
    GLKVector2 texCoord;
} texCoordVertexStruct;

@interface SPTextureOnlyEffect : SPEffect

@property (nonatomic, strong) GLKEffectPropertyTexture *texture;
@property (nonatomic) GLKVector4 tintColor;

@end
