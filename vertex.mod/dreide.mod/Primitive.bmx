Strict

Import "Mesh.bmx"

Type TPrimitive
	Function CreateQuad:TMesh()
		Local Mesh:TMesh, Surface:TSurface

		Mesh = New TMesh
		Surface = Mesh.CreateSurface()

		Surface.CreateVertex(-0.5,  0.5, 0.0, 0.0, 0.0) ' Left  Top
		Surface.CreateVertex( 0.5,  0.5, 0.0, 1.0, 0.0) ' Right Top
		Surface.CreateVertex( 0.5, -0.5, 0.0, 1.0, 1.0) ' Right Bottom
		Surface.CreateVertex(-0.5, -0.5, 0.0, 0.0, 1.0) ' Left  Bottom

		Surface.SetVertexNormal(0, 0.0, 0.0, 1.0)
		Surface.SetVertexNormal(1, 0.0, 0.0, 1.0)
		Surface.SetVertexNormal(2, 0.0, 0.0, 1.0)
		Surface.SetVertexNormal(3, 0.0, 0.0, 1.0)

		Surface.CreateTriangle(0, 1, 2)
		Surface.CreateTriangle(0, 2, 3)

		Surface.UpdateVertices()
		Surface.UpdateTriangles()

		Return Mesh
	End Function

	Function CreateDisc:TMesh(Segments:Int=36)
		Local Mesh:TMesh, Surface:TSurface, Index:Int, Angle:Float

		If Segments < 3 Then Return Null

		Mesh = New TMesh
		Surface = Mesh.CreateSurface()

		For Index = 0 To Segments
			Angle = (360.0/Float(Segments))*Float(Index)
			Surface.CreateVertex(Cos(Angle)*0.5, 0.0, Sin(Angle)*0.5, ..
			                     Cos(Angle)*0.5+0.5, Sin(Angle)*0.5+0.5)
			Surface.SetVertexNormal(Index, 0.0, 1.0, 0.0)
		Next

		For Index = 1 To Segments-1
			Surface.CreateTriangle(Index, Index+1, 0)
		Next

		Surface.UpdateVertices()
		Surface.UpdateTriangles()

		Return Mesh
	End Function

	Function CreateCube:TMesh(SubFaces:Int=False)
		Local Mesh:TMesh, Surface:TSurface

		Mesh = New TMesh
		If SubFaces Then
			' Front Face
			Surface = Mesh.CreateSurface()
			Surface.SetName("front")

			Surface.CreateVertex(-0.5,  0.5, 0.5, 0.0, 0.0)
			Surface.CreateVertex( 0.5,  0.5, 0.5, 1.0, 0.0)
			Surface.CreateVertex( 0.5, -0.5, 0.5, 1.0, 1.0)
			Surface.CreateVertex(-0.5, -0.5, 0.5, 0.0, 1.0)

			Surface.SetVertexNormal(0, 0.0, 0.0, 1.0)
			Surface.SetVertexNormal(1, 0.0, 0.0, 1.0)
			Surface.SetVertexNormal(2, 0.0, 0.0, 1.0)
			Surface.SetVertexNormal(3, 0.0, 0.0, 1.0)

			Surface.CreateTriangle(0, 1, 2)
			Surface.CreateTriangle(2, 3, 0)

			Surface.UpdateVertices()
			Surface.UpdateTriangles()

			' Back Face
			Surface = Mesh.CreateSurface()
			Surface.SetName("back")

			Surface.CreateVertex( 0.5,  0.5, -0.5, 0.0, 0.0)
			Surface.CreateVertex(-0.5,  0.5, -0.5, 1.0, 0.0)
			Surface.CreateVertex(-0.5, -0.5, -0.5, 1.0, 1.0)
			Surface.CreateVertex( 0.5, -0.5, -0.5, 0.0, 1.0)

			Surface.SetVertexNormal(0, 0.0, 0.0, -1.0)
			Surface.SetVertexNormal(1, 0.0, 0.0, -1.0)
			Surface.SetVertexNormal(2, 0.0, 0.0, -1.0)
			Surface.SetVertexNormal(3, 0.0, 0.0, -1.0)

			Surface.CreateTriangle(0, 1, 2)
			Surface.CreateTriangle(2, 3, 0)

			Surface.UpdateVertices()
			Surface.UpdateTriangles()

			' Right Face
			Surface = Mesh.CreateSurface()
			Surface.SetName("right")

			Surface.CreateVertex(0.5,  0.5,  0.5, 0.0, 0.0)
			Surface.CreateVertex(0.5,  0.5, -0.5, 1.0, 0.0)
			Surface.CreateVertex(0.5, -0.5, -0.5, 1.0, 1.0)
			Surface.CreateVertex(0.5, -0.5,  0.5, 0.0, 1.0)

			Surface.SetVertexNormal(0, 1.0, 0.0, 0.0)
			Surface.SetVertexNormal(1, 1.0, 0.0, 0.0)
			Surface.SetVertexNormal(2, 1.0, 0.0, 0.0)
			Surface.SetVertexNormal(3, 1.0, 0.0, 0.0)

			Surface.CreateTriangle(0, 1, 2)
			Surface.CreateTriangle(2, 3, 0)

			Surface.UpdateVertices()
			Surface.UpdateTriangles()

			' Left Face
			Surface = Mesh.CreateSurface()
			Surface.SetName("left")

			Surface.CreateVertex(-0.5,  0.5, -0.5, 0.0, 0.0)
			Surface.CreateVertex(-0.5,  0.5,  0.5, 1.0, 0.0)
			Surface.CreateVertex(-0.5, -0.5,  0.5, 1.0, 1.0)
			Surface.CreateVertex(-0.5, -0.5, -0.5, 0.0, 1.0)

			Surface.SetVertexNormal(0, -1.0, 0.0, 0.0)
			Surface.SetVertexNormal(1, -1.0, 0.0, 0.0)
			Surface.SetVertexNormal(2, -1.0, 0.0, 0.0)
			Surface.SetVertexNormal(3, -1.0, 0.0, 0.0)

			Surface.CreateTriangle(0, 1, 2)
			Surface.CreateTriangle(2, 3, 0)

			Surface.UpdateVertices()
			Surface.UpdateTriangles()

			' Top Face
			Surface = Mesh.CreateSurface()
			Surface.SetName("top")

			Surface.CreateVertex(-0.5, 0.5, -0.5, 0.0, 0.0)
			Surface.CreateVertex( 0.5, 0.5, -0.5, 1.0, 0.0)
			Surface.CreateVertex( 0.5, 0.5,  0.5, 1.0, 1.0)
			Surface.CreateVertex(-0.5, 0.5,  0.5, 0.0, 1.0)

			Surface.SetVertexNormal(0, 0.0, 1.0, 0.0)
			Surface.SetVertexNormal(1, 0.0, 1.0, 0.0)
			Surface.SetVertexNormal(2, 0.0, 1.0, 0.0)
			Surface.SetVertexNormal(3, 0.0, 1.0, 0.0)

			Surface.CreateTriangle(0, 1, 2)
			Surface.CreateTriangle(2, 3, 0)

			Surface.UpdateVertices()
			Surface.UpdateTriangles()

			' Bottom Face
			Surface = Mesh.CreateSurface()
			Surface.SetName("bottom")

			Surface.CreateVertex(-0.5, -0.5,  0.5, 0.0, 0.0)
			Surface.CreateVertex( 0.5, -0.5,  0.5, 1.0, 0.0)
			Surface.CreateVertex( 0.5, -0.5, -0.5, 1.0, 1.0)
			Surface.CreateVertex(-0.5, -0.5, -0.5, 0.0, 1.0)

			Surface.SetVertexNormal(0, 0.0, -1.0, 0.0)
			Surface.SetVertexNormal(1, 0.0, -1.0, 0.0)
			Surface.SetVertexNormal(2, 0.0, -1.0, 0.0)
			Surface.SetVertexNormal(3, 0.0, -1.0, 0.0)

			Surface.CreateTriangle(0, 1, 2)
			Surface.CreateTriangle(2, 3, 0)

			Surface.UpdateVertices()
			Surface.UpdateTriangles()
		Else
			Surface = Mesh.CreateSurface()

			' Vertices

			' Front Face
			Surface.CreateVertex(-0.5,  0.5,  0.5, 0.0, 0.0) '  0
			Surface.CreateVertex( 0.5,  0.5,  0.5, 1.0, 0.0) '  1
			Surface.CreateVertex( 0.5, -0.5,  0.5, 1.0, 1.0) '  2
			Surface.CreateVertex(-0.5, -0.5,  0.5, 0.0, 1.0) '  3
			
			Surface.SetVertexNormal( 0,  0.0,  0.0,  1.0)
			Surface.SetVertexNormal( 1,  0.0,  0.0,  1.0)
			Surface.SetVertexNormal( 2,  0.0,  0.0,  1.0)
			Surface.SetVertexNormal( 3,  0.0,  0.0,  1.0)

			'  Back Face
			Surface.CreateVertex( 0.5,  0.5, -0.5, 0.0, 0.0) '  4
			Surface.CreateVertex(-0.5,  0.5, -0.5, 1.0, 0.0) '  5
			Surface.CreateVertex(-0.5, -0.5, -0.5, 1.0, 1.0) '  6
			Surface.CreateVertex( 0.5, -0.5, -0.5, 0.0, 1.0) '  7

			Surface.SetVertexNormal( 4,  0.0,  0.0, -1.0)
			Surface.SetVertexNormal( 5,  0.0,  0.0, -1.0)
			Surface.SetVertexNormal( 6,  0.0,  0.0, -1.0)
			Surface.SetVertexNormal( 7,  0.0,  0.0, -1.0)

			' Right Face
			Surface.CreateVertex( 0.5,  0.5,  0.5, 0.0, 0.0) '  8
			Surface.CreateVertex( 0.5,  0.5, -0.5, 1.0, 0.0) '  9
			Surface.CreateVertex( 0.5, -0.5, -0.5, 1.0, 1.0) ' 10
			Surface.CreateVertex( 0.5, -0.5,  0.5, 0.0, 1.0) ' 11

			Surface.SetVertexNormal( 8,  1.0,  0.0,  0.0)
			Surface.SetVertexNormal( 9,  1.0,  0.0,  0.0)
			Surface.SetVertexNormal(10,  1.0,  0.0,  0.0)
			Surface.SetVertexNormal(11,  1.0,  0.0,  0.0)

			' Left Face
			Surface.CreateVertex(-0.5,  0.5, -0.5, 0.0, 0.0) ' 12
			Surface.CreateVertex(-0.5,  0.5,  0.5, 1.0, 0.0) ' 13
			Surface.CreateVertex(-0.5, -0.5,  0.5, 1.0, 1.0) ' 14
			Surface.CreateVertex(-0.5, -0.5, -0.5, 0.0, 1.0) ' 15

			Surface.SetVertexNormal(12, -1.0,  0.0,  0.0)
			Surface.SetVertexNormal(13, -1.0,  0.0,  0.0)
			Surface.SetVertexNormal(14, -1.0,  0.0,  0.0)
			Surface.SetVertexNormal(15, -1.0,  0.0,  0.0)

			' Top Face
			Surface.CreateVertex(-0.5,  0.5, -0.5, 0.0, 0.0) ' 16
			Surface.CreateVertex( 0.5,  0.5, -0.5, 1.0, 0.0) ' 17
			Surface.CreateVertex( 0.5,  0.5,  0.5, 1.0, 1.0) ' 18
			Surface.CreateVertex(-0.5,  0.5,  0.5, 0.0, 1.0) ' 19

			Surface.SetVertexNormal(16,  0.0,  1.0,  0.0)
			Surface.SetVertexNormal(17,  0.0,  1.0,  0.0)
			Surface.SetVertexNormal(18,  0.0,  1.0,  0.0)
			Surface.SetVertexNormal(19,  0.0,  1.0,  0.0)

			' Bottom Face
			Surface.CreateVertex(-0.5, -0.5,  0.5, 0.0, 0.0) ' 20
			Surface.CreateVertex( 0.5, -0.5,  0.5, 1.0, 0.0) ' 21
			Surface.CreateVertex( 0.5, -0.5, -0.5, 1.0, 1.0) ' 22
			Surface.CreateVertex(-0.5, -0.5, -0.5, 0.0, 1.0) ' 23

			Surface.SetVertexNormal(20,  0.0, -1.0,  0.0)
			Surface.SetVertexNormal(21,  0.0, -1.0,  0.0)
			Surface.SetVertexNormal(22,  0.0, -1.0,  0.0)
			Surface.SetVertexNormal(23,  0.0, -1.0,  0.0)

			' Triangles

			' Front Face
			Surface.CreateTriangle( 0,  1,  2)
			Surface.CreateTriangle( 2,  3,  0)

			' Back Face
			Surface.CreateTriangle( 4,  5,  6)
			Surface.CreateTriangle( 6,  7,  4)

			' Right Face
			Surface.CreateTriangle( 8,  9, 10)
			Surface.CreateTriangle(10, 11,  8)

			' Left Face
			Surface.CreateTriangle(12, 13, 14)
			Surface.CreateTriangle(14, 15, 12)

			' Top Face
			Surface.CreateTriangle(16, 17, 18)
			Surface.CreateTriangle(18, 19, 16)

			' Bottom Face
			Surface.CreateTriangle(20, 21, 22)
			Surface.CreateTriangle(22, 23, 20)

			' Update Vertices and Triangles
			Surface.UpdateVertices()
			Surface.UpdateTriangles()
		EndIf

		Return Mesh
	End Function

	Function CreateCone:TMesh(Segments:Int=32, Cap:Int=True)
		Local Mesh:TMesh, Surface:TSurface, Index:Int, Angle:Float

		If Segments < 3 Then Return Null

		Mesh = New TMesh

		Surface = Mesh.CreateSurface()
		Surface.SetName("body")

		' Body
		For Index = 0 To Segments
			Angle = (360.0/Float(Segments))*Float(Index)
			Surface.CreateVertex(0.0, 0.5, 0.0, ..
			                     1.0-Float(Index)/Float(Segments), 0.0)
			Surface.SetVertexNormal(Index*2, Cos(Angle), 0.0, Sin(Angle))

			Surface.CreateVertex(Cos(Angle)*0.5, -0.5, Sin(Angle)*0.5, ..
			                     1.0-Float(Index)/Float(Segments), 1.0)
			Surface.SetVertexNormal(Index*2+1, Cos(Angle), 0.0, Sin(Angle))
		Next

		For Index = 0 To Segments-1
			Surface.CreateTriangle((Index+1)*2+1, (Index+1)*2, Index*2)
			Surface.CreateTriangle(Index*2, Index*2+1, (Index+1)*2+1)
		Next

		Surface.UpdateVertices()
		Surface.UpdateTriangles()

		' Bottom Cap
		Surface = Mesh.CreateSurface()
		Surface.SetName("bottom")

		For Index = 0 To Segments
			Angle = (360.0/Float(Segments))*Float(Index)
			Surface.CreateVertex(Cos(Angle)*0.5, -0.5, Sin(Angle)*0.5, ..
			                     Cos(Angle)*0.5+0.5, Sin(Angle)*0.5+0.5)
			Surface.SetVertexNormal(Index, 0.0, -1.0, 0.0)
		Next

		For Index = 1 To Segments-1
			Surface.CreateTriangle(0, Index+1, Index)
		Next

		Surface.UpdateVertices()
		Surface.UpdateTriangles()

		Return Mesh
	End Function

	Function CreateCylinder:TMesh(Segments:Int=36, Caps:Int=True)
		Local Mesh:TMesh, Surface:TSurface, Index:Int, Angle:Float

		If Segments < 3 Then Return Null

		Mesh = New TMesh
		Surface = Mesh.CreateSurface()
		Surface.SetName("body")

		' Body
		For Index = 0 To Segments
			Angle = (360.0/Float(Segments))*Float(Index)
			Surface.CreateVertex(Cos(Angle)*0.5, 0.5, Sin(Angle)*0.5, ..
			                     1.0-Float(Index)/Float(Segments), 0.0)
			Surface.SetVertexNormal(Index*2, Cos(Angle), 0.0, Sin(Angle))

			Surface.CreateVertex(Cos(Angle)*0.5, -0.5, Sin(Angle)*0.5, ..
			                     1.0-Float(Index)/Float(Segments), 1.0)
			Surface.SetVertexNormal(Index*2+1, Cos(Angle), 0.0, Sin(Angle))
		Next

		For Index = 0 To Segments-1
			Surface.CreateTriangle((Index+1)*2+1, (Index+1)*2, Index*2)
			Surface.CreateTriangle(Index*2, Index*2+1, (Index+1)*2+1)
		Next

		Surface.UpdateVertices()
		Surface.UpdateTriangles()

		If Caps Then
			' Top Cap
			Surface = Mesh.CreateSurface()
			Surface.SetName("top")

			For Index = 0 To Segments
				Angle = (360.0/Float(Segments))*Float(Index)
				Surface.CreateVertex(Cos(Angle)*0.5, 0.5, Sin(Angle)*0.5, ..
				                     Cos(Angle)*0.5+0.5, Sin(Angle)*0.5+0.5)
				Surface.SetVertexNormal(Index, 0.0, 1.0, 0.0)
			Next

			For Index = 1 To Segments-1
				Surface.CreateTriangle(Index, Index+1, 0)
			Next

			Surface.UpdateVertices()
			Surface.UpdateTriangles()

			' Bottom Cap
			Surface = Mesh.CreateSurface()
			Surface.SetName("bottom")

			For Index = 0 To Segments
				Angle = (360.0/Float(Segments))*Float(Index)
				Surface.CreateVertex(Cos(Angle)*0.5, -0.5, Sin(Angle)*0.5, ..
				                     Cos(Angle)*0.5+0.5, Sin(Angle)*0.5+0.5)
				Surface.SetVertexNormal(Index, 0.0, -1.0, 0.0)
			Next

			For Index = 1 To Segments-1
				Surface.CreateTriangle(0, Index+1, Index)
			Next

			Surface.UpdateVertices()
			Surface.UpdateTriangles()
		EndIf

		Return Mesh
	End Function

	Function CreateSphere:TMesh(Segments:Int=36)
		Local Mesh:TMesh, Surface:TSurface, VSegment:Int, HSegment:Int
		Local Radius:Float, Angle:Float, NX:Float, NY:Float, NZ:Float
		Local TexU:Float, TexV:Float

		If Segments < 4 Then Return Null

		Mesh = New TMesh
		Surface = Mesh.CreateSurface()

		' Top Cap
		For HSegment = 0 To Segments
			Surface.CreateVertex(0.0, 0.5, 0.0, ..
			                     (1.0/(Float(Segments)))*Float(HSegment), 0.0)
			Surface.SetVertexNormal(HSegment, 0.0, 1.0, 0.0)
		Next

		' Body
		For VSegment = 1 To (Segments-2)/2
			Radius = Sin(360.0/Float(Segments)*Float(VSegment))
			TexV   = (1.0/((Float(Segments))/2.0))*Float(VSegment)
			For HSegment = 0 To Segments
				Angle = 360.0/Float(Segments)*Float(HSegment)

				NX =  Cos(Angle)*Radius
				NY =  Cos(360.0/Float(Segments)*Float(VSegment))
				NZ = -Sin(Angle)*Radius

				TexU = (1.0/(Float(Segments)))*Float(HSegment)

				Surface.CreateVertex(NX*0.5, NY*0.5, NZ*0.5, TexU, TexV)
				Surface.SetVertexNormal(VSegment*(Segments+1)+HSegment, ..
				                        NX, NY, NZ)
			Next
		Next

		' Bottom Cap
		For HSegment = 0 To Segments+1
			Surface.CreateVertex(0.0, -0.5, 0.0, ..
			                     (1.0/(Float(Segments)))*Float(HSegment), 1.0)
			Surface.SetVertexNormal((Segments+1)*(Segments/2)+HSegment, 0.0, -1.0, 0.0)
		Next

		For VSegment = 0 To (Segments-2)/2
			For HSegment = 0 To Segments-1
				Surface.CreateTriangle(VSegment*(Segments+1)+HSegment, ..
				                       VSegment*(Segments+1)+HSegment+1, ..
				                       (VSegment+1)*(Segments+1)+HSegment+1)

				Surface.CreateTriangle((VSegment+1)*(Segments+1)+HSegment+1, ..
				                       (VSegment+1)*(Segments+1)+HSegment, ..
				                       VSegment*(Segments+1)+HSegment)
			Next
		Next

		Surface.UpdateVertices()
		Surface.UpdateTriangles()

		Return Mesh
	End Function
End Type