//
//  SPBezierLoop.h
//  SpringDudes
//
//  Created by Mandel Bros on 4/26/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPBezierPath.h"
#import "SPMath.h"

@interface SPBezierLoop : SPBezierPath

- (GLKVector2)centroid;
- (SPAxisAlignedBoundingBox)boundingBox;

// Filling only works correctly if the bezier loop is convex!! (Because it uses a triangle fan with a point at the centroid, not crazy ear clipping or whatever other expensive concave triangulation algorithm)
- (void)fillWithTexture:(GLuint)texture usingModelViewMatrix:(GLKMatrix4)modelViewMatrix;
- (void)fillWithColor:(GLKVector4)color usingModelViewMatrix:(GLKMatrix4)modelViewMatrix;

@end
