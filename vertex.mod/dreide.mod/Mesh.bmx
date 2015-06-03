SuperStrict

Import "Entity.bmx"
Import "Surface.bmx"

Type TMesh Extends TEntity
	Field SurfaceCount : Int
	Field Surfaces     : TSurface[]

	Method New()
		Self.Class   = DDD_ENTITY_MESH
		Self.Name    = "Unnamed Mesh"
		Self.Visible = True
	End Method

	Method Remove()
		' Hmmmm
	End Method

	Method Render(Camera:TEntity)
		Local I:Int, Surface:TSurface
	
		glTranslatef(Self.Position[0], Self.Position[1], Self.Position[2])
		glScalef(Self.Scale[0], Self.Scale[1], Self.Scale[2])
		glRotatef(Self.Rotation[0], Self.Rotation[1], Self.Rotation[2], ..
		          Self.Rotation[3])
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].Render(Self)
		Next
	End Method
	
	Method CountSurfaces:Int()
		Return Self.SurfaceCount
	End Method
	
	Method CreateSurface:TSurface()
		Self.Surfaces = Self.Surfaces[..(Self.SurfaceCount+1)]
		Self.Surfaces[Self.SurfaceCount] = New TSurface

		Self.SurfaceCount :+ 1
		Return Self.Surfaces[Self.SurfaceCount-1]
	End Method

	Method AddSurface(Surface:TSurface)
		Self.Surfaces = Self.Surfaces[..(Self.SurfaceCount+1)]
		Self.Surfaces[Self.SurfaceCount] = Surface
	End Method

	Method GetSurface:TSurface(Index:Int=0)
		Return Self.Surfaces[Index]
	End Method

	Method SetMaterial(Material:TMaterial)
		Local I:Int
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].SetMaterial(Material)
		Next
	End Method

	Method ScaleVertices(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local I:Int
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].Scale(X, Y, Z, Update)
		Next
	End Method

	Method TranslateVertices(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local I:Int
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].Translate(X, Y, Z, Update)
		Next
	End Method

	Method GetWidth:Float()
		Local I:Int, Surface:TSurface, Vertex:Int, X:Float, MinX:Float, MaxX:Float

		For I = 0 Until Self.SurfaceCount
			Surface = Self.Surfaces[I]
			For Vertex = 0 Until Surface.CountVertices()
				X = Surface.GetVertexX(Vertex)
				If X < MinX Then MinX = X
				If X > MaxX Then MaxX = X
			Next
		Next
		
		Return MaxX-MinX
	End Method

	Method GetHeight:Float()
		Local I:Int, Surface:TSurface, Vertex:Int, Y:Float, MinY:Float, MaxY:Float

		For I = 0 Until Self.SurfaceCount
			Surface = Self.Surfaces[I]
			For Vertex = 0 Until Surface.CountVertices()
				Y = Surface.GetVertexY(Vertex)
				If Y < MinY Then MinY = Y
				If Y > MaxY Then MaxY = Y
			Next
		Next
		
		Return MaxY-MinY
	End Method

	Method GetDepth:Float()
		Local I:Int, Surface:TSurface, Vertex:Int, Z:Float, MinZ:Float, MaxZ:Float

		For I = 0 Until Self.SurfaceCount
			Surface = Self.Surfaces[I]
			For Vertex = 0 Until Surface.CountVertices()
				Z = Surface.GetVertexY(Vertex)
				If Z < MinZ Then MinZ = Z
				If Z > MaxZ Then MaxZ = Z
			Next
		Next
		
		Return MaxZ-MinZ
	End Method

	Method Invert(Normals:Int=True)
		Local I:Int
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].Invert(Normals)
		Next
	End Method
	
	Method SmoothNormals(Update:Int=True)
		Local I:Int
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].SmoothNormals(Update)
		Next
	End Method

	Method SetColor(R:Float, G:Float, B:Float, A:Float=1.0)
		Local I:Int
		
		For I = 0 Until Self.SurfaceCount
			Self.Surfaces[I].SetColor(R, G, B, A)
		Next
	End Method
End Type