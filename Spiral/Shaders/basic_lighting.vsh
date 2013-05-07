#ifdef GL_ES
precision mediump float;
#endif

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

attribute vec3 aPosition;
attribute vec3 aNormal;

varying vec3 vNormal;

void main (void)
{
    vNormal = aNormal;
	gl_Position	= projectionMatrix * modelViewMatrix * vec4(aPosition, 1);
}
