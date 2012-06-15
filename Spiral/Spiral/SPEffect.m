//
//  SPEffect.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPEffect.h"
#import "sourceUtil.h"
#import "ShaderProgramLoader.h"
#import "SPEffectsManager.h"

@interface SPEffect ()

@property (nonatomic, readwrite) GLuint programName;

@end

@implementation SPEffect
{
    GLint modelViewMatrixUniformIndex;
    GLint projectionMatrixUniformIndex;
}
@synthesize transform;
@synthesize positionVertexAttribute;
@synthesize colorVertexAttribute;
@synthesize texCoordVertexAttribute;
@synthesize normalVertexAttribute;

+ (void)load
{
    if (self == [SPEffect class])
        return;
    
    registerEffectClass(self);
}

+ (id)sharedInstance
{
    return [[SPEffectsManager sharedEffectsManager] effect:self];
}

- (id)initWithShaderName:(NSString *)shaderName
               withColor:(BOOL)hasColor
              withNormal:(BOOL)hasNormal
            withTexCoord:(BOOL)hasTexCoord
{
    return [self initWithShaderName:shaderName withColor:hasColor withNormal:hasNormal withTexCoord:hasTexCoord andAdditionalAttributes:@{}];
}


- (id)initWithShaderName:(NSString *)shaderName
               withColor:(BOOL)hasColor
              withNormal:(BOOL)hasNormal
            withTexCoord:(BOOL)hasTexCoord
 andAdditionalAttributes:(NSDictionary *)attributeSPictionary
{
    self = [super init];
    if (self)
    {
        //////////////////////////////////////////
		// Load and Setup shaders for rendering //
		//////////////////////////////////////////
		
        NSLog(@"Loading shader: %@", shaderName);
        
		demoSource *vtxSource = NULL;
		demoSource *frgSource = NULL;
        NSString *filePathName;
		
		filePathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
		vtxSource = srcLoadSource([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
		
		filePathName = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
		frgSource = srcLoadSource([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
		
		// Build Program
		self.programName = [ShaderProgramLoader buildProgramWithVertexSource:vtxSource
                                                          withFragmentSource:frgSource
                                                                   withColor:hasColor
                                                                  withNormal:hasNormal
                                                                withTexCoord:hasTexCoord
                                                     andAdditionalAttributes:attributeSPictionary];
		
		srcDestroySource(vtxSource);
		srcDestroySource(frgSource);
		
        // Every shader has a modelview & projection matrix!
        [self registerUniform:@"modelViewMatrix" atLocation:&modelViewMatrixUniformIndex];
        [self registerUniform:@"projectionMatrix" atLocation:&projectionMatrixUniformIndex];
        
        self.transform = [[GLKEffectPropertyTransform alloc] init];
        
        // These indices are determined in the ShaderProgramLoader buildProgram method
        // Every shader has a position attribute!
        self.positionVertexAttribute = POS_ATTRIB_IDX;

        // Not every shader has these attributes, but if they do, this is how they'll be handled
        self.colorVertexAttribute = COLOR_ATTRIB_IDX;
        self.normalVertexAttribute = NORMAL_ATTRIB_IDX;
        self.texCoordVertexAttribute = TEXCOORD_ATTRIB_IDX;
    }
    return self;
}

- (void)registerUniform:(NSString *)uniformName atLocation:(GLint *)uniformLocation
{
    *uniformLocation = glGetUniformLocation(self.programName, [uniformName UTF8String]);
    
    if (*uniformLocation < 0)
    {
        NSLog(@"No %@ in shader %@", uniformName, self);
    }
}

- (void)dealloc
{
	[ShaderProgramLoader destroyProgram:self.programName];
}

- (void)prepareToDraw
{
    // Use the program for rendering the world
	glUseProgram(self.programName);
    
    // Have our shader use the modelview & projection matrices that we calculated above
    glUniformMatrix4fv(projectionMatrixUniformIndex, 1, GL_FALSE, transform.projectionMatrix.m);
	glUniformMatrix4fv(modelViewMatrixUniformIndex, 1, GL_FALSE, transform.modelviewMatrix.m);
}

@end
