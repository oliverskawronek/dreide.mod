SuperStrict

Import pub.glew
?Linux
Import "-lX11"
Import "-lXxf86vm"
? 
Import pub.opengl
Import brl.linkedlist
Import brl.pixmap
Import "Error.bmx"
Import "HardwareInfo.bmx"
Import "Entity.bmx"

' Cube-Faces
Const DDD_TEXTURE_POSX : Int = 1 ' Positive X = Right
Const DDD_TEXTURE_NEGX : Int = 2 ' Negative X = Left
Const DDD_TEXTURE_POSY : Int = 3 ' Positive Y = Top
Const DDD_TEXTURE_NEGY : Int = 4 ' Negative Y = Bottom
Const DDD_TEXTURE_POSZ : Int = 5 ' Positive Z = Back
Const DDD_TEXTURE_NEGZ : Int = 6 ' Negative Z = Front

' Rendering-Modes
Const DDD_TEXTURE_TRANSFORMED : Int = %00000001
Const DDD_TEXTURE_COMPRESSED  : Int = %00000010
Const DDD_TEXTURE_MIPMAP      : Int = %00000100
Const DDD_TEXTURE_SPHEREMAP   : Int = %00001000
Const DDD_TEXTURE_CUBEMAP     : Int = %00010000
Const DDD_TEXTURE_PROJECTED   : Int = %00100000
Const DDD_TEXTURE_DEPTHMAP    : Int = %01000000

' Cube-Modes
Const DDD_TEXTURE_REFLECTION : Int = 1
Const DDD_TEXTURE_NORMAL     : Int = 2

' Filter
Const DDD_TEXTURE_POINTSAMPLING : Int = 1
Const DDD_TEXTURE_BILINEAR      : Int = 2
Const DDD_TEXTURE_TRILINEAR     : Int = 3
Const DDD_TEXTURE_ANISOTROPIC   : Int = 4

' Clamp-Modes
Const DDD_TEXTURE_CLAMP  : Int = 1
Const DDD_TEXTURE_REPEAT : Int = 2

' Blending-Modes
Const DDD_TEXTURE_REPLACE     : Int = 1
Const DDD_TEXTURE_MODULATE    : Int = 2
Const DDD_TEXTURE_MODULATE2X  : Int = 3
Const DDD_TEXTURE_DECAL       : Int = 4
Const DDD_TEXTURE_BLEND       : Int = 5
Const DDD_TEXTURE_ADD         : Int = 6
Const DDD_TEXTURE_SUBTRACT    : Int = 7
Const DDD_TEXTURE_INTERPOLATE : Int = 8
Const DDD_TEXTURE_DOT3        : Int = 9

Type TTexture
	Global List : TList

	Field Name           : String
	Field Filename       : String
	Field TextureID      : Int
	Field Size           : Int[2]
	Field CubeFace       : Int
	Field RenderMode     : Int
	Field BlendMode      : Int
	Field CubeMode       : Int
	Field CoordSet       : Int
	Field Transformation : TTransformation

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetFilename(Filename:String)
		Self.Filename = Filename
	End Method

	Method GetFilename:String()
		Return Self.Filename
	End Method

	Method SetPixmap:Int(Pixmap:TPixmap)
		Local Target:Int, Width:Int, Height:Int, Components:Int

		If Pixmap = Null Then TDreiDeError.DisplayError("Pixmap does not exist!")

		If Self.RenderMode & DDD_TEXTURE_CUBEMAP Then
			glBindTexture(GL_TEXTURE_CUBE_MAP, Self.TextureID)
			Target = GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT+Self.CubeFace-1
		Else
			glBindTexture(GL_TEXTURE_2D, Self.TextureID)
			Target = GL_TEXTURE_2D
		EndIf

		' Has Pixmap the Pixelformat RGBA8888?
		If Pixmap.Format <> PF_RGBA8888 Then Pixmap = Pixmap.Convert(PF_RGBA8888)

		' Get supported TextureSize
		Width  = Pixmap.Width
		Height = Pixmap.Height
		TTexture.AdjustTexSize(Width, Height)
		If (Width <> Pixmap.Width) Or (Height <> Pixmap.Height) Then
			Pixmap = ResizePixmap(Pixmap, Width, Height)
		EndIf

		If Self.RenderMode & DDD_TEXTURE_COMPRESSED Then
			If THardwareInfo.GLTCSupport Then
				Components = GL_COMPRESSED_RGBA
			ElseIf THardwareInfo.S3TCSupport
				Components = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT
			Else
				Components = GL_RGBA
			EndIf
		Else
			Components = GL_RGBA
		EndIf

		If Self.RenderMode & DDD_TEXTURE_MIPMAP Then
			If gluBuild2DMipmaps(Target, Components, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, ..
			                  Pixmap.Pixels) = 0 Then
				Return True
			Else
				Return False
			EndIf
		Else
			glTexImage2D(Target, 0, Components, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, ..
			             Pixmap.Pixels)

			If glGetError() = 0 Then
				Return True
			Else
				Return False
			EndIf
		EndIf
	End Method

	Method SetSize(Width:Int, Height:Int)
		Self.Size[0] = Width
		Self.Size[1] = Height
		AdjustTexSize(Self.Size[0], Self.Size[1])
	End Method

	Method GetSize(Width:Int Var, Height:Int Var)
		Width  = Self.Size[0]
		Height = Self.Size[1]
	End Method

	Method GetWidth:Int()
		Return Self.Size[0]
	End Method

	Method GetHeight:Int()
		Return Self.Size[1]
	End Method

	Method SetCubeFace(Face:Int)
		If (Face > 0) Or (Face < 6) Then
			Self.CubeFace = Face
		Else
			TDreiDeError.DisplayError("Cubeface is not supported!")
		EndIf
	End Method

	Method GetCubeFace:Int()
		Return Self.CubeFace
	End Method

	Method SetRenderMode(Mode:Int)
		If (Mode & DDD_TEXTURE_CUBEMAP) And (THardwareInfo.CubemapSupport = False) Then
			TDreiDeError.DisplayError("Cubemapping is not supported!")
		EndIf
		Self.RenderMode = Mode
	End Method

	Method AddRenderMode(Mode:Int)
		If (Mode & DDD_TEXTURE_CUBEMAP) And (THardwareInfo.CubemapSupport = False) Then
			TDreiDeError.DisplayError("Cubemapping is not supported!")
		EndIf
		Self.RenderMode :| Mode
	End Method

	Method RemoveRenderMode(Mode:Int)
		Self.RenderMode :& (~Mode)
	End Method

	Method GetRenderMode:Int()
		Return Self.RenderMode
	End Method

	Method SetBlendMode(Mode:Int)
		If (Mode => DDD_TEXTURE_REPLACE ) And (Mode <= DDD_TEXTURE_DOT3) Then
			Self.BlendMode = Mode
		Else
			TDreiDeError.DisplayError("Blendmode is not supported!")
		EndIf
	End Method

	Method GetBlendMode:Int()
		Return Self.BlendMode
	End Method

	Method SetCubeMode(Mode:Int)
		If (Mode > 0) And (Mode < 3) Then
			Self.CubeMode = Mode
		Else
			TDreiDeError.DisplayError("Cubemode is not supported!")
		EndIf
	End Method

	Method GetCubeMode:Int()
		Return Self.CubeMode
	End Method
	
	Method SetCoordSet(UVSet:Int)
		If (UVSet => 0) And (UVSet <= 1)
			Self.CoordSet = UVSet
		Else
			TDreiDeError.DisplayError("UV not supported!")
		EndIf
	EndMethod

	Method GetCoordSet:Int()
		Return Self.CoordSet
	EndMethod

	Method SetFilter(Filter:Int)
		Local Target:Int, MaxAnisotropy:Float

		If Self.RenderMode & DDD_TEXTURE_CUBEMAP Then
			Target = GL_TEXTURE_CUBE_MAP
		Else
			Target = GL_TEXTURE_2D
		EndIf
		glBindTexture(Target, Self.TextureID)

		If Self.RenderMode & DDD_TEXTURE_MIPMAP Then
			Select Filter
				Case DDD_TEXTURE_POINTSAMPLING
					glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST)
					glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
				
				Case DDD_TEXTURE_BILINEAR
					glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
					glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
				
				Case DDD_TEXTURE_TRILINEAR
					glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
					glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
				
				Case DDD_TEXTURE_ANISOTROPIC
					If THardwareInfo.AnIsoSupport Then
						glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, Varptr(MaxAnisotropy))
						glTexParameterf(Target, GL_TEXTURE_MAX_ANISOTROPY_EXT, MaxAnisotropy)
					Else
						TDreiDeError.DisplayError("AnIsotropic Filtering is not supported!")
					EndIf
				
				Default
					TDreiDeError.DisplayError("Filter is not supported!")
			End Select
		Else
			Select Filter
				Case DDD_TEXTURE_POINTSAMPLING
					glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
					glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
				
				Case DDD_TEXTURE_BILINEAR
					glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
					glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
				
				Case DDD_TEXTURE_ANISOTROPIC
					If THardwareInfo.AnIsoSupport Then
						glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, Varptr(MaxAnisotropy))
						glTexParameterf(Target, GL_TEXTURE_MAX_ANISOTROPY_EXT, MaxAnisotropy)
					Else
						TDreiDeError.DisplayError("AnIsotropic Filtering is not supported!")
					EndIf
				
				Default
					TDreiDeError.DisplayError("Filter is not supported!")
			End Select
		EndIf
	End Method

	Method SetWrap(UWrap:Int, VWrap:Int)
		Local Target:Int
		If Self.RenderMode & DDD_TEXTURE_CUBEMAP Then
			glBindTexture(GL_TEXTURE_2D, 0)
			Target = GL_TEXTURE_CUBE_MAP
		Else
			glBindTexture(GL_TEXTURE_2D, Self.TextureID)
			Target = GL_TEXTURE_2D
		EndIf

		If UWrap = DDD_TEXTURE_CLAMP Then
			glTexParameteri(Target, GL_TEXTURE_WRAP_S, GL_CLAMP)
		Else
			glTexParameteri(Target, GL_TEXTURE_WRAP_S, GL_REPEAT)
		EndIf

		If VWrap = DDD_TEXTURE_CLAMP Then
			glTexParameteri(Target, GL_TEXTURE_WRAP_T, GL_CLAMP)
		Else
			glTexParameteri(Target, GL_TEXTURE_WRAP_T, GL_REPEAT)
		EndIf
	End Method

	Method SetPosition(U:Float, V:Float, Update:Int=True)
		Self.Transformation.Position[0] = U
		Self.Transformation.Position[1] = V
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method Translate(U:Float, V:Float, Update:Int=True)
		Self.Transformation.Position[0] :+ U
		Self.Transformation.Position[1] :+ V
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method GetPosition(U:Float Var, V:Float Var)
		U = Self.Transformation.Position[0]
		V = Self.Transformation.Position[1]
	End Method

	Method GetU:Float()
		Return Self.Transformation.Position[0]
	End Method

	Method GetV:Float()
		Return Self.Transformation.Position[1]
	End Method

	Method SetRotation(Roll:Float, Update:Int=True)
		Self.Transformation.Rotation[2] = Roll
		Self.Transformation.RotateMatrix.SetRoll(Roll)
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method Turn(Roll:Float, Update:Int=True)
		Self.Transformation.Rotation[2] :+ Roll
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method GetRotation:Float()
		Return Self.Transformation.Rotation[2]
	End Method

	Method SetScale(U:Float, V:Float, Update:Int=True)
		Self.Transformation.Scale[0] = U
		Self.Transformation.Scale[1] = V
		If Update Then Self.Transformation.UpdateMatrices()
	End Method

	Method GetScale(U:Float Var, V:Float Var)
		U = Self.Transformation.Scale[0]
		V = Self.Transformation.Scale[1]
	End Method

	Method GetScaleU:Float()
		Return Self.Transformation.Scale[0]
	End Method

	Method GetScaleV:Float()
		Return Self.Transformation.Scale[1]
	End Method

	Method GrabBackBuffer(X:Int=0, Y:Int=0)
		Local Target:Int

		If Self.RenderMode & DDD_TEXTURE_CUBEMAP Then
			Target = GL_TEXTURE_CUBE_MAP_POSITIVE_X+Self.CubeFace
		Else
			Target = GL_TEXTURE_2D
		EndIf

		glBindTexture(Target, Self.TextureID)
		glCopyTexImage2D(Target, 0, GL_RGBA, X, Y, Self.Size[0], Self.Size[1], 0)
	End Method

	Method Render(Entity:TEntity)
		Local Matrix:Int

		If (Self.RenderMode & DDD_TEXTURE_TRANSFORMED) And ..
		   (Not (Self.RenderMode & DDD_TEXTURE_PROJECTED))Then
			glGetIntegerv(GL_MATRIX_MODE, Varptr(Matrix))
			glMatrixMode(GL_TEXTURE)
			glLoadMatrixf(Self.Transformation.Matrix.Components)
			glMatrixMode(Matrix)
		EndIf

		If Self.RenderMode & DDD_TEXTURE_SPHEREMAP Then
			glEnable(GL_TEXTURE_2D)
			glDisable(GL_TEXTURE_CUBE_MAP)
			glEnable(GL_TEXTURE_GEN_S)
			glEnable(GL_TEXTURE_GEN_T)
			glDisable(GL_TEXTURE_GEN_R)
			
			glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)
			glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP)

		ElseIf Self.RenderMode & DDD_TEXTURE_CUBEMAP Then
			glDisable(GL_TEXTURE_2D)
			glEnable(GL_TEXTURE_CUBE_MAP)

			glBindTexture(GL_TEXTURE_CUBE_MAP, Self.TextureID)

			glEnable(GL_TEXTURE_GEN_S)
			glEnable(GL_TEXTURE_GEN_T)
			glEnable(GL_TEXTURE_GEN_R)

			If Self.CubeMode = DDD_TEXTURE_REFLECTION Then
				glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_REFLECTION_MAP_ARB)
				glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_REFLECTION_MAP_ARB)
				glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_REFLECTION_MAP_ARB)
			Else
				glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_NORMAL_MAP_ARB)
				glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_NORMAL_MAP_ARB)
				glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_NORMAL_MAP_ARB)
			EndIf

		ElseIf Self.RenderMode & DDD_TEXTURE_PROJECTED Then
			glEnable(GL_TEXTURE_2D)
			glDisable(GL_TEXTURE_CUBE_MAP)
			glEnable(GL_TEXTURE_GEN_S)
			glEnable(GL_TEXTURE_GEN_T)
			glEnable(GL_TEXTURE_GEN_R)
			glEnable(GL_TEXTURE_GEN_Q)

			glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR)
			glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR)
			glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR)
			glTexGeni(GL_Q, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR)

			glTexGenfv(GL_S, GL_OBJECT_PLANE, [1.0, 0.0, 0.0, 0.0])
			glTexGenfv(GL_T, GL_OBJECT_PLANE, [0.0, 1.0, 0.0, 0.0])
			glTexGenfv(GL_R, GL_OBJECT_PLANE, [0.0, 0.0, 1.0, 0.0])
			glTexGenfv(GL_Q, GL_OBJECT_PLANE, [0.0, 0.0, 0.0, 1.0])

			' Edit me!
		Else
			glDisable(GL_TEXTURE_CUBE_MAP)
			glDisable(GL_TEXTURE_GEN_S)
			glDisable(GL_TEXTURE_GEN_T)
			glDisable(GL_TEXTURE_GEN_R)

			glEnable(GL_TEXTURE_2D)
			glBindTexture(GL_TEXTURE_2D, Self.TextureID)
		EndIf

		If THardwareInfo.TexBlendSupport Then
			Select Self.BlendMode
				Case DDD_TEXTURE_REPLACE
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE)

				Case DDD_TEXTURE_MODULATE
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
	
				Case DDD_TEXTURE_DECAL
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL)

				Case DDD_TEXTURE_BLEND
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND)
					
				Case DDD_TEXTURE_MODULATE2X
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
					glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE)
					glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS)
					glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE)
					glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 2.0)

				Case DDD_TEXTURE_ADD
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ADD)

				Case DDD_TEXTURE_SUBTRACT
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_SUBTRACT_ARB)

				Case DDD_TEXTURE_INTERPOLATE
					glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_INTERPOLATE_ARB)

				Case DDD_TEXTURE_DOT3
					glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
					glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB)
					glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS)
					glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE)
			End Select
		EndIf
	End Method

	Method New()
		glGenTextures(1, Varptr(Self.TextureID))

		Self.Name           = "Unnamed Texture"
		Self.Filename       = ""
		Self.Size           = [1, 1]
		Self.CubeFace       = DDD_TEXTURE_POSX
		Self.RenderMode     = 0
		Self.BlendMode      = DDD_TEXTURE_MODULATE
		Self.CubeMode       = DDD_TEXTURE_REFLECTION
		Self.CoordSet       = 0
		Self.Transformation = New TTransformation

		TTexture.List.AddLast(Self)
	End Method

	Method Delete()
		glDeleteTextures(1, Varptr(Self.TextureID))
	End Method

	Method Remove()
		TTexture.List.Remove(Self)
	End Method

	Function AdjustTexSize:Int(Width:Int Var, Height:Int Var)
		Function Pow2Size:Int(N:Int)
			Local Size:Int

			Size = 1
			While Size < N
				Size = Size Shl 1
			Wend

			Return Size
		End Function

		Width  = Pow2Size(Width)
		Height = Pow2Size(Height)
	End Function
End Type