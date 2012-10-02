//
//  Shader.fsh
//  iOSParticles
//
//  Created by Mike Rotondo on 5/14/12.
//  Copyright (c) 2012 Mike Rotondo. All rights reserved.
//

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform sampler2D sceneDepthTexture;

uniform vec2 viewportSize;
uniform vec2 cameraRange;

varying vec4 vColor;
varying vec2 vTexCoord;

float depthToZPosition(float depth)
{
    return cameraRange.x / (cameraRange.y - depth * (cameraRange.y - cameraRange.x)) * cameraRange.y;
}

void main()
{
    vec2 normalizedDeviceCoords = gl_FragCoord.xy / viewportSize;
    float sceneDepth = depthToZPosition(texture2D(sceneDepthTexture, normalizedDeviceCoords).z);
    float particleDepth = depthToZPosition(gl_FragCoord.z);
    float scale = 0.5;
    float fade = clamp((sceneDepth - particleDepth) * scale, 0.0, 1.0);
    vec4 color = vColor * texture2D(texture, vTexCoord);
    color.a *= fade;
//    color = vColor;
//    color = vec4((sceneDepth - 1.0) / 9.0, 0, 0, 1);
    gl_FragColor = color;
}
