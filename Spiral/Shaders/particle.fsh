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

varying vec4 vColor;
varying vec2 vTexCoord;

void main()
{
    gl_FragColor = vColor * texture2D(texture, vTexCoord);
}
