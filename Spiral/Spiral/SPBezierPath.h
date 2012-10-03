//
//  SPBezierPath.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/23/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPBezierPoint;

typedef void(^SPBezierPathEnumerationBlock)(SPBezierPoint *point, unsigned int i);

@interface SPBezierPath : NSObject

@property (nonatomic, readonly) SPBezierPoint *firstPoint;
@property (nonatomic, readonly) SPBezierPoint *lastPoint;

@property (nonatomic) GLKVector4 color;
@property (nonatomic) float lineWidth;


- (void)addPointAt:(GLKVector2)position;
- (void)interpolateWithMinimumSpacing:(float)spacing;
- (unsigned int)count;
- (void)enumeratePointsWithBlock:(SPBezierPathEnumerationBlock)enumerationBlock;
- (void)enumerateUserPointsWithBlock:(SPBezierPathEnumerationBlock)enumerationBlock;
- (NSArray *)orderedPoints;

- (void)strokeUsingModelViewMatrix:(GLKMatrix4)modelViewMatrix;

@end
