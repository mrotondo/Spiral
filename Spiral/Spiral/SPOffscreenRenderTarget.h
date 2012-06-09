//
//  SPOffscreenRenderTarget.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SPOffscreenRenderDrawingBlock)(void);

@interface SPOffscreenRenderTarget : NSObject

- (id)initWithTextureSize:(GLKVector2)textureSize depthOnly:(BOOL)depthOnly;
- (void)drawToTargetWithBlock:(SPOffscreenRenderDrawingBlock)drawingBlock;

@property (nonatomic, readonly) GLKVector2 size;
@property (nonatomic, readonly) GLuint texture;

@end
