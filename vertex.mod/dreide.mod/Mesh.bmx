SuperStrict

Import brl.linkedlist
Import "Error.bmx"
Import "Entity.bmx"
Import "Surface.bmx"

Type TMesh Extends TEntity
	Global List : TList

	Field Surfaces     : TList
	Field SurfaceCount : Int

	Method CountSurfaces:Int()
		Return Self.SurfaceCount
	End Method

	Method CreateSurface:TSurface()
		Local Surface:TSurface

		Surface = New TSurface
		Self.Surfaces.AddLast(Surface)
		Self.SurfaceCount :+ 1

		Return Surface
	End Method

	Method RemoveSurface(Surface:TSurface)
		If Self.Surfaces.Contains(Surface) Then
			Self.Surfaces.Remove(Surface)
			Self.SurfaceCount :- 1
		Else
			TDreiDeError.DisplayError("Surface does not exist!")
		EndIf
	End Method

	Method GetSurface:TSurface(Index:Int)
		If (Index => 0) And (Index <= Self.SurfaceCount) Then
			Return TSurface(Self.Surfaces.ValueAtIndex(Index))
		Else
			TDreiDeError.DisplayError("Surface out of Range!")
		EndIf
	End Method

	Method SetMaterial(Material:TMaterial)
		Local Surface:TSurface
		
		For Surface = EachIn Self.Surfaces
			Surface.SetMaterial(Material)
		Next
	End Method

	Method ScaleVertices(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Surface:TSurface
		
		For Surface = EachIn Self.Surfaces
			Surface.Scale(X, Y, Z, Update)
		Next
	End Method

	Method TranslateVertices(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Surface:TSurface
		
		For Surface = EachIn Self.Surfaces
			Surface.Translate(X, Y, Z, Update)
		Next
	End Method

	Method GetWidth:Float()
		Local Surface:TSurface, Vertex:Int, X:Float, MinX:Float, MaxX:Float
		
		For Surface = EachIn Self.Surfaces
			For Vertex = 0 To Surface.VertexCount-1
				X = Surface.Vertices[0].PeekFloat(Vertex*12)
				If X < MinX Then MinX = X
				If X > MaxX Then MaxX = X
			Next
		Next
		
		Return MaxX-MinX
	End Method
	
	Method GetHeight:Float()
		Local Surface:TSurface, Vertex:Int, Y:Float, MinY:Float, MaxY:Float
		
		For Surface = EachIn Self.Surfaces
			For Vertex = 0 To Surface.VertexCount-1
				Y = Surface.Vertices[0].PeekFloat(Vertex*12+4)
				If Y < MinY Then MinY = Y
				If Y > MaxY Then MaxY = Y
			Next
		Next
		
		Return MaxY-MinY
	End Method
	
	Method GetDepth:Float()
		Local Surface:TSurface, Vertex:Int, Z:Float, MinZ:Float, MaxZ:Float
		
		For Surface = EachIn Self.Surfaces
			For Vertex = 0 To Surface.VertexCount-1
				Z = Surface.Vertices[0].PeekFloat(Vertex*12+8)
				If Z < MinZ Then MinZ = Z
				If Z > MaxZ Then MaxZ = Z
			Next
		Next
		
		Return MaxZ-MinZ
	End Method

	Method Invert(Normals:Int=True)
		Local Surface:TSurface
		
		For Surface = EachIn Self.Surfaces
			Surface.Invert(Normals)
		Next
	End Method
	
	Method SmoothNormals(Update:Int=True)
		Local Surface:TSurface
		
		For Surface = EachIn Self.Surfaces
			Surface.SmoothNormals(Update)
		Next
	End Method

	Method SetColor(Red:Float, Green:Float, Blue:Float, Alpha:Float=1.0)
		Local Surface:TSurface
		
		For Surface = EachIn Self.Surfaces
			Surface.SetColor(Red, Green, Blue, Alpha)
		Next
	End Method

	Method Render()
		Local ParentList:TList, Parent:TEntity, Surface:TSurface

		' Set Transformation
		If Self.Parent Then
			ParentList = CreateList()

			Parent = Self.Parent
			Repeat
				ParentList.AddFirst(Parent)
				Parent = Parent.Parent
			Until Not Parent

			For Parent = EachIn ParentList
				glMultMatrixf(Parent.Transformation.Matrix.Components)
			Next
		EndIf

		glMultMatrixf(Self.Transformation.Matrix.Components)

		For Surface = EachIn Self.Surfaces
			Surface.Render(Self)
		Next
	End Method
	
	Method New()
		Self.Class  = DDD_ENTITY_MESH
		Self.Name   = "Unnamed Mesh"

		Self.Surfaces     = CreateList()
		Self.SurfaceCount = 0

		TMesh.List.AddLast(Self)
	End Method

	Method Remove()
		TMesh.List.Remove(Self)
		TEntity.List.Remove(Self)
	End Method
End Type