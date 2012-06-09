//
//  SPMath.h
//  SpringDudes
//
//  Created by Michael Rotondo on 4/22/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 How to make an SPQuad!
 v[1]----v[2]
   |       |
   |       |
 v[0]----v[3]
 */

typedef struct _SPQuad {
    GLKVector2 vertices[4];
} SPQuad;

typedef struct _SPAxisAlignedBoundingBox {
    GLKVector2 lowerLeft;
    GLKVector2 upperRight;
} SPAxisAlignedBoundingBox;

@interface SPMath : NSObject

+ (GLKVector2)transformPoint:(GLKVector2)point fromAABB:(SPAxisAlignedBoundingBox)AABBA toAABB:(SPAxisAlignedBoundingBox)AABBB;

+ (BOOL)quad:(SPQuad)quad containsPoint:(GLKVector2)point;

+ (BOOL)AABB:(SPAxisAlignedBoundingBox)boundingBox containsPoint:(GLKVector2)point;

+ (GLKVector2)sizeOfAABB:(SPAxisAlignedBoundingBox)boundingBox;
+ (GLKVector2)centerOfAABB:(SPAxisAlignedBoundingBox)boundingBox;
+ (SPAxisAlignedBoundingBox)moveAABB:(SPAxisAlignedBoundingBox)boundingBox toNewCenter:(GLKVector2)newCenter;
+ (SPAxisAlignedBoundingBox)scaleAABB:(SPAxisAlignedBoundingBox)boundingBox byAmount:(float)scalingFactor;

@end
