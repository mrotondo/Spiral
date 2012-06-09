//
//  SPStaticGeometry.m
//  SpringDudes
//
//  Created by Michael Rotondo on 3/23/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPStaticGeometry.h"

@implementation SPStaticGeometry
{
    GLuint    vertexBuffer;
    GLuint    indexBuffer;
    SPStaticGeometryInfoStruct geometryInfo;
}

- (id)initWithGeometryInitializationBlock:(SPStaticGeometryInitializationBlock)initializationBlock
{
    self = [super init];
    if (self)
    {
        geometryInfo = initializationBlock();
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     geometryInfo.numVertices * geometryInfo.sizeOfVertex,
                     geometryInfo.vertices, GL_STATIC_DRAW);
        free(geometryInfo.vertices);
        
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     geometryInfo.numIndices * geometryInfo.sizeOfIndex,
                     geometryInfo.indices, GL_STATIC_DRAW);
        free(geometryInfo.indices);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteBuffers(1, &indexBuffer);
}

- (void)drawGeometryWithBlock:(SPStaticGeometryDrawingBlock)drawingBlock
{
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    drawingBlock(geometryInfo);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

@end
