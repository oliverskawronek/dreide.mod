SuperStrict

Import pub.glew
?Linux
	Import "-lX11"
	Import "-lXxf86vm"
?
Import brl.standardio

Type THardwareInfo
	Global ScreenWidth  : Int
	Global ScreenHeight : Int
	Global ScreenDepth  : Int
	Global Fullscreen   : Int

	Global Vendor     : String
	Global Renderer   : String
	Global OGLVersion : String

	Global Extensions      : String
	Global VBOSupport      : Int ' Vertex Buffer Object
	Global GLTCSupport     : Int ' OpenGL's TextureCompression
	Global S3TCSupport     : Int ' S3's TextureCompression
	Global AnIsoSupport    : Int ' An-Istropic Filtering
	Global MultiTexSupport : Int ' MultiTexturing
	Global TexBlendSupport : Int ' TextureBlend
	Global CubemapSupport  : Int ' CubeMapping
	Global DepthmapSupport : Int ' DepthTexturing
	Global VPSupport       : Int ' VertexProgram (ARBvp1.0)
	Global FPSupport       : Int ' FragmentProgram (ARBfp1.0)
	Global ShaderSupport   : Int ' glSlang Shader Program
	Global VSSupport       : Int ' glSlang VertexShader
	Global FSSupport       : Int ' glSlang FragmentShader
	Global SLSupport       : Int ' OpenGL Shading Language 1.00

	Global MaxTextures : Int
	Global MaxTexSize  : Int
	Global MaxLights   : Int

	Function GetInfo()
		Local Extensions:String

		' Get HardwareInfo
		Vendor     = String.FromCString(Byte Ptr(glGetString(GL_VENDOR)))
		Renderer   = String.FromCString(Byte Ptr(glGetString(GL_RENDERER))) 
		OGLVersion = String.FromCString(Byte Ptr(glGetString(GL_VERSION)))

		' Get Extensions
		Extensions = String.FromCString(Byte Ptr(glGetString(GL_EXTENSIONS)))
		THardwareInfo.Extensions = Extensions

		' Check for Extensions
		THardwareInfo.VBOSupport      = Extensions.Find("GL_ARB_vertex_buffer_object") > -1
		THardwareInfo.GLTCSupport     = Extensions.Find("GL_ARB_texture_compression")
		THardwareInfo.S3TCSupport     = Extensions.Find("GL_EXT_texture_compression_s3tc") > -1
		THardwareInfo.AnIsoSupport    = Extensions.Find("GL_EXT_texture_filter_anisotropic")
		THardwareInfo.MultiTexSupport = Extensions.Find("GL_ARB_multitexture") > -1
		THardwareInfo.TexBlendSupport = Extensions.Find("GL_EXT_texture_env_combine") > -1
		THardwareInfo.CubemapSupport  = Extensions.Find("GL_ARB_texture_cube_map") > -1
		THardwareInfo.DepthmapSupport = Extensions.Find("GL_ARB_depth_texture") > -1
		THardwareInfo.VPSupport       = Extensions.Find("GL_ARB_vertex_program") > -1
		THardwareInfo.FPSupport       = Extensions.Find("GL_ARB_fragment_program") > -1
		THardwareInfo.ShaderSupport   = Extensions.Find("GL_ARB_shader_objects") > -1
		THardwareInfo.VSSupport       = Extensions.Find("GL_ARB_vertex_shader") > -1
		THardwareInfo.FSSupport       = Extensions.Find("GL_ARB_fragment_shader") > -1
		THardwareInfo.SLSupport       = Extensions.Find("GL_ARB_shading_language_100") > -1

		' Get some numerics
		glGetIntegerv(GL_MAX_TEXTURE_UNITS, Varptr(THardwareInfo.MaxTextures))
		glGetIntegerv(GL_MAX_TEXTURE_SIZE, Varptr(THardwareInfo.MaxTexSize))
		glGetIntegerv(GL_MAX_LIGHTS, Varptr(THardwareInfo.MaxLights))
	End Function

	Function DisplayInfo(LogFile:Int=False)
		Local Position:Int, Space:Int, Stream:TStream

		If LogFile Then
			Stream = WriteStream("DreiDeLog.txt") 
			Stream.WriteLine("DreiDe Hardwareinfo:")
			Stream.WriteLine("")

			' Display Driverinfo
			Stream.WriteLine("Vendor:         "+Vendor)
			Stream.WriteLine("Renderer:       "+Renderer)
			Stream.WriteLine("OpenGL-Version: "+OGLVersion)
			Stream.WriteLine("")

			' Display Hardwareranges
			Stream.WriteLine("Max Texture Units: "+MaxTextures)
			Stream.WriteLine("Max Texture Size:  "+MaxTexSize)
			Stream.WriteLine("Max Lights:        "+MaxLights)
			Stream.WriteLine("")

			' Display OpenGL-Extensions
			Stream.WriteLine("OpenGL Extensions:")
			While Position < Extensions.Length
				Space = Extensions.Find(" ", Position)
				If Space = -1 Then Exit
				Stream.WriteLine(Extensions[Position..Space])
				Position = Space+1
			Wend

			Stream.WriteLine("")
			Stream.WriteLine("- Ready -")
			Stream.Close()
		Else
			Print("DreiDe Hardwareinfo:")
			Print("")

			' Display Driverinfo
			Print("Vendor:         "+Vendor)
			Print("Renderer:       "+Renderer)
			Print("OpenGL-Version: "+OGLVersion)
			Print("")

			' Display Hardwareranges
			Print("Max Texture Units: "+MaxTextures)
			Print("Max Texture Size:  "+MaxTexSize)
			Print("Max Lights:        "+MaxLights)
			Print("")

			' Display OpenGL-Extensions
			Print("OpenGL Extensions:")
			While Position < Extensions.Length
				Space = Extensions.Find(" ", Position)
				If Space = -1 Then Exit
				Print(Extensions[Position..Space])
				Position = Space+1
			Wend

			Print("")
			Print("- Ready -")
		EndIf
	End Function
End Type