//
//  ShaderProgramLoader.h
//  OSXGLEssentials
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sourceUtil.h"

// Indicies to which we will set vertex array attibutes
// See buildVAO and buildProgram
enum {
	POS_ATTRIB_IDX,
    COLOR_ATTRIB_IDX,
	NORMAL_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX,
    BODYTEXCOORD_ATTRIB_IDX
};

@interface ShaderProgramLoader : NSObject

+ (GLuint)buildProgramWithVertexSource:(demoSource*)vertexSource
                    withFragmentSource:(demoSource*)fragmentSource 
                             withColor:(BOOL)hasColor
                            withNormal:(BOOL)hasNormal 
                          withTexCoord:(BOOL)hasTexCoord
               andAdditionalAttributes:(NSDictionary *)attributeSPictionary;
+ (void)destroyProgram:(GLuint)prgName;

@end
