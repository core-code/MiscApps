uniform vec3 size;

void main(void)
{
	gl_Position = ftransform();
	gl_FrontColor = vec4(gl_Vertex.xyz * size, 1.0);
}
