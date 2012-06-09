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
}
@synthesize firstPoint = _firstPoint, lastPoint = _lastPoint;

- (void)addPoint:(SPBezierPoint *)point
{
    if (!_firstPoint)
    {
        _firstPoint = point;
    }

    _lastPoint.nextUserPoint = point;
    _lastPoint = point;
    
    orderedPointsCache = nil;
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
    orderedPointsCache = nil;
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

- (void)strokeWithColor:(GLKVector4)color usingModelViewMatrix:(GLKMatrix4)modelViewMatrix andLineWidth:(float)lineWidth
{
    SPSingleColorEffect *effect = [SPSingleColorEffect sharedInstance];
    GLKMatrix4 originalModelViewMatrix = effect.transform.modelviewMatrix;
    effect.transform.modelviewMatrix = modelViewMatrix;
    effect.color = color;
    
    int numVertices = [self count] * 2;
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
    
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(effect.positionVertexAttribute);
    glVertexAttribPointer(effect.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, numVertices);
    glDisableVertexAttribArray(effect.positionVertexAttribute);
    
    effect.transform.modelviewMatrix = originalModelViewMatrix;
}

@end
