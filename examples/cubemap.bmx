SuperStrict

Rem
	Use ESC to exit
End Rem

Import vertex.dreide
Import brl.jpgloader

Global Texture  : TTexture
Global Pixmap   : TPixmap
Global Material : TMaterial

Global Mesh   : TMesh
Global Camera : TCamera

TDreiDe.Graphics3D(800, 600, 0, 0, False)

If Not THardwareInfo.CubemapSupport Then
	Notify("You need the following extension:"+Chr(10)+ ..
	       " - GL_ARB_texture_cube_map")
	EndGraphics()
	End
EndIf

Texture = New TTexture
Texture.AddRenderMode(DDD_TEXTURE_CUBEMAP | DDD_TEXTURE_MIPMAP)
Texture.SetFilter(DDD_TEXTURE_BILINEAR)

' Right-Face
Texture.SetCubeFace(DDD_TEXTURE_POSX)
Pixmap = LoadPixmap("media\cubemap\right.jpg")
Texture.SetPixmap(Pixmap)

' Left-Face
Texture.SetCubeFace(DDD_TEXTURE_NEGX)
Pixmap = LoadPixmap("media\cubemap\left.jpg")
Texture.SetPixmap(Pixmap)

' Top-Face
Texture.SetCubeFace(DDD_TEXTURE_POSY)
Pixmap = LoadPixmap("media\cubemap\top.jpg")
Texture.SetPixmap(Pixmap)

' Bottom-Face
Texture.SetCubeFace(DDD_TEXTURE_NEGY)
Pixmap = LoadPixmap("media\cubemap\bottom.jpg")
Texture.SetPixmap(Pixmap)

' Back-Face
Texture.SetCubeFace(DDD_TEXTURE_POSZ)
Pixmap = LoadPixmap("media\cubemap\back.jpg")
Texture.SetPixmap(Pixmap)

' Front-Face
Texture.SetCubeFace(DDD_TEXTURE_NEGZ)
Pixmap = LoadPixmap("media\cubemap\front.jpg")
Texture.SetPixmap(Pixmap)

Material = New TMaterial
Material.SetTexture(Texture)

Mesh = T3DSLoader.Load("media\mickey.3ds")
Mesh.SetMaterial(Material)

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 20.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

While Not KeyDown(KEY_ESCAPE)
	Mesh.Turn(0.0, 0.2, 0.0)

	Camera.Render()
	TDreiDe.UseMax2D()
	Flip()
Wend

EndGraphics()
End