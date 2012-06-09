//
//  SPGeometricPrimitives.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPGeometricPrimitives.h"
#import "SPTextureOnlyEffect.h"
#import "SPSingleColorEffect.h"

static NSString *SPCircleID = @"SPCircleID";
static NSString *SPQuadID = @"SPQuadID";

static SPGeometricPrimitives *sharedGeometricPrimitives;

@interface SPGeometricPrimitives ()

- (SPStaticGeometryInfoStruct)generateQuadGeometry;

@end

@implementation SPGeometricPrimitives
{
    NSMutableDictionary *primitives;
}

#pragma mark - Singleton setup & access

+ (void)initializeSharedGeometricPrimitives
{
    sharedGeometricPrimitives = [[SPGeometricPrimitives alloc] init];
}

+ (void)destroySharedGeometricPrimitives
{
    sharedGeometricPrimitives = nil;
}

+ (SPGeometricPrimitives *)sharedGeometricPrimitives
{
    return sharedGeometricPrimitives;
}

#pragma mark - Drawing

+ (void)drawPrimitiveForKey:(id)key withTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    SPStaticGeometry *primitive = [[self sharedGeometricPrimitives] primitiveForKey:key];
    
    [primitive drawGeometryWithBlock:^(SPStaticGeometryInfoStruct geometryInfo) {
        SPTextureOnlyEffect *effect = [SPTextureOnlyEffect sharedInstance];
        effect.texture.name = texture;

        GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
        effect.transform.modelviewMatrix = modelViewMatrix;
        [effect prepareToDraw];
        
        glEnableVertexAttribArray(effect.positionVertexAttribute);
        glEnableVertexAttribArray(effect.texCoordVertexAttribute);
        
        glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, position));
        glVertexAttribPointer(effect.texCoordVertexAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, texCoord));
        glDrawElements(geometryInfo.primitiveType, geometryInfo.numIndices, GL_UNSIGNED_INT, (void *)0);
        
        glDisableVertexAttribArray(effect.positionVertexAttribute);
        glDisableVertexAttribArray(effect.texCoordVertexAttribute);
        
        effect.transform.modelviewMatrix = originalModelViewMatrix;

    }];
}

+ (void)drawPrimitiveForKey:(id)key withColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    SPStaticGeometry *primitive = [[self sharedGeometricPrimitives] primitiveForKey:key];
    
    [primitive drawGeometryWithBlock:^(SPStaticGeometryInfoStruct geometryInfo) {
        SPSingleColorEffect *effect = [SPSingleColorEffect sharedInstance];
        effect.color = color;
        
        GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
        effect.transform.modelviewMatrix = modelViewMatrix;
        [effect prepareToDraw];
        
        glEnableVertexAttribArray(effect.positionVertexAttribute);
        glEnableVertexAttribArray(effect.texCoordVertexAttribute);
        
        glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, position));
        glDrawElements(geometryInfo.primitiveType, geometryInfo.numIndices, GL_UNSIGNED_INT, (void *)0);
        
        glDisableVertexAttribArray(effect.positionVertexAttribute);
        
        effect.transform.modelviewMatrix = originalModelViewMatrix;
    }];
}

+ (void)drawPrimitiveForKey:(id)key withBlock:(SPStaticGeometryDrawingBlock)block
{
    SPStaticGeometry *geometry = [[self sharedGeometricPrimitives] primitiveForKey:key];
    [geometry drawGeometryWithBlock:block];
}

#pragma mark - Convenience methods

+ (void)drawCircleWithColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    [self drawPrimitiveForKey:SPCircleID withColor:color andModelViewMatrix:modelViewMatrix];
}

+ (void)drawQuadWithColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    [self drawPrimitiveForKey:SPQuadID withColor:color andModelViewMatrix:modelViewMatrix];
}

+ (void)drawRegularPolygonWithNumSides:(int)numSides withColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    [[self sharedGeometricPrimitives] ensureExistenceOfRegularPolygonWithNumSides:numSides];
    [self drawPrimitiveForKey:[self primitiveIDForRegularPolygonWithNumSides:numSides] withColor:color andModelViewMatrix:modelViewMatrix];
}

+ (void)drawCircleWithTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    [self drawPrimitiveForKey:SPCircleID withTexture:texture andModelViewMatrix:modelViewMatrix];
}

+ (void)drawQuadWithTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    [self drawPrimitiveForKey:SPQuadID withTexture:texture andModelViewMatrix:modelViewMatrix];
}

+ (void)drawRegularPolygonWithNumSides:(int)numSides withTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
{
    [[self sharedGeometricPrimitives] ensureExistenceOfRegularPolygonWithNumSides:numSides];
    [self drawPrimitiveForKey:[self primitiveIDForRegularPolygonWithNumSides:numSides] withTexture:texture andModelViewMatrix:modelViewMatrix];
}

+ (void)drawCircleWithBlock:(SPStaticGeometryDrawingBlock)block
{
    [self drawPrimitiveForKey:SPCircleID withBlock:block];
}

+ (void)drawQuadWithBlock:(SPStaticGeometryDrawingBlock)block
{
    [self drawPrimitiveForKey:SPQuadID withBlock:block];
}

+ (void)drawRegularPolygonWithNumSides:(int)numSides withBlock:(SPStaticGeometryDrawingBlock)block
{
    [[self sharedGeometricPrimitives] ensureExistenceOfRegularPolygonWithNumSides:numSides];
    [self drawPrimitiveForKey:[self primitiveIDForRegularPolygonWithNumSides:numSides] withBlock:block];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        primitives = [@{
        SPCircleID : [[SPStaticGeometry alloc] initWithGeometryInitializationBlock:
                      ^SPStaticGeometryInfoStruct
                      {
                          return [self generateRegularPolygonWithNumSides:32];
                      }],
        SPQuadID : [[SPStaticGeometry alloc] initWithGeometryInitializationBlock:
                    ^SPStaticGeometryInfoStruct
                    {
                        return [self generateQuadGeometry];
                    }]
        } mutableCopy];
    }
    return self;
}

- (SPStaticGeometry *)primitiveForKey:(NSString *)key
{
    return [primitives objectForKey:key];
}

+ (NSString *)primitiveIDForRegularPolygonWithNumSides:(int)numSides
{
    return [NSString stringWithFormat:@"SPRegularPolygon%dID", numSides];
}

- (void)ensureExistenceOfRegularPolygonWithNumSides:(int)numSides
{
    NSString *key = [[self class] primitiveIDForRegularPolygonWithNumSides:numSides];
    SPStaticGeometry *geometry = [self primitiveForKey:key];
    if (!geometry)
    {
        geometry = [[SPStaticGeometry alloc] initWithGeometryInitializationBlock:^SPStaticGeometryInfoStruct{
            return [self generateRegularPolygonWithNumSides:numSides];
        }];
        [primitives setObject:geometry forKey:key];
    }
}

- (SPStaticGeometryInfoStruct)generateRegularPolygonWithNumSides:(int)numSides
{
    unsigned int numSegments = numSides;
    unsigned int numVertices = 1 + numSegments + 1;  // One for the center, one to close the loop
    primitiveVertexStruct *vertices = (primitiveVertexStruct *)malloc(sizeof(primitiveVertexStruct) * numVertices);
    unsigned int *indices = (unsigned int *)malloc(sizeof(unsigned int) * numVertices);
    
    primitiveVertexStruct center;
    center.position = GLKVector3Make(0, 0, 0);
    center.texCoord = GLKVector2Make(0, 0);
    vertices[0] = center;
    indices[0] = 0;
    
    for (int i = 0; i < numSegments + 1; i++)
    {
        float angle = 2 * M_PI * ((float)i / numSegments);
        primitiveVertexStruct primitiveVertex;
        primitiveVertex.position = GLKVector3Make(cosf(angle), sinf(angle), 0);
        primitiveVertex.texCoord = GLKVector2Make(primitiveVertex.position.x / 2 + 0.5,
                                                  primitiveVertex.position.y / 2 + 0.5);
        vertices[i + 1] = primitiveVertex;
        indices[i + 1] = i + 1;
    }
    
    SPStaticGeometryInfoStruct geometryInfo;
    geometryInfo.numVertices = numVertices;
    geometryInfo.sizeOfVertex = sizeof(primitiveVertexStruct);
    geometryInfo.vertices = vertices;
    
    geometryInfo.numIndices = numVertices;
    geometryInfo.sizeOfIndex = sizeof(unsigned int);
    geometryInfo.indices = indices;
    
    geometryInfo.primitiveType = GL_TRIANGLE_FAN;
    
    return geometryInfo;
}

- (SPStaticGeometryInfoStruct)generateQuadGeometry
{
    unsigned int numVertices = 4;
    primitiveVertexStruct *vertices = (primitiveVertexStruct *)malloc(sizeof(primitiveVertexStruct) * numVertices);
    unsigned int *indices = (unsigned int *)malloc(sizeof(unsigned int) * numVertices);
    
    vertices[0].position = GLKVector3Make(-0.5, -0.5, 0);
    vertices[0].texCoord = GLKVector2Make(0, 0);

    vertices[1].position = GLKVector3Make(-0.5, 0.5, 0);
    vertices[1].texCoord = GLKVector2Make(0, 1);

    vertices[2].position = GLKVector3Make(0.5, -0.5, 0);
    vertices[2].texCoord = GLKVector2Make(1, 0);

    vertices[3].position = GLKVector3Make(0.5, 0.5, 0);
    vertices[3].texCoord = GLKVector2Make(1, 1);
    
    for (int i = 0; i < numVertices; i++)
    {
        indices[i] = i;
    }
    
    SPStaticGeometryInfoStruct geometryInfo;
    geometryInfo.numVertices = numVertices;
    geometryInfo.sizeOfVertex = sizeof(primitiveVertexStruct);
    geometryInfo.vertices = vertices;
    
    geometryInfo.numIndices = numVertices;
    geometryInfo.sizeOfIndex = sizeof(unsigned int);
    geometryInfo.indices = indices;
    
    geometryInfo.primitiveType = GL_TRIANGLE_STRIP;
    
    return geometryInfo;
}

@end
