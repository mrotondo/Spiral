//
//  SPEffect+RegisterUniform.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPEffect+RegisterUniform.h"

@implementation SPEffect (RegisterUniform)

- (void)registerUniform:(NSString *)uniformName atLocation:(GLint *)uniformLocation
{
    *uniformLocation = glGetUniformLocation(self.programName, [uniformName UTF8String]);
    
    if (*uniformLocation < 0)
    {
        NSLog(@"No %@ in shader %@", uniformName, self);
    }
}

@end
