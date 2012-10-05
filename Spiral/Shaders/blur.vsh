#ifdef GL_ES
precision mediump float;
#endif

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

attribute vec3 aPosition;
attribute vec2 aTexCoord;

varying vec2 vTexCoord;

void main (void) 
{
    vTexCoord = aTexCoord;
	gl_Position	= projectionMatrix * modelViewMatrix * vec4(aPosition, 1);
}
