//
//  SPMath.m
//  SpringDudes
//
//  Created by Michael Rotondo on 4/22/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPMath.h"

@implementation SPMath

+ (GLKVector2)transformPoint:(GLKVector2)point fromAABB:(SPAxisAlignedBoundingBox)AABBA toAABB:(SPAxisAlignedBoundingBox)AABBB
{
    GLKVector2 sizeA = GLKVector2Subtract(AABBA.upperRight, AABBA.lowerLeft);
    GLKVector2 normalizedPoint = GLKVector2Divide(GLKVector2Subtract(point, AABBA.lowerLeft), sizeA);
    
    GLKVector2 sizeB = GLKVector2Subtract(AABBB.upperRight, AABBB.lowerLeft);
    GLKVector2 translatedPoint = GLKVector2Add(GLKVector2Multiply(normalizedPoint, sizeB), AABBB.lowerLeft);
    
    return translatedPoint;
}

+ (BOOL)quad:(SPQuad)quad containsPoint:(GLKVector2)point
{
    for (int i = 0; i < 4; i++)
    {
        GLKVector2 v0 = quad.vertices[i];
        GLKVector2 v1 = quad.vertices[(i + 1) % 4];
        
        GLKVector2 line = GLKVector2Subtract(v1, v0);
        GLKVector2 perpendicular = GLKVector2Make(-line.y, line.x);
        
        GLKVector2 lineToNewPoint = GLKVector2Subtract(point, v0);
        
        float side = GLKVector2DotProduct(perpendicular, lineToNewPoint);
        
        if (side > 0)
            return NO;
    }
    return YES;
}

+ (BOOL)AABB:(SPAxisAlignedBoundingBox)boundingBox containsPoint:(GLKVector2)point
{
    return (point.x >= boundingBox.lowerLeft.x &&
            point.x <= boundingBox.upperRight.x &&
            point.y >= boundingBox.lowerLeft.y &&
            point.y <= boundingBox.upperRight.y);
}

+ (GLKVector2)sizeOfAABB:(SPAxisAlignedBoundingBox)boundingBox
{
    GLKVector2 size = GLKVector2Subtract(boundingBox.upperRight, boundingBox.lowerLeft);
    return size;
}

+ (GLKVector2)centerOfAABB:(SPAxisAlignedBoundingBox)boundingBox
{
    GLKVector2 halfSize = GLKVector2DivideScalar(GLKVector2Subtract(boundingBox.upperRight, boundingBox.lowerLeft), 2.0);
    return GLKVector2Add(boundingBox.lowerLeft, halfSize);
}

+ (SPAxisAlignedBoundingBox)moveAABB:(SPAxisAlignedBoundingBox)boundingBox toNewCenter:(GLKVector2)newCenter
{
    GLKVector2 halfSize = GLKVector2DivideScalar(GLKVector2Subtract(boundingBox.upperRight, boundingBox.lowerLeft), 2.0);
    SPAxisAlignedBoundingBox newAABB;
    newAABB.lowerLeft = GLKVector2Subtract(newCenter, halfSize);
    newAABB.upperRight = GLKVector2Add(newCenter, halfSize);
    return newAABB;
}

+ (SPAxisAlignedBoundingBox)scaleAABB:(SPAxisAlignedBoundingBox)boundingBox byAmount:(float)scalingFactor
{
    GLKVector2 center = [self centerOfAABB:boundingBox];
    GLKVector2 halfSize = GLKVector2DivideScalar(GLKVector2Subtract(boundingBox.upperRight, boundingBox.lowerLeft), 2.0);
    GLKVector2 newHalfSize = GLKVector2MultiplyScalar(halfSize, scalingFactor);
    SPAxisAlignedBoundingBox newAABB;
    newAABB.lowerLeft = GLKVector2Subtract(center, newHalfSize);
    newAABB.upperRight = GLKVector2Add(center, newHalfSize);
    return newAABB;
}

@end
