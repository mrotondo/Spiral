//
//  ROPathPoint.m
//  PathStyleTest
//
//  Created by Michael Rotondo on 1/6/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPBezierPoint.h"

@interface SPBezierPoint ()
- (GLKVector2)GLKVector2BezierInterpolationA:(GLKVector2)a B:(GLKVector2)b C:(GLKVector2)c D:(GLKVector2)d T:(float)t;
- (unsigned int)bezierSubdivideA:(GLKVector2)a B:(GLKVector2)b C:(GLKVector2)c D:(GLKVector2)d spacing:(float)spacing;
@end

@implementation SPBezierPoint
{
    GLKVector2 _position;
}
@synthesize nextPoint, prevPoint;
@synthesize prevUserPoint, nextUserPoint;
@synthesize position = _position;

- (id)initWithPosition:(GLKVector2)position
{
    self = [super init];
    if (self) {
        _position = position;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p %@ (prev %p, next %p)>", [self class], self, NSStringFromGLKVector2(self.position), self.prevPoint, self.nextPoint];
}

- (void)setNextPoint:(SPBezierPoint *)newNextPoint
{
    if (nextPoint == newNextPoint)
        return;
    
    nextPoint = newNextPoint;
    nextPoint.prevPoint = self;
}

- (void)setNextUserPoint:(SPBezierPoint *)newNextUserPoint
{
    if (nextUserPoint == newNextUserPoint)
        return;
    
    nextUserPoint = newNextUserPoint;
    nextUserPoint.prevUserPoint = self;
    
    // Assume that we haven't interpolated yet, so we can also set the nextPoint to this point as well.
    nextPoint = newNextUserPoint;
    nextPoint.prevPoint = self;
}

- (float)distanceToPrevPoint
{
    if (self.prevPoint)
        return [self distanceToPoint:self.prevPoint];
    else
        return 0.0f;
}

- (float)distanceToNextPoint
{
    if (self.nextPoint)
        return [self distanceToPoint:self.nextPoint];
    else
        return 0.0f;
}

- (float)distanceToPoint:(SPBezierPoint *)otherPoint
{
    return GLKVector2Length(GLKVector2Subtract(self.position, otherPoint.position));
}

- (float)slope
{
    GLKVector2 tangent = self.tangent;
    return atan2f(tangent.y, tangent.x);
}

// Implements Catmull-Rom tangents (using the vector between the previous and next points to determine the tangent)
- (GLKVector2)tangent
{
    // If there is no next or previous point, arbitrarily say we have a horizontal tangent
    if (!self.nextUserPoint && !self.prevUserPoint && !self.nextPoint && !self.prevPoint)
        return GLKVector2Make(1.0f, 0.0f);
    
    SPBezierPoint *prev = self.prevUserPoint ? self.prevUserPoint : (self.prevPoint ? self.prevPoint : self);
    SPBezierPoint *next = self.nextUserPoint ? self.nextUserPoint : (self.nextPoint ? self.nextPoint : self);
    return GLKVector2DivideScalar(GLKVector2Subtract(next.position, prev.position), 2.0f);
}

- (GLKVector2)normal
{
    GLKVector2 tangent = self.tangent;
    return GLKVector2Normalize(GLKVector2Make(-tangent.y, tangent.x));
}

- (float)normalAngle
{
    GLKVector2 normal = self.normal;
    return atan2f(normal.y, normal.x);
}

- (GLKVector2)GLKVector2BezierInterpolationA:(GLKVector2)a B:(GLKVector2)b C:(GLKVector2)c D:(GLKVector2)d T:(float)t
{
    GLKVector2 ab,bc,cd,abbc,bccd;
    ab = GLKVector2Lerp(a, b, t);           // point between a and b
    bc = GLKVector2Lerp(b, c, t);           // point between b and c
    cd = GLKVector2Lerp(c, d, t);           // point between c and d
    abbc = GLKVector2Lerp(ab, bc, t);       // point between ab and bc
    bccd = GLKVector2Lerp(bc, cd, t);       // point between bc and cd
    return GLKVector2Lerp(abbc,bccd,t);     // point on the bezier-curve
}

- (unsigned int)bezierSubdivisionToNextPointWithSpacing:(float)spacing
{
    if (!self.nextPoint)
        return 0;
    
    GLKVector2 a = self.position;
    GLKVector2 b = GLKVector2Add(self.position, GLKVector2DivideScalar(self.tangent, 3.0f));
    GLKVector2 c = GLKVector2Subtract(self.nextPoint.position, GLKVector2DivideScalar(self.nextPoint.tangent, 3.0f));
    GLKVector2 d = self.nextPoint.position;
    
    return [self bezierSubdivideA:a B:b C:c D:d spacing:spacing];
}

- (unsigned int)bezierSubdivideA:(GLKVector2)a B:(GLKVector2)b C:(GLKVector2)c D:(GLKVector2)d spacing:(float)spacing
{
    unsigned int numPointsAdded = 0;
    
    GLKVector2 ab = GLKVector2Lerp(a, b, 0.5f);
    GLKVector2 bc = GLKVector2Lerp(b, c, 0.5f);
    GLKVector2 cd = GLKVector2Lerp(c, d, 0.5f);
    GLKVector2 abbc = GLKVector2Lerp(ab, bc, 0.5f);
    GLKVector2 bccd = GLKVector2Lerp(bc, cd, 0.5f);
    GLKVector2 newPoint = GLKVector2Lerp(abbc, bccd, 0.5f);
    
    if (GLKVector2Length(GLKVector2Subtract(newPoint, a)) > spacing &&
        GLKVector2Length(GLKVector2Subtract(newPoint, d)) > spacing)
    {
        SPBezierPoint *newPathPoint = [[SPBezierPoint alloc] initWithPosition:newPoint];
        SPBezierPoint *oldNextPoint = self.nextPoint;
        self.nextPoint = newPathPoint;
        newPathPoint.nextPoint = oldNextPoint;
        numPointsAdded += 1;
        
        numPointsAdded += [self bezierSubdivideA:a B:ab C:abbc D:newPoint spacing:spacing];
        numPointsAdded += [newPathPoint bezierSubdivideA:newPoint B:bccd C:cd D:d spacing:spacing];
    }
    
    return numPointsAdded;
}

@end
