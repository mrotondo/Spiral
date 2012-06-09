//
//  SPEffect.h
//  SpringDudes
//
//  Created by Michael Rotondo on 3/24/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPEffect : NSObject <GLKNamedEffect>

+ (id)sharedInstance;

- (id)initWithShaderName:(NSString *)shaderName
               withColor:(BOOL)hasColor
              withNormal:(BOOL)hasNormal
            withTexCoord:(BOOL)hasTexCoord;

- (id)initWithShaderName:(NSString *)shaderName
               withColor:(BOOL)hasColor
              withNormal:(BOOL)hasNormal
            withTexCoord:(BOOL)hasTexCoord
 andAdditionalAttributes:(NSDictionary *)attributeSPictionary;

@property (nonatomic, readonly) GLuint programName;
@property (nonatomic, strong) GLKEffectPropertyTransform *transform;
@property (nonatomic) GLuint positionVertexAttribute;
@property (nonatomic) GLuint colorVertexAttribute;
@property (nonatomic) GLuint normalVertexAttribute;
@property (nonatomic) GLuint texCoordVertexAttribute;

@end
