SuperStrict

Import "Entity.bmx"
Import "Math.bmx"

Type TAnimation
	Field Name          : String
	Field Entity        : TEntity
	Field FrameCount    : Int
	Field KeyframeCount : Int
	Field Keyframes     : TKeyframe[]
	Field Keytimes      : Int[]
	Field Frame         : Float

	Method New()
		Self.Name          = "Unnamed Animation"
		Self.Entity        = Null
		Self.FrameCount    = 0
		Self.KeyframeCount = 0
		Self.Frame         = 0.0
	End Method

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetEntity(Entity:TEntity)
		Self.Entity = Entity
	End Method

	Method GetEntity:TEntity()
		Return Self.Entity
	End Method

	Method CountFrames:Int()
		Return Self.FrameCount
	End Method

	Method CountKeyframes:Int()
		Return Self.KeyframeCount
	End Method

	Method AddKeyframe(Keyframe:TKeyframe, Frame:Int)
		If Frame < 0 Or Keyframe = Null Then Return

		Self.Keyframes = Self.Keyframes[..Self.KeyframeCount+1]
		Self.Keyframes[Self.KeyframeCount] = Keyframe

		Self.Keytimes = Self.Keytimes[..Self.KeyframeCount+1]
		Self.Keytimes[Self.KeyframeCount] = Frame

		Self.KeyframeCount :+ 1

		If Frame > Self.FrameCount Then Self.FrameCount = Frame
	End Method

	Method GetKeyframe:TKeyframe(Index:Int)
		If Index < 0 Or Index => Self.KeyframeCount Then Return Null
		Return Self.Keyframes[Index]
	End Method

	Method GetFrame:Float()
		Return Self.Frame
	End Method

	Method SetFrame:Int(Frame:Float)
		Local Index:Int, KeyA:Int, KeyB:Int
	
		If Not Self.Entity Or Frame < 0 Or Frame => Self.FrameCount ..
		   Then Return False

		KeyA = -1
		For Index = 1 Until Self.KeyframeCount
			If Self.Keytimes[Index-1] <= Int(Floor(Frame)) And ..
			   Self.Keytimes[Index  ] => Int(Ceil(Frame)) Then
			
				KeyA = Index-1
				KeyB = Index
				Exit
			EndIf
		Next
		If KeyA = -1 Then Return False

		TKeyframe.Interpolate(Keyframes[KeyA], Keyframes[KeyB], Self.Entity, ..
		                      Float(Frame-Self.Keytimes[KeyA]) ..
		                      / Float(Self.Keytimes[KeyB]-Self.Keytimes[KeyA]))
		
		Return True
	End Method
End Type

Type TKeyframe
	Field Rotation : Float[4]
	Field Position : Float[3]
	Field Scale    : Float[3]

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

	Function Interpolate(KeyA:TKeyframe, KeyB:TKeyframe, Entity:TEntity, T:Float)
		' Rotation
		TQuaternion.Slerp(KeyA.Rotation, KeyB.Rotation, Entity.Rotation, T)

		' Position
		Entity.Position[0] = (KeyB.Position[0]-KeyA.Position[0])*T + KeyA.Position[0]
		Entity.Position[1] = (KeyB.Position[1]-KeyA.Position[1])*T + KeyA.Position[1]
		Entity.Position[2] = (KeyB.Position[2]-KeyA.Position[2])*T + KeyA.Position[2]

		' Scale
		Entity.Scale[0] = (KeyB.Scale[0]-KeyA.Scale[0])*T + KeyA.Scale[0]
		Entity.Scale[1] = (KeyB.Scale[1]-KeyA.Scale[1])*T + KeyA.Scale[1]
		Entity.Scale[2] = (KeyB.Scale[2]-KeyA.Scale[2])*T + KeyA.Scale[2]
	End Function
End Type