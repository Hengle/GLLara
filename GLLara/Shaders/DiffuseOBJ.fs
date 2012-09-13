/*
 * Like Diffuse, but uses material properties and specular lighting
 */
#version 150

in vec4 outColor;
in vec2 outTexCoord;
in vec3 normalWorld;
in vec3 positionWorld;

out vec4 screenColor;

uniform sampler2D diffuseTexture;

struct Light {
	vec4 diffuseColor;
	vec4 specularColor;
	vec4 direction;
};

layout(std140) uniform LightData {
	vec4 cameraPosition;
	vec4 ambientColor;
	Light lights[3];
} lightData;

layout(std140) uniform AlphaTest {
	uint mode; // 0 - none, 1 - pass if greater than, 2 - pass if less than.
	float reference;
} alphaTest;

uniform RenderParameters {
	vec4 ambientColor;
	vec4 diffuseColor;
	vec4 specularColor;
	float specularExponent;
} parameters;

void main()
{
	// Find diffuse texture and do alpha test.
	vec4 diffuseTexColor = texture(diffuseTexture, outTexCoord);
	if ((alphaTest.mode == 1U && diffuseTexColor.a <= alphaTest.reference) || (alphaTest.mode == 2U && diffuseTexColor.a >= alphaTest.reference))
	discard;
	
	// Base diffuse color
	vec4 diffuseColor = diffuseTexColor * outColor;
	
	// Direction to camera
	vec3 cameraDirection = normalize(lightData.cameraPosition.xyz - positionWorld);
	
	vec4 color = lightData.ambientColor * diffuseColor * parameters.ambientColor;
	for (int i = 0; i < 3; i++)
	{
		// Diffuse term; this version does not use specular
		color += diffuseTexColor * lightData.lights[i].diffuseColor * max(dot(-normalWorld, lightData.lights[i].direction.xyz), 0) * parameters.diffuseColor;
		
		// Specular term
		vec3 reflectedLightDirection = reflect(lightData.lights[i].direction.xyz, normalWorld);
		float specularFactor = pow(max(dot(cameraDirection, reflectedLightDirection), 0), parameters.specularExponent);
		color += lightData.lights[i].specularColor * specularFactor * parameters.specularColor;
	}
	
	screenColor = vec4(color.rgb, diffuseTexColor.a);
}
