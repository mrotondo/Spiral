//
//  SPRegularPolygons.m
//  Creatura
//
//  Created by Mike Rotondo on 5/17/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SPRegularPolygons.h"

NSMutableDictionary *polygons;

@implementation SPRegularPolygons

+ (GLKVector2 *)polygonWithNumSides:(int)numSides
{
    if (!polygons)
    {
        polygons = [NSMutableDictionary dictionary];
    }
    
    NSNumber *key = [NSNumber numberWithInt:numSides];
    NSArray *vertices = [polygons objectForKey:key];
    if (!vertices)
    {
        [self addPolygonWithNumSides:numSides];
    }
    return (GLKVector2 *)[[polygons objectForKey:key] pointerValue];
}

+ (void)addPolygonWithNumSides:(int)numSides
{
    float angle = 0;
    GLKVector2 *vertices = (GLKVector2 *)malloc(numSides * sizeof(GLKVector2));
    for (int i = 0; i < numSides; i++)
    {
        angle += (2.0 * M_PI) / numSides;
        GLKVector2 vertex = GLKVector2Make(cos(angle), sin(angle));
        vertices[i] = vertex;
    }
    NSNumber *key = [NSNumber numberWithInt:numSides];
    [polygons setObject:[NSValue valueWithPointer:vertices] forKey:key];
}

+ (void)cleanUpPolygons
{
    for (NSValue *polygonValue in [polygons allValues])
    {
        GLKVector2 *polygon = [polygonValue pointerValue];
        free(polygon);
    }
    polygons = nil;
}

@end
