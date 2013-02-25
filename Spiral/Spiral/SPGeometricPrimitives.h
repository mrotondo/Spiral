//
//  SPGeometricPrimitives.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPStaticGeometry.h"
#import "SPMath.h"

typedef struct _primitiveVertexStruct
{
    GLKVector3 position;
    GLKVector2 texCoord;
} primitiveVertexStruct;

@interface SPGeometricPrimitives : NSObject

+ (void)initializeSharedGeometricPrimitives;
+ (void)destroySharedGeometricPrimitives;
+ (SPGeometricPrimitives *)sharedGeometricPrimitives;

+ (void)drawCircleWithColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawCircleWithTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawCircleWithBlock:(SPStaticGeometryDrawingBlock)block;

+ (void)drawQuadWithColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawQuadWithTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawQuadWithBlock:(SPStaticGeometryDrawingBlock)block;

+ (void)drawWireQuadWithColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawWireQuadWithTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawWireQuadWithBlock:(SPStaticGeometryDrawingBlock)block;

+ (void)drawRegularPolygonWithNumSides:(int)numSides withColor:(GLKVector4)color andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawRegularPolygonWithNumSides:(int)numSides withTexture:(GLuint)texture andModelViewMatrix:(GLKMatrix4)modelViewMatrix;
+ (void)drawRegularPolygonWithNumSides:(int)numSides withBlock:(SPStaticGeometryDrawingBlock)block;

@end
