//
//  SPEffectsManager.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/18/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _EffectClassStruct {
    Class effectClass;
    struct _EffectClassStruct *next;
} EffectClassStruct;

void registerEffectClass(Class effectClass);

@interface SPEffectsManager : NSObject

@property (nonatomic) GLKMatrix4 projectionMatrix;
@property (nonatomic) GLKMatrix4 modelViewMatrix;

+ (SPEffectsManager *)sharedEffectsManager;
+ (void)initializeSharedEffectsManager;
+ (void)destroySharedEffectsManager;

- (id<GLKNamedEffect>)effect:(Class)effectClass;

@end
