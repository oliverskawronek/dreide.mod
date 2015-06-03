SuperStrict

Rem	
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide
Import brl.jpgloader

Global Pixmap        : TPixmap
Global NormalMap     : TTexture
Global Texture       : TTexture
Global VertexProgram : TVertexProgram
Global Material      : TMaterial
Global Mesh          : TMesh
Global Camera        : TCamera

Global Angle : Float

TDreiDe.Graphics3D(800, 600, 0, 0, False)

If (Not THardwareInfo.MultiTexSupport) Or ..
   (Not THardwareInfo.TexBlendSupport) Or ..
   (Not THardwareInfo.VPSupport) Then

	Notify("You need the following extensions:"+Chr(10)+ ..
	       " - GL_ARB_multitexture"+Chr(10)+ ..
	       " - GL_EXT_texture_env_combine"+Chr(10)+ ..
	       " - GL_ARB_vertex_program")

	EndGraphics()
	End
EndIf

' Load NormalMap
Pixmap = LoadPixmap("media\head\normalmap.jpg")
NormalMap = New TTexture
NormalMap.SetFilter(DDD_TEXTURE_BILINEAR)
NormalMap.SetBlendMode(DDD_TEXTURE_DOT3)
NormalMap.SetPixmap(Pixmap)

' Load Texture
Pixmap = LoadPixmap("media\head\texture.jpg")
Texture = New TTexture
Texture.SetFilter(DDD_TEXTURE_BILINEAR)
Texture.SetBlendMode(DDD_TEXTURE_MODULATE2X)
Texture.SetPixmap(Pixmap)

Pixmap = Null

' Load VertexProgram
VertexProgram = New TVertexProgram
If Not VertexProgram.SetProgram(LoadProgram("media\bump.asm")) Then
	Notify("VertexProgram Error:"+Chr(10)+VertexProgram.GetError())
	EndGraphics()
	End
EndIf

' Include Palette and VertexProgram into a Material
Material = New TMaterial
Material.SetTexture(NormalMap, 0)
Material.SetTexture(Texture, 1)
Material.SetVertexProgram(VertexProgram)

' Load Mickey
Mesh = T3DSLoader.Load("media\head\head.3ds")
Mesh.SetMaterial(Material)

' Set Camera
Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 30.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

While Not KeyDown(KEY_ESCAPE)
	Angle :+ 0.1

	' Set LightPosition
	VertexProgram.SetLocalParameter(0, Cos(Angle)*40.0, 0.0, Sin(Angle)*40.0, 0.0)

	Camera.Render()
	Flip()
Wend

EndGraphics()
End

Function LoadProgram:String(URL:Object)
	Local Stream:TStream, Program:String

	Stream = ReadFile(URL)
	Program = ""
	While Not Stream.Eof()
		Program :+ Stream.ReadLine()+Chr(10)
	Wend
	Stream.Close()

	Return Program
End Function