SuperStrict

Rem
	Use LEFT and RIGHT to turn the base around the y-axis
	Use 1 and 2 to turn the base around the z-axis
	Use 3 and 4 to turn the parent around the z-axis
	Use 5 and 6 to turn the child around the z-axis
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide

Global Materials : TMaterial[3]
Global Joints    : TMesh[3]
Global Camera    : TCamera

TDreiDe.Graphics3D(800, 600, 0, 0, False)

' Base-Joint
Materials[0] = New TMaterial
Materials[0].SetDiffuseColor(1.0, 0.0, 0.0) ' Red

Joints[0] = TPrimitive.CreateCube()
Joints[0].SetMaterial(Materials[0])

' Parent-Joint
Materials[1] = New TMaterial
Materials[1].SetDiffuseColor(0.0, 1.0, 0.0) ' Green

Joints[1] = TPrimitive.CreateCube()
Joints[1].SetParent(Joints[0])
Joints[1].SetPosition(3.0, 0.0, 0.0)
Joints[1].SetMaterial(Materials[1])

' Child-Joint
Materials[2] = New TMaterial
Materials[2].SetDiffuseColor(0.0, 0.0, 1.0) ' Blue

Joints[2] = TPrimitive.CreateCube()
Joints[2].SetParent(Joints[1])
Joints[2].SetPosition(3.0, 0.0, 0.0)
Joints[2].SetMaterial(Materials[2])

Camera = New TCamera
Camera.SetPosition(0.0, 2.0, 10.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

' TLight-Module comming soon
glEnable(GL_LIGHTING)
glEnable(GL_LIGHT0)

While Not KeyDown(KEY_ESCAPE)
	If KeyDown(KEY_LEFT)  Then Joints[0].Turn(0.0,  0.05, 0.0)
	If KeyDown(KEY_RIGHT) Then Joints[0].Turn(0.0, -0.05, 0.0)

	If KeyDown(KEY_1) Then Joints[0].Turn(0.0, 0.0,  0.05)
	If KeyDown(KEY_2) Then Joints[0].Turn(0.0, 0.0, -0.05)

	If KeyDown(KEY_3) Then Joints[1].Turn(0.0, 0.0,  0.05)
	If KeyDown(KEY_4) Then Joints[1].Turn(0.0, 0.0, -0.05)

	If KeyDown(KEY_5) Then Joints[2].Turn(0.0, 0.0,  0.05)
	If KeyDown(KEY_6) Then Joints[2].Turn(0.0, 0.0, -0.05)

	Camera.Render()
	Flip()
Wend

EndGraphics()
End