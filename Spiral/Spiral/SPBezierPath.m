//
//  SPBezierPath.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/23/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPBezierPath.h"
#import "SPBezierPoint.h"
#import "SPSingleColorEffect.h"

@interface SPBezierPath ()

- (void)addPoint:(SPBezierPoint *)point;

@end

@implementation SPBezierPath
{
    SPBezierPoint *_firstPoint;
    SPBezierPoint *_lastPoint;
    
    unsigned int _count;

    NSArray *orderedPointsCache;
    
    GLuint strokeVBO;
}
@synthesize firstPoint = _firstPoint, lastPoint = _lastPoint;

- (void)setColor:(GLKVector4)color
{
    [self resetCaches];
    _color = color;
}

- (void)setLineWidth:(float)lineWidth
{
    [self resetCaches];
    _lineWidth = lineWidth;
}

- (void)resetCaches
{
    orderedPointsCache = nil;

    // reset stroke VBO
    glDeleteBuffers(1, &strokeVBO);
    strokeVBO = 0;
}

- (void)createStrokeVBO
{
    // Generate vertex data for path
    int numVertices = [self count] * 2;
    size_t verticesSize = numVertices * sizeof(GLKVector3);
    GLKVector3 vertices[numVertices];
    
    GLKVector3 baseAboveOffset = GLKVector3Make(0, self.lineWidth / 2.0, 0);
    GLKVector3 baseBelowOffset = GLKVector3Make(0, -self.lineWidth / 2.0, 0);

    float widthScalingFactor = 1.0;
//    float widthScalingFactorSmoothness = 0.99;
//    float widthScalingFactorTarget = 1.0;
    
    int i = 0;
    for (SPBezierPoint *point in [self orderedPoints])
    {
//        if ( point.isUserPoint )
//        {
//            widthScalingFactorTarget = 1 + (/* 1 - */ MAX(0, MIN(20, point.distanceToNextUserPoint / 0.01)));
////            NSLog(@"distance to next user point: %f, width scaling factor target: %f", point.distanceToNextUserPoint, widthScalingFactorTarget);
//        }
//        widthScalingFactor = widthScalingFactorSmoothness * widthScalingFactor + (1.0 - widthScalingFactorSmoothness) * widthScalingFactorTarget;
        
        GLKVector3 aboveOffset = GLKVector3MultiplyScalar(baseAboveOffset, widthScalingFactor);
        GLKVector3 belowOffset = GLKVector3MultiplyScalar(baseBelowOffset, widthScalingFactor);
        
        GLKVector3 pointPosition = GLKVector3Make(point.position.x, point.position.y, 0.0);
        GLKMatrix4 rotation = GLKMatrix4MakeRotation(point.slope, 0, 0, 1);
        GLKVector3 abovePoint = GLKVector3Add(pointPosition, GLKMatrix4MultiplyVector3(rotation, aboveOffset));
        GLKVector3 belowPoint = GLKVector3Add(pointPosition, GLKMatrix4MultiplyVector3(rotation, belowOffset));
        
        vertices[i * 2 + 0] = abovePoint;
        vertices[i * 2 + 1] = belowPoint;
        i++;
    }
    
    glGenBuffers(1, &strokeVBO);
    glBindBuffer(GL_ARRAY_BUFFER, strokeVBO);
    glBufferData(GL_ARRAY_BUFFER, verticesSize, vertices, GL_STATIC_DRAW);
}

- (void)addPoint:(SPBezierPoint *)point
{
    if (!_firstPoint)
    {
        _firstPoint = point;
    }

    _lastPoint.nextUserPoint = point;
    _lastPoint = point;
    
    [self resetCaches];
}

- (void)addPointAt:(GLKVector2)position
{
    SPBezierPoint *newPoint = [[SPBezierPoint alloc] initWithPosition:position];
    newPoint.isUserPoint = YES;
    [self addPoint:newPoint];
    ++_count;
}

- (void)interpolateWithMinimumSpacing:(float)spacing
{
    [self enumerateUserPointsWithBlock:^(SPBezierPoint *point, unsigned int i) {
        _count += [point bezierSubdivisionToNextPointWithSpacing:spacing];
    }];
    [self resetCaches];
}

- (unsigned int)count
{
    return _count;
}

- (void)enumeratePointsWithBlock:(SPBezierPathEnumerationBlock)enumerationBlock
{
    NSMutableSet *visitedPoints = [NSMutableSet setWithCapacity:_count];
    unsigned int i = 0;
    SPBezierPoint *point = _firstPoint;
    while (point)
    {
        if ([visitedPoints containsObject:point])
            return;
            
        [visitedPoints addObject:point];
        enumerationBlock(point, i++);
        point = point.nextPoint;
    }
}

- (void)enumerateUserPointsWithBlock:(SPBezierPathEnumerationBlock)enumerationBlock
{
    NSMutableSet *visitedPoints = [NSMutableSet setWithCapacity:_count];
    unsigned int i = 0;
    SPBezierPoint *point = _firstPoint;
    while (point)
    {
        if ([visitedPoints containsObject:point])
            return;
        
        [visitedPoints addObject:point];
        enumerationBlock(point, i++);
        point = point.nextUserPoint;
    }
}

- (NSArray *)orderedPoints
{
    if (orderedPointsCache)
    {
        return orderedPointsCache;
    }
    
    NSMutableArray *orderedPoints = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumeratePointsWithBlock:^(SPBezierPoint *point, unsigned int i) {
        [orderedPoints addObject:point];
    }];
    orderedPointsCache = orderedPoints;
    return orderedPoints;
}

- (void)strokeUsingModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    SPSingleColorEffect *effect = [SPSingleColorEffect sharedInstance];
    GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
    effect.transform.modelviewMatrix = modelViewMatrix;
    effect.color = self.color;
    
    int numVertices = [self count] * 2;
    
    if (!strokeVBO)
    {
        [self createStrokeVBO];
    }
    
    [effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, strokeVBO);
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, 0, (void *)0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, numVertices);
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    effect.transform.modelviewMatrix = originalModelViewMatrix;
}

@end
