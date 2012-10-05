//
//  SPColorOnlyEffect.m
//  SpringDudes
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPBlurEffect.h"
#import "ShaderProgramLoader.h"
#import "SPGeometricPrimitives.h"

@implementation SPBlurEffect
{
    GLint textureUniformIndex;
    GLint orientationUniformIndex;
    GLint amountUniformIndex;
    GLint scaleUniformIndex;
    GLint strengthUniformIndex;
    GLint texelSizeUniformIndex;

    SPOffscreenRenderTarget *blur1FrameBuffer;
    SPOffscreenRenderTarget *blur2FrameBuffer;
    GLKVector2 glowMapSize;
}

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"blur"
                           withColor:NO
                          withNormal:NO
                        withTexCoord:YES];
    if (self)
    {
        self.texCoordVertexAttribute = TEXCOORD_ATTRIB_IDX;
        self.texture = [[GLKEffectPropertyTexture alloc] init];
        [self registerUniform:@"texture" atLocation:&textureUniformIndex];
        [self registerUniform:@"orientation" atLocation:&orientationUniformIndex];
        [self registerUniform:@"amount" atLocation:&amountUniformIndex];
        [self registerUniform:@"scale" atLocation:&scaleUniformIndex];
        [self registerUniform:@"strength" atLocation:&strengthUniformIndex];
        [self registerUniform:@"texelSize" atLocation:&texelSizeUniformIndex];
        
        glowMapSize = GLKVector2Make(256, 256);
        self.texelSize = GLKVector2Divide(GLKVector2Make(1, 1), glowMapSize);
        
        blur1FrameBuffer = [[SPOffscreenRenderTarget alloc] initWithTextureSize:glowMapSize depthOnly:NO];
        blur2FrameBuffer = [[SPOffscreenRenderTarget alloc] initWithTextureSize:glowMapSize depthOnly:NO];
        
    }
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    glUniform1i(textureUniformIndex, 0);
    
    glUniform1i(orientationUniformIndex, self.orientation);
    glUniform1i(amountUniformIndex, self.amount);
    glUniform1f(scaleUniformIndex, self.scale);
    glUniform1f(strengthUniformIndex, self.strength);
    glUniform2fv(texelSizeUniformIndex, 1, self.texelSize.v);
}

- (void)drawBlurredBlock:(SPOffscreenRenderDrawingBlock)drawingBlock
{
    // Draw the input block to FBO 1
    [blur1FrameBuffer drawToTargetWithBlock:^{
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        drawingBlock();
    }];
    
    GLKMatrix4 quadTransform = GLKMatrix4Identity;
    quadTransform = GLKMatrix4Scale(quadTransform, 2, 2, 0);
    
    GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, -1, 1);

    GLKMatrix4 originalModelViewMatrix = self.transform.modelviewMatrix;
    GLKMatrix4 originalProjectionMatrix = self.transform.projectionMatrix;
    
    self.transform.modelviewMatrix = quadTransform;
    self.transform.projectionMatrix = orthoMatrix;

    
    // Blur FBO 1 horizontally to FBO 2
    self.texture.name = blur1FrameBuffer.texture;
    self.orientation = 1;
    [blur2FrameBuffer drawToTargetWithBlock:^{
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        [SPGeometricPrimitives drawQuadWithBlock:^(SPStaticGeometryInfoStruct geometryInfo) {
            [self prepareToDraw];
            
            glEnableVertexAttribArray(self.positionVertexAttribute);
            glEnableVertexAttribArray(self.texCoordVertexAttribute);
            
            glVertexAttribPointer(self.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, position));
            glVertexAttribPointer(self.texCoordVertexAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, texCoord));
            glDrawElements(geometryInfo.primitiveType, geometryInfo.numIndices, GL_UNSIGNED_INT, (void *)0);
            
            glDisableVertexAttribArray(self.positionVertexAttribute);
            glDisableVertexAttribArray(self.texCoordVertexAttribute);
        }];
    }];
    
    // Blur FBO 2 vertically to FBO 1
    self.texture.name = blur2FrameBuffer.texture;
    self.orientation = 0;
    [blur1FrameBuffer drawToTargetWithBlock:^{
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        [SPGeometricPrimitives drawQuadWithBlock:^(SPStaticGeometryInfoStruct geometryInfo) {
            [self prepareToDraw];
            
            glEnableVertexAttribArray(self.positionVertexAttribute);
            glEnableVertexAttribArray(self.texCoordVertexAttribute);
            
            glVertexAttribPointer(self.positionVertexAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, position));
            glVertexAttribPointer(self.texCoordVertexAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(primitiveVertexStruct), (void *)offsetof(primitiveVertexStruct, texCoord));
            glDrawElements(geometryInfo.primitiveType, geometryInfo.numIndices, GL_UNSIGNED_INT, (void *)0);
            
            glDisableVertexAttribArray(self.positionVertexAttribute);
            glDisableVertexAttribArray(self.texCoordVertexAttribute);
        }];
    }];
    
    self.transform.modelviewMatrix = originalModelViewMatrix;
    self.transform.projectionMatrix = originalProjectionMatrix;
    
    [SPGeometricPrimitives drawQuadWithTexture:blur1FrameBuffer.texture andModelViewMatrix:quadTransform];
}

@end
