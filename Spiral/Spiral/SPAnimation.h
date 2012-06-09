//
//  SPAnimation.h
//  SpringDudes
//
//  Created by Michael Rotondo on 4/23/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPMath.h"

typedef enum _SPAnimationCurve
{
    SP_ANIMATION_CURVE_LINEAR = 0,
    SP_ANIMATION_CURVE_EASE_IN_EASE_OUT = 1,
    SP_ANIMATION_CURVE_EASE_IN = 2
} SPAnimationCurve;

typedef void(^SPAnimationCompletionBlock)(void);
typedef void(^SPNumberAnimationUpdateBlock)(float currentValue);
typedef void(^SPGLKVector2AnimationUpdateBlock)(GLKVector2 currentValue);
typedef void(^SPAABBAnimationUpdateBlock)(SPAxisAlignedBoundingBox currentValue);

@interface SPAnimation : NSObject

+ (void)animateNumberFrom:(NSNumber *)startValue to:(NSNumber *)targetValue inSeconds:(NSTimeInterval)seconds withCurve:(SPAnimationCurve)curve andUpdateBlock:(SPNumberAnimationUpdateBlock)updateBlock andCompletionBlock:(SPAnimationCompletionBlock)completionBlock;

+ (void)animateGLKVector2From:(GLKVector2)startValue to:(GLKVector2)targetValue inSeconds:(NSTimeInterval)seconds withCurve:(SPAnimationCurve)curve andUpdateBlock:(SPGLKVector2AnimationUpdateBlock)updateBlock andCompletionBlock:(SPAnimationCompletionBlock)completionBlock;

+ (void)animateAABBFrom:(SPAxisAlignedBoundingBox)startValue to:(SPAxisAlignedBoundingBox)targetValue inSeconds:(NSTimeInterval)seconds withCurve:(SPAnimationCurve)curve andUpdateBlock:(SPAABBAnimationUpdateBlock)updateBlock andCompletionBlock:(SPAnimationCompletionBlock)completionBlock;

+ (void)updateAnimationsWithTimeElapsed:(NSTimeInterval)timeElapsed;

@end
