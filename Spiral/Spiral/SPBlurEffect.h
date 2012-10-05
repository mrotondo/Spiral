//
//  SPBlurEffect.h
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEffect.h"
#import "SPTextureOnlyEffect.h"
#import "SPOffscreenRenderTarget.h"

@interface SPBlurEffect : SPEffect

@property (nonatomic, strong) GLKEffectPropertyTexture *texture;
@property (nonatomic) int orientation;
@property (nonatomic) int amount;
@property (nonatomic) float scale;
@property (nonatomic) float strength;
@property (nonatomic) GLKVector2 texelSize;

- (void)drawBlurredBlock:(SPOffscreenRenderDrawingBlock)drawingBlock;

@end
