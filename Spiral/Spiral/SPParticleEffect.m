//
//  SPParticleEffect.m
//  Creatura
//
//  Created by Mike Rotondo on 5/19/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPParticleEffect.h"

@implementation SPParticleEffect
{
    GLint textureUniformIndex;
}
@synthesize texture;

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"particle"
                           withColor:YES
                          withNormal:NO
                        withTexCoord:YES];
    if (self)
    {
        self.texture = [[GLKEffectPropertyTexture alloc] init];
        [self registerUniform:@"texture" atLocation:&textureUniformIndex];
    }
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    glUniform1i(textureUniformIndex, 0);
}

@end
