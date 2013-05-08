#ifdef GL_ES
precision mediump float;
#endif

varying vec3 vEyeSpacePosition;
varying vec3 vNormal;

void main (void)
{
//    gl_FragColor = vec4(vNormal, 1.0);
    
    vec3 lightSourcePosition = vec3(0.0, 5.0, 0.0);
    vec4 diffuseLightColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    vec3 L = normalize(lightSourcePosition - vEyeSpacePosition);
    vec4 Idiff = diffuseLightColor * max(dot(vNormal, L), 0.0);
    Idiff = clamp(Idiff, 0.0, 1.0);
    
    gl_FragColor = Idiff;
}