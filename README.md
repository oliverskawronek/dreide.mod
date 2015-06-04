# DreiDe
A 3D engine for BlitzMax based on OpenGL. Supports entity based scene handling, texturing, 3DS and MD3 loading, etc.

> **Note**: This project was started 2005 and last updated 2007.

# Installation
1. Copy vertex.mod into your `%BlitzMax%/mod` folder
2. Make sure you have setup MinGW for BlitzMax correctly. Please check this topics:
 * [Installed MingW, can no longer build project](http://www.blitzbasic.com/Community/posts.php?topic=104435)
 * [Guide how to set up MinGW for BlitzMax](http://www.blitzbasic.com/Community/posts.php?topic=90964)
3. Open the MaxIDE, goto **Program** > **Build Modules**
4. Now you can import DreiDe by writing `import vertex.dreide`

# Example
A simple example that renders a rotating cube:

```
SuperStrict

Framework brl.blitz
Import vertex.dreide

TDreiDe.Graphics3D(800, 600)

Global Camera:TCamera = New TCamera
' Position the camera behind the cube
Camera.SetPosition(0, 0, 5)

Global Cube:TMesh = TPrimitive.CreateCube()

' There is no support for lighting, so we have to
' turn the lights manually on
glEnable(GL_LIGHTING)
glEnable(GL_LIGHT0)

' Press ESC to exit
While Not KeyDown(KEY_ESCAPE)
	' Turn the cube around the y- and z-axis about
	' 0.1 degree per frame
	Cube.Turn(0.0, 0.1, 0.1)

	Camera.Render()
	Flip()
Wend

EndGraphics()
End
```
