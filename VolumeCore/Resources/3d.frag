#extension GL_ARB_texture_rectangle : enable

uniform sampler3D voxelTexture;
uniform sampler1D transferFunctionTexture;
uniform sampler2DRect rayStartTexture;
uniform sampler2DRect rayEndTexture;
uniform int method;
uniform int width;
uniform int height;
uniform float stepsize;
uniform int steps;
uniform int stepmethod;
uniform float size_max;
uniform float maxsum;
uniform vec3 dataset_dimension;

vec3 computegradient(vec3 raypos)
{
	vec3 sample1, sample2;
	vec3 offset = vec3(1.0/dataset_dimension.x, 1.0/dataset_dimension.y, 1.0/dataset_dimension.z);
	
	sample1.x = texture3D(voxelTexture, raypos-vec3(offset.x,0.0,0.0)).x;
	sample2.x = texture3D(voxelTexture, raypos+vec3(offset.x,0.0,0.0)).x;
	sample1.y = texture3D(voxelTexture, raypos-vec3(0.0,offset.y,0.0)).y;
	sample2.y = texture3D(voxelTexture, raypos+vec3(0.0,offset.y,0.0)).y;
	sample1.z = texture3D(voxelTexture, raypos-vec3(0.0,0.0,offset.z)).z;
	sample2.z = texture3D(voxelTexture, raypos+vec3(0.0,0.0,offset.z)).z;			
	
	return (sample2 - sample1);
}

void main()
{	
	vec3 rayStart = texture2DRect(rayStartTexture, gl_TexCoord[0].xy).xyz;
	vec3 rayEnd = texture2DRect(rayEndTexture, gl_TexCoord[0].xy).xyz;
	vec3 rayDir = (rayEnd - rayStart);	
	int realsteps;
	if (stepmethod == 0) // relative
		realsteps = int(length(rayDir) * size_max * stepsize);
	else
		realsteps = steps;
		
	rayDir /= float(realsteps);
	vec4 color, curcolor, transferred;
	
 
	if (length(rayStart) != 0.0)
	{
		color = vec4(0.0,0.0,0.0,0.0);

		if (method == 0) // avg
		{
			for (int i = 0; i <= realsteps; i += 1) 
			{
				rayStart += rayDir;
				transferred = texture1D(transferFunctionTexture, texture3D(voxelTexture, rayStart).x * 16.0);	
				color.xyz += transferred.w * transferred.xyz;
				color.w += transferred.w; 
			}		
				
			color /= float(realsteps) * maxsum * 0.08;
		}
		else if (method == 1) // mip
		{
			vec3 raypos;
			
			for (int i = 0; i <= realsteps; i += 1) 
			{
				rayStart += rayDir;		
				curcolor = texture3D(voxelTexture, rayStart);
				
				if (curcolor.x > color.x)
				{
					color = curcolor;
					raypos = rayStart;
				}
			}
			
			color = texture1D(transferFunctionTexture, color.x * 16.0);	
		}		
		else if (method == 2) // comp
		{
			for (int i = 0; i <= realsteps; i += 1) 
			{		
				rayStart += rayDir;
				transferred = texture1D(transferFunctionTexture, texture3D(voxelTexture, rayStart).x * 16.0);				
				
				color.xyz += (1.0 - color.w) * transferred.w * transferred.xyz; 
				color.w += (1.0 - color.w) * transferred.w; 

				if (color.w >= 0.99)
					break;	
			}
		}
		else if (method == 3) // comp + shading
		{
			const float materialShininess = 30.0;
			
			for (int i = 0; i <= realsteps; i += 1) 
			{		
				rayStart += rayDir;
				transferred = texture1D(transferFunctionTexture, texture3D(voxelTexture, rayStart).x * 16.0);

				if (transferred.w > 0.001)
				{
					// shading				
					vec3 N = normalize(gl_NormalMatrix * computegradient(rayStart));
					vec3 L = normalize(vec3(gl_LightSource[0].position - (gl_ModelViewMatrix * vec4(rayStart, 1.0))));
					vec3 specular, diffuse, ambient;
					
					float NdotL = max(dot(N,L), 0.0);
					if (NdotL > 0.0)
					{
						float NdotHV = max(dot(N, normalize(gl_LightSource[0].halfVector.xyz)), 0.0);
						specular = gl_LightSource[0].specular.xyz * pow(NdotHV, materialShininess);
					}
					diffuse = transferred.xyz * gl_LightSource[0].diffuse.xyz;
					ambient = transferred.xyz * gl_LightSource[0].ambient.xyz;
					vec3 shadedColor = NdotL * diffuse + ambient + specular;

					color.xyz += (1.0 - color.w) * transferred.w * shadedColor.xyz; 
					color.w += (1.0 - color.w) * transferred.w; 

					if (color.w >= 0.99)
						break;	
				}
			}
		}		
							
		gl_FragColor = color;
	}
	else
		//gl_FragColor = abs(vec4(gl_TexCoord[0].x / float(width), gl_TexCoord[0].y / float(height), 1.0, 1.0)  - vec4(0.5, 0.5, 0.5, 0.5)) / 10.0;
		gl_FragColor = vec4(gl_TexCoord[0].x / float(width), gl_TexCoord[0].y / float(height), 1.0, 1.0);
}