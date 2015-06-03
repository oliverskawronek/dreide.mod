SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide
Import brl.jpgloader

Global Pixmap        : TPixmap
Global Texture       : TTexture
Global VertexProgram : TVertexProgram
Global Material      : TMaterial
Global Mesh          : TMesh
Global Camera        : TCamera

Global Angle : Float

TDreiDe.Graphics3D(800, 600, 0, 0, False)

If Not THardwareInfo.VPSupport Then
	Notify("You need the following extension:"+Chr(10)+ ..
	       " - GL_ARB_vertex_program")

	EndGraphics()
	End
EndIf

' Load Palette
Pixmap = LoadPixmap("media\palette.jpg")
Texture = New TTexture
Texture.SetFilter(DDD_TEXTURE_BILINEAR)
Texture.SetPixmap(Pixmap)

Pixmap = Null
'FlushMem()

' Load VertexProgram
VertexProgram = New TVertexProgram
If Not VertexProgram.SetProgram(LoadProgram("media\toon.asm")) Then
	Notify("VertexProgram Error:"+Chr(10)+VertexProgram.GetError())
	EndGraphics()
	End
EndIf
VertexProgram.SetLocalParameter(0, 0.0, 0.0, 1.0, 0.0)

' Include Palette and VertexProgram into a Material
Material = New TMaterial
Material.SetTexture(Texture)
Material.SetVertexProgram(VertexProgram)

' Load Mickey
Mesh = T3DSLoader.Load("media\mickey.3ds")
Mesh.SetMaterial(Material)

' Set Camera
Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 20.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

While Not KeyDown(KEY_ESCAPE)
	Angle :+ 0.1
	VertexProgram.SetLocalParameter(0, Cos(Angle), 0.0, Sin(Angle), 0.0)

	Mesh.Turn(0.0, 0.2, 0.0)

	Camera.Render()
	Flip(True)
'	FlushMem()
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