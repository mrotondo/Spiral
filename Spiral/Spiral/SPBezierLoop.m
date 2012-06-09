//
//  SPBezierLoop.m
//  SpringDudes
//
//  Created by Mandel Bros on 4/26/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPBezierLoop.h"
#import "SPBezierPoint.h"
#import "SPTextureOnlyEffect.h"
#import "SPSingleColorEffect.h"

@implementation SPBezierLoop
{
    NSMutableArray *_userPoints;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userPoints = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.lastPoint.nextUserPoint = nil;
    self.lastPoint.nextPoint = nil;
    self.firstPoint.prevUserPoint = nil;
    self.firstPoint.prevPoint = nil;
}

- (void)addPointAt:(GLKVector2)position
{
    [super addPointAt:position];
    [_userPoints addObject:self.lastPoint];
    self.lastPoint.nextUserPoint = self.firstPoint;
}

- (GLKVector2)centroid
{
    GLKVector2 sum;
    for (SPBezierPoint *point in _userPoints)
    {
        sum = GLKVector2Add(sum, point.position);
    }
    return GLKVector2DivideScalar(sum, [_userPoints count]);
}

- (SPAxisAlignedBoundingBox)boundingBox
{
    __block GLKVector2 lowerLeft = self.firstPoint.position;
    __block GLKVector2 upperRight = self.firstPoint.position;
    [self enumeratePointsWithBlock:^(SPBezierPoint *point, unsigned int i) {
        lowerLeft = GLKVector2Minimum(lowerLeft, point.position);
        upperRight = GLKVector2Maximum(upperRight, point.position);
    }];
    SPAxisAlignedBoundingBox boundingBox;
    boundingBox.lowerLeft = lowerLeft;
    boundingBox.upperRight = upperRight;
    return boundingBox;
}

- (void)fillWithTexture:(GLuint)texture usingModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    SPTextureOnlyEffect *effect = [SPTextureOnlyEffect sharedInstance];
    GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
    
    effect.transform.modelviewMatrix = modelViewMatrix;
    
    effect.texture.name = texture;
    
    SPAxisAlignedBoundingBox boundingBox = [self boundingBox];
    
    SPAxisAlignedBoundingBox unitSquare;
    unitSquare.lowerLeft = GLKVector2Make(0.0, 0.0);
    unitSquare.upperRight = GLKVector2Make(1.0, 1.0);
    
    int numVertices = 1 + [self count] + 1;
    texCoordVertexStruct vertices[numVertices];
    
    GLKVector2 centroid = [self centroid];
    texCoordVertexStruct centerVertex;
    centerVertex.position = GLKVector3Make(centroid.x, centroid.y, 0.0);
    centerVertex.texCoord = [SPMath transformPoint:centroid fromAABB:boundingBox toAABB:unitSquare];
    vertices[0] = centerVertex;
    
    int i = 0;
    for (SPBezierPoint *point in [self orderedPoints])
    {
        texCoordVertexStruct vertex;
        vertex.position = GLKVector3Make(point.position.x, point.position.y, 0.0);
        vertex.texCoord = [SPMath transformPoint:point.position fromAABB:boundingBox toAABB:unitSquare];
        
        vertices[i + 1] = vertex;
        
        i++;
    }
    
    GLKVector2 firstPointPosition = self.firstPoint.position;
    texCoordVertexStruct finalVertex;
    finalVertex.position = GLKVector3Make(firstPointPosition.x, firstPointPosition.y, 0.0);
    finalVertex.texCoord = [SPMath transformPoint:firstPointPosition fromAABB:boundingBox toAABB:unitSquare];
    vertices[numVertices - 1] = finalVertex;
    
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glEnableVertexAttribArray(effect.texCoordVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(texCoordVertexStruct), &vertices[0].position);
    glVertexAttribPointer(effect.texCoordVertexAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(texCoordVertexStruct), &vertices[0].texCoord);
    glDrawArrays(GL_TRIANGLE_FAN, 0, numVertices);
    glDisableVertexAttribArray(effect.texCoordVertexAttribute);
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    
    effect.transform.modelviewMatrix = originalModelViewMatrix;
}

- (void)fillWithColor:(GLKVector4)color usingModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    SPSingleColorEffect *effect = [SPSingleColorEffect sharedInstance];
    GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
    effect.transform.modelviewMatrix = modelViewMatrix;
    effect.color = color;
    
    int numVertices = 1 + [self count] + 1;
    GLKVector3 vertices[numVertices];
    
    GLKVector2 centroid = [self centroid];
    vertices[0] = GLKVector3Make(centroid.x, centroid.y, 0.0);
    
    int i = 0;
    for (SPBezierPoint *point in [self orderedPoints])
    {
        vertices[i+1] = GLKVector3Make(point.position.x, point.position.y, 0.0);
        i++;
    }
    
    GLKVector2 firstPointPosition = self.firstPoint.position;
    vertices[numVertices - 1] = GLKVector3Make(firstPointPosition.x, firstPointPosition.y, 0.0);
    
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLE_FAN, 0, numVertices);
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    
    effect.transform.modelviewMatrix = originalModelViewMatrix;
}

- (void)strokeWithColor:(GLKVector4)color usingModelViewMatrix:(GLKMatrix4)modelViewMatrix andLineWidth:(float)lineWidth
{
    SPSingleColorEffect *effect = [SPSingleColorEffect sharedInstance];
    GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
    effect.transform.modelviewMatrix = modelViewMatrix;
    effect.color = color;
    
    int numVertices = ([self count] + 1) * 2;
    GLKVector3 vertices[numVertices];
    
    GLKVector3 aboveOffset = GLKVector3Make(0, lineWidth / 2.0, 0);
    GLKVector3 belowOffset = GLKVector3Make(0, -lineWidth / 2.0, 0);
    
    int i = 0;
    for (SPBezierPoint *point in [self orderedPoints])
    {
        GLKVector3 pointPosition = GLKVector3Make(point.position.x, point.position.y, 0.0);
        GLKMatrix4 rotation = GLKMatrix4MakeRotation(point.slope, 0, 0, 1);
        GLKVector3 abovePoint = GLKVector3Add(pointPosition, GLKMatrix4MultiplyVector3(rotation, aboveOffset));
        GLKVector3 belowPoint = GLKVector3Add(pointPosition, GLKMatrix4MultiplyVector3(rotation, belowOffset));
        
        vertices[i * 2 + 0] = abovePoint;
        vertices[i * 2 + 1] = belowPoint;
        i++;
    }

    // re-add first point to close the loop.
    SPBezierPoint *point = self.firstPoint;
    GLKVector3 pointPosition = GLKVector3Make(point.position.x, point.position.y, 0.0);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(point.slope, 0, 0, 1);
    GLKVector3 abovePoint = GLKVector3Add(pointPosition, GLKMatrix4MultiplyVector3(rotation, aboveOffset));
    GLKVector3 belowPoint = GLKVector3Add(pointPosition, GLKMatrix4MultiplyVector3(rotation, belowOffset));
    
    vertices[i * 2 + 0] = abovePoint;
    vertices[i * 2 + 1] = belowPoint;
    
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, numVertices);
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    
    effect.transform.modelviewMatrix = originalModelViewMatrix;
}


@end
