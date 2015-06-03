# DreiDe
A 3d engine for BlitzMax based on OpenGL. Supports entity based scene handling, texturing, 3DS and MD3 loading, etc.

This project was started 2005 and last updated 2007.

# Installation
1. Copy vertex.mod into your %BlitzMax%/mod folder
2. Make sure you have setup MinGW for BlitzMax correctly. Please check this topics:
 * [Installed MingW, can no longer build project](http://www.blitzbasic.com/Community/posts.php?topic=104435)
 * [Guide how to set up MinGW for BlitzMax](http://www.blitzbasic.com/Community/posts.php?topic=90964)
3. Open the MaxIDE, goto Program > Build Modules
4. Now you can import DreiDe by writing `import vertex.dreide`
5. Test DreiDe with

	```
	SuperStrict

	Framework brl.blitz
	Import vertex.dreide

	TDreiDe.Graphics3D(800, 600)
	WaitKey()
	End
	```