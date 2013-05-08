#ifdef GL_ES
precision mediump float;
#endif

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

attribute vec3 aPosition;
attribute vec3 aNormal;

varying vec3 vEyeSpacePosition;
varying vec3 vNormal;

void main (void)
{
    
    vec4 eyeSpacePosition = modelViewMatrix * vec4(aPosition, 1);
    vEyeSpacePosition = vec3(eyeSpacePosition);
    vNormal = normalize(normalMatrix * aNormal);
	gl_Position	= projectionMatrix * eyeSpacePosition;
}
