SuperStrict

Module Vertex.DreiDe

ModuleInfo "Version: 2.62 Beta"
ModuleInfo "Author: Oliver Skawronek"
ModuleInfo "Additional Work: Mikkel Fredborg"
ModuleInfo "Thanks: Cliff 'Papa Lazarou' Harman"
ModuleInfo "Thanks: Daniel 'Eizdealer' Kallfass"
ModuleInfo "License: GNU Lesser General Public License, Version 3"

Import BRL.GLGraphics
Import Pub.Glew
Import "HardwareInfo.bmx"
Import "Entity.bmx"
Import "Light.bmx"
Import "Camera.bmx"
Import "Material.bmx"
Import "Mesh.bmx"
Import "Animation.bmx"
Import "Primitive.bmx"
Import "DDSLoader.bmx"
Import "MD3Model.bmx"
Import "Q3BSP.bmx"
Import "3DSLoader.bmx"
Import "B3DLoader.bmx"


Type TDreiDe
	Function Graphics3D:TGraphics(Width:Int, Height:Int, Depth:Int=0, Hertz:Int=60)
		Local Graphics:TGraphics

		Graphics = GLGraphics(Width, Height, Depth, Hertz)
		If Not Graphics Then Return Null
		
		GlewInit()

		' Save current Screen Resolution
		THardwareInfo.ScreenWidth  = Width
		THardwareInfo.ScreenHeight = Height
		THardwareInfo.ScreenDepth  = Depth
		THardwareInfo.ScreenHertz  = Hertz

		THardwareInfo.GetInfo()

		TEntity.List = New TList

		' Set GL-FrontFace
		glFrontFace(GL_CW)

		' Enable Vertex- And Elementarrays
		glEnableClientState(GL_VERTEX_ARRAY)
		glEnableClientState(GL_NORMAL_ARRAY)
		glEnableClientState(GL_COLOR_ARRAY)

		' Enable seperate Specularcolor
		glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SEPARATE_SPECULAR_COLOR)
		
		' Clear Window
		glClearColor(0.0, 0.0, 0.0, 1.0)
		glClear(GL_COLOR_BUFFER_BIT)
		Flip()

		Return Graphics
	End Function
	
	Function DisplayInfo()
	End Function
End Type