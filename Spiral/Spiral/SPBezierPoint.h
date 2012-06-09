//
//  ROPathPoint.h
//  PathStyleTest
//
//  Created by Michael Rotondo on 1/6/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//


// ROPathPoint is a doubly-linked list object which represents an XY position.
// It can calculate information about the distance and angle to its neighbors.
// It can also create points between itself and its next neighbor using bezier
// interpolation, with a user-specifiable minimum spacing between points.

#import <Foundation/Foundation.h>

@interface SPBezierPoint : NSObject 

@property (nonatomic, strong) SPBezierPoint *nextPoint;
@property (nonatomic, weak) SPBezierPoint *prevPoint;

// For points originating from user input instead of interpolation, we hold onto the user-provided prev & next points so that we can interpolate between these points properly, instead of using the interpolated points to calculate tangents etc
@property (nonatomic, weak) SPBezierPoint *nextUserPoint;
@property (nonatomic, weak) SPBezierPoint *prevUserPoint;

// Dynamically-calculated properties
@property (nonatomic, readonly) GLKVector2 position;
@property (nonatomic, readonly) float distanceToPrevPoint;
@property (nonatomic, readonly) float distanceToNextPoint;
@property (nonatomic, readonly) float slope;
@property (nonatomic, readonly) GLKVector2 tangent;
@property (nonatomic, readonly) GLKVector2 normal; // left-pointing
@property (nonatomic, readonly) float normalAngle;

- (id)initWithPosition:(GLKVector2)position;
- (float)distanceToPoint:(SPBezierPoint *)otherPoint;
- (unsigned int)bezierSubdivisionToNextPointWithSpacing:(float)spacing;

@end
