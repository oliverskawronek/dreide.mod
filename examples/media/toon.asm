!!ARBvp1.0

# Toonshading VertexProgram v1.1 by Oliver Skawronek

# Matrices
PARAM ModelViewInv[4]        = { state.matrix.modelview.invtrans };
PARAM ModelViewProjection[4] = { state.matrix.mvp };

# Temporary variable
TEMP Position, EyeNormal, UVCoords, Result;

# Transform VertexPosition
DP4 Position.x, ModelViewProjection[0], vertex.position;
DP4 Position.y, ModelViewProjection[1], vertex.position;
DP4 Position.z, ModelViewProjection[2], vertex.position;
DP4 Position.w, ModelViewProjection[3], vertex.position;

# Transform VertexNormal
DP3 EyeNormal.x, ModelViewInv[0], vertex.normal;
DP3 EyeNormal.y, ModelViewInv[1], vertex.normal;
DP3 EyeNormal.z, ModelViewInv[2], vertex.normal;

# Copy VertexTexCoords in to UVCoords
MOV UVCoords, vertex.texcoord;

# U-Coord of Vertex = Dot Product between EyeNormal und LightDirection
DP3 UVCoords.x, EyeNormal, program.local[0];

# If UVCoord.x < 0.0 Then UVCoord.x = 0.01
SGE Result.x, UVCoords.x, 0.0;
MUL UVCoords.x, UVCoords.x, Result.x;

SLT Result.x, UVCoords.x, 0.01;
MUL Result.x, Result.x, 0.01;
ADD UVCoords.x, UVCoords.x, Result.x; 

# Output the result
MOV result.position, Position;
MOV result.texcoord, UVCoords;
MOV result.color, vertex.color;

END