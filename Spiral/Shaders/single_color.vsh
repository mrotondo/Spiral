#ifdef GL_ES
precision mediump float;
#endif

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

attribute vec2 aPosition;

void main (void)
{
	gl_Position	= projectionMatrix * modelViewMatrix * vec4(aPosition, 0, 1);
}
