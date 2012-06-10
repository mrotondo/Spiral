#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform vec4 tintColor;

varying vec2 vTexCoord;

void main (void)
{
    gl_FragColor = tintColor * texture2D(texture, vTexCoord);
    
    // For checkin' out depth textures
    //    gl_FragColor = vec4(vec3(texture2D(texture, vTexCoord).z), 1);

    // For checking out texCoords
    //    gl_FragColor = vec4(vTexCoord, 0, 1);
}