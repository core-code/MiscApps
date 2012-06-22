uniform sampler2D 	pointspriteTexture;
	
varying mat2		mat;

void main()
{
	vec2 h = vec2(0.5, 0.5); 
	vec2 rot = (mat * (gl_TexCoord[0].st - h)) + h;
	gl_FragColor = texture2D(pointspriteTexture, rot.st);

	gl_FragColor.w = 1.0;
}

