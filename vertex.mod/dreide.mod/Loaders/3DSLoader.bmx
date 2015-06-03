Strict

Import brl.filesystem
Import brl.endianstream
Import "..\Mesh.bmx"
Import "..\Surface.bmx"
Import "..\Material.bmx"
Import "..\Texture.bmx"

' 3DS Chunks
Const DDD_3DS_RGB3F             : Int = $0010
Const DDD_3DS_RGB3B             : Int = $0011
Const DDD_3DS_RGBGAMMA3B        : Int = $0012
Const DDD_3DS_RGBGAMMA3F        : Int = $0013
Const DDD_3DS_PERCENTI          : Int = $0030
Const DDD_3DS_PERCENTF          : Int = $0031
Const DDD_3DS_MAIN              : Int = $4D4D
Const DDD_3DS_3DEDITOR          : Int = $3D3D
Const DDD_3DS_OBJECTBLOCK       : Int = $4000
Const DDD_3DS_TRIMESH           : Int = $4100
Const DDD_3DS_VERTEXLIST        : Int = $4110
Const DDD_3DS_FACELIST          : Int = $4120
Const DDD_3DS_FACEMATLIST       : Int = $4130
Const DDD_3DS_TEXCOORDS         : Int = $4140
Const DDD_3DS_MATERIALBLOCK     : Int = $AFFF
Const DDD_3DS_MATERIALNAME      : Int = $A000
Const DDD_3DS_MATERIALAMBIENT   : Int = $A010
Const DDD_3DS_MATERIALDIFFUSE   : Int = $A020
Const DDD_3DS_MATERIALSPECULAR  : Int = $A030
Const DDD_3DS_MATERIALSHININESS : Int = $A040
Const DDD_3DS_TEXTUREMAP1       : Int = $A200
Const DDD_3DS_TEXTUREMAP2       : Int = $A33A
Const DDD_3DS_MAPFILENAME       : Int = $A300
Const DDD_3DS_MAPVSCALE         : Int = $A354
Const DDD_3DS_MAPUSCALE         : Int = $A356
Const DDD_3DS_MAPUOFFSET        : Int = $A358
Const DDD_3DS_MAPVOFFSET        : Int = $A35A
Const DDD_3DS_MAPROTATION       : Int = $A35C

Type T3DSLoader
	Field Stream        : TStream
	Field ChunkID       : Short
	Field ChunkSize     : Int
	Field Surface       : TSurface
	Field VertexCount   : Int
	Field TriangleCount : Int
	Field Mesh          : TMesh
	Field Material      : TMaterial
	Field Materials     : TList
	Field TextureLayer  : Int
	Field Texture       : TTexture

	Method ReadChunk()
		Self.ChunkID   = Self.Stream.ReadShort()
		Self.ChunkSize = Self.Stream.ReadInt()
	End Method

	Method ScipChunk()
		Self.Stream.Seek(Self.Stream.Pos()+Self.ChunkSize-6)
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

	Method ReadRGB(Format:Int, Red:Float Var, Green:Float Var, Blue:Float Var)
		Select Format
			Case DDD_3DS_RGB3F
				Red   = Self.Stream.ReadFloat()
				Green = Self.Stream.ReadFloat()
				Blue  = Self.Stream.ReadFloat()

			Case DDD_3DS_RGB3B
				Red   = Float(Self.Stream.ReadByte())/255.0
				Green = Float(Self.Stream.ReadByte())/255.0
				Blue  = Float(Self.Stream.ReadByte())/255.0

			Case DDD_3DS_RGBGAMMA3F
				Red   = Self.Stream.ReadFloat()
				Green = Self.Stream.ReadFloat()
				Blue  = Self.Stream.ReadFloat()

			Case DDD_3DS_RGBGAMMA3B
				Red   = Float(Self.Stream.ReadByte())/255.0
				Green = Float(Self.Stream.ReadByte())/255.0
				Blue  = Float(Self.Stream.ReadByte())/255.0

			Default
				Self.ScipChunk()
		End Select
	End Method

	Method ReadPercent:Float(Format:Int)
		Select Format
			Case DDD_3DS_PERCENTI
				Return Float(Self.Stream.ReadShort())/100.0
				
			Case DDD_3DS_PERCENTF
				Return Self.Stream.ReadFloat()/100.0
				
			Default
				Self.ScipChunk()
				Return 0.0
		End Select
	End Method

	Method ReadVertexList()
		Local Index:Int, Position:Float[3]

		Self.VertexCount = Self.Stream.ReadShort()

		For Index = 0 To Self.VertexCount-1
			Position[0] = Self.Stream.ReadFloat()
			Position[1] = Self.Stream.ReadFloat()
			Position[2] = Self.Stream.ReadFloat()
			
			Self.Surface.CreateVertex(Position[0], Position[1], Position[2])
		Next

		Self.Surface.UpdateVertices()
	End Method

	Method ReadFaceList()
		Local Index:Int, Indices:Int[3]

		Self.TriangleCount = Self.Stream.ReadShort()
		For Index = 0 To Self.TriangleCount-1
			Indices[2] = Self.Stream.ReadShort()
			Indices[1] = Self.Stream.ReadShort()
			Indices[0] = Self.Stream.ReadShort()
			Self.Stream.ReadShort() ' FaceFlags

			Self.Surface.CreateTriangle(Indices[0], Indices[1], Indices[2])
		Next

		Self.Surface.UpdateTriangles()
		Self.Surface.SmoothNormals()
	End Method

	Method ReadFaceMatList()
		Local Name:String, Material:TMaterial, Found:Int, Count:Int

		Name = Self.ReadCString()

		' Search for the MaterialName
		Found = False
		For Material = EachIn Self.Materials
			If Material.GetName() = Name Then
				Found = True
				Exit
			EndIf
		Next

		If Found Then Self.Surface.SetMaterial(Material)

		Count = Self.Stream.ReadShort()
		Self.Stream.Seek(Self.Stream.Pos()+Count*2)
	End Method

	Method ReadTexCoords()
		Local Count:Int, Index:Int, U:Float, V:Float

		Count = Self.Stream.ReadShort()
		For Index = 0 To Count-1
			U = Self.Stream.ReadFloat()
			V = -Self.Stream.ReadFloat()

			Self.Surface.SetVertexTexCoords(Index, U, V, 0)
			Self.Surface.SetVertexTexCoords(Index, U, V, 1)
		Next

		Self.Surface.UpdateVertices(False, False, True, True, False, False)
	End Method

	Method LoadMap()
		Local Filename:String, Pixmap:TPixmap

		Filename = Self.ReadCString()
		Pixmap = LoadPixmap("littleendian::"+Filename)

		If Pixmap Then
			Self.Texture.SetFilter(DDD_TEXTURE_BILINEAR)
			Self.Texture.SetPixmap(Pixmap)
			Self.Texture.SetFilename(Filename)

			If Self.TextureLayer = DDD_3DS_TEXTUREMAP1 Then
				' Layer 0
				Self.Material.SetTexture(Self.Texture, 0)
			Else
				' Layer 1
				Self.Material.SetTexture(Self.Texture, 1)
			EndIf
		EndIf
	End Method

	Method ReadMap(Layer:Int)
		Self.Texture      = New TTexture
		Self.TextureLayer = Layer
	End Method

	Method ReadTriMesh()
		Self.Surface = Self.Mesh.CreateSurface()
	End Method

	Method ReadMaterialBlock()
		Self.Material = New TMaterial
		Self.Materials.AddLast(Self.Material)
	End Method

	Method New()
		Self.Stream        = Null
		Self.ChunkID       = 0
		Self.ChunkSize     = 0
		Self.Surface       = Null
		Self.VertexCount   = 0
		Self.TriangleCount = 0
		Self.Mesh          = Null
		Self.Material      = Null
		Self.Materials     = CreateList()
		Self.TextureLayer  = 0
		Self.Texture       = Null
	End Method

	Function Load:TMesh(URL:Object)
		Local Loader:T3DSLoader, Size:Int
		Local OldDir:String
		Local Red:Float, Green:Float, Blue:Float, Percent:Float
		Local Pixmap:TPixmap

		Loader = New T3DSLoader

		Loader.Stream = LittleEndianStream(ReadStream(URL))
		If Not Loader.Stream Then Return Null

		Size = Loader.Stream.Size()

		' Read Main-Chunk
		Loader.ReadChunk()
		If (Loader.ChunkID <> DDD_3DS_MAIN) Or (Loader.ChunkSize <> Size) Then
			Loader.Stream.Close()
			Return Null
		EndIf

		' Find 3DEditor-Chunk
		While Not Loader.Stream.Eof()
			Loader.ReadChunk()
			If Loader.ChunkID = DDD_3DS_3DEDITOR Then
				Exit
			Else
				Loader.ScipChunk()
			EndIf
		Wend

		OldDir = CurrentDir()
		If String(URL) <> "" Then ChangeDir(ExtractDir(String(URL)))

		Loader.Mesh = New TMesh

		While Not Loader.Stream.Eof()
			Loader.ReadChunk()

			Select Loader.ChunkID
				Case DDD_3DS_OBJECTBLOCK
					Loader.Mesh.SetName(Loader.ReadCString())

				Case DDD_3DS_MATERIALBLOCK
					Loader.ReadMaterialBlock()

				Case DDD_3DS_TRIMESH
					Loader.ReadTriMesh()

				Case DDD_3DS_VERTEXLIST
					Loader.ReadVertexList()

				Case DDD_3DS_FACELIST
					Loader.ReadFaceList()

				Case DDD_3DS_FACEMATLIST
					Loader.ReadFaceMatList()

				Case DDD_3DS_TEXCOORDS
					Loader.ReadTexCoords()

				Case DDD_3DS_MATERIALNAME
					Loader.Material.SetName(Loader.ReadCString())

				Case DDD_3DS_MATERIALAMBIENT
					Loader.ReadChunk()
					Loader.ReadRGB(Loader.ChunkID, Red, Green, Blue)
					Loader.Material.SetAmbientColor(Red, Green, Blue)

				Case DDD_3DS_MATERIALDIFFUSE
					Loader.ReadChunk()
					Loader.ReadRGB(Loader.ChunkID, Red, Green, Blue)
					Loader.Material.SetDiffuseColor(Red, Green, Blue)

				Case DDD_3DS_MATERIALSPECULAR
					Loader.ReadChunk()
					Loader.ReadRGB(Loader.ChunkID, Red, Green, Blue)
					Loader.Material.SetSpecularColor(Red, Green, Blue)

				Case DDD_3DS_MATERIALSHININESS
					Loader.ReadChunk()
					Percent = Loader.ReadPercent(Loader.ChunkID)
					Loader.Material.SetShininess(Percent)

				Case DDD_3DS_MAPFILENAME
					Loader.LoadMap()

				Case DDD_3DS_MAPVSCALE
					Loader.Texture.Transformation.Scale[0] = Loader.Stream.ReadFloat()

				Case DDD_3DS_MAPUSCALE
					Loader.Texture.Transformation.Scale[1] = Loader.Stream.ReadFloat()

				Case DDD_3DS_MAPUOFFSET
					Loader.Texture.Transformation.Position[0] = Loader.Stream.ReadFloat()

				Case DDD_3DS_MAPVOFFSET
					Loader.Texture.Transformation.Position[1] = Loader.Stream.ReadFloat()

				Case DDD_3DS_MAPROTATION
					Loader.Texture.SetRotation(Loader.Stream.ReadFloat())

				Default
					If (Loader.ChunkID = DDD_3DS_TEXTUREMAP1) Or ..
					   (Loader.ChunkID = DDD_3DS_TEXTUREMAP2) Then
						Loader.ReadMap(Loader.ChunkID)
					Else
						Loader.ScipChunk()
					EndIf
			End Select
		Wend

		Loader.Stream.Close()
		ChangeDir(OldDir)

		Return Loader.Mesh
	End Function
End Type