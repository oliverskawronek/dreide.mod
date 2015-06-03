SuperStrict

Import BRL.LinkedList

' Classes
Const DDD_ENTITY_UNKNOWN : Int = 0, ..
      DDD_ENTITY_PIVOT   : Int = 1, ..
      DDD_ENTITY_CAMERA  : Int = 2, ..
      DDD_ENTITY_LIGHT   : Int = 3, ..
      DDD_ENTITY_MESH    : Int = 4, ..
      DDD_ENTITY_MD3     : Int = 5, ..
      DDD_ENTITY_Q3MAP   : Int = 6

Type TEntity
	Global List : TList

	Field Class       : Int
	Field Name        : String
	Field Visible     : Int
	Field Rotation    : Float[4]
	Field Position    : Float[3]
	Field Scale       : Float[3]
	
	Method New()
		Self.Rotation = [0.0, 0.0, 1.0, 0.0]
		Self.Position = [0.0, 0.0, 0.0]
		Self.Scale    = [1.0, 1.0, 1.0]

		TEntity.List.AddLast(Self)
	End Method

	Method Render(Camera:TEntity) Abstract

	Method GetClass:Int()
		Return Self.Class
	End Method

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method SetVisible(Enable:Int)
		Self.Visible = Enable
	End Method

	Method GetVisible:Int()
		Return Self.Visible
	End Method

	Method SetRotation(Angle:Float, X:Float, Y:Float, Z:Float)
		Self.Rotation[0] = Angle
		Self.Rotation[1] = X
		Self.Rotation[2] = Y
		Self.Rotation[3] = Z
	End Method

	Method SetPosition(X:Float, Y:Float, Z:Float)
		Self.Position[0] = X
		Self.Position[1] = Y
		Self.Position[2] = Z
	End Method

	Method SetScale(X:Float, Y:Float, Z:Float)
		Self.Scale[0] = X
		Self.Scale[1] = Y
		Self.Scale[2] = Z
	End Method
End Type