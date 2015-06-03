SuperStrict

Rem
	Use ESC to exit
End Rem

Framework brl.blitz
Import vertex.dreide

Global Shader   : TShader
Global Program  : String
Global Location : Int
Global Uniform  : TUniform
Global Material : TMaterial
Global Mesh     : TMesh
Global Camera   : TCamera
Global Time     : Float

TDreiDe.Graphics3D(800, 600, 0, 0, False)

If (Not THardwareInfo.ShaderSupport) Or ..
   (Not THardwareInfo.VSSupport) Or ..
   (Not THardwareInfo.FSSupport) Or ..
   (Not THardwareInfo.SLSupport) Then

	Notify("You need the following extensions:"+Chr(10)+ ..
	       " - GL_ARB_shader_objects"+Chr(10)+ ..
	       " - GL_ARB_vertex_shader"+Chr(10)+ ..
	       " - GL_ARB_fragment_shader"+Chr(10)+ ..
	       " - GL_ARB_shading_language_100")

	EndGraphics()
	End
EndIf

Shader = New TShader

Program = LoadProgram("media\test_vs.glsl")
If Not Shader.SetProgram(Program, DDD_SHADER_VERTEX) Then
	Notify("VertexShader:"+Chr(10)+Shader.GetError())
	EndGraphics()
	End
EndIf

Program = LoadProgram("media\test_fs.glsl")
If Not Shader.SetProgram(Program, DDD_SHADER_FRAGMENT) Then
	Notify("FragmentShader:"+Chr(10)+Shader.GetError())
	EndGraphics()
	End
EndIf

If Not Shader.Link() Then
	Notify("Linker:"+Chr(10)+Shader.GetError())
	EndGraphics()
	End
EndIf

Location = Shader.GetUniformLocation("SzeneColor")
If Location = -1 Then
	Notify("Shader:"+Chr(10)+"Uniform "+Chr(34)+"SzeneColor"+Chr(34)+" not found!")
	EndGraphics()
	End
EndIf

Uniform = New TUniform
Shader.AddUniform(Uniform)

Material = New TMaterial
Material.SetShader(Shader)

Mesh = TPrimitive.CreateQuad()
Mesh.SetMaterial(Material)

Camera = New TCamera
Camera.SetPosition(0.0, 0.0, 3.0)
Camera.SetClearColor(0.4, 0.6, 0.8)

While Not KeyDown(KEY_ESCAPE)
	Time :+ 0.1

	Uniform.SetFloat(Location, DDD_SHADER_UNIFORM4F, ..
	                 Cos(Time)*0.5+0.5, Cos(Time)*0.5+0.5, Sin(Time)*0.5+0.5, 1.0)


	Camera.Render()
	Flip()
Wend

EndGraphics()
End

Function LoadProgram:String(URL:Object)
	Local Stream:TStream, Program:String

	Stream = ReadFile(URL)
	Program = ""
	While Not Stream.Eof()
		Program :+ Stream.ReadLine()+Chr(10)
	Wend
	Stream.Close()

	Return Program
End Function