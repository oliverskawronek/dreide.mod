SuperStrict

Import brl.linkedlist
Import brl.stream
Import "Error.bmx"
Import "HardwareInfo.bmx"

Type TFragmentProgram
	Global List : TList

	Global MaxInstructions    : Int
	Global MaxLocalParams     : Int
	Global MaxEnvParams       : Int
	Global MaxTemporaries     : Int
	Global MaxParams          : Int
	Global MaxAttribs         : Int
	Global MaxTexInstructions : Int

	Field Name      : String
	Field ProgramID : Int
	Field Program   : String
	Field Error     : String

	Method SetName(Name:String)
		Self.Name = Name
	End Method

	Method GetName:String()
		Return Self.Name
	End Method

	Method SetProgram:Int(Program:String)
		Local Success:Int, Enum:Int

		Self.Program = Program
		If THardwareInfo.FPSupport Then
			glEnable(GL_FRAGMENT_PROGRAM_ARB)

			glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, Self.ProgramID)

			Program = Program.Replace(Chr(13), "")
			glProgramStringARB(GL_FRAGMENT_PROGRAM_ARB, GL_PROGRAM_FORMAT_ASCII_ARB, ..
			                   Program.Length, Program.ToCString())
			If glGetError() = GL_INVALID_OPERATION Then
				Enum = GL_PROGRAM_ERROR_STRING_ARB
				Self.Error = String.FromCString(Byte Ptr(glGetString(Enum)))
				Success = False
			Else
				Success = True
			EndIf

			glDisable(GL_FRAGMENT_PROGRAM_ARB)
			Return Success
		Else
			Return False
		EndIf
	End Method

	Method GetProgram:String()
		Return Self.Program
	End Method

	Method GetError:String()
		Return Self.Error
	End Method

	Method SetLocalParameter(Index:Int, X:Float, Y:Float, Z:Float, W:Float)
		If (Index => 0) And (Index <= TFragmentProgram.MaxLocalParams) Then
			glProgramLocalParameter4fARB(GL_FRAGMENT_PROGRAM_ARB, Index, X, Y, Z, W)
		Else
			TDreiDeError.DisplayError("FragmentProgram-Local-Parameter-Index out of range!")
		EndIf
	End Method

	Method Render()
		If THardwareInfo.FPSupport Then ..
		   glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, Self.ProgramID)
	End Method

	Method New()
		Self.Name = "Unnamed FragmentProgram"
		If THardwareInfo.VPSupport Then
			glGenProgramsARB(1, Varptr(Self.ProgramID))
		Else
			Self.ProgramID = -1
		EndIf
		Self.Program = ""
		Self.Error   = "" 

		TFragmentProgram.List.AddLast(Self)
	End Method

	Method Delete()
		If THardwareInfo.FPSupport Then glDeleteProgramsARB(1, Varptr(Self.ProgramID))
	End Method

	Method Remove()
		TFragmentProgram.List.Remove(Self)
	End Method

	Function SetEnvParameter(Index:Int, X:Float, Y:Float, Z:Float, W:Float)
		If (Index => 0) And (Index <= TFragmentProgram.MaxLocalParams) Then
			glProgramEnvParameter4fARB(GL_FRAGMENT_PROGRAM_ARB, Index, X, Y, Z, W)
		Else
			TDreiDeError.DisplayError("FragmentProgram-Environment-Parameter-Index out of range!")
		EndIf
	End Function

	Function GetInfo()
		If THardwareInfo.VPSupport Then
			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_INSTRUCTIONS_ARB, ..
			                  Varptr(MaxInstructions))

			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_LOCAL_PARAMETERS_ARB, ..
			                  Varptr(MaxLocalParams))

			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_ENV_PARAMETERS_ARB, ..
			                  Varptr(MaxEnvParams))

			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_TEMPORARIES_ARB, ..
			                  Varptr(MaxTemporaries))

			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_PARAMETERS_ARB, ..
			                  Varptr(MaxParams))

			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_ATTRIBS_ARB, ..
			                  Varptr(MaxAttribs))

			glGetProgramivARB(GL_FRAGMENT_PROGRAM_ARB, GL_MAX_PROGRAM_TEX_INSTRUCTIONS_ARB, ..
			                  Varptr(MaxTexInstructions))
		EndIf
	End Function
End Type