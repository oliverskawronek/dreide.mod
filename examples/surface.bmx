SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide

Global Mesh    : TMesh
Global Surface : TSurface
Global Camera  : TCamera

TDreiDe.Graphics3D(800, 600, 0, 0, False)

Mesh = New TMesh
Surface = Mesh.CreateSurface()

Surface.CreateVertex( 0.0,  0.5, 0.0) ' Vertex 0
Surface.CreateVertex( 0.5, -0.5, 0.0) ' Vertex 1
Surface.CreateVertex(-0.5, -0.5, 0.0) ' Vertex 2

Surface.SetVertexColor(0, 1.0, 0.0, 0.0) ' Red
Surface.SetVertexColor(1, 0.0, 1.0, 0.0) ' Green
Surface.SetVertexColor(2, 0.0, 0.0, 1.0) ' Blue

Surface.CreateTriangle(0, 1, 2)

Surface.UpdateVertices()
Surface.UpdateTriangles()

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 2.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

While Not KeyDown(KEY_ESCAPE)
	Camera.Render()
	Flip()
Wend

EndGraphics()
End