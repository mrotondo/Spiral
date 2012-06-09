//
//  SPEffect+RegisterUniform.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPEffect.h"

@interface SPEffect (RegisterUniform)

- (void)registerUniform:(NSString *)uniformName atLocation:(GLint *)uniformLocation;

@end
