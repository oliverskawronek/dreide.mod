SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide
Import brl.jpgLoader

Global Pixmap          : TPixmap
Global BumpMap         : TTexture
Global Texture         : TTexture
Global FragmentProgram : TFragmentProgram
Global Material        : TMaterial

Global Mesh   : TMesh
Global Camera : TCamera

Global Time : Float

TDreiDe.Graphics3D(800, 600, 0, 0, False)

If Not THardwareInfo.FPSupport Then
	Notify("You need the following extension:"+Chr(10)+ ..
	       " - GL_ARB_fragment_program")

	EndGraphics()
	End
EndIf

FragmentProgram = New TFragmentProgram
If Not FragmentProgram.SetProgram(LoadProgram("media\water.asm")) Then
	Notify("FragmentProgram Error:"+Chr(10)+FragmentProgram.GetError())
	EndGraphics()
	End
EndIf

Pixmap = LoadPixmap("media\waterbump.jpg")
BumpMap = New TTexture
BumpMap.SetFilter(DDD_TEXTURE_BILINEAR)
BumpMap.SetPixmap(Pixmap)

Pixmap = LoadPixmap("media\water.jpg")
Texture = New TTexture
Texture.SetFilter(DDD_TEXTURE_BILINEAR)
Texture.SetPixmap(Pixmap)

Material = New TMaterial
Material.SetTexture(Texture, 0)
Material.SetTexture(BumpMap, 1)
Material.SetTexture(BumpMap, 2)
Material.SetFragmentProgram(FragmentProgram)

Mesh = TPrimitive.CreateQuad()
Mesh.ScaleVertices(10.0, 10.0, 1.0)
Mesh.SetMaterial(Material)

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 4.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

While Not KeyDown(KEY_ESCAPE)
	Time :+ 0.0003
	FragmentProgram.SetLocalParameter(0, Time, Time*3.0, 0.0, 0.0)

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