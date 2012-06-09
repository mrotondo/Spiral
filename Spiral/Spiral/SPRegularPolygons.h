//
//  SPRegularPolygons.h
//  Creatura
//
//  Created by Mike Rotondo on 5/17/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPRegularPolygons : NSObject

+ (GLKVector2 *)polygonWithNumSides:(int)numSides;
+ (void)cleanUpPolygons;

@end
