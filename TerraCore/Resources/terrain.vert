#ifdef SHADING
varying vec3 normal;  
varying vec3 position; 
varying float height;
#endif
uniform sampler2D heightTextureUnit;
uniform float heightTextureSize;
uniform float heightScale;
uniform float waterHeight;

void main (void)
{	

	gl_TexCoord[0] = vec4(gl_MultiTexCoord0.x, 1.0 - gl_MultiTexCoord0.y, gl_MultiTexCoord0.z, gl_MultiTexCoord0.w); // note, the "1.0 - " is because the texcoords of the meshes aren't aligned with the mesh ... could drop the texcoords altogether because they can be reconstructed from the worldspace vertex positions cause in our case the mesh won't be moved or rotated or stuff. 'nuff said, longest comment ever, blah, blah

#ifdef SHADING
	float stepsize = 400.0 / heightTextureSize;
	float stepsizeTexture = 1.0 / heightTextureSize;
	vec3 n = vec3(0.0,0.0,0.0);
	
	vec3 sample = vec3(gl_Vertex.x, max(texture2D(heightTextureUnit, gl_TexCoord[0].xy).x, waterHeight) * heightScale, gl_Vertex.z);
	vec3 sampleleft = vec3(gl_Vertex.x - stepsize, max(texture2D(heightTextureUnit, gl_TexCoord[0].xy - vec2(stepsizeTexture, 0.0)).x, waterHeight) * heightScale, gl_Vertex.z);
	vec3 sampleright = vec3(gl_Vertex.x + stepsize, max(texture2D(heightTextureUnit, gl_TexCoord[0].xy + vec2(stepsizeTexture, 0.0)).x, waterHeight) * heightScale, gl_Vertex.z);
	vec3 samplebottom = vec3(gl_Vertex.x, max(texture2D(heightTextureUnit, gl_TexCoord[0].xy - vec2(0.0, stepsizeTexture)).x, waterHeight) * heightScale, gl_Vertex.z - stepsize);
	vec3 sampletop = vec3(gl_Vertex.x, max(texture2D(heightTextureUnit, gl_TexCoord[0].xy + vec2(0.0, stepsizeTexture)).x, waterHeight) * heightScale, gl_Vertex.z + stepsize);

	n += normalize(cross(sampletop - sample, sampleright - sample));
	n += normalize(cross(sampleright - sample, samplebottom - sample));
	n += normalize(cross(samplebottom - sample, sampleleft - sample));
	n += normalize(cross(sampleleft - sample, sampletop - sample));
    normal = normalize(gl_NormalMatrix * n);
	

	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(sample, 1.0);
	
    position = vec3(gl_ModelViewMatrix * vec4(sample, 1.0));
	height = sample.y / heightScale;
#endif
#ifdef WIREFRAME
	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(gl_Vertex.x, max(texture2D(heightTextureUnit, gl_TexCoord[0].xy).x, waterHeight) * heightScale, gl_Vertex.z, gl_Vertex.w);
#endif
}