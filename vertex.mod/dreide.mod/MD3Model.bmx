SuperStrict

Import BRL.EndianStream
Import "Mesh.bmx"

' MD3 Header Constants
Const DDD_MD3_MAGIC   : Int = $33504449, .. ' "IDP3"
      DDD_MD3_VERSION : Int = 15

' MD3 Limits
Const DDD_MD3_MAXTRIANGLES : Int = 8192, ..  ' Per Surface
      DDD_MD3_MAXVERTICES  : Int = 4096, ..  ' Per Surface
      DDD_MD3_MAXSHADERS   : Int =  256 , .. ' Per Surface
      DDD_MD3_MAXFRAMES    : Int = 1024, ..  ' Per Model
      DDD_MD3_MAXSURFACES  : Int =   32, ..  ' Per Model
      DDD_MD3_MAXTAGS      : Int =   16      ' Per Frame

Type TMD3Header
	Field Ident          : Int    ' "IDP3"
	Field Version        : Int    ' 15
	Field Name           : String
	Field Flags          : Int
	Field NumFrames      : Int
	Field NumTags        : Int
	Field NumSurfaces    : Int
	Field NumSkins       : Int
	Field OffsetFrames   : Int
	Field OffsetTags     : Int
	Field OffsetSurfaces : Int
	Field OffsetEnd      : Int    ' = FileSize

	Method Read(Stream:TStream)
		Self.Ident          = Stream.ReadInt()
		Self.Version        = Stream.ReadInt()
		Self.Name           = Stream.ReadString(64)
		Self.Flags          = Stream.ReadInt()
		Self.NumFrames      = Stream.ReadInt()
		Self.NumTags        = Stream.ReadInt()
		Self.NumSurfaces    = Stream.ReadInt()
		Self.NumSkins       = Stream.ReadInt()
		Self.OffsetFrames   = Stream.ReadInt()
		Self.OffsetTags     = Stream.ReadInt()
		Self.OffsetSurfaces = Stream.ReadInt()
		Self.OffsetEnd      = Stream.ReadInt()

		If Self.Name.Find(Chr(0)) <> -1 Then ..
		   Self.Name = Self.Name[0..Self.Name.Find(Chr(0))]
	End Method

	Method Check:Int()
		If (Self.Ident <> DDD_MD3_MAGIC) Or ..
		   (Self.Version <> DDD_MD3_VERSION) Or ..
		   (Self.NumFrames > DDD_MD3_MAXFRAMES) Or ..
		   (Self.NumSurfaces > DDD_MD3_MAXSURFACES) Or ..
		   (Self.NumTags > DDD_MD3_MAXTAGS) Then
			Return False
		Else
			Return True
		EndIf
	End Method
End Type

Type TMD3Surface
	Field Ident           : Int    ' "IDP3"
	Field Name            : String
	Field Flags           : Int    ' Unknown
	Field NumFrames       : Int
	Field NumShaders      : Int
	Field NumVertices     : Int 
	Field NumTriangles    : Int
	Field OffsetTriangles : Int
	Field OffsetShaders   : Int    ' Offset from start of the Surface
	Field OffsetTexCoords : Int    ' Texturecoords for all Frames
	Field OffsetVertices  : Int    ' NumVertices*NumFrames
	Field OffsetEnd       : Int    ' Offset of next Surface

	Method Read(Stream:TStream)
		Self.Ident           = Stream.ReadInt()
		Self.Name            = Stream.ReadString(64)
		Self.Flags           = Stream.ReadInt()
		Self.NumFrames       = Stream.ReadInt()
		Self.NumShaders      = Stream.ReadInt()
		Self.NumVertices     = Stream.ReadInt()
		Self.NumTriangles    = Stream.ReadInt()
		Self.OffsetTriangles = Stream.ReadInt()
		Self.OffsetShaders   = Stream.ReadInt()
		Self.OffsetTexCoords = Stream.ReadInt()
		Self.OffsetVertices  = Stream.ReadInt()
		Self.OffsetEnd       = Stream.ReadInt()

		If Self.Name.Find(Chr(0)) <> -1 Then ..
		   Self.Name = Self.Name[0..Self.Name.Find(Chr(0))]
	End Method

	Method Check:Int()
		If (Self.Ident <> DDD_MD3_MAGIC) Or ..
		   (Self.NumTriangles > DDD_MD3_MAXTRIANGLES) Or ..
		   (Self.NumVertices > DDD_MD3_MAXVERTICES) Or ..
		   (Self.NumShaders > DDD_MD3_MAXSHADERS) Then

			Return False
		Else
			Return True
		EndIf
	End Method
End Type

' For DreiDe only
Type TMD3SurfaceFrame
	Field Surface : TSurface
	Field Frames  : Float[,,]
End Type

Type TMD3Model Extends TMesh
	Field FrameCount    : Int
	Field SurfaceFrames : TList

	Method CountFrames:Int()
		Return Self.FrameCount
	End Method

	Method SetFrame:Int(Frame:Float, Update:Int=True)
		Local Frame0       : Int, ..
		      Frame1       : Int, ..
		      Weight       : Float, ..
		      SurfaceFrame : TMD3SurfaceFrame, ..
		      Surface      : TSurface, ..
		      Vertex       : Int, ..
		      Position     : Float[3]

		Frame0 = Int(Floor(Frame))
		Frame1 = Int(Ceil(Frame))
		Weight = Frame-Float(Frame0)
		If (Frame0 < 0) Or (Frame1 => Self.FrameCount) Then Return False

		For SurfaceFrame = EachIn Self.SurfaceFrames
			Surface = SurfaceFrame.Surface

			For Vertex = 1 To Surface.VertexCount
				If Frame0 = Frame1 Then
					' No interpolation
					Position[0] = SurfaceFrame.Frames[Frame0, Vertex-1, 0]
					Position[1] = SurfaceFrame.Frames[Frame0, Vertex-1, 1]
					Position[2] = SurfaceFrame.Frames[Frame0, Vertex-1, 2]
				Else
					' Linear Interpolation
					Position[0] = SurfaceFrame.Frames[Frame0, Vertex-1, 0]*(1.0-Weight)+ ..
					              SurfaceFrame.Frames[Frame1, Vertex-1, 0]*Weight

					Position[1] = SurfaceFrame.Frames[Frame0, Vertex-1, 1]*(1.0-Weight)+ ..
					              SurfaceFrame.Frames[Frame1, Vertex-1, 1]*Weight

					Position[2] = SurfaceFrame.Frames[Frame0, Vertex-1, 2]*(1.0-Weight)+ ..
					              SurfaceFrame.Frames[Frame1, Vertex-1, 2]*Weight
				EndIf

				Surface.SetVertexPosition(Vertex-1, Position[0], Position[1], Position[2])
			Next

			If Update Then Surface.UpdateVertices(True, False, False, False, False, False)
		Next

		Return True
	End Method

	Method New()
		Self.Class = DDD_ENTITY_MD3
		Self.Name  = "Unnamed MD3 Model"

		Self.FrameCount    = 0
		Self.SurfaceFrames = CreateList()
	End Method

	Method Remove()
		TMD3Model.List.Remove(Self)
		TMesh.List.Remove(Self)
		TEntity.List.Remove(Self)
	End Method

	Function Load:TMD3Model(URL:Object, Skin:Object=Null)
		Local Stream       : TStream, ..
		      Header       : TMD3Header, ..
		      MD3Surface   : TMD3Surface, ..
		      SurfaceFrame : TMD3SurfaceFrame, ..
		      Index        : Int, ..
		      Model        : TMD3Model, ..
		      Surface      : TSurface, ..
		      Offset       : Int, ..
		      Vertex       : Int, ..
		      Triangle     : Int, ..
		      TexCoords    : Float[2], ..
		      Indices      : Int[3], ..
		      NormalIndex  : Byte[2], ..
		      Alpha        : Float, ..
		      Beta         : Float, ..
		      Normal       : Float[3], ..
		      Frame        : Int

		Stream = LittleEndianStream(ReadStream(URL))
		If Not Stream Then Return Null

		Header = New TMD3Header
		Header.Read(Stream)

		' Check Header
		If Not Header.Check() Then
			Stream.Close()
			Return Null
		EndIf

		' Create MD3 Model
		Model = New TMD3Model

		If Header.Name <> "" Then Model.Name = Header.Name
		Model.FrameCount = Header.NumFrames

		' Loading MD3 Surfaces
		MD3Surface = New TMD3Surface
		Stream.Seek(Header.OffsetSurfaces)

		For Index = 1 To Header.NumSurfaces
			Offset = Stream.Pos()
			MD3Surface.Read(Stream)

			' Check MD3 Surface Header
			If Not MD3Surface.Check() Then
				Stream.Close()
				Model.Remove()
				Return Null
			EndIf

			' Create Surface
			Surface = Model.CreateSurface()
			SurfaceFrame = New TMD3SurfaceFrame
			SurfaceFrame.Surface = Surface
			SurfaceFrame.Frames  = New Float[MD3Surface.NumFrames, ..
			                                 MD3Surface.NumVertices, 3]
			Model.SurfaceFrames.AddLast(SurfaceFrame)

			' Set Name
			If MD3Surface.Name <> "" Then Surface.Name = MD3Surface.Name

			' Read TexCoords 
			Stream.Seek(Offset+MD3Surface.OffsetTexCoords)
			For Vertex = 1 To MD3Surface.NumVertices
				TexCoords[0] = Stream.ReadFloat() ' U
				TexCoords[1] = Stream.ReadFloat() ' V

				Surface.CreateVertex(0.0, 0.0, 0.0, TexCoords[0], ..
				                                    TexCoords[1])
			Next

			' Read Triangles
			Stream.Seek(Offset+MD3Surface.OffsetTriangles)
			For Triangle = 1 To MD3Surface.NumTriangles
				Indices[0] = Stream.ReadInt() ' Vertex 0
				Indices[1] = Stream.ReadInt() ' Vertex 1
				Indices[2] = Stream.ReadInt() ' Vertex 2

				Surface.CreateTriangle(Indices[0], ..
				                       Indices[1], ..
				                       Indices[2])
			Next
			Surface.UpdateTriangles()

			' Read Vertex Normals and first Frame
			Stream.Seek(Offset+MD3Surface.OffsetVertices)
			For Vertex = 1 To MD3Surface.NumVertices
				SurfaceFrame.Frames[0, Vertex-1, 2] = Float(ReadSignedShort(Stream))/64.0
				SurfaceFrame.Frames[0, Vertex-1, 0] = Float(ReadSignedShort(Stream))/64.0
				SurfaceFrame.Frames[0, Vertex-1, 1] = Float(ReadSignedShort(Stream))/64.0	

				NormalIndex[0] = Stream.ReadByte()
				NormalIndex[1] = Stream.ReadByte()

				' Spherical NormalCoords
				Alpha = (2.0*NormalIndex[0]*Float(Pi)/255.0)*(180.0/Float(Pi))
				Beta  = (2.0*NormalIndex[1]*Float(Pi)/255.0)*(180.0/Float(Pi))

				Normal[2] = Cos(Beta)*Sin(Alpha)
				Normal[0] = Sin(Beta)*Sin(Alpha)
				Normal[1] = Cos(Alpha)

				Surface.SetVertexNormal(Vertex-1, Normal[0], ..
				                                  Normal[1], ..
				                                  Normal[2])
			Next
			Surface.UpdateVertices()

			' Read rest of Frames
			For Frame = 2 To MD3Surface.NumFrames
				For Vertex = 1 To MD3Surface.NumVertices
					SurfaceFrame.Frames[Frame-1, Vertex-1, 2] = ..
					   Float(ReadSignedShort(Stream))/64.0

					SurfaceFrame.Frames[Frame-1, Vertex-1, 0] = ..
					   Float(ReadSignedShort(Stream))/64.0

					SurfaceFrame.Frames[Frame-1, Vertex-1, 1] = ..
					   Float(ReadSignedShort(Stream))/64.0

					' Skip NormalIndex
					Stream.ReadShort()
				Next
			Next

			' Next Surface
			Stream.Seek(Offset+MD3Surface.OffsetEnd)
		Next

		Stream.Close()

		' Set Skin
		If Skin Then LoadSkin(Model, Skin)

		' Set First Frame
		Model.SetFrame(0.0)

		Return Model

		Function LoadSkin(Model:TMD3Model, URL:Object)
			Local Stream:TStream, Line:String, SurfaceName:String, SurfaceTexture:String
			Local SurfaceFrame:TMD3SurfaceFrame, Surface:TSurface
			Local Pixmap:TPixmap, Texture:TTexture, Material:TMaterial

			Stream = LittleEndianStream(ReadStream(URL))
			If Not Stream Then Return

			While Not Stream.Eof()
				Line = Stream.ReadLine().ToLower()

				' Tags don't have a Texture
				If (Line[0..4] = "tag_") Or (Line.Find(",") = -1) Then Continue

				' Parse Line
				SurfaceName = Line[0..Line.Find(",")]
				SurfaceTexture = Line[Line.Find(",")+1..Line.Length]
				SurfaceTexture = ExtractDir(RealPath(String(URL)))+"/"..
				                 +StripDir(SurfaceTexture)

				' Find Surface
				For SurfaceFrame = EachIn Model.SurfaceFrames
					Surface = SurfaceFrame.Surface
					If Surface.Name.ToLower() = SurfaceName Then
						Pixmap = LoadPixmap("littleendian::"+SurfaceTexture)
						If Not Pixmap Then Exit

						' Set Material
						Texture = New TTexture
						Texture.SetPixmap(Pixmap)
						Texture.SetFilter(DDD_TEXTURE_BILINEAR)

						Material = New TMaterial
						Material.SetTexture(Texture)

						Surface.SetMaterial(Material)
						Exit
					EndIf
				Next
			Wend
		EndFunction

		Function ReadSignedShort:Int(Stream:TStream)
			Local Value : Int

			' If the most significant Bit is set, Value is negative 
			Value = Stream.ReadShort()
			If Value & $8000 Then Value = Value-$FFFF

			Return Value
		End Function
	End Function	
End Type