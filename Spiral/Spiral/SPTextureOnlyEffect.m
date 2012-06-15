//
//  SPTextureOnlyEffect.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPTextureOnlyEffect.h"
#import "ShaderProgramLoader.h"

@implementation SPTextureOnlyEffect
{
    GLint textureUniformIndex;
    GLint tintColorUniformIndex;
}
@synthesize texture;

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"texture_only"
                           withColor:NO
                          withNormal:NO
                        withTexCoord:YES];
    if (self)
    {
        self.texCoordVertexAttribute = TEXCOORD_ATTRIB_IDX;
        self.texture = [[GLKEffectPropertyTexture alloc] init];
        [self registerUniform:@"texture" atLocation:&textureUniformIndex];
        [self registerUniform:@"tintColor" atLocation:&tintColorUniformIndex];
        
        self.tintColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    }
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    glUniform1i(textureUniformIndex, 0);
    
    glUniform4fv(tintColorUniformIndex, 1, self.tintColor.v);
}

@end
