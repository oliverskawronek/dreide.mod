SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import Vertex.DreiDe
Import Brl.JPGLoader

Global Texture  : TTexture
Global Pixmap   : TPixmap
Global Material : TMaterial

Global Mesh   : TMesh
Global Camera : TCamera

TDreiDe.Graphics3D(800, 600, 0, 0, False)

Texture = New TTexture
Texture.AddRenderMode(DDD_TEXTURE_SPHEREMAP | DDD_TEXTURE_MIPMAP)
Texture.SetFilter(DDD_TEXTURE_TRILINEAR)

Pixmap = LoadPixmap("media\spheremap.jpg")
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
	Flip()
Wend

EndGraphics()
End