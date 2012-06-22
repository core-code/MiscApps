uniform sampler2D heightTextureUnit;
uniform sampler2D waterTextureUnit;
uniform sampler2D sandTextureUnit;
uniform sampler2D grassTextureUnit;
uniform sampler2D rockTextureUnit;
uniform sampler2D snowTextureUnit;
	
#ifdef SHADING
varying vec3 normal;  
varying vec3 position;  
varying float height;
#endif

void main()  
{  
#ifdef SHADING
    // normalize the vertex normal and the view vector  
    vec3 n = normalize(normal);
    vec3 view = normalize(-position);
 
    // these variables will accumulate for each light  
    vec4 ambient = vec4(gl_FrontLightModelProduct.sceneColor);  
	vec4 diffuse = vec4(0.0);  
	vec4 specular = vec4(0.0);  
    
	// determine the light and light reflection vectors  
	vec3 light = normalize(gl_LightSource[0].position.xyz - position);  
	vec3 reflected = -reflect(light, n);   

  
	// add the current light's ambient value  
	ambient += gl_FrontLightProduct[0].ambient;  
  
	// calculate and add the current light's diffuse value  
	vec4 calculatedDiffuse = vec4(max(dot(n, light), 0.0));  
	diffuse += gl_FrontLightProduct[0].diffuse * calculatedDiffuse;  
  
	// calculate and add the current light's specular value  
	vec4 calculatedSpecular = vec4(pow(max(dot(reflected, view), 0.0), 0.3 * gl_FrontMaterial.shininess));
	specular += clamp(gl_FrontLightProduct[0].specular * calculatedSpecular, 0.0, 1.0);  

	gl_FragColor = ambient + diffuse + specular;

	#ifdef HEIGHTCODING
	gl_FragColor *= texture2D(heightTextureUnit, gl_TexCoord[0].xy);
	#endif
	#ifdef TERRAINTEXTURING
	if (height < 1.0/9.0)
		gl_FragColor *= texture2D(waterTextureUnit, gl_TexCoord[0].xy * 40.0);
	else if  (height < 2.0/9.0)
	{
		float factor = ((height - 1.0/9.0) * 9.0);
		gl_FragColor *= texture2D(sandTextureUnit, gl_TexCoord[0].xy * 40.0) * factor + texture2D(waterTextureUnit, gl_TexCoord[0].xy * 40.0) * (1.0 - factor);
	}
	else if  (height < 3.0/9.0)
		gl_FragColor *= texture2D(sandTextureUnit, gl_TexCoord[0].xy * 40.0);
	else if  (height < 4.0/9.0)
	{
		float factor = ((height - 3.0/9.0) * 9.0);
		vec4 sample = texture2D(grassTextureUnit, gl_TexCoord[0].xy * 40.0) * factor + texture2D(sandTextureUnit, gl_TexCoord[0].xy * 40.0) * (1.0 - factor);
		gl_FragColor *= sample;
	}
	else if  (height < 5.0/9.0)
		gl_FragColor *= texture2D(grassTextureUnit, gl_TexCoord[0].xy * 40.0);
	else if  (height < 6.0/9.0)
	{
		float factor = ((height - 5.0/9.0) * 9.0);
		vec4 sample = texture2D(rockTextureUnit, gl_TexCoord[0].xy * 40.0) * factor + texture2D(grassTextureUnit, gl_TexCoord[0].xy * 40.0) * (1.0 - factor);
		gl_FragColor *= sample;
	}		
	else if  (height < 7.0/9.0)
		gl_FragColor *= texture2D(rockTextureUnit, gl_TexCoord[0].xy * 40.0);	
	else if  (height < 8.0/9.0)
	{
		float factor = ((height - 7.0/9.0) * 9.0);
		vec4 sample = texture2D(snowTextureUnit, gl_TexCoord[0].xy * 40.0) * factor + texture2D(rockTextureUnit, gl_TexCoord[0].xy * 40.0) * (1.0 - factor);
		gl_FragColor *= sample;
	}
	else		
		gl_FragColor *= texture2D(snowTextureUnit, gl_TexCoord[0].xy * 40.0);	
		
	//gl_FragColor *= texture2D(heightTextureUnit, gl_TexCoord[0].xy) * 1.4;		// we take the heightmap as ambient occlusion approximation. take that crytek.
	//gl_FragColor += (texture2D(heightTextureUnit, gl_TexCoord[0].xy) - vec4(0.6,0.6,0.6,0.0)) / 5.0;		// we take the heightmap as ambient occlusion approximation. take that crytek.
	#endif
#endif
#ifdef WIREFRAME
	gl_FragColor = vec4(1.0,1.0,1.0,1.0);
#endif
}  