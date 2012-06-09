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

- (void)addPointAt:(GLKVector2)position;
- (void)interpolateWithMinimumSpacing:(float)spacing;
- (unsigned int)count;
- (void)enumeratePointsWithBlock:(SPBezierPathEnumerationBlock)enumerationBlock;
- (void)enumerateUserPointsWithBlock:(SPBezierPathEnumerationBlock)enumerationBlock;
- (NSArray *)orderedPoints;

- (void)strokeWithColor:(GLKVector4)color usingModelViewMatrix:(GLKMatrix4)modelViewMatrix andLineWidth:(float)lineWidth;

@end
