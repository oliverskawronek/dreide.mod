!!ARBvp1.0

# Bumpmapping VertexProgram v1.1 by Oliver Skawronek

# Matrices
PARAM ModelViewInv[4]        = { state.matrix.modelview.invtrans };
PARAM ModelViewProjection[4] = { state.matrix.mvp };

# Temporary variable
TEMP Position, LightPosition, EyeNormal, Distance, Dot3, Color;

# Transform VertexPosition
DP4 Position.x, ModelViewProjection[0], vertex.position;
DP4 Position.y, ModelViewProjection[1], vertex.position;
DP4 Position.z, ModelViewProjection[2], vertex.position;
DP4 Position.w, ModelViewProjection[3], vertex.position;

# Transform LightPosition
DP4 LightPosition.x, ModelViewProjection[0], program.local[0];
DP4 LightPosition.y, ModelViewProjection[1], program.local[0];
DP4 LightPosition.z, ModelViewProjection[2], program.local[0];
DP4 LightPosition.w, ModelViewProjection[3], program.local[0];

# Transform VertexNormal
DP3 EyeNormal.x, ModelViewInv[0], vertex.normal;
DP3 EyeNormal.y, ModelViewInv[1], vertex.normal;
DP3 EyeNormal.z, ModelViewInv[2], vertex.normal;

# Distance = VertexPosition-LightPosition
SUB Distance, Position, LightPosition;

# Normalize DistanceVector
DP3 Distance.w, Distance, Distance;     # w = x*x+y*y+z*z
RSQ Distance.w, Distance.w;             # w = 1.0/sqrt(w)
MUL Distance.xyz, Distance, Distance.w; # x = x*w, y = y*w, z = z*w

# DotProduct between EyeNormal- and DistanceVector
DP3 Dot3.x, EyeNormal, Distance;

# If DotProduct < 0.0 Then DotProduct = 0.0
SGE Dot3.y, Dot3.x, 0.0;
MUL Dot3.x, Dot3.x, Dot3.y;

# Calculate Color
MUL Color.x, Distance.x, Dot3.x;
MUL Color.y, Distance.y, Dot3.x;
MUL Color.z, Distance.z, Dot3.x;
MOV Color.w, vertex.color.w;

ADD Color.x, Color.x, 1.0;
ADD Color.y, Color.y, 1.0;
ADD Color.z, Color.z, 1.0;

MUL Color.x, Color.x, 0.5;
MUL Color.y, Color.y, 0.5;
MUL Color.z, Color.z, 0.5;

# Output the Result
MOV result.position, Position;
MOV result.color, Color;
MOV result.texcoord, vertex.texcoord;
MOV result.texcoord[1], vertex.texcoord[1];

END