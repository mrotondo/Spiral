//
//  SPSingleColorEffect.m
//  Creatura
//
//  Created by Mike Rotondo on 4/30/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPSingleColorEffect.h"
#import "SPEffect+RegisterUniform.h"

@implementation SPSingleColorEffect
{
    GLint colorUniformIndex;
}
@synthesize color;

+ (void)load
{
    [super load];
}

- (id)init
{
    self = [super initWithShaderName:@"single_color"
                           withColor:NO
                          withNormal:NO
                        withTexCoord:NO];
    if (self)
    {
        [self registerUniform:@"color" atLocation:&colorUniformIndex];
    }
    return self;
}

- (void)prepareToDraw
{
    [super prepareToDraw];
    
    glUniform4fv(colorUniformIndex, 1, self.color.v);
}

@end
