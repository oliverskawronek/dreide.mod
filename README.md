# DreiDe
A 3D engine for BlitzMax based on OpenGL. Supports entity based scene handling, texturing, 3DS and MD3 loading, etc.

> **Note**: This project was started in 2005 and last updated in 2007. It is currently not under active development!

# About the branches
DreiDe was completly rewritten by starting version 2.60. The newest version 2.62 (year 2007) is managed in the **master** branch. There are many things that are not supported by the current version.

Please checkout the **2.59** branch for the older, but feature rich version. There are also many examples for this version.
You can do this by typing `git checkout 2.59`

# Installation
1. Copy vertex.mod into your `%BlitzMax%/mod` folder
2. Make sure you have setup MinGW for BlitzMax correctly. Please check this topics:
 * [Installed MingW, can no longer build project](http://www.blitzbasic.com/Community/posts.php?topic=104435)
 * [Guide how to set up MinGW for BlitzMax](http://www.blitzbasic.com/Community/posts.php?topic=90964)
3. Open the MaxIDE, goto **Program** > **Build Modules**
4. Now you can import DreiDe by writing `import vertex.dreide`

DreiDe was successfully testet with Windows 7, BlitzMax 1.50 and GCC 4.5.2.

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
Global Angle:Float = 0
While Not KeyDown(KEY_ESCAPE)
	' Turn the cube around the (1, 1, 0)-axis about
	' 0.1 degree per frame
	Angle :+ 0.1
	Cube.SetRotation(Angle, 1, 1, 0)

	Camera.Render()
	Flip()
Wend

EndGraphics()
End
```
