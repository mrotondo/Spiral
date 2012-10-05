#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;

varying vec2 vTexCoord;

uniform vec2 texelSize;
uniform int orientation;
uniform int amount;
uniform float scale;
uniform float strength;

float gaussian (float x, float deviation)
{
	return (1.0 / sqrt(2.0 * 3.141592 * deviation)) * exp(-((x * x) / (2.0 * deviation)));
}

void main ()
{
	// Locals
	float halfBlur = float(amount) * 0.5;
	vec4 colour = vec4(0.0);
	vec4 texColour = vec4(0.0);
	
	// Gaussian deviation
	float deviation = halfBlur * 0.35;
	deviation *= deviation;
	float strength = 1.0 - strength;
	
	if ( orientation == 0 )
	{
		// Horizontal blur
		for (int i = 0; i < 10; ++i)
		{
			if ( i >= amount )
				break;
			
			float offset = float(i) - halfBlur;
			texColour = texture2D(texture, vTexCoord + vec2(offset * texelSize.x * scale, 0.0)) * gaussian(offset * strength, deviation);
			colour += texColour;
		}
	}
	else
	{
		// Vertical blur
		for (int i = 0; i < 10; ++i)
		{
			if ( i >= amount )
				break;
			
			float offset = float(i) - halfBlur;
			texColour = texture2D(texture, vTexCoord + vec2(0.0, offset * texelSize.y * scale)) * gaussian(offset * strength, deviation);
			colour += texColour;
		}
	}
	
	// Apply colour
	gl_FragColor = clamp(colour, 0.0, 1.0);
	gl_FragColor.w = 1.0;
}