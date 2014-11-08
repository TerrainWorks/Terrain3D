#version 420 core

smooth in vec2 tc;
smooth in vec4 outPos;
out vec4 color;

layout (binding = 0) uniform usamplerBuffer buffer;
layout (binding = 1) uniform sampler2DArray sampler;

uniform float spacing;
uniform int heightMapSize;
uniform int textureMapResolution;


uint textureIndexForPos(vec4 pos)
{
	ivec2 indexPos;
	indexPos.x = int(pos.x / spacing);
	indexPos.y = int(pos.z / spacing);

	int centerIndex = indexPos.x + indexPos.y*heightMapSize;
	return texelFetch(buffer, centerIndex).r;
}


vec4 texelForIndex(uint index)
{
	vec3 pos;
	pos.x = tc.x;
	pos.y = tc.y;
	pos.z = index;

	return texture(sampler, pos);
}


void main()
{
	vec4 topLeft = texelForIndex(textureIndexForPos(outPos));
	vec4 topRight = texelForIndex(textureIndexForPos(outPos + vec4(spacing, 0, 0, 0)));
	vec4 bottomLeft = texelForIndex(textureIndexForPos(outPos + vec4(0, 0, spacing, 0)));
	vec4 bottomRight = texelForIndex(textureIndexForPos(outPos + vec4(spacing, 0, spacing, 0)));

	float integerPart;
	float hLerp = modf(outPos.x/spacing, integerPart);
	float vLerp = modf(outPos.z/spacing, integerPart);

	vec4 h1 = mix(topLeft, topRight, hLerp);
	vec4 h2 = mix(bottomLeft, bottomRight, hLerp);

	color = mix(h1, h2, vLerp);
}
