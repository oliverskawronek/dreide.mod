# DreiDe
A 3D engine for BlitzMax based on OpenGL.

**Highlights:**
* Entity system with parent child relations
* Shaders: OpenGL Shading Language 1.00, glSlang Shaders
* Material:
 * Wire frame or points
 * Flat or gouraud shading
 * Blend modes: alpha, multiply, add
 * Material colors: ambient, diffuse, specular, emmisive
* Bump Mapping (see example)
* Toon Shading (see example)
* Multitexturing
* Predefined primitives: quad, disc, cube, cone, cylinder, sphere
* Supported mesh filetypes:
 * 3D Studio *.3ds
 * Blitz3D *.b3d (experimental)
* Additional texture format:
 * DirectDraw Surface *.dds

> **Note**: This project was started in 2005 and last updated in 2007. It is currently not under active development!

# About the branches
DreiDe was completly rewritten by starting version 2.60. The newest version 2.62 (year 2007) is managed in the **master** branch. There are many things that are not supported by the current version.

Please checkout the **2.59** branch for the older, but feature rich version. There are also many examples for this version.
You can do this by typing `git checkout 2.59`

# Installation
1. Copy **vertex.mod** into your `%BlitzMax%/mod` folder
2. Make sure you have setup MinGW for BlitzMax correctly. Please check this topics:
 * [Guide how to set up MinGW for BlitzMax](http://www.blitzbasic.com/Community/posts.php?topic=90964)
 * [Installed MingW, can no longer build project](http://www.blitzbasic.com/Community/posts.php?topic=104435)
3. Open the MaxIDE, goto **Program** > **Build Modules**
4. Now you can import DreiDe by writing `import vertex.dreide`

DreiDe was successfully testet with Windows 7, BlitzMax 1.50 and GCC 4.5.2.

# Screenshots
**Toon Shading**
![Toon Shading](https://cloud.githubusercontent.com/assets/10528519/8034685/58a592d6-0dea-11e5-922a-37d6f97a99c2.png "Screenshot Toon Shading")

**Cube Mapping**
![Cube Mapping](https://cloud.githubusercontent.com/assets/10528519/8034687/58aa993e-0dea-11e5-9bb9-100c753cf805.png "Screenshot Cube Mapping")

**Bumpmapping**
![Bumpmapping](https://cloud.githubusercontent.com/assets/10528519/8034686/58aa5f14-0dea-11e5-822c-1bd1b99f41d1.png "Screenshot Bumpmapping")

**Custom Shaders**
![Custom Shader](https://cloud.githubusercontent.com/assets/10528519/8034688/58ab87d6-0dea-11e5-977a-9c23c471b428.png "Screenshot Water Shader")

# Example
A simple example that renders a rotating cube:

```blitzmax
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
