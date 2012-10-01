//
//  SPParticleManager.m
//  iOSParticles
//
//  Created by Mike Rotondo on 5/14/12.
//  Copyright (c) 2012 Mike Rotondo. All rights reserved.
//

#import "SPParticleManager.h"
#import "SPParticleEffect.h"
#import "glUtil.h"

@implementation SPParticle

@end

@implementation SPParticleManager
{
    int numVerticesPerParticle;
    int numIndicesPerParticle;

    GLKVector4 *quadVertexPositions;
    
    size_t particleVerticesDataSize;
    ParticleVertexStruct *particleVerticesData;
    GLuint textureCoordsVertexBuffer;
    GLuint positionColorVertexBuffer;
    int maxParticlesPerDrawCall;

    GLuint texture;
    GLint textureUniformIndex;
}

- (id)initWithTexture:(GLuint)aTexture
{
    self = [super init];
    if (self) {
        // These are both 6 to account for degenerate points between quads, since we're using triangle strips to render the particles
        numVerticesPerParticle = 6;
        
        // Create the points that define the texture quad (unit square centered around (0, 0))
        [self generateGeometry];
        
        // Allocate the memory we will use to dynamically refill the VBO with particle positions & colors each frame
        [self allocateVertices];
        
        // Create the static texture coords buffer and the dynamic position/color buffer
        [self generateVertexBuffers];
        
        texture = aTexture;
    }
    return self;
}

- (void)dealloc
{
    free(quadVertexPositions);
    free(particleVerticesData);
}

- (void)generateGeometry
{
    // Static quad position data, to be transformed for each particle for each frame
    quadVertexPositions = (GLKVector4 *)malloc(numVerticesPerParticle * sizeof(GLKVector4));
    // first triangle
    quadVertexPositions[0] = GLKVector4Make(-0.5, -0.5, 0, 1);
    quadVertexPositions[1] = GLKVector4Make(-0.5, 0.5, 0, 1);
    quadVertexPositions[2] = GLKVector4Make(0.5, -0.5, 0, 1);
    // second triangle
    quadVertexPositions[3] = GLKVector4Make(-0.5, 0.5, 0, 1);
    quadVertexPositions[4] = GLKVector4Make(0.5, 0.5, 0, 1);
    quadVertexPositions[5] = GLKVector4Make(0.5, -0.5, 0, 1);
}

- (void)allocateVertices
{
    maxParticlesPerDrawCall = 10000; // WHAT SHOULD THIS BE
    particleVerticesDataSize = numVerticesPerParticle * maxParticlesPerDrawCall * sizeof(ParticleVertexStruct);
    particleVerticesData = (ParticleVertexStruct *)malloc(particleVerticesDataSize);
}

- (void)generateTextureCoordsVBO
{
    // Static texture coords data
    const GLKVector2 quadTextureCoordsData[] = {
        // first triangle:
        GLKVector2Make(0.0, 0.0),
        GLKVector2Make(0.0, 1.0),
        GLKVector2Make(1.0, 0.0),
        // second triangle
        GLKVector2Make(0.0, 1.0),
        GLKVector2Make(1.0, 1.0),
        GLKVector2Make(1.0, 0.0)
    };
    
    // We generate a vertex buffer that contains individual texture coords for each particle, even though they are all identical, because we
    // can't mix indexed drawing with non-indexed (drawElements vs drawArrays)
    size_t textureCoordsBufferDataSize = numVerticesPerParticle * maxParticlesPerDrawCall * sizeof(GLKVector2);
    GLKVector2 *textureCoordsBufferData = malloc(textureCoordsBufferDataSize);
    for (int i = 0; i < maxParticlesPerDrawCall; i++)
    {
        for (int j = 0; j < numVerticesPerParticle; j++)
        {
            textureCoordsBufferData[i * numVerticesPerParticle + j] = quadTextureCoordsData[j];
        }
    }
    
    // Generate and populate the texture coords VBO
    glGenBuffers(1, &textureCoordsVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, textureCoordsVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, textureCoordsBufferDataSize, textureCoordsBufferData, GL_STATIC_DRAW);
}

- (void)generatePositionVBO
{
    // We zero out the position & color data array for now, since it will be populated with meaningful data before drawing
    memset(particleVerticesData, 0, particleVerticesDataSize);
    
    // Generate the position and color VBO
    glGenBuffers(1, &positionColorVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, positionColorVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, particleVerticesDataSize, particleVerticesData, GL_DYNAMIC_DRAW);
}

- (void)generateVertexBuffers
{
    [self generateTextureCoordsVBO];
    [self generatePositionVBO];
}

- (void)drawParticles:(NSArray *)particles
{
#warning we don't support drawing particles from back to front yet, so translucent particles in 3D look weird
    
    SPParticleEffect *effect = [SPParticleEffect sharedInstance];
    effect.texture.name = texture;
    [effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, textureCoordsVertexBuffer);
    glVertexAttribPointer(effect.texCoordVertexAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(GLKVector2), (void*)0);
    glEnableVertexAttribArray(effect.texCoordVertexAttribute);
    
    int i = 0;
    for (SPParticle *particle in particles)
    {
        GLKVector3 position = particle.position;
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(position.x, position.y, 0);
#warning we only rotate around the z axis for now.
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, particle.angles.z, 0, 0, 1);
        GLKVector3 scales = particle.scales;
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, scales.x, scales.y, scales.z);
        
        for (int j = 0; j < numVerticesPerParticle; j++)
        {
            particleVerticesData[i * numVerticesPerParticle + j].position = GLKMatrix4MultiplyVector4(modelViewMatrix, quadVertexPositions[j]);
            particleVerticesData[i * numVerticesPerParticle + j].color = particle.color;
        }
        
        ++i;
        
        if (i == maxParticlesPerDrawCall)
        {
            [self drawNumParticles:i withEffect:effect];
            i = 0;
        }
    }
    // draw the leftovers
    if (i > 0)
    {
        [self drawNumParticles:i withEffect:effect];
    }
    
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    glDisableVertexAttribArray(effect.colorVertexAttribute);
    glDisableVertexAttribArray(effect.texCoordVertexAttribute);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)drawNumParticles:(unsigned int)numParticles withEffect:(SPEffect *)effect
{
    glBindBuffer(GL_ARRAY_BUFFER, positionColorVertexBuffer);
    GetGLError();

    glBufferSubData(GL_ARRAY_BUFFER, 0, particleVerticesDataSize, particleVerticesData);

    GetGLError();
    
//    glFlush();
    
    glVertexAttribPointer(effect.positionVertexAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(ParticleVertexStruct), (void *)offsetof(ParticleVertexStruct, position));
    glVertexAttribPointer(effect.colorVertexAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(ParticleVertexStruct), (void *)offsetof(ParticleVertexStruct, color));
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glEnableVertexAttribArray(effect.colorVertexAttribute);
    
    glDrawArrays(GL_TRIANGLES, 0, numParticles * numVerticesPerParticle);
    
}

@end
