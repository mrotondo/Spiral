//
//  SPColorOnlyEffect.h
//  SpringDudes
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEffect.h"

typedef struct _colorVertexStruct {
    GLKVector3 position;
    GLKVector4 color;
} colorVertexStruct;

@interface SPColorOnlyEffect : SPEffect

@end
