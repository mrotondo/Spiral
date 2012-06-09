//
//  ShaderProgramLoader.m
//  OSXGLEssentials
//
//  Created by Luke Iannini on 3/11/12.
//  Copyright (c) 2012 Eeoo. All rights reserved.
//

#import "ShaderProgramLoader.h"

#define GetGLError()									\
{														\
GLenum err = glGetError();							\
while (err != GL_NO_ERROR) {						\
NSLog(@"GLError %s set in File:%s Line:%d\n",	\
GetGLErrorString(err),					\
__FILE__,								\
__LINE__);								\
err = glGetError();								\
}													\
}

@implementation ShaderProgramLoader

+ (GLuint)buildProgramWithVertexSource:(demoSource*)vertexSource
                    withFragmentSource:(demoSource*)fragmentSource
                             withColor:(BOOL)hasColor
                            withNormal:(BOOL)hasNormal
                          withTexCoord:(BOOL)hasTexCoord
               andAdditionalAttributes:(NSDictionary *)attributeSPictionary
{
    GetGLError();
    
	GLuint prgName;
	
	GLint logLength, status;
	
	// String to pass to glShaderSource
	GLchar* sourceString = NULL;  
	
	// Determine if GLSL version 140 is supported by this context.
	//  We'll use this info to generate a GLSL shader source string  
	//  with the proper version preprocessor string prepended
	float  glLanguageVersion;
	
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	sscanf((char *)glGetString(GL_SHADING_LANGUAGE_VERSION), "OpenGL ES GLSL ES %f", &glLanguageVersion);
#else
	sscanf((char *)glGetString(GL_SHADING_LANGUAGE_VERSION), "%f", &glLanguageVersion);	
#endif
	
	// GL_SHADING_LANGUAGE_VERSION returns the version standard version form 
	//  with decimals, but the GLSL version preprocessor directive simply
	//  uses integers (thus 1.10 should 110 and 1.40 should be 140, etc.)
	//  We multiply the floating point number by 100 to get a proper
	//  number for the GLSL preprocessor directive
	GLuint version = 100 * glLanguageVersion;
	
	// Get the size of the version preprocessor string info so we know 
	//  how much memory to allocate for our sourceString
	const GLsizei versionStringSize = sizeof("#version 123\n");
	
	// Create a program object
	prgName = glCreateProgram();
    GetGLError();
	
	// Indicate the attribute indicies on which vertex arrays will be
	//  set with glVertexAttribPointer
	//  See buildVAO to see where vertex arrays are actually set
	glBindAttribLocation(prgName, POS_ATTRIB_IDX, "aPosition");
    GetGLError();
	
    if (hasColor)
    {
		glBindAttribLocation(prgName, COLOR_ATTRIB_IDX, "aColor");        
    }
    GetGLError();
    
	if (hasNormal)
	{
		glBindAttribLocation(prgName, NORMAL_ATTRIB_IDX, "aNormal");
	}
    GetGLError();
	
	if (hasTexCoord)
	{
		glBindAttribLocation(prgName, TEXCOORD_ATTRIB_IDX, "aTexCoord");
	}
    GetGLError();
    
    [attributeSPictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *attributeName = key;
        NSNumber *attributeIndexNumber = obj;
        glBindAttribLocation(prgName, [attributeIndexNumber unsignedIntValue], [attributeName UTF8String]);
    }];
	
	//////////////////////////////////////
	// Specify and compile VertexShader //
	//////////////////////////////////////
	
	// Allocate memory for the source string including the version preprocessor information
	sourceString = (GLchar *)malloc(vertexSource->byteSize + versionStringSize);
	
	// Prepend our vertex shader source string with the supported GLSL version so
	//  the shader will work on ES, Legacy, and OpenGL 3.2 Core Profile contexts
	sprintf(sourceString, "#version %d\n%s", version, vertexSource->string);
    
	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);	
	glShaderSource(vertexShader, 1, (const GLchar **)&(sourceString), NULL);
    GetGLError();
	glCompileShader(vertexShader);
    GetGLError();
	glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &logLength);
    GetGLError();
	
	if (logLength > 0) 
	{
		GLchar *log = (GLchar*) malloc(logLength);
		glGetShaderInfoLog(vertexShader, logLength, &logLength, log);
		NSLog(@"Vtx Shader compile log:%s\n", log);
		free(log);
	}
	
	glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);
    GetGLError();
	if (status == 0)
	{
		NSLog(@"Failed to compile vtx shader:\n%s\n", sourceString);
		return 0;
	}
	
	free(sourceString);
	sourceString = NULL;
	
	// Attach the vertex shader to our program
	glAttachShader(prgName, vertexShader);
    GetGLError();
	
	/////////////////////////////////////////
	// Specify and compile Fragment Shader //
	/////////////////////////////////////////
	
	// Allocate memory for the source string including the version preprocessor	 information
	sourceString = (GLchar *)malloc(fragmentSource->byteSize + versionStringSize);
	
	// Prepend our fragment shader source string with the supported GLSL version so
	//  the shader will work on ES, Legacy, and OpenGL 3.2 Core Profile contexts
	sprintf(sourceString, "#version %d\n%s", version, fragmentSource->string);
	
	GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);	
	glShaderSource(fragShader, 1, (const GLchar **)&(sourceString), NULL);
    GetGLError();
	glCompileShader(fragShader);
    GetGLError();
	glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, &logLength);
    GetGLError();
	if (logLength > 0)
	{
		GLchar *log = (GLchar*)malloc(logLength);
		glGetShaderInfoLog(fragShader, logLength, &logLength, log);
		NSLog(@"Frag Shader compile log:\n%s\n", log);
		free(log);
	}
	
	glGetShaderiv(fragShader, GL_COMPILE_STATUS, &status);
    GetGLError();
	if (status == 0)
	{
		NSLog(@"Failed to compile frag shader:\n%s\n", sourceString);
		return 0;
	}
	
	free(sourceString);
	sourceString = NULL;
	
	// Attach the fragment shader to our program
	glAttachShader(prgName, fragShader);
    GetGLError();
    
	
	//////////////////////
	// Link the program //
	//////////////////////
    GetGLError();
	
	glLinkProgram(prgName);
    GetGLError();
	glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
    GetGLError();
	if (logLength > 0)
	{
		GLchar *log = (GLchar*)malloc(logLength);
		glGetProgramInfoLog(prgName, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s\n", log);
		free(log);
	}
	
    GetGLError();
	glGetProgramiv(prgName, GL_LINK_STATUS, &status);
    GetGLError();
	if (status == 0)
	{
		NSLog(@"Failed to link program");
		return 0;
	}
    GetGLError();
	
	glValidateProgram(prgName);
    GetGLError();
	glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar*)malloc(logLength);
		glGetProgramInfoLog(prgName, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s\n", log);
		free(log);
	}
    GetGLError();
	
	glGetProgramiv(prgName, GL_VALIDATE_STATUS, &status);
    GetGLError();
	if (status == 0)
	{
		NSLog(@"Failed to validate program");
		return 0;
	}
    GetGLError();
	
	
	glUseProgram(prgName);
    
    GetGLError();
	
	return prgName;
	
}

+ (void)destroyProgram:(GLuint)prgName
{	
	
	if(0 == prgName)
	{
		return;
	}
	
	GLsizei shaderNum;
	GLsizei shaderCount;
	
	// Get the number of attached shaders
	glGetProgramiv(prgName, GL_ATTACHED_SHADERS, &shaderCount);
	
	GLuint* shaders = (GLuint*)malloc(shaderCount * sizeof(GLuint));
	
	// Get the names of the shaders attached to the program
	glGetAttachedShaders(prgName,
						 shaderCount,
						 &shaderCount,
						 shaders);
	
	// Delete the shaders attached to the program
	for(shaderNum = 0; shaderNum < shaderCount; shaderNum++)
	{
		glDeleteShader(shaders[shaderNum]);
	}
	
	free(shaders);
	
	// Delete the program
	glDeleteProgram(prgName);
	glUseProgram(0);
}

@end
