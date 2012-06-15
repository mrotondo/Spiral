//
//  Shader.fsh
//  SpiralDemo
//
//  Created by Mike Rotondo on 6/15/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
