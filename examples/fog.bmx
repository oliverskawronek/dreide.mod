SuperStrict

Rem
	Use UP and DOWN to move the cube
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide

Global Mesh   : TMesh
Global Camera : TCamera

TDreiDe.Graphics3D(800, 600, 0, 0, False)

Mesh = TPrimitive.CreateCube()

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 10.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

Camera.SetFogMode(DDD_CAMERA_FOGENABLE | DDD_CAMERA_FOGLINEAR)
Camera.SetFogRange(10.0, 20.0)
Camera.SetFogColor(0.4, 0.6, 0.8)

' TLight-Module comming soon
glEnable(GL_LIGHTING)
glEnable(GL_LIGHT0)

While Not KeyDown(KEY_ESCAPE)
	Mesh.Turn(0.0, 0.1, 0.1)

	If KeyDown(KEY_UP) Then Mesh.Translate(0.0, 0.0, -0.05)
	If KeyDown(KEY_DOWN) Then Mesh.Translate(0.0, 0.0, 0.05)

	Camera.Render()
	Flip()
Wend

EndGraphics()
End