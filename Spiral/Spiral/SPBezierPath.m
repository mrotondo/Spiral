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
}

- (void)createStrokeVBO
{
    // Generate vertex data for path
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
    [self addPoint:[[SPBezierPoint alloc] initWithPosition:position]];
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
    GLKVector3 vertices[numVertices];
    
    GLKVector3 aboveOffset = GLKVector3Make(0, self.lineWidth / 2.0, 0);
    GLKVector3 belowOffset = GLKVector3Make(0, -self.lineWidth / 2.0, 0);
    
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
    
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, numVertices);
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    
    effect.transform.modelviewMatrix = originalModelViewMatrix;
}

@end
