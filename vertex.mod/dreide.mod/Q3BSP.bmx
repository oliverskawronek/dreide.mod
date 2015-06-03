SuperStrict

Import BRL.GLGraphics
Import BRL.Pixmap
Import BRL.FileSystem
Import BRL.EndianStream
Import "Entity.bmx"
Import "Texture.bmx"

' Header
Const DDD_Q3MAP_MAGIC   : Int = $50534249, .. ' "IBSP"
      DDD_Q3MAP_VERSION : Int = $2E

' Lumps
Const DDD_Q3MAP_ENTITIES    : Int = 0, ..
      DDD_Q3MAP_TEXTURES    : Int = 1, ..
      DDD_Q3MAP_PLANES      : Int = 2, ..
      DDD_Q3MAP_NODES       : Int = 3, ..
      DDD_Q3MAP_LEAFS       : Int = 4, ..
      DDD_Q3MAP_LEAFFACES   : Int = 5, ..
      DDD_Q3MAP_LEAFBRUSHES : Int = 6, ..
      DDD_Q3MAP_MODELS      : Int = 7, ..
      DDD_Q3MAP_BRUSHES     : Int = 8, ..
      DDD_Q3MAP_BRUSHSIDES  : Int = 9, ..
      DDD_Q3MAP_VERTICES    : Int = 10, ..
      DDD_Q3MAP_INDICES     : Int = 11, ..
      DDD_Q3MAP_EFFECTS     : Int = 12, ..
      DDD_Q3MAP_FACES       : Int = 13, ..
      DDD_Q3MAP_LIGHTMAPS   : Int = 14, ..
      DDD_Q3MAP_LIGHTVOLS   : Int = 15, ..
      DDD_Q3MAP_VISDATA     : Int = 16

' FaceTypes
Const DDD_Q3MAP_POLYGON : Int = 1, ..
      DDD_Q3MAP_PATCH   : Int = 2, ..
      DDD_Q3MAP_MESH    : Int = 3

Type TQ3Map Extends TEntity
	Field TextureCount  : Int
	Field LightmapCount : Int
	Field Textures      : Int[]
	Field Lightmaps     : Int[]

	Method Render(Camera:TEntity)
	End Method

	Function Load:TQ3Map(URL:Object, Gamma:Float=0.0, Tesselation:Int=4)
		Return TQ3MapLoader.Load(URL, Gamma, Tesselation)
	End Function
End Type

Type TQ3Header
	Field Magic   : Int
	Field Version : Int
	Field Lumps   : Int[17, 2]

	Method Read(Stream:TStream)
		Self.Magic   = Stream.ReadInt()
		Self.Version = Stream.ReadInt()
		Stream.Read(Self.Lumps, 136)
	End Method

	Method Check:Int()
		If (Self.Magic <> DDD_Q3MAP_MAGIC) Or ..
           (Self.Version <> DDD_Q3MAP_VERSION) Then
			Return False
		Else
			Return True
		EndIf
	End Method
End Type

Type TQ3Texture
	Field Name     : String
	Field Flags    : Int
	Field Contents : Int

	Method Read(Stream:TStream)
		Self.Name     = Stream.ReadString(64)
		Self.Flags    = Stream.ReadInt()
		Self.Contents = Stream.ReadInt()

		If Self.Name.Find("~0") <> -1 Then ..
		   Self.Name = Self.Name[0..Self.Name.Find("~0")]
	End Method

	Method GetFilename:String()
		If Self.Name = "noshader" Then
			Return ""
		ElseIf FileType(Self.Name+".jpg") = 1 Then
			Return Self.Name+".jpg"
		ElseIf FileType(Self.Name+".tga") = 1 Then
			Return Self.Name+".tga"
		Else
			If FileType(StripDir(Self.Name)+".jpg") = 1 Then
				Return StripDir(Self.Name)+".jpg"
			ElseIf FileType(StripDir(Self.Name)+".tga") = 1 Then
				Return StripDir(Self.Name)+".tga"
			Else
				Return ""
			EndIf
		EndIf
	End Method

	Method LoadGLTexture:Int()
		Local Pixmap  : TPixmap, ..
		      Format  : Int, ..
		      Width   : Int, ..
		      Height  : Int, ..
		      Texture : Int

		Pixmap = LoadPixmap(Self.GetFilename())
		If Not Pixmap Then Return -1

		Select Pixmap.Format
			Case PF_RGB888
				Format = GL_RGB
			Case PF_BGR888
				Pixmap = Pixmap.Convert(PF_RGB888)
				Format = GL_RGB
			Case PF_RGBA8888
				Format = GL_RGBA
			Case PF_BGRA8888
				Pixmap = Pixmap.Convert(PF_RGBA8888)
				Format = GL_RGBA
		End Select

		Width  = Pixmap.Width
		Height = Pixmap.Height
		TTexture.AdjustTexSize(Width, Height)
		If (Width <> Pixmap.Width) Or (Height <> Pixmap.Height) Then ..
		   Pixmap = ResizePixmap(Pixmap, Width, Height)

		glGenTextures(1, Varptr(Texture))
		glBindTexture(GL_TEXTURE_2D, Texture)
		gluBuild2DMipmaps(GL_TEXTURE_2D, Format, Width, Height, Format, ..
		                  GL_UNSIGNED_BYTE, Pixmap.Pixels)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

		Return Texture
	End Method
End Type

Type TQ3Lightmap
	Field Pixels : Byte[49152]

	Method Read(Stream:TStream)
		Stream.Read(Self.Pixels, 49152)
	End Method

	Method MakeGLTexture:Int(Gamma:Float=0.0)
		Local Index   : Int, ..
		      Bias    : Int, ..
		      Pixel   : Int, ..
		      Texture : Int

		If Gamma <> 0.0 Then
			For Index = 0 Until 49152
				Bias = Gamma*255.0
				Pixel = Self.Pixels[Index]

				Pixel :+ Bias
				If Pixel < 0   Then Pixel = 0
				If Pixel > 255 Then Pixel = 255

				Self.Pixels[Index] = Pixel
			Next
		EndIf

		glGenTextures(1, Varptr(Texture))
		glBindTexture(GL_TEXTURE_2D, Texture)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 128, 128, 0, GL_RGB, ..
		             GL_UNSIGNED_BYTE, Self.Pixels)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE)
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS)
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE)
		glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 2.0)

		Return Texture
	End Method
End Type

Type TQ3BiQuadPatch
	Field ControlPoints : Float[9, 14]
	Field Vertices      : Float[,]
	Field Indices       : Int[]

	Method Tesselate(Tesselation:Int)
	End Method
End Type

Type TQ3Face
	Field TextureID      : Int
	Field Effect         : Int
	Field FaceType       : Int
	Field FirstVertex    : Int
	Field NumVertices    : Int
	Field FirstIndex     : Int
	Field NumIndices     : Int
	Field LightmapID     : Int
	Field LightmapStart  : Int[2]
	Field LightmapSize   : Int[2]
	Field LightmapOrigin : Float[3]
	Field Tangent        : Float[2, 3]
	Field Normal         : Float[3]
	Field PatchSize      : Int[2]
	Field Patches        : TQ3BiQuadPatch[,]

	Method Read(Loader:TQ3MapLoader, Tesselation:Int)
		Self.TextureID   = Loader.Stream.ReadInt()
		Self.Effect      = Loader.Stream.ReadInt()
		Self.FaceType    = Loader.Stream.ReadInt()
		Self.FirstVertex = Loader.Stream.ReadInt()
		Self.NumVertices = Loader.Stream.ReadInt()
		Self.FirstIndex  = Loader.Stream.ReadInt()
		Self.NumIndices  = Loader.Stream.ReadInt()
		Self.LightmapID  = Loader.Stream.ReadInt()

		Loader.Stream.Read(Self.LightmapStart, 8)
		Loader.Stream.Read(Self.LightmapSize, 8)

		Self.LightmapOrigin[0] =  Loader.Stream.ReadFloat()
		Self.LightmapOrigin[2] = -Loader.Stream.ReadFloat()
		Self.LightmapOrigin[1] =  Loader.Stream.ReadFloat()

		Self.Tangent[0, 0] =  Loader.Stream.ReadFloat()
		Self.Tangent[0, 2] = -Loader.Stream.ReadFloat()
		Self.Tangent[0, 1] =  Loader.Stream.ReadFloat()

		Self.Tangent[1, 0] =  Loader.Stream.ReadFloat()
		Self.Tangent[1, 2] = -Loader.Stream.ReadFloat()
		Self.Tangent[1, 1] =  Loader.Stream.ReadFloat()
		
		Loader.Stream.Read(Self.Normal, 12)
		Loader.Stream.Read(Self.PatchSize, 8)
		
		If Self.FaceType = DDD_Q3MAP_PATCH Then
		ElseIf Self.FaceType = DDD_Q3MAP_POLYGON Or ..
		       Self.FaceType = DDD_Q3MAP_MESH Then
		EndIf
	End Method
End Type

Type TQ3MapLoader
	Field Stream      : TStream
	Field Map         : TQ3Map
	Field Header      : TQ3Header
	Field Vertices    : Float[,]
	Field Indices     : Int[]
	Field Faces       : TQ3Face[]
	Field Planes      : Float[,]

	Function Load:TQ3Map(URL:Object, Gamma:Float=0.0, Tesselation:Int=4)
		Local Loader   : TQ3MapLoader, ..
		      OldDir   : String, ..
		      Count    : Int, ..
		      Index    : Int, ..
		      Texture  : TQ3Texture, ..
		      Lightmap : TQ3LightMap

		' Check if Stream can load
		Loader = New TQ3MapLoader
		Loader.Stream = LittleEndianStream(ReadStream(URL))
		If Not Loader.Stream Then Return Null

		' Check header
		Loader.Header = New TQ3Header
		Loader.Header.Read(Loader.Stream)
		If Not Loader.Header.Check() Then
			Loader.Stream.Close()
			Return Null
		EndIf

		' New Quake3 Map
		Loader.Map = New TQ3Map

		' Change Directory for Textures
		OldDir = CurrentDir()
		If String(URL) <> "" Then ChangeDir(ExtractDir(String(URL)))

		' Load Textures
		Loader.Stream.Seek(Loader.Header.Lumps[DDD_Q3MAP_TEXTURES, 0])
		Count = Loader.Header.Lumps[DDD_Q3MAP_TEXTURES, 1]/72
		Loader.Map.TextureCount = Count
		Loader.Map.Textures = New Int[Count]
		
		Texture = New TQ3Texture
		For Index = 0 Until Count
			Texture.Read(Loader.Stream)
			Loader.Map.Textures[Index] = Texture.LoadGLTexture()
		Next

		' Load Lightmaps
		Loader.Stream.Seek(Loader.Header.Lumps[DDD_Q3MAP_LIGHTMAPS, 0])
		Count = Loader.Header.Lumps[DDD_Q3MAP_LIGHTMAPS, 1]/49152
		Loader.Map.LightmapCount = Count
		Loader.Map.Lightmaps = New Int[Count]
		
		Lightmap = New TQ3LightMap
		For Index = 0 Until Count
			Lightmap.Read(Loader.Stream)
			Loader.Map.Lightmaps[Index] = Lightmap.MakeGLTexture(Gamma)
		Next
		
		' Load Vertices
		Loader.Stream.Seek(Loader.Header.Lumps[DDD_Q3MAP_VERTICES, 0])
		Count = Loader.Header.Lumps[DDD_Q3MAP_VERTICES, 1]/44
		Loader.Vertices = New Float[Count, 14]

		For Index = 0 Until Count
			' Position
			Loader.Vertices[Index, 0] = Loader.Stream.ReadFloat()/64.0
			Loader.Vertices[Index, 2] = Loader.Stream.ReadFloat()/(-64.0)
			Loader.Vertices[Index, 1] = Loader.Stream.ReadFloat()/64.0

			' Texture UV
			Loader.Vertices[Index, 6] = Loader.Stream.ReadFloat()
			Loader.Vertices[Index, 7] = Loader.Stream.ReadFloat()
			
			' Lightmap UV
			Loader.Vertices[Index, 8] = Loader.Stream.ReadFloat()
			Loader.Vertices[Index, 9] = Loader.Stream.ReadFloat()

			' Normal
			Loader.Vertices[Index, 3] = Loader.Stream.ReadFloat()
			Loader.Vertices[Index, 5] = -Loader.Stream.ReadFloat()
			Loader.Vertices[Index, 4] = Loader.Stream.ReadFloat()
			
			' Color
			Loader.Vertices[Index, 10] = Float(Loader.Stream.ReadByte())/255.0
			Loader.Vertices[Index, 11] = Float(Loader.Stream.ReadByte())/255.0
			Loader.Vertices[Index, 12] = Float(Loader.Stream.ReadByte())/255.0
			Loader.Vertices[Index, 13] = Float(Loader.Stream.ReadByte())/255.0
		Next

		' Load Indices
		Loader.Stream.Seek(Loader.Header.Lumps[DDD_Q3MAP_INDICES, 0])
		Count = Loader.Header.Lumps[DDD_Q3MAP_INDICES, 1]/4
		Loader.Indices = New Int[Count]
		Loader.Stream.Read(Loader.Indices, Count*4)

		' Load Faces
		Loader.Stream.Seek(Loader.Header.Lumps[DDD_Q3MAP_FACES, 0])
		Count = Loader.Header.Lumps[DDD_Q3MAP_FACES, 1]/104
		Loader.Faces = New TQ3Face[Count]

		For Index = 0 Until Count
			Loader.Faces[Index] = New TQ3Face
			Loader.Faces[Index].Read(Loader, Tesselation)
		Next

		Loader.Stream.Close()
		ChangeDir(OldDir)

		Return Loader.Map
	End Function
End Type
