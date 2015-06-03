SuperStrict

Import brl.linkedlist
Import brl.bank
Import "Error.bmx"
Import "HardwareInfo.bmx"
Import "Material.bmx"
Import "Camera.bmx"

Type TSurface
	Global List : TList

	Field Name           : String
	Field Material       : TMaterial
	Field Dynamic        : Int
	Field VertexCount    : Int
	Field Vertices       : TBank[6]
	Field VertexBuffer   : Int[6]
	Field TriangleCount  : Int
	Field Triangles      : TBank
	Field TriangleBuffer : Int
	
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

	Method SetDynamic(Enable:Int)
		If Enable Then
			Self.Dynamic = True
		Else
			Self.Dynamic = False
		EndIf
	End Method

	Method GetDynamic:Int()
		Return Self.Dynamic
	End Method

	Method CountVertices:Int()
		Return Self.VertexCount
	End Method

	Method CountTriangles:Int()
		Return Self.TriangleCount
	End Method

	Method CreateVertex:Int(X:Float, Y:Float, Z:Float, U:Float=0.0, V:Float=0.0)		
		' Resize Vertex-, Noramal-, UV0-, UV1- and ColorBuffer
		Self.Vertices[0].Resize((Self.VertexCount+1)*12)
		Self.Vertices[1].Resize((Self.VertexCount+1)*12)
		Self.Vertices[2].Resize((Self.VertexCount+1)*8)
		Self.Vertices[3].Resize((Self.VertexCount+1)*8)
		Self.Vertices[4].Resize((Self.VertexCount+1)*16)
		Self.Vertices[5].Resize((Self.VertexCount+1)*16)
		
		Self.VertexCount :+ 1
		
		' Set Vertex-Defaults
		Self.SetVertexPosition(Self.VertexCount-1,  X, Y, Z)
		Self.SetVertexNormal(Self.VertexCount-1, 0.0, 0.0, 0.0)
		Self.SetVertexTexCoords(Self.VertexCount-1, U, V)
		Self.SetVertexTexCoords(Self.VertexCount-1, U, V, 1)
		Self.SetVertexColor(Self.VertexCount-1, 1.0, 1.0, 1.0, 1.0)
		Self.SetVertexAttributes(Self.VertexCount-1, 0.0, 0.0, 0.0, 0.0)
		
		Return Self.VertexCount-1
	End Method

	Method SetVertexPosition(Vertex:Int, X:Float, Y:Float, Z:Float)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Self.Vertices[0].PokeFloat(Vertex*12,   X)
			Self.Vertices[0].PokeFloat(Vertex*12+4, Y)
			Self.Vertices[0].PokeFloat(Vertex*12+8, Z)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexPosition(Vertex:Int, X:Float Var, Y:Float Var, Z:Float Var)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			X = Self.Vertices[0].PeekFloat(Vertex*12)
			Y = Self.Vertices[0].PeekFloat(Vertex*12+4)
			Z = Self.Vertices[0].PeekFloat(Vertex*12+8)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexX:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[0].PeekFloat(Vertex*12)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexY:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[0].PeekFloat(Vertex*12+4)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexZ:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[0].PeekFloat(Vertex*12+8)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method SetVertexNormal(Vertex:Int, X:Float, Y:Float, Z:Float)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Self.Vertices[1].PokeFloat(Vertex*12,   X)
			Self.Vertices[1].PokeFloat(Vertex*12+4, Y)
			Self.Vertices[1].PokeFloat(Vertex*12+8, Z)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexNormal(Vertex:Int, X:Float Var, Y:Float Var, Z:Float Var)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			X = Self.Vertices[1].PeekFloat(Vertex*12)
			Y = Self.Vertices[1].PeekFloat(Vertex*12+4)
			Z = Self.Vertices[1].PeekFloat(Vertex*12+8)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexNX:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[1].PeekFloat(Vertex*12)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexNY:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[1].PeekFloat(Vertex*12+4)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexNZ:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[1].PeekFloat(Vertex*12+8)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method SetVertexTexCoords(Vertex:Int, U:Float, V:Float, UVSet:Int=0)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			If UVSet = 0 Then
				Self.Vertices[2].PokeFloat(Vertex*8,   U)
				Self.Vertices[2].PokeFloat(Vertex*8+4, V)
			ElseIf UVSet = 1
				Self.Vertices[3].PokeFloat(Vertex*8,   U)
				Self.Vertices[3].PokeFloat(Vertex*8+4, V)
			Else
				Notify("UV-Set not avariable!", True)
			EndIf
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexTexCoords(Vertex:Int, U:Float Var, V:Float Var, UVSet:Int=0)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			If UVSet = 0 Then
				U = Self.Vertices[2].PeekFloat(Vertex*8)
				V = Self.Vertices[2].PeekFloat(Vertex*8+4)
			ElseIf UVSet = 1
				U = Self.Vertices[3].PeekFloat(Vertex*8)
				V = Self.Vertices[3].PeekFloat(Vertex*8+4)
			Else
				TDreiDeError.DisplayError("UV-Set is not avariable!")
			EndIf
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexU:Float(Vertex:Int, UVSet:Int=0)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			If UVSet = 0 Then
				Return Self.Vertices[2].PeekFloat(Vertex*8)
			ElseIf UVSet = 1
				Return Self.Vertices[3].PeekFloat(Vertex*8)
			Else
				TDreiDeError.DisplayError("UV-Set is not avariable!")
			EndIf
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexV:Float(Vertex:Int, UVSet:Int=0)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			If UVSet = 0 Then
				Return Self.Vertices[2].PeekFloat(Vertex*8+4)
			ElseIf UVSet = 1
				Return Self.Vertices[3].PeekFloat(Vertex*8+4)
			Else
				TDreiDeError.DisplayError("UV-Set is not avariable!")
			EndIf
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method SetVertexColor(Vertex:Int, Red:Float, Green:Float, Blue:Float, Alpha:Float=1.0)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Self.Vertices[4].PokeFloat(Vertex*16,    Red)
			Self.Vertices[4].PokeFloat(Vertex*16+4,  Green)
			Self.Vertices[4].PokeFloat(Vertex*16+8,  Blue)
			Self.Vertices[4].PokeFloat(Vertex*16+12, Alpha)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexColor(Vertex:Int, Red:Float Var, Green:Float Var, Blue:Float Var, Alpha:Float Var)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Red   = Self.Vertices[4].PeekFloat(Vertex*16)
			Green = Self.Vertices[4].PeekFloat(Vertex*16+4)
			Blue  = Self.Vertices[4].PeekFloat(Vertex*16+8)
			Alpha = Self.Vertices[4].PeekFloat(Vertex*16+12)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexRed:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[4].PeekFloat(Vertex*16)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexGreen:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[4].PeekFloat(Vertex*16+4)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexBlue:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[4].PeekFloat(Vertex*16+8)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method GetVertexAlpha:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[4].PeekFloat(Vertex*16+12)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method
	
	Method SetVertexAttributes(Vertex:Int, X:Float, Y:Float, Z:Float, W:Float)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Self.Vertices[5].PokeFloat(Vertex*16,    X)
			Self.Vertices[5].PokeFloat(Vertex*16+4,  Y)
			Self.Vertices[5].PokeFloat(Vertex*16+8,  Z)
			Self.Vertices[5].PokeFloat(Vertex*16+12, W)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method
	
	Method GetVertexAttributes(Vertex:Int, X:Float Var, Y:Float Var, Z:Float Var, W:Float Var)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			X = Self.Vertices[5].PeekFloat(Vertex*16)
			Y = Self.Vertices[5].PeekFloat(Vertex*16+4)
			Z = Self.Vertices[5].PeekFloat(Vertex*16+8)
			W = Self.Vertices[5].PeekFloat(Vertex*16+12)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method
	
	Method GetVertexAttributeX:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[5].PeekFloat(Vertex*16)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method
	
	Method GetVertexAttributeY:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[5].PeekFloat(Vertex*16+4)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method
	
	Method GetVertexAttributeZ:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[5].PeekFloat(Vertex*16+8)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method
	
	Method GetVertexAttributeW:Float(Vertex:Int)
		If (Vertex => 0) And (Vertex < Self.VertexCount) Then
			Return Self.Vertices[5].PeekFloat(Vertex*16+12)
		Else
			TDreiDeError.DisplayError("Vertex does not exist!")
		EndIf
	End Method

	Method UpdateVertices(Position:Int=True, Normal:Int=True, UV0:Int=True, UV1:Int=True, ..
	       Color:Int=True, Attributes:Int=True)
		Local Flag:Int

		' Check, if there VertexBufferObject-Support
		If Not THardwareInfo.VBOSupport Then Return

		If Self.Dynamic Then
			Flag = GL_DYNAMIC_DRAW
		Else
			Flag = GL_STATIC_DRAW
		EndIf

		' Transfer Buffer(s) from WorkRAM into VideoRAM
		If Position Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[0])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*12, Self.Vertices[0].Buf(), Flag)
		EndIf

		If Normal Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[1])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*12, Self.Vertices[1].Buf(), Flag)
		EndIf

		If UV0 Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[2])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*8, Self.Vertices[2].Buf(), Flag)
		EndIf

		If UV1 Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[3])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*8, Self.Vertices[3].Buf(), Flag)
		EndIf

		If Color Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[4])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*16, Self.Vertices[4].Buf(), Flag)
		EndIf

		If Attributes Then
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[5])
			glBufferDataARB(GL_ARRAY_BUFFER, Self.VertexCount*16, Self.Vertices[5].Buf(), Flag)
		EndIf
	End Method

	Method CreateTriangle:Int(V0:Int, V1:Int, V2:Int)
		' Check, if vertices exists
		If (V0 < 0) Or (V0 => Self.VertexCount) Then ..
		   TDreiDeError.DisplayError("Vertex V0 does not exist!")

		If (V1 < 0) Or (V1 => Self.VertexCount) Then ..
		   TDreiDeError.DisplayError("Vertex V1 does not exist!")

		If (V2 < 0) Or (V2 => Self.VertexCount) Then ..
		   TDreiDeError.DisplayError("Vertex V2 does not exist!")

		' Resize TriangleBuffer
		Self.TriangleCount :+ 1
		Self.Triangles.Resize(Self.TriangleCount*12)

		' Set Vertex-Indices
		Self.SetTriangle(Self.TriangleCount-1, V0, V1, V2)

		Return Self.TriangleCount-1
	End Method

	Method SetTriangle(Triangle:Int, V0:Int, V1:Int, V2:Int)
		If (Triangle < 0) Or (Triangle => Self.TriangleCount) Then ..
			TDreiDeError.DisplayError("Triangle does not exist!")
	
		If (V0 < 0) Or (V0 => Self.VertexCount) Then ..
		   TDreiDeError.DisplayError("Vertex V0 does not exist!")

		If (V1 < 0) Or (V1 => Self.VertexCount) Then ..
		   TDreiDeError.DisplayError("Vertex V1 does not exist!")

		If (V2 < 0) Or (V2 => Self.VertexCount) Then ..
		   TDreiDeError.DisplayError("Vertex V2 does not exist!")

		Self.Triangles.PokeInt(Triangle*12,   V0)
		Self.Triangles.PokeInt(Triangle*12+4, V1)
		Self.Triangles.PokeInt(Triangle*12+8, V2)
	End Method
	
	Method GetTriangle(Triangle:Int, V0:Int Var, V1:Int Var, V2:Int Var)
		If (Triangle < 0) Or (Triangle => Self.TriangleCount) Then ..
			TDreiDeError.DisplayError("Triangle does not exist!")
			
		V0 = Self.Triangles.PeekInt(Triangle*12)
		V1 = Self.Triangles.PeekInt(Triangle*12+4)
		V2 = Self.Triangles.PeekInt(Triangle*12+8)
	End Method

	Method GetTriangleVertex:Int(Triangle:Int, Vertex:Int)
		If (Triangle < 0) Or (Triangle => Self.TriangleCount) Then ..
			TDreiDeError.DisplayError("Triangle does not exist!")

		If (Vertex < 0) Or (Vertex > 2) Then ..
			TDreiDeError.DisplayError("Vertex does not exist!")

		Return Self.Triangles.PeekInt(Triangle*12+(Vertex*4))
	End Method

	Method UpdateTriangles()
		Local Flag:Int

		' Check, if there VertexBufferObject-Support
		If Not THardwareInfo.VBOSupport Then Return

		If Self.Dynamic Then
			Flag = GL_DYNAMIC_DRAW
		Else
			Flag = GL_STATIC_DRAW
		EndIf

		' Transfer TriangleBuffer from WorkRAM into VideoRAM
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, Self.TriangleBuffer)
		glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER, Self.TriangleCount*12, Self.Triangles.Buf(), ..
		                Flag)
	End Method

	Method Scale(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Vertex:Int, VX:Float, VY:Float, VZ:Float

		For Vertex = 0 To Self.VertexCount-1
			Self.Vertices[0].PokeFloat(Vertex*12, Self.Vertices[0].PeekFloat(Vertex*12)*X)
			Self.Vertices[0].PokeFloat(Vertex*12+4, Self.Vertices[0].PeekFloat(Vertex*12+4)*Y)
			Self.Vertices[0].PokeFloat(Vertex*12+8, Self.Vertices[0].PeekFloat(Vertex*12+8)*Z)
		Next

		If Update Then Self.UpdateVertices(True, False, False, False, False, False)
	End Method

	Method Translate(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Vertex:Int, VX:Float, VY:Float, VZ:Float

		For Vertex = 0 To Self.VertexCount-1
			Self.Vertices[0].PokeFloat(Vertex*12, Self.Vertices[0].PeekFloat(Vertex*12)+X)
			Self.Vertices[0].PokeFloat(Vertex*12+4, Self.Vertices[0].PeekFloat(Vertex*12+4)+Y)
			Self.Vertices[0].PokeFloat(Vertex*12+8, Self.Vertices[0].PeekFloat(Vertex*12+8)+Z)
		Next

		If Update Then Self.UpdateVertices(True, False, False, False, False, False)
	End Method

	Method GetWidth:Float()
		Local Vertex:Int, X:Float, MinX:Float, MaxX:Float

		' Find the lowest and highest X-Coordinate
		For Vertex = 0 To Self.VertexCount-1
			X = Self.Vertices[0].PeekFloat(Vertex*12)
			If X < MinX Then MinX = X
			If X > MaxX Then MaxX = X
		Next

		Return MaxX-MinX
	End Method

	Method GetHeight:Float()
		Local Vertex:Int, Y:Float, MinY:Float, MaxY:Float

		' Find the lowest and highest Y-Coordinate
		For Vertex = 0 To Self.VertexCount-1
			Y = Self.Vertices[0].PeekFloat(Vertex*12+4)
			If Y < MinY Then MinY = Y
			If Y > MaxY Then MaxY = Y
		Next

		Return MaxY-MinY
	End Method

	Method GetDepth:Float()
		Local Vertex:Int, Z:Float, MinZ:Float, MaxZ:Float

		' Find the lowest and highest Z-Coordinate
		For Vertex = 0 To Self.VertexCount-1
			Z = Self.Vertices[0].PeekFloat(Vertex*12+8)
			If Z < MinZ Then MinZ = Z
			If Z > MaxZ Then MaxZ = Z
		Next

		Return MaxZ-MinZ
	End Method

	Method Invert(Normals:Int=True, Update:Int=True)
		Local Index:Int, V0:Int, V2:Int

		For Index = 0 To Self.TriangleCount-1
			V0 = Self.Triangles.PeekInt(Index*12)
			V2 = Self.Triangles.PeekInt(Index*12+8) 
			
			Self.Triangles.PokeInt(Index*12, V2)
			Self.Triangles.PokeInt(Index*12+8, V0)
		Next

		If Update Then Self.UpdateTriangles()

		If Normals Then
			For Index = 0 To Self.VertexCount-1
				Self.Vertices[1].PokeFloat(Index*12,   -Self.Vertices[1].PeekFloat(Index*12))
				Self.Vertices[1].PokeFloat(Index*12+4, -Self.Vertices[1].PeekFloat(Index*12+4))
				Self.Vertices[1].PokeFloat(Index*12+8, -Self.Vertices[1].PeekFloat(Index*12+8))
			Next

			If Update Then Self.UpdateVertices(False, True, False, False, False, False)
		EndIf
	End Method
	
	Method SmoothNormals(Update:Int=True)
		Local FaceNormals:Float[,], Index:Int, Index2:Float, Indices:Int[,]
		Local Vertices:Float[3, 3], Edges:Float[2, 3], Length:Float
		Local Normal:Float[3], Count:Int

		FaceNormals = New Float[Self.TriangleCount, 3]
		Indices = New Int[Self.TriangleCount, 3]
		
		' Calculate alle FaceNormals
		For Index = 0 To Self.TriangleCount-1
			' Get VertexIndices
			Indices[Index, 0] = Self.Triangles.PeekInt(Index*12)
			Indices[Index, 1] = Self.Triangles.PeekInt(Index*12+4)
			Indices[Index, 2] = Self.Triangles.PeekInt(Index*12+8)

			' Get VertexPositions
			Vertices[0, 0] = Self.Vertices[0].PeekFloat(Indices[Index, 0]*12)
			Vertices[0, 1] = Self.Vertices[0].PeekFloat(Indices[Index, 0]*12+4)
			Vertices[0, 2] = Self.Vertices[0].PeekFloat(Indices[Index, 0]*12+8)

			Vertices[1, 0] = Self.Vertices[0].PeekFloat(Indices[Index, 1]*12)
			Vertices[1, 1] = Self.Vertices[0].PeekFloat(Indices[Index, 1]*12+4)
			Vertices[1, 2] = Self.Vertices[0].PeekFloat(Indices[Index, 1]*12+8)

			Vertices[2, 0] = Self.Vertices[0].PeekFloat(Indices[Index, 2]*12)
			Vertices[2, 1] = Self.Vertices[0].PeekFloat(Indices[Index, 2]*12+4)
			Vertices[2, 2] = Self.Vertices[0].PeekFloat(Indices[Index, 2]*12+8)
			
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
			FaceNormals[Index, 0] :/ Length
			FaceNormals[Index, 1] :/ Length
			FaceNormals[Index, 2] :/ Length
		Next

		' Interpolate all VertexNormals
		For Index = 0 To Self.VertexCount-1
			Count = 0
			Normal[0] = 0.0
			Normal[1] = 0.0
			Normal[2] = 0.0

			For Index2 = 0 To Self.TriangleCount-1
				If (Indices[Index2, 0] = Index) Or ..
				   (Indices[Index2, 1] = Index) Or ..
				   (Indices[Index2, 2] = Index) Then
					Normal[0] :+ FaceNormals[Index2, 0]
					Normal[1] :+ FaceNormals[Index2, 1]
					Normal[2] :+ FaceNormals[Index2, 2]
					Count :+ 1
				EndIf
			Next
			If Count > 0 Then
				Normal[0] :/ Count
				Normal[1] :/ Count
				Normal[2] :/ Count
				Self.SetVertexNormal(Index, Normal[0], Normal[1], Normal[2])
			EndIf
		Next
		
		If Update Then Self.UpdateVertices(False, True, False, False, False, False)
	End Method

	Method SetColor(Red:Float, Green:Float, Blue:Float, Alpha:Float=1.0, Update:Int=True)
		Local Index:Int

		For Index = 0 To Self.VertexCount-1
			Self.Vertices[4].PokeFloat(Index*16,    Red)
			Self.Vertices[4].PokeFloat(Index*16+4,  Green)
			Self.Vertices[4].PokeFloat(Index*16+8,  Blue)
			Self.Vertices[4].PokeFloat(Index*16+12, Alpha)
		Next

		If Update Then Self.UpdateVertices(False, False, False, False, True, False)
	End Method

	Method Render(Entity:TEntity)
		' Check for Material
		If Self.Material Then
			Local Layer:Int
			Local UVSet:Int

			' Set Material specific OpenGL-Settings
			Self.Material.Render()

			' Go through all layers
			For Layer = 0 Until THardwareInfo.MaxTextures
				glClientActiveTexture(GL_TEXTURE0+Layer)
				glActiveTexture(GL_TEXTURE0+Layer)

				If Self.Material.TextureList[Layer] Then
					UVSet = 2 + Self.Material.TextureList[Layer].GetCoordSet()

					glEnableClientState(GL_TEXTURE_COORD_ARRAY)
					If THardwareInfo.VBOSupport Then
						' Bind Texture-Coordinates 0
						glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[UVSet])
						glTexCoordPointer(2, GL_FLOAT, 0, Null)
					Else
						glTexCoordPointer(2, GL_FLOAT, 0, Self.Vertices[UVSet].Buf())
					EndIf
					Self.Material.TextureList[Layer].Render(Entity)
				Else
					glDisable(GL_TEXTURE_2D)
					glDisable(GL_TEXTURE_CUBE_MAP)
				EndIf
			Next

			' Use Vertex- or FragmentProgram?
			If Material.VertexProgram Or Material.FragmentProgram Then
				If THardwareInfo.VBOSupport Then
					glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[5])
					glVertexAttribPointerARB(0, 4, GL_FLOAT, False, 0, Null)
				Else
					glVertexAttribPointerARB(0, 4, GL_FLOAT, False, 0, Self.Vertices[5].Buf())
				EndIf
			EndIf
		Else
			' No Material -> Set defaults
			TMaterial.RenderDefault()
		EndIf

		' Check for VertexBufferObject-Support
		If THardwareInfo.VBOSupport Then
			' Render all Buffers of the VideoRAM

			' Bind Vertex-Color
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[4])
			glColorPointer(4, GL_FLOAT, 0, Null)

			' Bind Normals
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[1])
			glNormalPointer(GL_FLOAT, 0, Null)

			' Bind Vertices
			glBindBufferARB(GL_ARRAY_BUFFER, Self.VertexBuffer[0])
			glVertexPointer(3, GL_FLOAT, 0, Null)

			' Bind TriangleBuffer
			glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, Self.TriangleBuffer)

			' Display Triangles
			glDrawElements(GL_TRIANGLES, Self.TriangleCount*3, GL_UNSIGNED_INT, Null)
		Else
			' Render all Buffers of the WorkRAM
			glColorPointer(4, GL_FLOAT, 0, Self.Vertices[4].Buf())
			glNormalPointer(GL_FLOAT, 0, Self.Vertices[1].Buf())
			glVertexPointer(3, GL_FLOAT, 0, Self.Vertices[0].Buf())
			glDrawElements(GL_TRIANGLES, Self.TriangleCount*3, GL_UNSIGNED_INT, ..
			               Self.Triangles.Buf())
		EndIf
	End Method

	Method New()
		Local Index:Int

		Self.Name          = "Unnamed Surface"
		Self.Material      = Null
		Self.Dynamic       = False
		Self.VertexCount   = 0
		' Create Vertex- and TriangleBuffer(s)
		For Index = 0 To 5
			Self.Vertices[Index] = CreateBank()
		Next
		Self.Triangles = CreateBank()
		If THardwareInfo.VBOSupport Then
			' Generate HardwareBuffers for Vertices and Traingles
			glGenBuffersARB(6, Self.VertexBuffer)
			glGenBuffersARB(1, Varptr(Self.TriangleBuffer))
		EndIf
		Self.TriangleCount = 0

		TSurface.List.AddLast(Self)
	End Method

	Method Delete()
		If THardwareInfo.VBOSupport Then
			' Delete HardwareBuffers for Vertices and Traingles
			glDeleteBuffers(5, Self.VertexBuffer)
			glDeleteBuffers(1, Varptr(Self.TriangleBuffer))
		EndIf
	End Method

	Method Remove()
		TSurface.List.Remove(Self)
	End Method
End Type