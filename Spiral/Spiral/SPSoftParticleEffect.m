//
//  SPParticleEffect.m
//  Creatura
//
//  Created by Mike Rotondo on 5/19/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPSoftParticleEffect.h"

@implementation SPSoftParticleEffect
{
    GLint textureUniformIndex;
    GLint sceneDepthTextureUniformIndex;
    GLint viewportSizeUniformIndex;
    GLint cameraRangeUniformIndex;
}

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"soft_particle"
                           withColor:YES
                          withNormal:NO
                        withTexCoord:YES];
    if (self)
    {
        self.texture = [[GLKEffectPropertyTexture alloc] init];
        self.sceneDepthTexture = [[GLKEffectPropertyTexture alloc] init];
        [self registerUniform:@"texture" atLocation:&textureUniformIndex];
        [self registerUniform:@"sceneDepthTexture" atLocation:&sceneDepthTextureUniformIndex];
        [self registerUniform:@"viewportSize" atLocation:&viewportSizeUniformIndex];
        [self registerUniform:@"cameraRange" atLocation:&cameraRangeUniformIndex];
    }
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];

    glUniform1i(textureUniformIndex, 0);
    glUniform1i(sceneDepthTextureUniformIndex, 1);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.sceneDepthTexture.name);
    
    glUniform2fv(viewportSizeUniformIndex, 1, self.viewportSize.v);
    glUniform2fv(cameraRangeUniformIndex, 1, self.cameraRange.v);
}

@end
