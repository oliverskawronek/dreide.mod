uniform vec4 SzeneColor;

void main(void)
{
   gl_FragColor = gl_Color*SzeneColor;
}