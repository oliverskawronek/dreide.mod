SuperStrict

Import "Texture.bmx"

' Render Modes
Const DDD_MATERIAL_WIRE     : Int = %00000001, ..
      DDD_MATERIAL_GOURAUD  : Int = %00000010, ..
      DDD_MATERIAL_FILL     : Int = %00000100, ..
      DDD_MATERIAL_CULLBF   : Int = %00001000, ..
      DDD_MATERIAL_NOFOG    : Int = %00010000, ..
      DDD_MATERIAL_TEXTURED : Int = %00100000

' Blend Modes
Const DDD_MATERIAL_NOBLEND    : Int = 1, ..
      DDD_MATERIAL_ALPHABLEND : Int = 2, ..
      DDD_MATERIAL_ADDBLEND   : Int = 3, ..
      DDD_MATERIAL_MULTBLEND  : Int = 4

Type TMaterial
	Field Name          : String
	Field RenderMode    : Int
	Field BlendMode     : Int
	Field Shininess     : Float
	Field AmbientColor  : Float[4]
	Field DiffuseColor  : Float[4]
	Field SpecularColor : Float[4]
	Field EmissiveColor : Float[4]
	Field LineWidth     : Float
	Field PointSize     : Float
	Field Textures      : TTexture[]

	Method New()
		Self.Name          = "Unnamed Material"
		Self.RenderMode    = DDD_MATERIAL_WIRE ..
		                       | DDD_MATERIAL_GOURAUD ..
		                       | DDD_MATERIAL_FILL ..
		                       | DDD_MATERIAL_CULLBF ..
		                       | DDD_MATERIAL_TEXTURED
		Self.BlendMode     = DDD_MATERIAL_ALPHABLEND
		Self.Shininess     = 0.0
		Self.AmbientColor  = [0.2, 0.2, 0.2, 1.0]
		Self.DiffuseColor  = [0.8, 0.8, 0.8, 1.0]
		Self.SpecularColor = [0.0, 0.0, 0.0, 1.0]
		Self.EmissiveColor = [0.0, 0.0, 0.0, 1.0]
		Self.LineWidth     = 1.0
		Self.PointSize     = 1.0
		Self.Textures      = New TTexture[THardwareInfo.MaxTextures]
	End Method

	Method Render(Camera:TEntity)
		Local Face : Int, ..
		      Fog  : Int
	
		' BackfaceCulling
		If Self.RenderMode & DDD_MATERIAL_CULLBF Then
			' Active
			Face = GL_FRONT
			glEnable(GL_CULL_FACE)
			glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 0.0)
		Else
			' Inactive
			Face = GL_FRONT_AND_BACK
			glDisable(GL_CULL_FACE)
			glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 1.0)
		EndIf

		' Shadingmodel
		If Self.RenderMode & DDD_MATERIAL_GOURAUD Then
			' Gouraudshading
			glShadeModel(GL_SMOOTH)
		Else
			' Flatshading
			glShadeModel(GL_FLAT)
		EndIf

		' FillMode
		If Self.RenderMode & DDD_MATERIAL_FILL Then
			' Filling
			glPolygonMode(Face, GL_FILL)
		Else
			If Self.RenderMode & DDD_MATERIAL_WIRE Then
				' Wireframe
				glLineWidth(Self.LineWidth)
				glPolygonMode(Face, GL_LINE)
			Else
				' Pointframe
				glPointSize(Self.PointSize)
				glPolygonMode(Face, GL_POINT)
			EndIf
		EndIf

		' Fog
		glGetBooleanv(GL_FOG, Varptr(Fog))
		If Self.RenderMode & DDD_MATERIAL_NOFOG Then glDisable(GL_FOG)
		
		' BlendMode
		Select Self.BlendMode
			Case DDD_MATERIAL_NOBLEND
				glDisable(GL_BLEND)

			Case DDD_MATERIAL_ALPHABLEND
				glEnable(GL_BLEND)
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

			Case DDD_MATERIAL_ADDBLEND
				glEnable(GL_BLEND)
				glBlendFunc(GL_SRC_ALPHA, GL_ONE)

			Case DDD_MATERIAL_MULTBLEND
				glEnable(GL_BLEND)
				glBlendFunc(GL_DST_COLOR, GL_ZERO)
		End Select

		' MaterialParameters
		glMaterialf(Face, GL_SHININESS, Self.Shininess)
		glMaterialfv(Face, GL_AMBIENT, Self.AmbientColor)
		glMaterialfv(Face, GL_DIFFUSE, Self.DiffuseColor)
		glMaterialfv(Face, GL_SPECULAR, Self.SpecularColor)
		glMaterialfv(Face, GL_EMISSION, Self.EmissiveColor)

		' Texture
		If Not (Self.RenderMode & DDD_MATERIAL_TEXTURED) Then
			glClientActiveTexture(GL_TEXTURE0)
			glDisableClientState(GL_TEXTURE_COORD_ARRAY)
			glActiveTexture(GL_TEXTURE0)
			glDisable(GL_TEXTURE_2D)
			glDisable(GL_TEXTURE_CUBE_MAP)
		Else
			Local Layer:Int, Exist:Int=False
			For Layer = 0 To THardwareInfo.MaxTextures-1
				If Self.Textures[Layer] Then
					Exist = True
					Exit
				EndIf
			Next

			If Not Exist Then
				glClientActiveTexture(GL_TEXTURE0)
				glDisableClientState(GL_TEXTURE_COORD_ARRAY)
				glActiveTexture(GL_TEXTURE0)
				glDisable(GL_TEXTURE_2D)
				glDisable(GL_TEXTURE_CUBE_MAP)
			EndIf
		EndIf

		' Fog
		If Fog Then
			glEnable(GL_FOG)
		Else
			glDisable(GL_FOG)
		EndIf
	End Method

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetRenderMode(Mode:Int)
		Self.RenderMode = Mode
	End Method

	Method AddRenderMode(Mode:Int)
		Self.RenderMode :| Mode
	End Method

	Method RemoveRenderMode(Mode:Int)
		Self.RenderMode :& (~Mode)
	End Method

	Method GetRenderMode:Int()
		Return Self.RenderMode
	End Method

	Method SetBlendMode(Mode:Int)
		If (Mode => 0) And (Mode <= 3) Then Self.BlendMode = Mode
	End Method

	Method GetBlendMode:Int()
		Return Self.BlendMode
	End Method

	Method SetShininess(Shininess:Float)
		Self.Shininess = Shininess
	End Method

	Method GetShininess:Float()
		Return Self.Shininess
	End Method

	Method SetAmbientColor(R:Float, G:Float, B:Float, A:Float=1.0)
		Self.AmbientColor[0] = R
		Self.AmbientColor[1] = G
		Self.AmbientColor[2] = B
		Self.AmbientColor[3] = A
	End Method

	Method GetAmbientColor(R:Float Var, G:Float Var, B:Float Var, A:Float Var)
		R = Self.AmbientColor[0]
		G = Self.AmbientColor[1]
		B = Self.AmbientColor[2]
		A = Self.AmbientColor[3]
	End Method

	Method GetAmbientRed:Float()
		Return Self.AmbientColor[0]
	End Method

	Method GetAmbientGreen:Float()
		Return Self.AmbientColor[1]
	End Method

	Method GetAmbientBlue:Float()
		Return Self.AmbientColor[2]
	End Method

	Method GetAmbientAlpha:Float()
		Return Self.AmbientColor[3]
	End Method

	Method SetDiffuseColor(R:Float, G:Float, B:Float)
		Self.DiffuseColor[0] = R
		Self.DiffuseColor[1] = G
		Self.DiffuseColor[2] = B
	End Method

	Method GetDiffuseColor(R:Float Var, G:Float Var, B:Float Var)
		R = Self.DiffuseColor[0]
		G = Self.DiffuseColor[1]
		B = Self.DiffuseColor[2]
	End Method

	Method GetDiffuseRed:Float()
		Return Self.DiffuseColor[0]
	End Method

	Method GetDiffuseGreen:Float()
		Return Self.DiffuseColor[1]
	End Method

	Method GetDiffuseBlue:Float()
		Return Self.DiffuseColor[2]
	End Method

	Method SetAlpha(Alpha:Float)
		Self.DiffuseColor[3] = Alpha
	End Method

	Method GetAlpha:Float()
		Return Self.DiffuseColor[3]
	End Method

	Method SetSpecularColor(R:Float, G:Float, B:Float, A:Float=1.0)
		Self.SpecularColor[0] = R
		Self.SpecularColor[1] = G
		Self.SpecularColor[2] = B
		Self.SpecularColor[3] = A
	End Method

	Method GetSpecularColor(R:Float Var, G:Float Var, B:Float Var, A:Float Var)
		R = Self.SpecularColor[0]
		G = Self.SpecularColor[1]
		B = Self.SpecularColor[2]
		A = Self.SpecularColor[3]
	End Method

	Method GetSpecularRed:Float()
		Return Self.SpecularColor[0]
	End Method

	Method GetSpecularGreen:Float()
		Return Self.SpecularColor[1]
	End Method

	Method GetSpecularBlue:Float()
		Return Self.SpecularColor[2]
	End Method

	Method GetSpecularAlpha:Float()
		Return Self.SpecularColor[3]
	End Method

	Method SetEmmisiveColor(Red:Float, Green:Float, Blue:Float, Alpha:Float=1.0)
		Self.EmissiveColor = [Red, Green, Blue, Alpha]
	End Method

	Method SetEmissiveColor(R:Float, G:Float, B:Float, A:Float=1.0)
		Self.EmissiveColor[0] = R
		Self.EmissiveColor[1] = G
		Self.EmissiveColor[2] = B
		Self.EmissiveColor[3] = A
	End Method

	Method GetEmessiveColor(R:Float Var, G:Float Var, B:Float Var, A:Float Var)
		R = Self.EmissiveColor[0]
		G = Self.EmissiveColor[1]
		B = Self.EmissiveColor[2]
		A = Self.EmissiveColor[3]
	End Method

	Method GetEmissiveRed:Float()
		Return Self.EmissiveColor[0]
	End Method

	Method GetEmissiveGreen:Float()
		Return Self.EmissiveColor[1]
	End Method

	Method GetEmissiveBlue:Float()
		Return Self.EmissiveColor[2]
	End Method

	Method GetEmissiveAlpha:Float()
		Return Self.EmissiveColor[3]
	End Method

	Method SetLineWidth(Width:Float)
		Self.LineWidth = Width
	End Method

	Method GetLineWidth:Float()
		Return Self.LineWidth
	End Method

	Method SetPointSize(Size:Float)
		Self.PointSize = Size
	End Method

	Method GetPointSize:Float()
		Return Self.PointSize
	End Method

	Method SetTexture(Texture:TTexture, Index:Int=0)
		If Index < 0 Or Index => THardwareInfo.MaxTextures Then Return
		Self.Textures[Index] = Texture
	End Method

	Method GetTexture:TTexture(Index:Int=0)
		If Index < 0 Or Index => THardwareInfo.MaxTextures Then Return Null
		Return Self.Textures[Index]
	End Method

	Function RenderDefault()
		' BackfaceCulling
		glEnable(GL_CULL_FACE)

		' Standard Material
		glMaterialf(GL_FRONT, GL_SHININESS, 0.0)
		glMaterialfv(GL_FRONT, GL_AMBIENT, [0.2, 0.2, 0.2, 1.0])
		glMaterialfv(GL_FRONT, GL_DIFFUSE, [0.8, 0.8, 0.8, 1.0])
		glMaterialfv(GL_FRONT, GL_SPECULAR, [0.0, 0.0, 0.0, 1.0])
		glMaterialfv(GL_FRONT, GL_EMISSION, [0.0, 0.0, 0.0, 1.0])

		' Alphablending
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glEnable(GL_BLEND)

		' No Texture
		glClientActiveTexture(GL_TEXTURE0)
		glDisableClientState(GL_TEXTURE_COORD_ARRAY)
		glActiveTexture(GL_TEXTURE0)
		glDisable(GL_TEXTURE_2D)
		glDisable(GL_TEXTURE_CUBE_MAP)	
	End Function
End Type