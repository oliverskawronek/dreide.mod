SuperStrict

Import brl.linkedlist
Import brl.stream
Import "Error.bmx"
Import "HardwareInfo.bmx"

' Targets
Const DDD_SHADER_VERTEX   : Int = 1
Const DDD_SHADER_FRAGMENT : Int = 2

' Uniform Formats
Const DDD_SHADER_UNIFORM1F : Int = $11
Const DDD_SHADER_UNIFORM2F : Int = $12
Const DDD_SHADER_UNIFORM3F : Int = $13
Const DDD_SHADER_UNIFORM4F : Int = $14

Const DDD_SHADER_UNIFORM1I : Int = $21
Const DDD_SHADER_UNIFORM2I : Int = $22
Const DDD_SHADER_UNIFORM3I : Int = $23
Const DDD_SHADER_UNIFORM4I : Int = $24

Const DDD_SHADER_UNIFORM2X2F : Int = $31
Const DDD_SHADER_UNIFORM3X3F : Int = $32
Const DDD_SHADER_UNIFORM4X4F : Int = $33

Type TShader
	Global List : TList

	Field Name            : String
	Field ProgramObject   : Int
	Field VertexShader    : Int
	Field FragmentShader  : Int
	Field VertexProgram   : String
	Field FragmentProgram : String
	Field Uniforms        : TList
	Field Error           : String

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetProgram:Int(Program:String, Target:Int)
		Local ShaderObject:Int, ProgramPtr:Byte Ptr[1], Length:Int
		Local Status:Int

		If Self.ProgramObject = -1 Then Return False

		Select Target
			Case DDD_SHADER_VERTEX
				If Not THardwareInfo.VSSupport Then Return False

				If Program = "" Then
					If Self.VertexShader <> -1 Then
						' Delete VertexShader
						glDetachObjectARB(Self.ProgramObject, Self.VertexShader)
						Self.VertexShader = -1
						Self.VertexProgram = ""						Return True
					EndIf
				Else
					If Self.VertexShader <> -1 Then
						' Delete actually VertexShader, create new VertexShader
						glDetachObjectARB(Self.ProgramObject, Self.VertexShader)
						Self.VertexShader = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB)
					Else
						' Create VertexShader
						Self.VertexShader = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB)
					EndIf
					Self.VertexProgram = Program
					ShaderObject = Self.VertexShader
				EndIf

			Case DDD_SHADER_FRAGMENT
				If Not THardwareInfo.FSSupport Then Return False

				If Program = "" Then
					If Self.FragmentShader <> -1 Then
						' Delete FragmentShader
						glDetachObjectARB(Self.ProgramObject, Self.FragmentShader)
						Self.FragmentShader = -1
						Self.FragmentProgram = ""
						Return True
					EndIf
				Else
					If Self.FragmentShader <> -1 Then
						' Delete actually FragmentShader create new FragmentShader
						glDetachObjectARB(Self.ProgramObject, Self.FragmentShader)
						Self.FragmentShader = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB)
					Else
						' Create FragmentShader
						Self.FragmentShader = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB)
					EndIf
					Self.FragmentProgram = Program
					ShaderObject = Self.FragmentShader
				EndIf

			Default
				TDreiDeError.DisplayError("Target is not supported!")
		End Select

		' Set Shader ProgramCode
		ProgramPtr[0] = Program.ToCString()
		Length = Program.Length
		glShaderSourceARB(ShaderObject, 1, ProgramPtr, Varptr(Length))

		' Compile ProgramCode
		glCompileShaderARB(ShaderObject)
		glGetObjectParameterivARB(ShaderObject, GL_OBJECT_COMPILE_STATUS_ARB, Varptr(Status))

		If Status = 0 Then
			' SyntaxError
			Self.Error = TShader.GetInfoLog(ShaderObject)
			glDeleteObjectARB(ShaderObject)
			If Target = DDD_SHADER_VERTEX Then
				Self.VertexShader = -1
			Else
				Self.FragmentShader = -1
			EndIf

			Return False
		Else
			' Attach Shader to ProgramObject
			glAttachObjectARB(Self.ProgramObject, ShaderObject)
			glDeleteObjectARB(ShaderObject)

			Return True
		EndIf
	End Method

	Method GetProgram:String(Target:Int)
		Select Target
			Case DDD_SHADER_VERTEX
				Return Self.VertexProgram

			Case DDD_SHADER_FRAGMENT
				Return Self.FragmentProgram

			Default
				TDreiDeError.DisplayError("Target is not supported!")
		End Select
	End Method

	Method Link:Int()
		Local Status:Int

		If Not THardwareInfo.SLSupport Then Return False

		' Link ProgramObject
		glLinkProgramARB(Self.ProgramObject)
		glGetObjectParameterivARB(Self.ProgramObject, GL_OBJECT_LINK_STATUS_ARB, Varptr(Status))

		If Status = 0 Then
			' Get LinkError
			Self.Error = TShader.GetInfoLog(Self.ProgramObject)
			Return False
		Else
			Return True
		EndIf
	End Method

	Method GetError:String()
		Return Self.Error
	End Method

	Method GetUniformLocation:Int(Name:String)
		If THardwareInfo.ShaderSupport Then
			Return glGetUniformLocation(Self.ProgramObject, Name.ToCString())
		Else
			Return -1
		EndIf
	End Method

	Method AddUniform(Uniform:TUniform)
		If Uniform = Null Then
			TDreiDeError.DisplayError("Uniform does not exist!")
		Else
			Self.Uniforms.AddLast(Uniform)
		EndIf
	End Method

	Method RemoveUniform(Uniform:TUniform)
		If Uniform = Null Then
			TDreiDeError.DisplayError("Uniform does not exist!")
		Else
			Self.Uniforms.Remove(Uniform)
		EndIf
	End Method

	Method Render()
		Local Uniform:TUniform

		If THardwareInfo.ShaderSupport Then glUseProgramObjectARB(Self.ProgramObject)

		For Uniform = EachIn Self.Uniforms
			Select Uniform.Format
				Case DDD_SHADER_UNIFORM1F
					glUniform1fARB(Uniform.Location, Uniform.FloatParameter[0])

				Case DDD_SHADER_UNIFORM2F
					glUniform2fARB(Uniform.Location, Uniform.FloatParameter[0], ..
					                                 Uniform.FloatParameter[1])

				Case DDD_SHADER_UNIFORM3F
					glUniform3fARB(Uniform.Location, Uniform.FloatParameter[0], ..
					                                 Uniform.FloatParameter[1], .. 
					                                 Uniform.FloatParameter[2])

				Case DDD_SHADER_UNIFORM4F
					glUniform4fARB(Uniform.Location, Uniform.FloatParameter[0], ..
					                                 Uniform.FloatParameter[1], .. 
					                                 Uniform.FloatParameter[2], ..
					                                 Uniform.FloatParameter[3])

				Case DDD_SHADER_UNIFORM1I
					glUniform1iARB(Uniform.Location, Uniform.IntParameter[0])

				Case DDD_SHADER_UNIFORM2I
					glUniform2iARB(Uniform.Location, Uniform.IntParameter[0], ..
					                                 Uniform.IntParameter[1])

				Case DDD_SHADER_UNIFORM3I
					glUniform3iARB(Uniform.Location, Uniform.IntParameter[0], ..
					                                 Uniform.IntParameter[1], .. 
					                                 Uniform.IntParameter[2])

				Case DDD_SHADER_UNIFORM4I
					glUniform4iARB(Uniform.Location, Uniform.IntParameter[0], ..
					                                 Uniform.IntParameter[1], .. 
					                                 Uniform.IntParameter[2], ..
					                                 Uniform.IntParameter[3])

				Case DDD_SHADER_UNIFORM2X2F
					glUniformMatrix2fvARB(Uniform.Location, 4, Uniform.Transpose, ..
					                      Uniform.Matrix2X2)

				Case DDD_SHADER_UNIFORM3X3F
					glUniformMatrix3fvARB(Uniform.Location, 9, Uniform.Transpose, ..
					                      Uniform.Matrix3X3)

				Case DDD_SHADER_UNIFORM4X4F
					glUniformMatrix4fvARB(Uniform.Location, 16, Uniform.Transpose, ..
					                      Uniform.Matrix4X4)
			End Select
		Next
	End Method

	Method New()
		Self.Name = "Unnamend Shader"
		If THardwareInfo.ShaderSupport Then
			Self.ProgramObject = glCreateProgramObjectARB()
		Else
			Self.ProgramObject = -1
		EndIf
		Self.VertexShader    = -1
		Self.FragmentShader  = -1
		Self.VertexProgram   = ""
		Self.FragmentProgram = ""
		Self.Uniforms        = CreateList()
		Self.Error           = ""

		TShader.List.AddLast(Self)
	End Method

	Method Delete()
		If THardwareInfo.ShaderSupport Then glDeleteObjectARB(Self.ProgramObject)
	End Method

	Method Remove()
		TShader.List.Remove(Self)
	End Method

	Function GetInfoLog:String(Obj:Int)
		Local Length:Int, InfoLog:Byte[], CharsWritten:Int

		glGetObjectParameterivARB(Obj, GL_OBJECT_INFO_LOG_LENGTH_ARB, Varptr(Length))
		If Length > 1 Then
			InfoLog = New Byte[Length]
			glGetInfoLogARB(Obj, Length, Varptr(CharsWritten), InfoLog)
			Return String.FromCString(InfoLog)
		Else
			Return ""
		EndIf
	End Function
End Type

Type TUniform
	Field Format         : Int
	Field Location       : Int         ' Just use MyShader.GetUniformLocation("MyUniform")
	Field FloatParameter : Float[4]    ' DDD_SHADER_UNIFORMNF (0 < N < 5)
	Field IntParameter   : Int[4]      ' DDD_SHADER_UNIFORMNI (0 < N < 5)
	Field Matrix2x2      : Float[2, 2] ' DDD_SHADER_UNIFORM2X2F
	Field Matrix3X3      : Float[3, 3] ' DDD_SHADER_UNIFORM3X3F
	Field Matrix4X4      : Float[4, 4] ' DDD_SHADER_UNIFORM4X4F
	Field Transpose      : Int         ' For matrices only!

	Method SetFloat(Location:Int, Format:Int, X:Float, Y:Float=0.0, Z:Float=0.0, W:Float=0.0)
		Self.Location = Location
		Select Format
			Case DDD_SHADER_UNIFORM1F
				Self.FloatParameter[0] = X

			Case DDD_SHADER_UNIFORM2F
				Self.FloatParameter[0] = X
				Self.FloatParameter[1] = Y

			Case DDD_SHADER_UNIFORM3F
				Self.FloatParameter[0] = X
				Self.FloatParameter[1] = Y
				Self.FloatParameter[2] = Z

			Case DDD_SHADER_UNIFORM4F
				Self.FloatParameter[0] = X
				Self.FloatParameter[1] = Y
				Self.FloatParameter[2] = Z
				Self.FloatParameter[3] = W

			Default
				TDreiDeError.DisplayError("UniformFormat is not supported!")
		End Select
		Self.Format = Format
	End Method

	Method SetInt(Location:Int, Format:Int, X:Int, Y:Int=0, Z:Int=0, W:Int=0)
		Self.Location = Location
		Select Format
			Case DDD_SHADER_UNIFORM1I
				Self.IntParameter[0] = X

			Case DDD_SHADER_UNIFORM2I
				Self.IntParameter[0] = X
				Self.IntParameter[1] = Y

			Case DDD_SHADER_UNIFORM3I
				Self.IntParameter[0] = X
				Self.IntParameter[1] = Y
				Self.IntParameter[2] = Z

			Case DDD_SHADER_UNIFORM4I
				Self.IntParameter[0] = X
				Self.IntParameter[1] = Y
				Self.IntParameter[2] = Z
				Self.IntParameter[3] = W

			Default
				TDreiDeError.DisplayError("UniformFormat is not supported!")
		End Select
		Self.Format = Format
	End Method

	Method SetMatrix2x2(Location:Int, Matrix:Float[,], Transpose:Int=True)
		Self.Location  = Location
		Self.Matrix2x2 = Matrix
		Self.Format    = DDD_SHADER_UNIFORM2X2F
		Self.Transpose = Transpose
	End Method

	Method SetMatrix3x3(Location:Int, Matrix:Float[,], Transpose:Int=True)
		Self.Location  = Location
		Self.Matrix3x3 = Matrix
		Self.Format    = DDD_SHADER_UNIFORM3X3F
		Self.Transpose = Transpose
	End Method

	Method SetMatrix4x4(Location:Int, Matrix:Float[,], Transpose:Int=True)
		Self.Location  = Location
		Self.Matrix4x4 = Matrix
		Self.Format    = DDD_SHADER_UNIFORM4X4F
		Self.Transpose = Transpose
	End Method

	Method New()
		Self.Location       = 0
		Self.Format         = DDD_SHADER_UNIFORM4F
		Self.FloatParameter = [0.0, 0.0, 0.0, 0.0]
		Self.IntParameter   = [0, 0, 0, 0]
		Self.Matrix2x2      = Null
		Self.Matrix3x3      = Null
		Self.Matrix4x4      = Null
		Self.Transpose      = True
	End Method
End Type