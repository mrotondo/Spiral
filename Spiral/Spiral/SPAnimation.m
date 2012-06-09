//
//  SPAnimation.m
//  SpringDudes
//
//  Created by Michael Rotondo on 4/23/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPAnimation.h"

NSMutableSet *animations;

@interface SPAnimation ()

@property (nonatomic, readonly) BOOL complete;

- (void)updateValue;

@end

@interface SPNumberAnimation : SPAnimation

- (id)initWithStartValue:(NSNumber *)startValue targetValue:(NSNumber *)targetValue length:(NSTimeInterval)length curve:(SPAnimationCurve)curve updateBlock:(SPNumberAnimationUpdateBlock)updateBlock completionBlock:(SPAnimationCompletionBlock)completionBlock;

@end

@interface SPGLKVector2Animation : SPAnimation

- (id)initWithStartValue:(GLKVector2)startValue targetValue:(GLKVector2)targetValue length:(NSTimeInterval)length curve:(SPAnimationCurve)curve updateBlock:(SPGLKVector2AnimationUpdateBlock)updateBlock completionBlock:(SPAnimationCompletionBlock)completionBlock;

@end

@interface SPAABBAnimation : SPAnimation

- (id)initWithStartValue:(SPAxisAlignedBoundingBox)startValue targetValue:(SPAxisAlignedBoundingBox)targetValue length:(NSTimeInterval)length curve:(SPAnimationCurve)curve updateBlock:(SPAABBAnimationUpdateBlock)updateBlock completionBlock:(SPAnimationCompletionBlock)completionBlock;

@end

@implementation SPAnimation
{
    NSTimeInterval _totalTimeElapsed;
    NSTimeInterval _length;
    SPAnimationCurve _curve;
    SPAnimationCompletionBlock _completionBlock;
}

+ (void)updateAnimationsWithTimeElapsed:(NSTimeInterval)timeElapsed
{
    for (SPAnimation *animation in [animations copy])
    {
        [animation updateWithTimeElapsed:timeElapsed];
        if (animation.complete)
        {
            [animations removeObject:animation];
        }
    }
}

+ (void)animateNumberFrom:(NSNumber *)startValue
                       to:(NSNumber *)targetValue
                inSeconds:(NSTimeInterval)seconds
                withCurve:(SPAnimationCurve)curve
           andUpdateBlock:(SPNumberAnimationUpdateBlock)updateBlock
       andCompletionBlock:(SPAnimationCompletionBlock)completionBlock
{
    if (!animations)
    {
        animations = [NSMutableSet set];
    }
    
    SPAnimation *animation = [[SPNumberAnimation alloc] initWithStartValue:startValue targetValue:targetValue length:seconds curve:curve updateBlock:updateBlock completionBlock:completionBlock];
    
    [animations addObject:animation];
}

+ (void)animateGLKVector2From:(GLKVector2)startValue
                           to:(GLKVector2)targetValue
                    inSeconds:(NSTimeInterval)seconds
                    withCurve:(SPAnimationCurve)curve
               andUpdateBlock:(SPGLKVector2AnimationUpdateBlock)updateBlock
           andCompletionBlock:(SPAnimationCompletionBlock)completionBlock
{
    if (!animations)
    {
        animations = [NSMutableSet set];
    }
    
    SPAnimation *animation = [[SPGLKVector2Animation alloc] initWithStartValue:startValue targetValue:targetValue length:seconds curve:curve updateBlock:updateBlock completionBlock:completionBlock];
    
    [animations addObject:animation];
}

+ (void)animateAABBFrom:(SPAxisAlignedBoundingBox)startValue to:(SPAxisAlignedBoundingBox)targetValue inSeconds:(NSTimeInterval)seconds withCurve:(SPAnimationCurve)curve andUpdateBlock:(SPAABBAnimationUpdateBlock)updateBlock andCompletionBlock:(SPAnimationCompletionBlock)completionBlock
{
    if (!animations)
    {
        animations = [NSMutableSet set];
    }
    
    SPAnimation *animation = [[SPAABBAnimation alloc] initWithStartValue:startValue targetValue:targetValue length:seconds curve:curve updateBlock:updateBlock completionBlock:completionBlock];
    
    [animations addObject:animation];
}

- (id)initWithLength:(NSTimeInterval)length curve:(SPAnimationCurve)curve completionBlock:(SPAnimationCompletionBlock)completionBlock
{
    self = [super init];
    if (self)
    {
        _totalTimeElapsed = 0;
        _length = length;
        _curve = curve;
        _completionBlock = completionBlock;
        _complete = NO;
    }
    return self;    
}

- (void)updateValue
{
    NSAssert(NO, @"Only subclasses of NSAnimation can be used!");
}

- (float)calculateProgress
{
    float percent = _totalTimeElapsed / _length;
    float progress = 0.0;
    switch (_curve)
    {
        case SP_ANIMATION_CURVE_LINEAR:
            progress = percent;
            break;
        case SP_ANIMATION_CURVE_EASE_IN_EASE_OUT:
            progress = 3.0 * powf(percent, 2.0) - 2.0 * powf(percent, 3.0);
            break;
        case SP_ANIMATION_CURVE_EASE_IN:
            progress = powf(percent, 5);
            break;
        default:
            progress = 0.0;
    }
    return progress;
}

- (void)updateWithTimeElapsed:(NSTimeInterval)timeElapsed
{
    _totalTimeElapsed += timeElapsed;
    
    if (_totalTimeElapsed >= _length)
    {
        [self finalize];
        _completionBlock();
        _complete = YES;
        return;
    }
    
    [self updateValue];
}

@end

@implementation SPNumberAnimation
{
    NSNumber *_startValue;
    NSNumber *_targetValue;
    SPNumberAnimationUpdateBlock _updateBlock;
}

- (id)initWithStartValue:(NSNumber *)startValue targetValue:(NSNumber *)targetValue length:(NSTimeInterval)length curve:(SPAnimationCurve)curve updateBlock:(SPNumberAnimationUpdateBlock)updateBlock completionBlock:(SPAnimationCompletionBlock)completionBlock
{
    self = [super initWithLength:length curve:curve completionBlock:completionBlock];
    if (self)
    {
        _startValue = startValue;
        _targetValue = targetValue;
        _updateBlock = updateBlock;
    }
    return self;    
}

- (void)updateValue
{
    float progress = [self calculateProgress];
    float difference = [_targetValue floatValue] - [_startValue floatValue];
    float currentValue = [_startValue floatValue] + progress * difference;
    _updateBlock(currentValue);
}

- (void)finalize
{
    _updateBlock([_targetValue floatValue]);
}

@end

@implementation SPGLKVector2Animation
{
    GLKVector2 _startValue;
    GLKVector2 _targetValue;
    GLKVector2 _difference;
    SPGLKVector2AnimationUpdateBlock _updateBlock;
}

- (id)initWithStartValue:(GLKVector2)startValue targetValue:(GLKVector2)targetValue length:(NSTimeInterval)length curve:(SPAnimationCurve)curve updateBlock:(SPGLKVector2AnimationUpdateBlock)updateBlock completionBlock:(SPAnimationCompletionBlock)completionBlock
{
    self = [super initWithLength:length curve:curve completionBlock:completionBlock];
    if (self)
    {
        _startValue = startValue;
        _targetValue = targetValue;
        _difference = GLKVector2Subtract(_targetValue, _startValue);
        _updateBlock = updateBlock;
    }
    return self;
}

- (void)updateValue
{
    float progress = [self calculateProgress];
    GLKVector2 currentValue = GLKVector2Add(_startValue, GLKVector2MultiplyScalar(_difference, progress));
    _updateBlock(currentValue);
}

- (void)finalize
{
    _updateBlock(_targetValue);
}

@end

@implementation SPAABBAnimation
{
    SPAxisAlignedBoundingBox _startValue;
    SPAxisAlignedBoundingBox _targetValue;
    GLKVector2 _lowerLeftDifference;
    GLKVector2 _upperRightDifference;
    SPAABBAnimationUpdateBlock _updateBlock;
}

- (id)initWithStartValue:(SPAxisAlignedBoundingBox)startValue targetValue:(SPAxisAlignedBoundingBox)targetValue length:(NSTimeInterval)length curve:(SPAnimationCurve)curve updateBlock:(SPAABBAnimationUpdateBlock)updateBlock completionBlock:(SPAnimationCompletionBlock)completionBlock
{
    self = [super initWithLength:length curve:curve completionBlock:completionBlock];
    if (self)
    {
        _startValue = startValue;
        _targetValue = targetValue;
        _lowerLeftDifference = GLKVector2Subtract(_targetValue.lowerLeft, _startValue.lowerLeft);
        _upperRightDifference = GLKVector2Subtract(_targetValue.upperRight, _startValue.upperRight);
        _updateBlock = updateBlock;
    }
    return self;
}

- (void)updateValue
{
    float progress = [self calculateProgress];
    GLKVector2 currentLowerLeftValue = GLKVector2Add(_startValue.lowerLeft, GLKVector2MultiplyScalar(_lowerLeftDifference, progress));
    GLKVector2 currentUpperRightValue = GLKVector2Add(_startValue.upperRight, GLKVector2MultiplyScalar(_upperRightDifference, progress));
    SPAxisAlignedBoundingBox currentValue;
    currentValue.lowerLeft = currentLowerLeftValue;
    currentValue.upperRight = currentUpperRightValue;
    _updateBlock(currentValue);
}

- (void)finalize
{
    _updateBlock(_targetValue);
}

@end
