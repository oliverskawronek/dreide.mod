!!ARBfp1.0

# Watershading VertexProgram by Jan "YellowRider" Müller

TEMP color, color2, color3, color4, normal, texcoord, texcoord2;

ADD texcoord2, fragment.texcoord, program.local[0].x;
ADD texcoord, fragment.texcoord, program.local[0].y;
MUL texcoord, texcoord, 0.15;

TEX color2, texcoord2, texture[1], 2D;
TEX color3, texcoord, texture[2], 2D;

MUL color4, color2, 1.10;
MUL color2, color2, 0.03;
MUL color3, color3, 0.03;
ADD color2, color3, color2;

MOV texcoord, 0;
ADD texcoord, fragment.texcoord, color2;
TEX color, texcoord, texture[0], 2D;

MOV result.color, color;

END