#ifdef GL_ES
precision mediump float;
#endif

varying vec3 vEyeSpacePosition;  // v
varying vec4 vColor;
varying vec3 vNormal;  // N

void main (void)
{
//    gl_FragColor = vec4(vNormal, 1.0);
    
    vec4 diffuseLightColor = vec4(1.0, 0.8, 0.3, 1.0);
    vec4 specularLightColor = vec4(1.0, 1.0, 1.0, 1.0);
    float shininess = 0.8;

    vec3 lightSourcePosition = vec3(0.0, 5.0, -5.0);
    
    vec3 vectorFromLight = normalize(lightSourcePosition - vEyeSpacePosition);  // L
    vec3 vectorToEye = normalize(-vEyeSpacePosition); // E
    vec3 lightReflection = normalize(-reflect(vectorFromLight, vNormal)); // R
    
    vec4 Idiff = diffuseLightColor * max(dot(vNormal, vectorFromLight), 0.0);
    Idiff = clamp(Idiff, 0.0, 1.0);
    
    vec4 Ispec = specularLightColor * pow(max(dot(lightReflection, vectorToEye), 0.0), 0.3 * shininess);
    Ispec = clamp(Ispec, 0.0, 1.0);
    
    gl_FragColor = vColor * (Idiff + Ispec);
}