//
//  SPEffectsManager.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/18/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPEffectsManager.h"
#import "SPEffect.h"
#import <objc/runtime.h>

EffectClassStruct *effectClassList;

void registerEffectClass(Class effectClass)
{
    EffectClassStruct *newEffectClass = (EffectClassStruct *)malloc(sizeof(EffectClassStruct));
    newEffectClass->effectClass = effectClass;
    newEffectClass->next = effectClassList;
    effectClassList = newEffectClass;
}

static SPEffectsManager *sharedEffectsManager;

@interface SPEffectsManager ()

- (id<GLKNamedEffect>)effect:(Class)effectClass;
- (void)addEffectClass:(Class)effectClass;

@end

@implementation SPEffectsManager
{
    NSMutableDictionary *effects;
    
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _modelViewMatrix;
}
@synthesize projectionMatrix = _projectionMatrix;
@synthesize modelViewMatrix = _modelViewMatrix;

+ (SPEffectsManager *)sharedEffectsManager
{
    return sharedEffectsManager;
}

+ (void)initializeSharedEffectsManager
{
    sharedEffectsManager = [[SPEffectsManager alloc] init];
    while (effectClassList != NULL)
    {
        [sharedEffectsManager addEffectClass:effectClassList->effectClass];
        EffectClassStruct *processedStruct = effectClassList;
        effectClassList = effectClassList->next;
        free(processedStruct);
    }
}

+ (void)destroySharedEffectsManager
{
    sharedEffectsManager = nil;
}

- (void)setProjectionMatrix:(GLKMatrix4)aProjectionMatrix
{
    _projectionMatrix = aProjectionMatrix;
    
    [effects enumerateKeysAndObjectsUsingBlock:^(id key, SPEffect *effect, BOOL *stop) {
        effect.transform.projectionMatrix = aProjectionMatrix;
    }];
}

- (void)setModelViewMatrix:(GLKMatrix4)aModelViewMatrix
{
    _modelViewMatrix = aModelViewMatrix;
    
    [effects enumerateKeysAndObjectsUsingBlock:^(id key, SPEffect *effect, BOOL *stop) {
        effect.transform.modelviewMatrix = aModelViewMatrix;
    }];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        effects = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addEffectClass:(Class)effectClass
{
    [effects setObject:[[effectClass alloc] init] forKey:[effectClass class]];
}

- (id<GLKNamedEffect>)effect:(Class)effectClass
{
    return [effects objectForKey:effectClass];
}

@end
