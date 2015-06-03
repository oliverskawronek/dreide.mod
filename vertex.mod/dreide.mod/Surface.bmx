SuperStrict

Import "Material.bmx"

Type TSurface
	Field Name          : String
	Field Material      : TMaterial
	Field Dynamic       : Int
	Field VertexCount   : Int
	Field Vertices      : Float Ptr[6]
	Field VBuffers      : Int[6]
	Field TriangleCount : Int
	Field Triangles     : Int Ptr
	Field IBuffer       : Int

	Method New()
		Self.Name          = "Unnamed Surface"
		Self.Material      = Null
		Self.Dynamic       = False
		Self.VertexCount   = 0
		If THardwareInfo.VBOSupport Then
			' Generate HardwareBuffers for Vertices and Traingles
			glGenBuffersARB(6, Self.VBuffers)
			glGenBuffersARB(1, Varptr(Self.IBuffer))
		EndIf
		Self.TriangleCount = 0
	End Method

	Method Delete()
		If THardwareInfo.VBOSupport Then
			' Delete HardwareBuffers for Vertices and Traingles
			glDeleteBuffers(5, Self.VBuffers)
			glDeleteBuffers(1, Varptr(Self.IBuffer))
		EndIf
	End Method

	Method Render(Entity:TEntity)
		' Material
		If Self.Material Then
			Local Layer:Int, UVSet:Int

			' Render Material
			Self.Material.Render(Entity)

			' Bind all Textures
			For Layer = 0 Until THardwareInfo.MaxTextures
				glClientActiveTexture(GL_TEXTURE0+Layer)
				glActiveTexture(GL_TEXTURE0+Layer)

				If Self.Material.Textures[Layer] Then
					UVSet = 2+Self.Material.Textures[Layer].GetCoordSet()

					glEnableClientState(GL_TEXTURE_COORD_ARRAY)
					If THardwareInfo.VBOSupport Then
						' Bind TextureCoords 0
						glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[UVSet])
						glTexCoordPointer(2, GL_FLOAT, 0, Null)
					Else
						glTexCoordPointer(2, GL_FLOAT, 0, Self.Vertices[UVSet])
					EndIf
					Self.Material.Textures[Layer].Render(Entity)
				Else
					glDisable(GL_TEXTURE_2D)
					glDisable(GL_TEXTURE_CUBE_MAP)
				EndIf
			Next
		Else
			' Set MaterialDefaults
			TMaterial.RenderDefault()
		EndIf

		' Check for VertexBufferObject-Support
		If THardwareInfo.VBOSupport Then
			' Render all Buffers of the VideoRAM

			' Bind Vertex-Color
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[4])
			glColorPointer(4, GL_FLOAT, 0, Null)

			' Bind Normals
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[1])
			glNormalPointer(GL_FLOAT, 0, Null)

			' Bind Vertices
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[0])
			glVertexPointer(3, GL_FLOAT, 0, Null)

			' Bind TriangleBuffer
			glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, Self.IBuffer)

			' Display Triangles
			glDrawElements(GL_TRIANGLES, Self.TriangleCount*3, GL_UNSIGNED_INT, Null)
		Else
			' Render all Buffers in the WorkRAM
			glColorPointer(4, GL_FLOAT, 0, Self.Vertices[4])
			glNormalPointer(GL_FLOAT, 0, Self.Vertices[1])
			glVertexPointer(3, GL_FLOAT, 0, Self.Vertices[0])
			glDrawElements(GL_TRIANGLES, Self.TriangleCount*3, GL_UNSIGNED_INT, ..
			               Self.Triangles)
		EndIf
	End Method

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetMaterial(Material:TMaterial)
		Self.Material = Material
	End Method

	Method GetMaterial:TMaterial()
		Return Self.Material
	End Method

	Method SetDynamic(Dynamic:Int)
		Self.Dynamic = Dynamic
	End Method

	Method GetDynamic:Int()
		Return Self.Dynamic
	End Method

	Method CountVertices:Int()
		Return Self.VertexCount
	End Method

	Method CreateVertex:Int(X:Float, Y:Float, Z:Float, U:Float=0.0, V:Float=0.0)
		Local Temp : Byte Ptr

		If Self.VertexCount < 1 Then
			Self.Vertices[0] = Float Ptr(MemAlloc(12))
			Self.Vertices[1] = Float Ptr(MemAlloc(12))
			Self.Vertices[2] = Float Ptr(MemAlloc(8))
			Self.Vertices[3] = Float Ptr(MemAlloc(8))
			Self.Vertices[4] = Float Ptr(MemAlloc(16))
			Self.Vertices[5] = Float Ptr(MemAlloc(4))
		Else
			' Copy Positions
			Temp = MemAlloc((Self.VertexCount+1)*12)
			MemCopy(Temp, Self.Vertices[0], Self.VertexCount*12)
			MemFree(Self.Vertices[0])
			Self.Vertices[0] = Float Ptr(Temp)

			' Copy Normals
			Temp = MemAlloc((Self.VertexCount+1)*12)
			MemCopy(Temp, Self.Vertices[1], Self.VertexCount*12)
			MemFree(Self.Vertices[1])
			Self.Vertices[1] = Float Ptr(Temp)

			' Copy TexCoords 0
			Temp = MemAlloc((Self.VertexCount+1)*8)
			MemCopy(Temp, Self.Vertices[2], Self.VertexCount*8)
			MemFree(Self.Vertices[2])
			Self.Vertices[2] = Float Ptr(Temp)

			' Copy TexCoords 1
			Temp = MemAlloc((Self.VertexCount+1)*8)
			MemCopy(Temp, Self.Vertices[3], Self.VertexCount*8)
			MemFree(Self.Vertices[3])
			Self.Vertices[3] = Float Ptr(Temp)

			' Copy Colors
			Temp = MemAlloc((Self.VertexCount+1)*16)
			MemCopy(Temp, Self.Vertices[4], Self.VertexCount*16)
			MemFree(Self.Vertices[4])
			Self.Vertices[4] = Float Ptr(Temp)

			' Copy Attributes
			Temp = MemAlloc((Self.VertexCount+1)*4)
			MemCopy(Temp, Self.Vertices[5], Self.VertexCount*4)
			MemFree(Self.Vertices[5])
			Self.Vertices[5] = Float Ptr(Temp)
		EndIf

		' Position
		Self.Vertices[0][VertexCount*3  ] = X
		Self.Vertices[0][VertexCount*3+1] = Y
		Self.Vertices[0][VertexCount*3+2] = Z

		' Normal
		Self.Vertices[1][VertexCount*3  ] = 0.0
		Self.Vertices[1][VertexCount*3+1] = 0.0
		Self.Vertices[1][VertexCount*3+2] = 0.0

		' TexCoords 0
		Self.Vertices[2][VertexCount*2  ] = U
		Self.Vertices[2][VertexCount*2+1] = V

		' TexCoords 1
		Self.Vertices[3][VertexCount*2  ] = U
		Self.Vertices[3][VertexCount*2+1] = V

		' Color
		Self.Vertices[4][VertexCount*4  ] = 1.0
		Self.Vertices[4][VertexCount*4+1] = 1.0
		Self.Vertices[4][VertexCount*4+2] = 1.0
		Self.Vertices[4][VertexCount*4+3] = 1.0

		' Attribute
		Self.Vertices[5][VertexCount    ] = 0.0

		Self.VertexCount :+ 1
		Return Self.VertexCount-1
	End Method

	Method SetVertexPosition:Int(Vertex:Int, X:Float, Y:Float, Z:Float)
		If Vertex < 0 Or Vertex => VertexCount Then Return False

		Self.Vertices[0][Vertex*3]   = X
		Self.Vertices[0][Vertex*3+1] = Y
		Self.Vertices[0][Vertex*3+2] = Z

		Return True
	End Method

	Method GetVertexPosition:Int(Vertex:Int, X:Float Var, Y:Float Var, Z:Float Var)
		If Vertex < 0 Or Vertex => VertexCount Then Return False

		X = Self.Vertices[0][Vertex*3]
		Y = Self.Vertices[0][Vertex*3+1]
		Z = Self.Vertices[0][Vertex*3+2]

		Return True
	End Method

	Method GetVertexX:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[0][Vertex*3]
	End Method

	Method GetVertexY:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[0][Vertex*3+1]
	End Method

	Method GetVertexZ:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[0][Vertex*3+2]
	End Method

	Method SetVertexNormal:Int(Vertex:Int, X:Float, Y:Float, Z:Float)
		If Vertex < 0 Or Vertex => VertexCount Then Return False

		Self.Vertices[1][Vertex*3]   = X
		Self.Vertices[1][Vertex*3+1] = Y
		Self.Vertices[1][Vertex*3+2] = Z

		Return True
	End Method

	Method GetVertexNormal:Int(Vertex:Int, X:Float Var, Y:Float Var, Z:Float Var)
		If Vertex < 0 Or Vertex => VertexCount Then Return False

		X = Self.Vertices[1][Vertex*3]
		Y = Self.Vertices[1][Vertex*3+1]
		Z = Self.Vertices[1][Vertex*3+2]

		Return True
	End Method

	Method GetVertexNX:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[1][Vertex*3]
	End Method

	Method GetVertexNY:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[1][Vertex*3+1]
	End Method

	Method GetVertexNZ:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[1][Vertex*3+2]
	End Method
	
	Method SetVertexTexCoords:Int(Vertex:Int, U:Float, V:Float, UVSet:Int=0)
		If Vertex < 0 Or Vertex => VertexCount Or ..
		   UVSet < 0 Or UVSet > 1 Then Return False
		
		If UVSet = 0 Then
			Self.Vertices[2][Vertex*2]   = U
			Self.Vertices[2][Vertex*2+1] = V
		Else
			Self.Vertices[3][Vertex*2]   = U
			Self.Vertices[3][Vertex*2+1] = V
		EndIf

		Return True
	End Method

	Method GetVertexTexCoords:Int(Vertex:Int, U:Float Var, V:Float Var, UVSet:Int=0)
		If Vertex < 0 Or Vertex => VertexCount Or ..
		   UVSet < 0 Or UVSet > 1 Then Return 0.0
		
		If UVSet = 0 Then
			U = Self.Vertices[2][Vertex*2]
			V = Self.Vertices[2][Vertex*2+1]
		Else
			U = Self.Vertices[3][Vertex*2]
			V = Self.Vertices[3][Vertex*2+1]
		EndIf

		Return True
	End Method

	Method GetVertexU:Float(Vertex:Int, UVSet:Int=0)
		If Vertex < 0 Or Vertex => VertexCount Or ..
		   UVSet < 0 Or UVSet > 1 Then Return 0.0
		
		If UVSet = 0
			Return Self.Vertices[2][Vertex*2]
		Else
			Return Self.Vertices[3][Vertex*2]
		EndIf
	End Method

	Method GetVertexV:Float(Vertex:Int, UVSet:Int=0)
		If Vertex < 0 Or Vertex => VertexCount Or ..
		   UVSet < 0 Or UVSet > 1 Then Return 0.0
		
		If UVSet = 0
			Return Self.Vertices[2][Vertex*2+1]
		Else
			Return Self.Vertices[3][Vertex*2+1]
		EndIf
	End Method

	Method SetVertexColor:Int(Vertex:Int, R:Float, G:Float, B:Float, A:Float=1.0)
		If Vertex < 0 Or Vertex => VertexCount Then Return False
		
		Self.Vertices[4][Vertex*4]   = R
		Self.Vertices[4][Vertex*4+1] = G
		Self.Vertices[4][Vertex*4+2] = B
		Self.Vertices[4][Vertex*4+3] = A

		Return True
	End Method

	Method GetVertexColor:Int(Vertex:Int, R:Float Var, G:Float Var, B:Float Var, ..
	                          A:Float Var)
		If Vertex < 0 Or Vertex => VertexCount Then Return False

		R = Self.Vertices[4][Vertex*4]
		G = Self.Vertices[4][Vertex*4+1]
		B = Self.Vertices[4][Vertex*4+2]
		A = Self.Vertices[4][Vertex*4+3]

		Return True
	End Method

	Method GetVertexR:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[4][Vertex*4]
	End Method

	Method GetVertexG:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[4][Vertex*4+1]
	End Method

	Method GetVertexB:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[4][Vertex*4+2]
	End Method

	Method GetVertexA:Float(Vertex:Int)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[4][Vertex*4+3]
	End Method
	
	Method SetVertexAttribute:Int(Vertex:Int, Value:Float)
		If Vertex < 0 Or Vertex => VertexCount Then Return False
		
		Self.Vertices[4][Vertex] = Value
		Return True
	End Method

	Method GetVertexAttribute:Float(Vertex:Int, Value:Float)
		If Vertex < 0 Or Vertex => VertexCount Then Return 0.0
		Return Self.Vertices[5][Vertex]
	End Method

	Method CountTriangles:Int()
		Return Self.TriangleCount
	End Method

	Method CreateTriangle:Int(V0:Int, V1:Int, V2:Int)
		Local Temp : Byte Ptr

		If V0 < 0 Or V0 => Self.VertexCount Or ..
		   V1 < 0 Or V1 => Self.VertexCount Or ..
		   V2 < 0 Or V2 => Self.VertexCount Then Return -1
		
		If Self.TriangleCount < 1 Then
			Self.Triangles = Int Ptr(MemAlloc(12))
		Else
			' Copy Indices
			Temp = MemAlloc((Self.TriangleCount+1)*12)
			MemCopy(Temp, Self.Triangles, Self.TriangleCount*12)
			Self.Triangles = Int Ptr(Temp)
		EndIf
		
		' Set Indices
		Self.Triangles[Self.TriangleCount*3  ] = V0
		Self.Triangles[Self.TriangleCount*3+1] = V1
		Self.Triangles[Self.TriangleCount*3+2] = V2
		
		Self.TriangleCount :+ 1
		Return Self.TriangleCount-1
	End Method
	
	Method SetTriangle:Int(Triangle:Int, V0:Int, V1:Int, V2:Int)
		If Triangle < 0 Or Triangle => Self.TriangleCount Or .. 
		   V0 < 0 Or V0 => Self.VertexCount Or ..
		   V1 < 0 Or V1 => Self.VertexCount Or ..
		   V2 < 0 Or V2 => Self.VertexCount Then Return False
		
		Self.Triangles[Triangle*3  ] = V0
		Self.Triangles[Triangle*3+1] = V1
		Self.Triangles[Triangle*3+2] = V2
		
		Return True
	End Method
	
	Method UpdateVertices:Int(Position:Int=True, Normal:Int=True, UV0:Int=True, ..
	                          UV1:Int=True, Color:Int=True, Attributes:Int=True)
		Local Flag : Int

		' Check for VertexBufferObject-Support
		If Not THardwareInfo.VBOSupport Then Return False

		If Self.Dynamic Then
			Flag = GL_DYNAMIC_DRAW
		Else
			Flag = GL_STATIC_DRAW
		EndIf

		' Transfer Buffer(s) from WorkRAM to VideoRAM
		If Position Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[0])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*12, Self.Vertices[0], Flag)
		EndIf

		If Normal Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[1])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*12, Self.Vertices[1], Flag)
		EndIf

		If UV0 Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[2])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*8, Self.Vertices[2], Flag)
		EndIf

		If UV1 Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[3])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*8, Self.Vertices[3], Flag)
		EndIf

		If Color Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[4])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*16, Self.Vertices[4], Flag)
		EndIf

		If Attributes Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VBuffers[5])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*4, Self.Vertices[5], Flag)
		EndIf
		
		Return True
	End Method
	
	Method UpdateTriangles:Int()
		Local Flag : Int

		' Check for VertexBufferObject-Support
		If Not THardwareInfo.VBOSupport Then Return False

		If Self.Dynamic Then
			Flag = GL_DYNAMIC_DRAW
		Else
			Flag = GL_STATIC_DRAW
		EndIf

		' Transfer TriangleBuffer from WorkRAM into VideoRAM
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, Self.IBuffer)
		glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER, Self.TriangleCount*12, Self.Triangles, ..
		                Flag)
		
		Return True
	End Method

	Method Scale(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Vertex : Int

		For Vertex = 0 To Self.VertexCount-1
			Self.Vertices[0][Vertex*3  ] :* X
			Self.Vertices[0][Vertex*3+1] :* Y
			Self.Vertices[0][Vertex*3+2] :* Z
		Next

		If Update Then Self.UpdateVertices(True, False, False, False, False, False)
	End Method
	
	Method Translate(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Vertex : Int

		For Vertex = 0 To Self.VertexCount-1
			Self.Vertices[0][Vertex*3  ] :+ X
			Self.Vertices[0][Vertex*3+1] :+ Y
			Self.Vertices[0][Vertex*3+2] :+ Z
		Next

		If Update Then Self.UpdateVertices(True, False, False, False, False, False)
	End Method
	
	Method GetWidth:Float()
		Local Vertex : Int, ..
		      X      : Float, ..
		      MinX   : Float, ..
		      MaxX   : Float

		If Self.VertexCount < 1 Then Return 0.0

		X = Self.Vertices[0][0]
		MinX = X
		MaxX = X

		' Find the lowest and highest X-Coordinate
		For Vertex = 1 Until Self.VertexCount
			X = Self.Vertices[0][Vertex*3]
			If X < MinX Then MinX = X
			If X > MaxX Then MaxX = X
		Next

		Return MaxX-MinX
	End Method

	Method GetHeight:Float()
		Local Vertex : Int, ..
		      Y      : Float, ..
		      MinY   : Float, ..
		      MaxY   : Float

		If Self.VertexCount < 1 Then Return 0.0

		Y = Self.Vertices[0][1]
		MinY = Y
		MaxY = Y

		' Find the lowest and highest Y-Coordinate
		For Vertex = 0 Until Self.VertexCount
			Y = Self.Vertices[0][Vertex*3+1]
			If Y < MinY Then MinY = Y
			If Y > MaxY Then MaxY = Y
		Next

		Return MaxY-MinY
	End Method

	Method GetDepth:Float()
		Local Vertex : Int, ..
		      Z      : Float, ..
		      MinZ   : Float, ..
		      MaxZ   : Float

		If Self.VertexCount < 1 Then Return 0.0

		Z = Self.Vertices[0][2]
		MinZ = Z
		MaxZ = Z

		' Find the lowest and highest Z-Coordinate
		For Vertex = 0 Until Self.VertexCount
			Z = Self.Vertices[0][Vertex*3+2]
			If Z < MinZ Then MinZ = Z
			If Z > MaxZ Then MaxZ = Z
		Next

		Return MaxZ-MinZ
	End Method

	Method Invert(Normals:Int=True, Update:Int=True)
		Local Index : Int, ..
		      V0    : Int, ..
		      V2    : Int

		For Index = 0 To Self.TriangleCount-1
			V0 = Self.Triangles[Index*3]
			V2 = Self.Triangles[Index*3+2] 
			
			Self.Triangles[Index*3]   = V2
			Self.Triangles[Index*3+2] = V0
		Next

		If Update Then Self.UpdateTriangles()

		If Normals Then
			For Index = 0 Until Self.VertexCount
				Self.Vertices[1][Index*3  ] :* -1.0
				Self.Vertices[1][Index*3+1] :* -1.0
				Self.Vertices[1][Index*3+2] :* -1.0
			Next

			If Update Then Self.UpdateVertices(False, True, False, False, False, False)
		EndIf
	End Method

	Method SmoothNormals(Update:Int=True)
		Local FaceNormals : Float[,], ..
		      Index       : Int, ..
		      Index2      : Float, ..
		      V           : Int, ..
		      Vertices    : Float[3, 3], ..
		      Edges       : Float[2, 3], ..
		      Length      : Float, ..
		      Normal      : Float[3], ..
		      Count       : Int

		FaceNormals = New Float[Self.TriangleCount, 3]
		
		' Calculate alle FaceNormals
		For Index = 0 Until Self.TriangleCount
			' Vertex 0
			V = Self.Triangles[Index*3]*3
			Vertices[0, 0] = Self.Vertices[0][V  ]
			Vertices[0, 1] = Self.Vertices[0][V+1]
			Vertices[0, 2] = Self.Vertices[0][V+2]

			' Vertex 0
			V = Self.Triangles[Index*3+1]*3
			Vertices[1, 0] = Self.Vertices[0][V  ]
			Vertices[1, 1] = Self.Vertices[0][V+1]
			Vertices[1, 2] = Self.Vertices[0][V+2]

			' Vertex 0
			V = Self.Triangles[Index*3+2]*3
			Vertices[2, 0] = Self.Vertices[0][V  ]
			Vertices[2, 1] = Self.Vertices[0][V+1]
			Vertices[2, 2] = Self.Vertices[0][V+2]
			
			' Get EdgeVectors between Vertex1-Vertex0 and Vertex2-Vertex0
			Edges[0, 0] = Vertices[0, 0]-Vertices[1, 0]
			Edges[0, 1] = Vertices[0, 1]-Vertices[1, 1]
			Edges[0, 2] = Vertices[0, 2]-Vertices[1, 2]
			
			Edges[1, 0] = Vertices[0, 0]-Vertices[2, 0]
			Edges[1, 1] = Vertices[0, 1]-Vertices[2, 1]
			Edges[1, 2] = Vertices[0, 2]-Vertices[2, 2]
			
			' Calculate the FaceNormal by using the CrossProduct
			FaceNormals[Index, 0] = Edges[0, 1]*Edges[1, 2] - Edges[0, 2]*Edges[1, 1]
			FaceNormals[Index, 1] = Edges[0, 2]*Edges[1, 0] - Edges[0, 0]*Edges[1, 2]
			FaceNormals[Index, 2] = Edges[0, 0]*Edges[1, 1] - Edges[0, 1]*Edges[1, 0]
			
			' Caluclate the Length of this Vector
			Length = -Sqr(FaceNormals[Index, 0]*FaceNormals[Index, 0] + ..
			              FaceNormals[Index, 1]*FaceNormals[Index, 1] + ..
			              FaceNormals[Index, 2]*FaceNormals[Index, 2])
			
			' Normalize this Vector
			If Length = 0.0 Then Length = 1.0
			FaceNormals[Index, 0] :/ Length
			FaceNormals[Index, 1] :/ Length
			FaceNormals[Index, 2] :/ Length
		Next

		' Interpolate all VertexNormals
		For Index = 0 Until Self.VertexCount
			Count = 0
			Normal[0] = 0.0
			Normal[1] = 0.0
			Normal[2] = 0.0

			For Index2 = 0 To Self.TriangleCount-1
				If (Self.Triangles[Index2*3  ] = Index) Or ..
				   (Self.Triangles[Index2*3+1] = Index) Or ..
				   (Self.Triangles[Index2*3+2] = Index) Then
					Normal[0] :+ FaceNormals[Index2, 0]
					Normal[1] :+ FaceNormals[Index2, 1]
					Normal[2] :+ FaceNormals[Index2, 2]
					Count :+ 1
				EndIf
			Next
			If Count > 0 Then
				Self.Vertices[1][Index*3  ] = Normal[0]/Float(Count)
				Self.Vertices[1][Index*3+1] = Normal[1]/Float(Count)
				Self.Vertices[1][Index*3+2] = Normal[2]/Float(Count)
			EndIf
		Next
		
		If Update Then Self.UpdateVertices(False, True, False, False, False, False)
	End Method

	Method SetColor(R:Float, G:Float, B:Float, A:Float=1.0, Update:Int=True)
		Local Index : Int

		For Index = 0 Until Self.VertexCount
			Self.Vertices[4][Index*4]   = R
			Self.Vertices[4][Index*4+1] = G
			Self.Vertices[4][Index*4+2] = B
			Self.Vertices[4][Index*4+3] = A
		Next

		If Update Then Self.UpdateVertices(False, False, False, False, True, False)
	End Method
End Type