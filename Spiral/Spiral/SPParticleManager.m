//
//  SPParticleManager.m
//  iOSParticles
//
//  Created by Mike Rotondo on 5/14/12.
//  Copyright (c) 2012 Mike Rotondo. All rights reserved.
//

#import "SPParticleManager.h"
#import "SPParticleEffect.h"

@implementation SPParticle

@end

@implementation SPParticleManager
{
    int numVerticesPerParticle;
    int numIndicesPerParticle;

    GLKVector4 *quadVertices;
    GLKVector2 *texCoords;
    
    ParticleVertexStruct *vertices;
    GLuint indexBuffer;
    int maxParticlesPerDrawCall;

    GLuint texture;
    GLint textureUniformIndex;
}

- (id)initWithTexture:(GLuint)aTexture
{
    self = [super init];
    if (self) {
        numVerticesPerParticle = 4;
        numIndicesPerParticle = 6;
        
        [self generateGeometry];
        
        [self allocateVertices];
        
        [self generateIndexBuffer];
        
        texture = aTexture;
    }
    return self;
}

- (void)dealloc
{
    free(quadVertices);
    free(texCoords);
    
    free(vertices);
}

- (void)allocateVertices
{
    maxParticlesPerDrawCall = 100;
    vertices = (ParticleVertexStruct *)malloc(numVerticesPerParticle * maxParticlesPerDrawCall * sizeof(ParticleVertexStruct));
}

- (void)generateIndexBuffer
{
    numIndicesPerParticle = 6;
    int numIndices = maxParticlesPerDrawCall * numIndicesPerParticle;
    unsigned int indices[numIndices];
    
    for (int i = 0; i < maxParticlesPerDrawCall; i++)
    {
        indices[i * 6 + 0] = i * 4 + 0;
        indices[i * 6 + 1] = i * 4 + 1;
        indices[i * 6 + 2] = i * 4 + 2;
        indices[i * 6 + 3] = i * 4 + 3;
        indices[i * 6 + 4] = i * 4 + 3;
        indices[i * 6 + 5] = (i + 1) * 4 + 0;
    }
    
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices * sizeof(unsigned int), indices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


- (void)generateGeometry
{
    quadVertices = (GLKVector4 *)malloc(numVerticesPerParticle * sizeof(GLKVector4));
    quadVertices[0] = GLKVector4Make(-0.5, -0.5, 0, 1);
    quadVertices[1] = GLKVector4Make(-0.5, 0.5, 0, 1);
    quadVertices[2] = GLKVector4Make(0.5, -0.5, 0, 1);
    quadVertices[3] = GLKVector4Make(0.5, 0.5, 0, 1);

    texCoords = (GLKVector2 *)malloc(numVerticesPerParticle * sizeof(GLKVector2));
    texCoords[0] = GLKVector2Make(0, 0);
    texCoords[1] = GLKVector2Make(0, 1);
    texCoords[2] = GLKVector2Make(1, 0);
    texCoords[3] = GLKVector2Make(1, 1);
}

- (void)drawParticles:(NSArray *)particles
{
#warning we don't support drawing particles from back to front yet, so translucent particles in 3D look weird
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    
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
            vertices[i * numVerticesPerParticle + j].position = GLKMatrix4MultiplyVector4(modelViewMatrix, quadVertices[j]);
            vertices[i * numVerticesPerParticle + j].color = particle.color;
            vertices[i * numVerticesPerParticle + j].texCoord = texCoords[j];
        }
        
        ++i;
        
        if (i == maxParticlesPerDrawCall)
        {
            [self drawNumParticles:i];
            i = 0;
        }
    }
    // draw the leftovers
    if (i > 0)
    {
        [self drawNumParticles:i];
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void)drawNumParticles:(unsigned int)numParticles
{
    SPParticleEffect *effect = [SPParticleEffect sharedInstance];
    effect.texture.name = texture;
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glEnableVertexAttribArray(effect.colorVertexAttribute);
    glEnableVertexAttribArray(effect.texCoordVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(ParticleVertexStruct), &vertices[0].position);
    glVertexAttribPointer(effect.colorVertexAttribute, 4, GL_FLOAT, GL_FALSE, sizeof(ParticleVertexStruct), &vertices[0].color);
    glVertexAttribPointer(effect.texCoordVertexAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(ParticleVertexStruct), &vertices[0].texCoord);
    
    glDrawElements(GL_TRIANGLE_STRIP, numParticles * numIndicesPerParticle, GL_UNSIGNED_INT, (void *)0);
    
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    glDisableVertexAttribArray(effect.colorVertexAttribute);
    glDisableVertexAttribArray(effect.texCoordVertexAttribute);
}

@end
