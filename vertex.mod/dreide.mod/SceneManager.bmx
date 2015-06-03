SuperStrict

Import brl.linkedlist
Import "Math.bmx"

Type TBoundingVolume
	Field Parent         : TBoundingVolume
	Field Frustum        : TFrustum
	Field Transformation : TTransformation

	Method IsInFrustum:Int() Abstract

	Method Transform:TMatrix4()
		Local GlobalMatrix:TMatrix4, ParentList:TList, Parent:TBoundingVolume

		GlobalMatrix = New TMatrix4

		If Self.Parent Then
			ParentList = CreateList()
			Parent = Self.Parent

			While Parent
				ParentList.AddFirst(Parent)
				Parent = Parent.Parent
			Wend

			GlobalMatrix.SetIdentity()

			For Parent = EachIn ParentList
				GlobalMatrix.MultMatrix(Parent.Transformation.Matrix, GlobalMatrix)
			Next

			GlobalMatrix.MultMatrix(Self.Transformation.Matrix, GlobalMatrix)
		Else
			MemCopy(GlobalMatrix.Components, Self.Transformation.Matrix.Components, 16*4)
		EndIf

		Return GlobalMatrix
	End Method

	Method New()
		Self.Frustum        = Null
		Self.Transformation = Null
	End Method
End Type

Type TBoundingSphere Extends TBoundingVolume
	Field Radius : Float	

	Method SetRadius(Radius:Float)
		Self.Radius = Radius
	End Method

	Method GetRadius:Float()
		Return Self.Radius
	End Method

	Method IsInFrustum:Int()
		Local GlobalMatrix:TMatrix4, X:Float, Y:Float, Z:Float, Index:Int

		If Self.Parent Then
			GlobalMatrix = Self.Transform()
		Else
			GlobalMatrix = Self.Transformation.Matrix
		EndIf

		X = GlobalMatrix.Components[3, 0]
		Y = GlobalMatrix.Components[3, 1]
		Z = GlobalMatrix.Components[3, 2]

		For Index = 0 To 5
			If Self.Frustum.ClipPlanes[Index, 0]*X+ ..
			   Self.Frustum.ClipPlanes[Index, 1]*Y+ ..
			   Self.Frustum.ClipPlanes[Index, 2]*Z+ ..
			   Self.Frustum.ClipPlanes[Index, 3] <= -Self.Radius Then Return False
		Next

		Return True
	End Method
End Type

Type TBoundingBox Extends TBoundingVolume
	Field Point1 : Float[3]
	Field Point2 : Float[3]

	Method IsInFrustum:Int()
		Local Index:Int

	End Method
End Type