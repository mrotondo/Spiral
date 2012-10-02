//
//  Shader.vsh
//  iOSParticles
//
//  Created by Mike Rotondo on 5/14/12.
//  Copyright (c) 2012 Mike Rotondo. All rights reserved.
//

#ifdef GL_ES
precision mediump float;
#endif

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

attribute vec4 aPosition;
attribute vec4 aColor;
attribute vec2 aTexCoord;

varying vec4 vColor;
varying vec2 vTexCoord;

void main()
{
    vTexCoord = aTexCoord;
    vColor = aColor;
    
    gl_Position = projectionMatrix * modelViewMatrix * aPosition;
}
