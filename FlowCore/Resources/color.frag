uniform sampler1D transferFunctionTexture;
uniform sampler2DRect inverseGridTextureX, inverseGridTextureY;
uniform sampler2DRect channelTexture[5];
uniform float channelMin[5];
uniform float channelMax[5];

uniform int channel;
uniform vec2 min, max, step, offset, size;
uniform float scale;

vec2 cellAt(vec2 position)
{	
	vec2 coord = vec2((position.y - min.y) / step.y, (position.x - min.x) / step.x);
	
	return vec2(texture2DRect(inverseGridTextureY, coord).x, texture2DRect(inverseGridTextureX, coord).x);
}

void main()
{	
	vec2 tc = vec2(gl_TexCoord[0].x, gl_TexCoord[0].y);
	vec2 coord = vec2((tc.y - offset.y) / scale + min.x, (tc.x - offset.x) / scale + min.y);

	if (coord.x > min.x && coord.y > min.y &&
		coord.x < max.x && coord.y < max.y)
	{
		float value;

		if (channel == 0) value = texture2DRect(channelTexture[0], cellAt(coord)).x;
		else if (channel == 1) value = texture2DRect(channelTexture[1], cellAt(coord)).x;
		else if (channel == 2) value = texture2DRect(channelTexture[2], cellAt(coord)).x;
		else if (channel == 3) value = texture2DRect(channelTexture[3], cellAt(coord)).x;
		else if (channel == 4) value = texture2DRect(channelTexture[4], cellAt(coord)).x;

		value -= channelMin[channel];
		value /= channelMax[channel] - channelMin[channel];
		gl_FragColor = texture1D(transferFunctionTexture, value);

	}
	else
		gl_FragColor = vec4(0.1, 0.1, 0.1, 0.0);

}