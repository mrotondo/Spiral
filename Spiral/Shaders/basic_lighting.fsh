#ifdef GL_ES
precision mediump float;
#endif

varying vec3 vNormal;

void main (void)
{
    gl_FragColor = vec4(vNormal, 1);
}