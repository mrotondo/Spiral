//
//  SPOffscreenRenderTarget.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPOffscreenRenderTarget.h"
#import "SPEffectsManager.h"
#import "SPGLKitHelper.h"

@implementation SPOffscreenRenderTarget
{
    GLuint framebuffer;
    GLuint texture;
    GLKVector2 _size;
}
@synthesize size = _size;

- (id)initWithTextureSize:(GLKVector2)textureSize depthOnly:(BOOL)depthOnly
{
    self = [super init];
    if (self) {

        _size = textureSize;
        
        // create the fbo
        glGenFramebuffers(1, &framebuffer);
        GetGLError();
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        GetGLError();
        
        // create the texture
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        GetGLError();
        
        if (!depthOnly)
        {
            // create the depth render buffer
            GLuint depthRenderbuffer;
            glGenRenderbuffers(1, &depthRenderbuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, textureSize.x, textureSize.y);
            
            // specify the texture as a color format
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  textureSize.x, textureSize.y, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
            
            // attach the texture to the fbo
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
            
            // attach the depth buffer to the fbo
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        }
        else
        {
            // specify the texture as a depth format
            glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, textureSize.x, textureSize.y, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT, 0);
            GetGLError();
            
            // attach the texture to the fbo
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, texture, 0);
            GetGLError();

#if !(TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
            glDrawBuffer(GL_NONE);
            glReadBuffer(GL_NONE);
#endif
        }
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"failed to make complete framebuffer object %x", status);
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    return self;
}

- (void)drawToTargetWithBlock:(SPOffscreenRenderDrawingBlock)drawingBlock
{
    GLint originalFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &originalFBO);
    
    int originalViewport[4];
    glGetIntegerv(GL_VIEWPORT, (int *)originalViewport);
    glViewport(0, 0, self.size.x, self.size.y);
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    drawingBlock();
    
    glBindFramebuffer(GL_FRAMEBUFFER, originalFBO);
    
    glViewport(originalViewport[0], originalViewport[1], originalViewport[2], originalViewport[3]);
}

- (GLuint)texture
{
    return texture;
}

@end
