SuperStrict

Import brl.linkedlist
Import pub.glew
?Linux
	Import "-lX11"
	Import "-lXxf86vm"
?

Import "Math.bmx"

Const DDD_ENTITY_UNKNOWN : Int = 0
Const DDD_ENTITY_PIVOT   : Int = 1
Const DDD_ENTITY_CAMERA  : Int = 2
Const DDD_ENTITY_LIGHT   : Int = 3
Const DDD_ENTITY_MESH    : Int = 4
Const DDD_ENTITY_MD3     : Int = 5
Const DDD_ENTITY_Q3MAP   : Int = 6

Type TEntity
	Global List : TList

	Field Class   : Int
	Field Name    : String
	Field Visible : Int
	Field Parent  : TEntity

	Field Transformation : TTransformation

	Method GetClass:Int()
		Return Class
	End Method

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetVisible(Visible:Int)
		Self.Visible = Visible
	End Method

	Method GetVisible:Int()
		Return Self.Visible
	End Method

	Method SetParent(Entity:TEntity)
		Self.Parent = Entity
	End Method

	Method GetParent:TEntity()
		Return Self.Parent
	End Method

	Method SetPosition(X:Float, Y:Float, Z:Float, Update:Int=True)
		Self.Transformation.Position[0] = X
		Self.Transformation.Position[1] = Y
		Self.Transformation.Position[2] = Z
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method Translate(X:Float, Y:Float, Z:Float, Update:Int=True)
		Self.Transformation.Position[0] :+ X
		Self.Transformation.Position[1] :+ Y
		Self.Transformation.Position[2] :+ Z
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method Move(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local Vector:TVector4

		Vector = New TVector4
		Vector.Components[0] = X
		Vector.Components[1] = Y
		Vector.Components[2] = Z
		Vector.MultMatrix(Self.Transformation.Matrix, Vector)

		Self.Transformation.Position[0] :+ Vector.Components[0]
		Self.Transformation.Position[1] :+ Vector.Components[1]
		Self.Transformation.Position[2] :+ Vector.Components[2]
		If Update Then Self.Transformation.UpdateMatrices() 
	End Method

	Method GetPosition(X:Float Var, Y:Float Var, Z:Float Var)
		X = Self.Transformation.Position[0]
		Y = Self.Transformation.Position[1]
		Z = Self.Transformation.Position[2]
	End Method

	Method GetPositionX:Float()
		Return Self.Transformation.Position[0]
	End Method

	Method GetPositionY:Float()
		Return Self.Transformation.Position[1]
	End Method

	Method GetPositionZ:Float()
		Return Self.Transformation.Position[2]
	End Method

	Method SetRotation(Pitch:Float, Yaw:Float, Roll:Float, Update:Int=True)
		Self.Transformation.Rotation[0] = Pitch
		Self.Transformation.Rotation[1] = Yaw
		Self.Transformation.Rotation[2] = Roll
		Self.Transformation.RotateMatrix.SetRotate(Pitch, Yaw, Roll)
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method Turn(Pitch:Float, Yaw:Float, Roll:Float, Update:Int=True)
		Self.Transformation.Rotation[0] :+ Pitch
		Self.Transformation.Rotation[1] :+ Yaw
		Self.Transformation.Rotation[2] :+ Roll
		Self.Transformation.RotateMatrix.SetRotate(Self.Transformation.Rotation[0], ..
		                                           Self.Transformation.Rotation[1], ..
		                                           Self.Transformation.Rotation[2])
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method Point(X:Float, Y:Float, Z:Float, Update:Int=True)
		Local DX:Float, DY:Float, DZ:Float

		DX = (Self.Transformation.Position[0]-X)
		DY = (Self.Transformation.Position[1]-Y)
		DZ = (Self.Transformation.Position[2]-Z)

		Self.Transformation.Rotation[0] = -ATan2(DY, Sqr(DX*DX+DZ*DZ))
		Self.Transformation.Rotation[1] = -ATan2(DX, DZ)

		Self.Transformation.RotateMatrix.SetRotate(Self.Transformation.Rotation[0], ..
		                                           Self.Transformation.Rotation[1], ..
		                                           Self.Transformation.Rotation[2])
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method GetRotation(Pitch:Float Var, Yaw:Float Var, Roll:Float Var)
		Pitch = Self.Transformation.Rotation[0]
		Yaw   = Self.Transformation.Rotation[1]
		Roll  = Self.Transformation.Rotation[2]
	End Method

	Method GetPitch:Float()
		Return Self.Transformation.Rotation[0]
	End Method

	Method GetYaw:Float()
		Return Self.Transformation.Rotation[1]
	End Method

	Method GetRoll:Float()
		Return Self.Transformation.Rotation[2]
	End Method

	Method SetScale(X:Float, Y:Float, Z:Float, Update:Int=True)
		Self.Transformation.Scale[0] = X
		Self.Transformation.Scale[1] = X
		Self.Transformation.Scale[2] = X
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method GetScale(X:Float Var, Y:Float Var, Z:Float Var)
		X = Self.Transformation.Scale[0]
		Y = Self.Transformation.Scale[1]
		Z = Self.Transformation.Scale[2]
	End Method

	Method GetScaleX:Float()
		Return Self.Transformation.Scale[0]
	End Method

	Method GetScaleY:Float()
		Return Self.Transformation.Scale[1]
	End Method

	Method GetScaleZ:Float()
		Return Self.Transformation.Scale[2]
	End Method

	Method Render() Abstract

	Method New()
		Self.Class   = DDD_ENTITY_UNKNOWN
		Self.Name    = "Unnamed Entity"
		Self.Visible = True
		Self.Parent  = Null

		Self.Transformation  = New TTransformation

		TEntity.List.AddLast(Self)
	End Method

	Method Remove()
		TEntity.List.Remove(Self)
	End Method
End Type