//
//  ITParticleManager.h
//  iOSParticles
//
//  Created by Mike Rotondo on 5/14/12.
//  Copyright (c) 2012 Mike Rotondo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPParticle <NSObject>

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 scales;
@property (nonatomic) GLKVector3 angles;
@property (nonatomic) GLKVector4 color;

@end

@interface SPParticleManager : NSObject

@property (nonatomic) GLuint program;

- (id)initWithTexture:(GLuint)texture;
- (void)drawParticles:(NSArray *)particles;

@end
