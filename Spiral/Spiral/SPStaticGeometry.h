//
//  SPStaticGeometry.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/23/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _SPStaticGeometryInfoStruct {
    unsigned int sizeOfVertex;
    unsigned int numVertices;
    void *vertices;

    unsigned int sizeOfIndex;
    unsigned int numIndices;
    void *indices;
    
    GLenum primitiveType;
} SPStaticGeometryInfoStruct;

typedef SPStaticGeometryInfoStruct (^SPStaticGeometryInitializationBlock)(void);
typedef void(^SPStaticGeometryDrawingBlock)(SPStaticGeometryInfoStruct geometryInfo);

@interface SPStaticGeometry : NSObject

- (id)initWithGeometryInitializationBlock:(SPStaticGeometryInitializationBlock)initializationBlock;
- (void)drawGeometryWithBlock:(SPStaticGeometryDrawingBlock)drawingBlock;

@end
