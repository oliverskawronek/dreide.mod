SuperStrict

Import brl.linkedlist
Import pub.glew
?Linux
	Import "-lX11"
	Import "-lXxf86vm"
?
Import "Error.bmx"
Import "VertexProgram.bmx"
Import "FragmentProgram.bmx"
Import "GlSlang.bmx"
Import "Texture.bmx"

' Render-Modes
Const DDD_MATERIAL_WIRE     : Int = %00000001 ' else point
Const DDD_MATERIAL_GOURAUD  : Int = %00000010 ' else flat
Const DDD_MATERIAL_FILL     : Int = %00000100 ' else wire or point
Const DDD_MATERIAL_CULLBF   : Int = %00001000 ' else no culling
Const DDD_MATERIAL_NOFOG    : Int = %00010000 ' else fog
Const DDD_MATERIAL_TEXTURED : Int = %00100000 ' else not textured

' Blend-Modes
Const DDD_MATERIAL_NOBLEND       : Int = 0
Const DDD_MATERIAL_ALPHABLEND    : Int = 1
Const DDD_MATERIAL_MULTIPLYBLEND : Int = 2
Const DDD_MATERIAL_ADDBLEND      : Int = 3

Type TMaterial
	Global List : TList

	Field Name            : String
	Field VertexProgram   : TVertexProgram
	Field FragmentProgram : TFragmentProgram
	Field Shader          : TShader
	Field TextureList     : TTexture[]
	Field RenderMode      : Int
	Field BlendMode       : Int
	Field Shininess       : Float
	Field AmbientColor    : Float[4]
	Field DiffuseColor    : Float[4]
	Field SpecularColor   : Float[4]
	Field EmissiveColor   : Float[4]
	Field LineWidth       : Float
	Field PointSize       : Float

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetVertexProgram(VertexProgram:TVertexProgram)
		Self.VertexProgram = VertexProgram
	End Method

	Method GetVertexProgram:TVertexProgram()
		Return Self.VertexProgram
	End Method
	
	Method SetFragmentProgram(FragmentProgram:TFragmentProgram)
		Self.FragmentProgram = FragmentProgram
	End Method

	Method GetFragmentProgram:TFragmentProgram()
		Return Self.FragmentProgram
	End Method

	Method SetShader(Shader:TShader)
		Self.Shader = Shader
	End Method

	Method GetShader:TShader()
		Return Self.Shader
	End Method

	Method SetTexture(Texture:TTexture, Layer:Int=0)
		If (Layer < 0) Or (Layer => THardwareInfo.MaxTextures) Then Return
		Self.TextureList[Layer] = Texture
	End Method

	Method GetTexture:TTexture(Layer:Int=0)
		If (Layer < 0) Or (Layer => THardwareInfo.MaxTextures) Then Return Null
		Return Self.TextureList[Layer]
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

	Method SetAmbientColor(Red:Float, Green:Float, Blue:Float, Alpha:Float=1.0)
		Self.AmbientColor = [Red, Green, Blue, Alpha]
	End Method

	Method GetAmbientColor(Red:Float Var, Green:Float Var, Blue:Float Var, Alpha:Float Var)
		Red   = Self.AmbientColor[0]
		Green = Self.AmbientColor[1]
		Blue  = Self.AmbientColor[2]
		Alpha = Self.AmbientColor[3]
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

	Method SetDiffuseColor(Red:Float, Green:Float, Blue:Float)
		Self.DiffuseColor = [Red, Green, Blue, Self.DiffuseColor[3]]
	End Method

	Method GetDiffuseColor(Red:Float Var, Green:Float Var, Blue:Float Var)
		Red   = Self.DiffuseColor[0]
		Green = Self.DiffuseColor[1]
		Blue  = Self.DiffuseColor[2]
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

	Method SetSpecularColor(Red:Float, Green:Float, Blue:Float, Alpha:Float=1.0)
		Self.SpecularColor = [Red, Green, Blue, Alpha]
	End Method

	Method GetSpecularColor(Red:Float Var, Green:Float Var, Blue:Float Var, Alpha:Float Var)
		Red   = Self.SpecularColor[0]
		Green = Self.SpecularColor[1]
		Blue  = Self.SpecularColor[2]
		Alpha = Self.SpecularColor[3]
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

	Method GetEmissiveColor(Red:Float Var, Green:Float Var, Blue:Float Var, Alpha:Float Var)
		Red   = Self.EmissiveColor[0]
		Green = Self.EmissiveColor[1]
		Blue  = Self.EmissiveColor[2]
		Alpha = Self.EmissiveColor[3]
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
		If Width < 0.0 Then TDreiDeError.DisplayError("Width must be greater than 0.0!")
		Self.LineWidth = Width
	End Method

	Method GetLineWidth:Float()
		Return Self.LineWidth
	End Method

	Method SetPointSize(Size:Float)
		If Size < 0.0 Then TDreiDeError.DisplayError("Size must be greater than 0.0!")
		Self.PointSize = Size
	End Method

	Method GetPointSize:Float()
		Return Self.PointSize
	End Method

	Method Render()
		Local Face:Int

		' Using VertexProgram?
		If Self.VertexProgram Then
			Self.VertexProgram.Render()
			glEnable(GL_VERTEX_PROGRAM_ARB)
		Else
			glDisable(GL_VERTEX_PROGRAM_ARB)
		EndIf
		
		' Using FragmentProgram?
		If Self.FragmentProgram Then
			Self.FragmentProgram.Render()
			glEnable(GL_FRAGMENT_PROGRAM_ARB)
		Else
			glDisable(GL_FRAGMENT_PROGRAM_ARB)
		EndIf
		
		' Using Shader?
		If Self.Shader Then
			Self.Shader.Render()
		Else
			If THardwareInfo.ShaderSupport Then glUseProgramObjectARB(Null)
		EndIf

		' Is BackfaceCulling active?
		If Self.RenderMode & DDD_MATERIAL_CULLBF Then
			Face = GL_FRONT
			glEnable(GL_CULL_FACE)
			glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 0.0)
		Else
			Face = GL_FRONT_AND_BACK
			glDisable(GL_CULL_FACE)
			glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 1.0)
		EndIf

		' Using Gouraudshading?
		If Self.RenderMode & DDD_MATERIAL_GOURAUD Then
			glShadeModel(GL_SMOOTH)
		Else
			glShadeModel(GL_FLAT)
		EndIf

		' Draw filled?
		If Self.RenderMode & DDD_MATERIAL_FILL Then
			glPolygonMode(Face, GL_FILL)
		Else
			If Self.RenderMode & DDD_MATERIAL_WIRE Then
				glLineWidth(Self.LineWidth)
				glPolygonMode(Face, GL_LINE)
			Else
				glPointSize(Self.PointSize)
				glPolygonMode(Face, GL_POINT)
			EndIf
		EndIf
		
		If Self.RenderMode & DDD_MATERIAL_NOFOG Then glDisable(GL_FOG)

		' Choose current Blendmode
		Select Self.BlendMode
			Case DDD_MATERIAL_NOBLEND
				glDisable(GL_BLEND)

			Case DDD_MATERIAL_ALPHABLEND
				glEnable(GL_BLEND)
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

			Case DDD_MATERIAL_MULTIPLYBLEND
				glEnable(GL_BLEND)
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

			Case DDD_MATERIAL_ADDBLEND
				glEnable(GL_BLEND)
				glBlendFunc(GL_SRC_ALPHA, GL_ONE)
		End Select

		' Set Material-Parameters and Colors
		glMaterialf(Face, GL_SHININESS, Self.Shininess)
		glMaterialfv(Face, GL_AMBIENT, Self.AmbientColor)
		glMaterialfv(Face, GL_DIFFUSE, Self.DiffuseColor)
		glMaterialfv(Face, GL_SPECULAR, Self.SpecularColor)
		glMaterialfv(Face, GL_EMISSION, Self.EmissiveColor)

		' Using Tetxures?
		If Not (Self.RenderMode & DDD_MATERIAL_TEXTURED) Then
			glClientActiveTexture(GL_TEXTURE0)
			glDisableClientState(GL_TEXTURE_COORD_ARRAY)
			glActiveTexture(GL_TEXTURE0)
			glDisable(GL_TEXTURE_2D)
			glDisable(GL_TEXTURE_CUBE_MAP)
		Else
			Local Layer:Int, Exist:Int=False
			For Layer = 0 To THardwareInfo.MaxTextures-1
				If Self.TextureList[Layer] Then
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
	End Method

	Method New()
		Self.Name            = "Unnamed Material"
		Self.VertexProgram   = Null
		Self.FragmentProgram = Null
		Self.Shader          = Null
		Self.TextureList     = New TTexture[THardwareInfo.MaxTextures]
		Self.BlendMode       = DDD_MATERIAL_ALPHABLEND
		Self.RenderMode      = DDD_MATERIAL_WIRE ..
		                       | DDD_MATERIAL_GOURAUD ..
		                       | DDD_MATERIAL_FILL ..
		                       | DDD_MATERIAL_CULLBF ..
		                       | DDD_MATERIAL_TEXTURED
		Self.Shininess       = 0.0
		Self.AmbientColor    = [0.2, 0.2, 0.2, 1.0]
		Self.DiffuseColor    = [0.8, 0.8, 0.8, 1.0]
		Self.SpecularColor   = [0.0, 0.0, 0.0, 1.0]
		Self.EmissiveColor   = [0.0, 0.0, 0.0, 1.0]
		Self.LineWidth       = 1.0
		Self.PointSize       = 1.0

		TMaterial.List.AddLast(Self)
	End Method

	Method Remove()
		TMaterial.List.Remove(Self)
	End Method

	Function RenderDefault()
		' Backface-Culling
		glEnable(GL_CULL_FACE)

		' Standard-Material
		glMaterialf(GL_FRONT, GL_SHININESS, 0.0)
		glMaterialfv(GL_FRONT, GL_AMBIENT, [0.2, 0.2, 0.2, 1.0])
		glMaterialfv(GL_FRONT, GL_DIFFUSE, [0.8, 0.8, 0.8, 1.0])
		glMaterialfv(GL_FRONT, GL_SPECULAR, [0.0, 0.0, 0.0, 1.0])
		glMaterialfv(GL_FRONT, GL_EMISSION, [0.0, 0.0, 0.0, 1.0])

		' Normal looking Blending
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glEnable(GL_BLEND)

		' No Material -> No Texture
		glClientActiveTexture(GL_TEXTURE0)
		glDisableClientState(GL_TEXTURE_COORD_ARRAY)
		glActiveTexture(GL_TEXTURE0)
		glDisable(GL_TEXTURE_2D)
		glDisable(GL_TEXTURE_CUBE_MAP)
		
		' No Vertex- and FragmentProgram
		glDisable(GL_VERTEX_PROGRAM_ARB)
		glDisable(GL_FRAGMENT_PROGRAM_ARB)

		' No Shader
		If THardwareInfo.ShaderSupport Then glUseProgramObjectARB(Null)		
	End Function
End Type