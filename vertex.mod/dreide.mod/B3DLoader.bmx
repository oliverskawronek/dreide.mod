SuperStrict

Import BRL.EndianStream
Import "Mesh.bmx"

' Chunks
Const DDD_B3D_BB3D : Int = $44334242, ..
      DDD_B3D_TEXS : Int  = $53584554, ..
      DDD_B3D_BRUS : Int  = $53555242, ..
      DDD_B3D_NODE : Int  = $45444F4E, ..
      DDD_B3D_VRTS : Int  = $53545256, ..
      DDD_B3D_TRIS : Int  = $53495254, ..
      DDD_B3D_MESH : Int  = $4853454D

' Texture-Flags
Const DDD_B3D_COLORMAP  : Int =     1, ..
      DDD_B3D_ALPHAMAP  : Int =     2, ..
      DDD_B3D_MASKED    : Int =     4, ..
      DDD_B3D_MIPMAP    : Int =     8, ..
      DDD_B3D_CLAMPU    : Int =    16, ..
      DDD_B3D_CLAMPV    : Int =    32, ..
      DDD_B3D_SPHEREMAP : Int =    64, ..
      DDD_B3D_CUBEMAP   : Int =   128, ..
      DDD_B3D_UVSET1    : Int = 65536

' Texture and Brush Blend-Modes
Const DDD_B3D_NOTEXTURE  : Int = 0, ..
      DDD_B3D_NOBLEND    : Int = 1, ..
      DDD_B3D_REPLACE    : Int = 1, ..
      DDD_B3D_MODULATE   : Int = 2, ..
      DDD_B3D_ADD        : Int = 3, ..
      DDD_B3D_DOT3       : Int = 4, ..
      DDD_B3D_MODULATE2X : Int = 5

' Brush FX-Modes
Const DDD_B3D_NOFX          : Int =  0, ..
      DDD_B3D_FULLBRIGHT    : Int =  1, ..
      DDD_B3D_VERTEXCOLOR   : Int =  2, ..
      DDD_B3D_FLATSHADING   : Int =  4, ..
      DDD_B3D_DISABLEFOG    : Int =  8, ..
      DDD_B3D_DISABLECULLBF : Int = 16

Type TB3DLoader
	Field Stream    : TStream
	Field ChunkID   : Int
	Field ChunkSize : Int
	Field Mesh      : TMesh
	Field Surface   : TSurface
	Field Textures  : TList
	Field Materials : TList
	Field Name      : String
	Field Position  : Float[3]
	Field Scale     : Float[3]
	Field Rotation  : Float[4]

	Method ReadChunk()
		Self.ChunkID   = Self.Stream.ReadInt()
		Self.ChunkSize = Self.Stream.ReadInt()
	End Method

	Method ScipChunk()
		Self.Stream.Seek(Self.Stream.Pos()+Self.ChunkSize)
	End Method

	Method ReadCString:String()
		Local Char:Byte, CString:String

		' Null-Terminated-String
		While Not Self.Stream.Eof()
			Char = Self.Stream.ReadByte()
			If Char = 0 Then Exit
			CString :+ Chr(Char)
		Wend

		Return CString
	End Method

	Method ReadTextures()
		Local ChunkEndPos:Int, Filename:String, Flags:Int, Blend:Int
		Local Offset:Float[2], Scale:Float[2], Rotation:Float
		Local ClampU:Int, ClampV:Int
		Local Texture:TTexture, Pixmap:TPixmap

		ChunkEndPos = Self.Stream.Pos()+Self.ChunkSize

		While Self.Stream.Pos() < ChunkEndPos
			Filename  = Self.ReadCString()
			Flags     = Self.Stream.ReadInt()
			Blend     = Self.Stream.ReadInt()
			Offset[0] = Self.Stream.ReadFloat()
			Offset[1] = Self.Stream.ReadFloat()
			Scale[0]  = Self.Stream.ReadFloat()
			Scale[1]  = Self.Stream.ReadFloat()
			Rotation  = Self.Stream.ReadFloat()

			Texture = New TTexture

			'If Flags & DDD_B3D_ALPHAMAP Then ' Alphamap!
			'If Flags & DDD_B3D_MASKED Then ' Masked!
			If Flags & DDD_B3D_MIPMAP Then Texture.AddRenderMode(DDD_TEXTURE_MIPMAP)

			If (Flags & DDD_B3D_CLAMPU) Then
				ClampU = DDD_TEXTURE_CLAMP
			Else
				ClampU = DDD_TEXTURE_REPEAT
			EndIf

			If (Flags & DDD_B3D_CLAMPV) Then
				ClampV = DDD_TEXTURE_CLAMP
			Else
				ClampV = DDD_TEXTURE_REPEAT
			EndIf

			If Flags & DDD_B3D_SPHEREMAP Then Texture.AddRenderMode(DDD_TEXTURE_SPHEREMAP)
			'If Flags & DDD_B3D_CUBEMAP Then ' Cubemap!

			If Flags & DDD_B3D_UVSET1 Then
				Texture.SetCoordSet(1)
			Else
				Texture.SetCoordSet(0)
			EndIf

			Texture.SetWrap(DDD_TEXTURE_CLAMP, DDD_TEXTURE_CLAMP)

			Pixmap = LoadPixmap("littleendian::"+Filename)
			If Pixmap Then
				Texture.SetPixmap(Pixmap)
				Texture.SetFilename(Filename)
			EndIf

			Select Flags
				Case DDD_B3D_REPLACE
					Texture.SetBlendMode(DDD_TEXTURE_REPLACE)

				Case DDD_B3D_MODULATE
					Texture.SetBlendMode(DDD_TEXTURE_MODULATE)

				Case DDD_B3D_ADD
					Texture.SetBlendMode(DDD_TEXTURE_ADD)

				Case DDD_B3D_DOT3
					Texture.SetBlendMode(DDD_TEXTURE_DOT3)

				Case DDD_B3D_MODULATE2X
					Texture.SetBlendMode(DDD_TEXTURE_MODULATE2X)
			End Select

			Texture.SetPosition(Offset[0], Offset[1])
			Texture.SetScale(Scale[0], Scale[1])
			Texture.SetRotation(Rotation)

			Self.Textures.AddLast(Texture)
		Wend
	End Method

	Method ReadBrushs()
		Local ChunkEndPos:Int, TexCount:Int, Material:TMaterial
		Local Name:String, Color:Float[4]
		Local Shininess:Float, Blend:Int, FX:Int
		Local Index:Int, TexIndex:Int, Texture:TTexture

		ChunkEndPos = Self.Stream.Pos()+Self.ChunkSize

		TexCount = Self.Stream.ReadInt()
		While Self.Stream.Pos() < ChunkEndPos
			Material = New TMaterial
			Material.SetName(Self.ReadCString())
			Material.SetDiffuseColor(Self.Stream.ReadFloat(), ..
			                         Self.Stream.ReadFloat(), ..
			                         Self.Stream.ReadFloat())
			Material.SetAlpha(Self.Stream.ReadFloat())
			Material.SetShininess(Self.Stream.ReadFloat())

			Blend = Self.Stream.ReadInt()
			Select Blend
				Case DDD_B3D_NOBLEND
					Material.SetBlendMode(DDD_MATERIAL_NOBLEND)

				Case DDD_B3D_MODULATE
					Material.SetBlendMode(DDD_MATERIAL_MULTBLEND)

				Case DDD_B3D_ADD
					Material.SetBlendMode(DDD_MATERIAL_ADDBLEND)
			End Select

			FX = Self.Stream.ReadInt()
			'If FX & DDD_B3D_VERTEXCOLOR Then ' VertexColor !
			If FX & DDD_B3D_FLATSHADING Then Material.RemoveRenderMode(DDD_MATERIAL_GOURAUD)
			If FX & DDD_B3D_DISABLEFOG Then Material.AddRenderMode(DDD_MATERIAL_NOFOG)
			If FX & DDD_B3D_DISABLECULLBF Then Material.RemoveRenderMode(DDD_MATERIAL_CULLBF)

			For Index = 1 To TexCount
				TexIndex = Self.Stream.ReadInt()
				If TexIndex <> -1 Then
					Texture = TTexture(Self.Textures.ValueAtIndex(TexIndex))
					Material.SetTexture(Texture, Index-1)
				EndIf
			Next

			Self.Materials.AddLast(Material)
		Wend
	End Method

	Method ReadNode()
		Self.Name = Self.ReadCString()

		Self.Position[0] = Self.Stream.ReadFloat()
		Self.Position[1] = Self.Stream.ReadFloat()
		Self.Position[2] = Self.Stream.ReadFloat()

		Self.Scale[0] = Self.Stream.ReadFloat()
		Self.Scale[1] = Self.Stream.ReadFloat()
		Self.Scale[2] = Self.Stream.ReadFloat()

		Self.Rotation[0] = Self.Stream.ReadFloat()
		Self.Rotation[1] = Self.Stream.ReadFloat()
		Self.Rotation[2] = Self.Stream.ReadFloat()
		Self.Rotation[3] = Self.Stream.ReadFloat()
	End Method

	Method ReadMesh()
	End Method

	Method ReadVertices()
	End Method
	
	Method ReadTriangles()
	End Method

	Method New()
		Self.Stream    = Null
		Self.ChunkID   = 0
		Self.ChunkSize = 0
		Self.Mesh      = Null
		Self.Textures  = CreateList()
		Self.Materials = CreateList()
	End Method

	Function Load:TMesh(URL:Object)
		Local Loader:TB3DLoader, Size:Int
		Local OldDir:String

		Loader = New TB3DLoader

		Loader.Stream = LittleEndianStream(ReadStream(URL))
		If Not Loader.Stream Then Return Null

		Size = Loader.Stream.Size()

		' Read Main-Chunk
		Loader.ReadChunk()
		If (Loader.ChunkID <> DDD_B3D_BB3D) Or (Loader.ChunkSize <> Size-8) Then
			Loader.Stream.Close()
			Return Null
		EndIf

		' Check Version
		If Loader.Stream.ReadInt() <> 1 Then
			Loader.Stream.Close()
			Return Null
		EndIf

		OldDir = CurrentDir()
		If String(URL) <> "" Then ChangeDir(ExtractDir(String(URL)))

		Loader.Mesh = New TMesh

		While Not Loader.Stream.Eof()
			Loader.ReadChunk()

			Select Loader.ChunkID
				Case DDD_B3D_TEXS
					Loader.ReadTextures()

				Case DDD_B3D_BRUS
					Loader.ReadBrushs()

				Case DDD_B3D_NODE
					Loader.ReadNode()

				Case DDD_B3D_MESH
					Loader.ScipChunk()

				Case DDD_B3D_VRTS
					Loader.ScipChunk()

				Case DDD_B3D_TRIS
					Loader.ScipChunk()

				Default
					Loader.ScipChunk() 
			End Select
		Wend

		Loader.Stream.Close()
		ChangeDir(OldDir)

		Return Loader.Mesh
	End Function
End Type