uniform sampler1D transferFunctionTexture;
uniform sampler2DRect inverseGridTextureX, inverseGridTextureY;
uniform sampler2DRect channelTexture[5];
uniform float channelMin[5];
uniform float channelMax[5];

uniform int channel;
uniform vec2 min, max, step, offset, size;
uniform float scale;

uniform int velocityScale;
uniform float particleScale;

varying mat2 mat;

vec2 cellAt(vec2 position)
{	
	vec2 coord = vec2((position.y - min.y) / step.y, (position.x - min.x) / step.x);
	
	return vec2(texture2DRect(inverseGridTextureY, coord).x, texture2DRect(inverseGridTextureX, coord).x);
}

void main(void)
{
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_TexCoord[0] = gl_MultiTexCoord0;

	vec2 pos = (gl_Vertex.xy - offset)  / scale;
	pos += min.yx;
	pos = pos.yx;
	
	if (velocityScale > 0)
	{
		float value = texture2DRect(channelTexture[2], cellAt(pos)).x;
		value -= channelMin[2];
		value /= channelMax[2] - channelMin[2];
		value += 0.5;
		gl_PointSize = particleScale * value;
	}
	else
		gl_PointSize = particleScale;
	
	vec2 bla = cellAt(pos);
	vec2 flow = normalize(vec2(texture2DRect(channelTexture[0], bla).x, texture2DRect(channelTexture[1], bla).x));
	float angle = acos(dot(vec2(1.0, 0.0), flow));
	if (flow.y < 0.0)
			angle = 2.0*3.14 - angle;
	float cc = cos(angle);
	float ss = sin(angle);
	mat = mat2(cc, -ss, ss, cc);
}