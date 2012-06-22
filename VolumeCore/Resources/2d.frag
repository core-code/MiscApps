uniform sampler3D voxelTexture;
uniform sampler1D transferFunctionTexture;
uniform float depth;
uniform float stepsize;
uniform int side;
uniform int method;
uniform float maxsum;

void main()
{	
	if (gl_TexCoord[0].x < 1.0 && gl_TexCoord[0].x > 0.0 && gl_TexCoord[0].y > 0.0 && gl_TexCoord[0].y < 1.0)
	{
		float steps;
		vec4 color, curcolor;
		
		if (method == 0) // slice
		{
			if (side == 0)
				color = texture3D(voxelTexture, vec3(gl_TexCoord[0].x, depth, gl_TexCoord[0].y));	
			else if (side == 1)
				color = texture3D(voxelTexture, vec3(gl_TexCoord[0].x, gl_TexCoord[0].y , depth));	
			else if (side == 2)
				color = texture3D(voxelTexture, vec3(depth, gl_TexCoord[0].x, gl_TexCoord[0].y));	
		}
		else if (method == 1) // avg
		{
			if (side == 0)
			{
				for (float i = 0.0; i <= 1.0; i += stepsize) 
				{
					color += texture3D(voxelTexture, vec3(gl_TexCoord[0].x, i, gl_TexCoord[0].y));
					steps += 1.0;
				}				
			}	
			else if (side == 1)
			{
				for (float i = 0.0; i <= 1.0; i += stepsize) 
				{
					color += texture3D(voxelTexture, vec3(gl_TexCoord[0].x, gl_TexCoord[0].y, i));
					steps += 1.0;
				}				
			}
			else if (side == 2)
			{
				for (float i = 0.0; i <= 1.0; i += stepsize) 
				{
					color += texture3D(voxelTexture, vec3(i, gl_TexCoord[0].x, gl_TexCoord[0].y));
					steps += 1.0;
				}			
			}
									
			color /= steps * maxsum * 0.15;		
		}
		else if (method == 2) // mip
		{
			color = vec4(0.0,0.0,0.0,0.0);
			
			if (side == 0)
			{
				for (float i = 0.0; i <= 1.0; i += stepsize) 
				{			
					curcolor = texture3D(voxelTexture, vec3(gl_TexCoord[0].x, i, gl_TexCoord[0].y));
				
					if (curcolor.x > color.x)
						color = curcolor;
				}
			}	
			else if (side == 1)
			{
				for (float i = 0.0; i <= 1.0; i += stepsize) 
				{			
					curcolor = texture3D(voxelTexture, vec3(gl_TexCoord[0].x, gl_TexCoord[0].y, i));
				
					if (curcolor.x > color.x)
						color = curcolor;
				}			
			}
			else if (side == 2)
			{
				for (float i = 0.0; i <= 1.0; i += stepsize) 
				{			
					curcolor = texture3D(voxelTexture, vec3(i, gl_TexCoord[0].x, gl_TexCoord[0].y));
				
					if (curcolor.x > color.x)
						color = curcolor;
				}			
			}
		}	
		
		gl_FragColor = texture1D(transferFunctionTexture, color.x * 16.0);
	}
	else
		gl_FragColor = abs(gl_TexCoord[0] - vec4(0.5, 0.5, 0.5, 0.5)) / 10.0;
}