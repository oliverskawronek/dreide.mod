SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide
Import brl.jpgLoader

Global Mesh   : TMesh
Global Camera : TCamera

TDreiDe.Graphics3D(800, 600, 0, 0, False)

Mesh = T3DSLoader.Load("media\dreezle\dreezle.3ds")

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 30.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

' TLight-Module comming soon
glEnable(GL_LIGHTING)
glEnable(GL_LIGHT0)

While Not KeyDown(KEY_ESCAPE)
	Mesh.Turn(0.0, 0.2, 0.0)

	Camera.Render()
	Flip()
Wend

EndGraphics()
End