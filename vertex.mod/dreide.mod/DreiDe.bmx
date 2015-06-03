SuperStrict

Module vertex.dreide

ModuleInfo "Version: 2.59"
ModuleInfo "Author: Oliver Skawronek"
ModuleInfo "Additional Work: Mikkel Fredborg"
ModuleInfo "Thanks: Cliff 'Papa Lazarou' Harman"
ModuleInfo "Thanks: Daniel 'Eizdealer' Kallfass"
ModuleInfo "License: GNU Lesser General Public License, Version 3"

Import brl.max2d
Import brl.gLMax2d
Import pub.glew
?Linux
	Import "-lX11"
	Import "-lXxf86vm"
?
Import pub.opengl

Import "HardwareInfo.bmx"
Import "SceneManager.bmx"
Import "Entity.bmx"
Import "Pivot.bmx"
Import "Camera.bmx"
Import "Mesh.bmx"
Import "Primitive.bmx"
Import "Loaders\3DSLoader.bmx"
'Import "Loaders\B3DLoader.bmx"
Import "MD3Model.bmx"
Import "Surface.bmx"
Import "Material.bmx"
Import "VertexProgram.bmx"
Import "FragmentProgram.bmx"
Import "GlSlang.bmx"
Import "Texture.bmx"
Import "Loaders\DDSLoader.bmx"

Type TDreiDe
	Function Graphics3D:Int(Width:Int, Height:Int, Depth:Int=0, Hertz:Int=60, ..
	                        Fullscreen:Int=True)

		' Create Window + RenderContext
		SetGraphicsDriver(GLMax2DDriver(), GRAPHICS_BACKBUFFER | GRAPHICS_DEPTHBUFFER)
		If Fullscreen
			Graphics(Width, Height, Depth, Hertz)
		Else
			Graphics(Width, Height, 0, Hertz)
		EndIf

		' Init OpenGL
		GlewInit()

		' Save current Screen Resolution
		THardwareInfo.ScreenWidth  = Width
		THardwareInfo.ScreenHeight = Height
		THardwareInfo.ScreenDepth  = Depth
		THardwareInfo.Fullscreen   = Fullscreen

		' Init DreiDe
		TEntity.List          = CreateList()
		TPivot.List           = CreateList()
		TCamera.List          = CreateList()
		TMesh.List            = CreateList()
		TMD3Model.List        = CreateList()
		TSurface.List         = CreateList()
		TMaterial.List        = CreateList()
		TTexture.List         = CreateList()
		TVertexProgram.List   = CreateList()
		TFragmentProgram.List = CreateList()
		TShader.List          = CreateList()

		' Get HardwareExtensions- and Limits
		THardwareInfo.GetInfo()
		TVertexProgram.GetInfo()
		TFragmentProgram.GetInfo()

		' Set GL-FrontFace
		glFrontFace(GL_CW)

		' Enable Vertex- And Elementarrays
		glEnableClientState(GL_VERTEX_ARRAY)
		glEnableClientState(GL_NORMAL_ARRAY)
		glEnableClientState(GL_COLOR_ARRAY)

		' Enable seperate Specularcolor
		glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SEPARATE_SPECULAR_COLOR)

		' Display a blank screen
		glClear(GL_COLOR_BUFFER_BIT)

		Return True
	End Function

	Function UseMax2D()
		Local X:Int, Y:Int, Width:Int, Height:Int, Layer:Int

		GetViewport(X, Y, Width, Height)

		' Disable DreiDe-Features
		glDisable(GL_LIGHTING)
		glDisable(GL_DEPTH_TEST)
		glDisable(GL_SCISSOR_TEST)
		glDisable(GL_FOG)
		glDisable(GL_CULL_FACE)

		' Set all Matrices to default
		glMatrixMode(GL_TEXTURE)
		glLoadIdentity()

		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()

		' OrthogonalRendering for Max2D
		glOrtho(0, GraphicsWidth(), GraphicsHeight(), 0, -1.0, 1.0)

		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()

		SetViewport(X, Y, Width, Height)

		' Clear Textures		
		For Layer = 0 To THardwareInfo.MaxTextures-1
			glActiveTexture(GL_TEXTURE0+Layer)

			glDisable(GL_TEXTURE_CUBE_MAP)
			glDisable(GL_TEXTURE_GEN_S)
			glDisable(GL_TEXTURE_GEN_T)
			glDisable(GL_TEXTURE_GEN_R)

			glDisable(GL_TEXTURE_2D)
		Next

		' Activate Texture-Layer 0
		glActiveTexture(GL_TEXTURE0)

		' To reset states!
		DrawRect(-10, -10, 5, 5)
	EndFunction

	Function DisplayStatus()
		Print "DreiDe Statusinfo:"
		Print ""

		' Display Screeninfo
		Print "Screeninfo: "
		Print " - Screen-Width:  "+THardwareInfo.ScreenWidth
		Print " - Screen-Height: "+THardwareInfo.ScreenHeight
		Print " - Screen-Depth:  "+THardwareInfo.ScreenDepth
		Print " - Fullscreen:    "+THardwareInfo.Fullscreen
		Print ""

		' Display Number of Objects
		Print "Number of objects:"
		Print " - Entitys:          "+TEntity.List.Count()
		Print "  - Pivots:          "+TPivot.List.Count()
		Print "  - Cameras:         "+TCamera.List.Count()
		Print "  - Meshs:           "+TMesh.List.Count()
		Print "   - MD3-Models:     "+TMD3Model.List.Count()
		Print " - Surfaces:         "+TSurface.List.Count()
		Print " - Materials:        "+TMaterial.List.Count()
		Print " - Textures:         "+TTexture.List.Count()
		Print " - VertexPrograms:   "+TVertexProgram.List.Count()
		Print " - FragmentPrograms: "+TFragmentProgram.List.Count()
		Print " - Shaders:          "+TShader.List.Count()

		Print ""
		Print "- Ready -"
	End Function
End Type