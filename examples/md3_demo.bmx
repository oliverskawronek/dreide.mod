SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide
Import brl.pngLoader

Global Model      : TMD3Model
Global Camera     : TCamera
Global FrameCount : Int
Global Frame      : Float

TDreiDe.Graphics3D(800, 600, 0, 0, False)

Model = TMD3Model.Load("media\alien\upper_2.md3", ..
                       "media\alien\upper_default.skin")
Model.SetPosition(0.0, -10.0, 0.0)

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 30.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

' TLight-Module comming soon
glEnable(GL_LIGHTING)
glEnable(GL_LIGHT0)

FrameCount = Model.CountFrames()

While Not KeyDown(KEY_ESCAPE)
	Frame :+ 0.03
	If Int(Ceil(Frame)) => FrameCount Then Frame = 0.0
	Model.SetFrame(Frame)

	Camera.Render()
	Flip(True)
'	FlushMem()
Wend

EndGraphics()
End