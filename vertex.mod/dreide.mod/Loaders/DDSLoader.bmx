SuperStrict

Import brl.endianstream
Import "..\Texture.bmx"
Import "..\HardwareInfo.bmx"

' Signature
Const DDD_DDS_MAGIC : Int = $20534444

' DirectDraw Surface Desciption
Const DDD_DDSD_CAPS        : Int = $00000001
Const DDD_DDSD_HEIGHT      : Int = $00000002
Const DDD_DDSD_WIDTH       : Int = $00000004
Const DDD_DDSD_PITCH       : Int = $00000008
Const DDD_DDSD_PIXELFORMAT : Int = $00001000
Const DDD_DDSD_MIPMAPCOUNT : Int = $00020000
Const DDD_DDSD_LINEARSIZE  : Int = $00080000
Const DDD_DDSD_DEPTH       : Int = $00800000

' DirectDraw Pixel Format
Const DDD_DDPF_ALPHAPIXELS : Int = $00000001
Const DDD_DDPF_FOURCC      : Int = $00000004
Const DDD_DDPF_RGB         : Int = $00000040

' DirectDraw Four Character Code(Compression Methods)
Const DDD_FOURCCC_DXT1 : Int = $31545844
Const DDD_FOURCCC_DXT3 : Int = $33545844
Const DDD_FOURCCC_DXT5 : Int = $35545844

' DirectDraw Surface Capabilities
Const DDD_DDSCAPS_COMPLEX : Int = $00000008
Const DDD_DDSCAPS_TEXTURE : Int = $00001000
Const DDD_DDSCAPS_MIPMAP  : Int = $00400000

' DirectDraw Surface Capabilities 2
Const DDD_DDSCAPS2_CUBEMAP           : Int = $00000200
Const DDD_DDSCAPS2_CUBEMAP_POSITIVEX : Int = $00000400
Const DDD_DDSCAPS2_CUBEMAP_NEGATIVEX : Int = $00000800
Const DDD_DDSCAPS2_CUBEMAP_POSITIVEY : Int = $00001000
Const DDD_DDSCAPS2_CUBEMAP_NEGATIVEY : Int = $00002000
Const DDD_DDSCAPS2_CUBEMAP_POSITIVEZ : Int = $00004000
Const DDD_DDSCAPS2_CUBEMAP_NEGATIVEZ : Int = $00008000
Const DDD_DDSCAPS2_VOLUME            : Int = $00200000

' DDS PixelFormats
Const DDD_DDS_RGBA8888 : Int = 1 ' -> GL_RGBA
Const DDD_DDS_RGBA5551 : Int = 2 ' -> GL_RGBA
Const DDD_DDS_RGBA4444 : Int = 3 ' -> GL_RGBA
Const DDD_DDS_RGB888   : Int = 4 ' -> GL_RGB
Const DDD_DDS_RGB565   : Int = 5 ' -> GL_RGB
Const DDD_DDS_DXT1     : Int = 6 ' -> GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
Const DDD_DDS_DXT3     : Int = 7 ' -> GL_COMPRESSED_RGBA_S3TC_DXT3_EXT
Const DDD_DDS_DXT5     : Int = 8 ' -> GL_COMPRESSED_RGBA_S3TC_DXT5_EXT

' DirectDraw PixelFormat
Type TDDS_DDPIXELFORMAT
	Field Size            : Int
	Field Flags           : Int
	Field FourCC          : Int
	Field RGBBitCount     : Int
	Field RBitMask        : Int
	Field GBitMask        : Int
	Field BBitMask        : Int
	Field RGBAlphaBitMask : Int

	Method Read(Stream:TStream)
		Self.Size            = Stream.ReadInt()
		Self.Flags           = Stream.ReadInt()
		Self.FourCC          = Stream.ReadInt()
		Self.RGBBitCount     = Stream.ReadInt()
		Self.RBitMask        = Stream.ReadInt()
		Self.RBitMask        = Stream.ReadInt()
		Self.RBitMask        = Stream.ReadInt()
		Self.RGBAlphaBitMask = Stream.ReadInt()
	End Method
End Type

' DirectDraw Capabilities
Type TDDS_DDCAPS2
	Field Caps1    : Int
	Field Caps2    : Int
	Field Reserved : Int[2]
		Method Read(Stream:TStream)
		Self.Caps1 = Stream.ReadInt()
		Self.Caps2 = Stream.ReadInt()
		Stream.Seek(Stream.Pos()+8)
	End Method
End Type

' DirectDraw SurfaceDescription
Type TDDS_DDSURFACEDESC2
	Field Size              : Int
	Field Flags             : Int
	Field Height            : Int
	Field Width             : Int
	Field PitchOrLinearSize : Int
	Field Depth             : Int
	Field MipMapCount       : Int
	Field Reserved1         : Int[11]
	Field PixelFormat       : TDDS_DDPIXELFORMAT
	Field Caps              : TDDS_DDCAPS2
	Field Reserved2         : Int

	Method Read(Stream:TStream)
		Self.Size              = Stream.ReadInt()
		Self.Flags             = Stream.ReadInt()
		Self.Height            = Stream.ReadInt()
		Self.Width             = Stream.ReadInt()
		Self.PitchOrLinearSize = Stream.ReadInt()
		Self.Depth             = Stream.ReadInt()
		Self.MipMapCount       = Stream.ReadInt()
		Stream.Seek(Stream.Pos()+44)
		Self.PixelFormat.Read(Stream)
		Self.Caps.Read(Stream)
		Stream.Seek(Stream.Pos()+4)
	End Method

	Method New()
		Self.PixelFormat = New TDDS_DDPIXELFORMAT
		Self.Caps        = New TDDS_DDCAPS2
	End Method
End Type

Type TDDSLoader
	Field Stream      : TStream
	Field Texture     : TTexture
	Field SurfaceDesc : TDDS_DDSURFACEDESC2
	Field Width       : Int
	Field Height      : Int
	Field Size        : Int
	Field Format      : Int
	Field Components  : Int
	Field Data        : Byte[]

	Method CheckHeader:Int()
		If (Self.SurfaceDesc.Size <> 124) Or .. 
		   (Not Self.SurfaceDesc.Flags & (DDD_DDSD_WIDTH ..
		                                  | DDD_DDSD_HEIGHT ..
		                                  | DDD_DDSD_CAPS ..
		                                  | DDD_DDSD_PIXELFORMAT)) Or ..
		   (Self.SurfaceDesc.PitchOrLinearSize = 0) Or ..
		   (Self.SurfaceDesc.PixelFormat.Size <> 32) Or ..
		   (Not Self.SurfaceDesc.Caps.Caps1 & DDD_DDSCAPS_TEXTURE) Or ..
		   (Self.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_VOLUME) Then

			Return False
		Else
			Return True
		EndIf 
	End Method

	Method GetPixelFormat:Int()
		If Self.SurfaceDesc.PixelFormat.Flags & DDD_DDPF_RGB Then
			' Uncompressed
			If Self.SurfaceDesc.PixelFormat.Flags & DDD_DDPF_ALPHAPIXELS Then
				' Alpha
				If Self.SurfaceDesc.PixelFormat.RGBBitCount = 16 Then
					If Self.SurfaceDesc.PixelFormat.RGBAlphaBitMask & $8000 Then
						' RGBA5551
						Self.Size       = Self.Width*Self.Height*2
						Self.Components = GL_RGBA
						Self.Format     = DDD_DDS_RGBA5551
						Self.Data       = New Byte[Self.Width*Self.Height*4]
						Return True
					Else
						' RGBA4444
						Self.Size       = Self.Width*Self.Height*2
						Self.Components = GL_RGBA
						Self.Format     = DDD_DDS_RGBA4444
						Self.Data       = New Byte[Self.Width*Self.Height*4]
						Return True
					EndIf
				ElseIf Self.SurfaceDesc.PixelFormat.RGBBitCount = 32 Then
					' RGBA8888
					Self.Size       = Self.Width*Self.Height*4
					Self.Components = GL_RGBA
					Self.Format     = DDD_DDS_RGBA8888
					Self.Data       = New Byte[Self.Width*Self.Height*4]
					Return True
				Else
					Return False
				EndIf
			Else
				' No Alpha
				If Self.SurfaceDesc.PixelFormat.RGBBitCount = 16 Then
					' RGB565
					Self.Size       = Self.Width*Self.Height*2
					Self.Components = GL_RGB
					Self.Format     = DDD_DDS_RGB565
					Self.Data       = New Byte[Self.Width*Self.Height*3]
					Return True
				ElseIf Self.SurfaceDesc.PixelFormat.RGBBitCount = 24	
					' RGB888
					Self.Size       = Self.Width*Self.Height*3
					Self.Components = GL_RGB
					Self.Format     = DDD_DDS_RGB888
					Self.Data       = New Byte[Self.Width*Self.Height*3]
					Return True
				Else
					Return False
				EndIf
			EndIf
		ElseIf Self.SurfaceDesc.PixelFormat.Flags & DDD_DDPF_FOURCC
			If Not THardwareInfo.S3TCSupport Then Return False

			Select Self.SurfaceDesc.PixelFormat.FourCC
				Case DDD_FOURCCC_DXT1
					' DXT1
					Self.Size       = Self.SurfaceDesc.PitchOrLinearSize
					Self.Components = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
					Self.Format     = DDD_DDS_DXT1
					Self.Data       = New Byte[Self.Size]
					Return True

				Case DDD_FOURCCC_DXT3
					' DXT3
					Self.Size       = Self.SurfaceDesc.PitchOrLinearSize
					Self.Components = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT
					Self.Format     = DDD_DDS_DXT3
					Self.Data       = New Byte[Self.Size]
					Return True

				Case DDD_FOURCCC_DXT5
					' DXT5
					Self.Size       = Self.SurfaceDesc.PitchOrLinearSize
					Self.Components = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT
					Self.Format     = DDD_DDS_DXT5
					Self.Data       = New Byte[Self.Size]
					Return True

				Default
					Return False

			End Select
		Else
			Return False
		EndIf
	End Method

	Method ReadImage(Width:Int, Height:Int, Size:Int=0)
		Local X:Int, Y:Int, RGBA:Int, Red:Byte, Green:Byte, Blue:Byte, Alpha:Byte
		Local Offset:Int
	
		Select Self.Format
			Case DDD_DDS_RGBA8888
				Offset = 0
				For Y = 0 To Height-1
					For X = 0 To Width-1
						Self.Data[Offset+3]   = Self.Stream.ReadByte()
						Self.Data[Offset+2] = Self.Stream.ReadByte()
						Self.Data[Offset+1] = Self.Stream.ReadByte()
						Self.Data[Offset+0] = Self.Stream.ReadByte()

						Offset :+ 4
					Next
				Next

			Case DDD_DDS_RGBA5551
				Offset = 0
				For Y = 0 To Height-1
					For X = 0 To Width-1
						RGBA  = Self.Stream.ReadShort()
						Red   = (RGBA Shl 10) & $003E
						Green = (RGBA Shl  5) & $07C0
						Blue  =  RGBA         & $F800
						Alpha = (RGBA Shl 15) & $0001

						Self.Data[Offset]   = Red
						Self.Data[Offset+1] = Green
						Self.Data[Offset+2] = Blue
						Self.Data[Offset+3] = Alpha

						Offset :+ 4
					Next
				Next

			Case DDD_DDS_RGBA4444
				Offset = 0
				For Y = 0 To Height-1
					For X = 0 To Width-1
						RGBA  = Self.Stream.ReadShort()
						Red   = (RGBA Shl  8) & $F000
						Green = (RGBA Shl  4) & $0F00
						Blue  =  RGBA         & $00F0
						Alpha = (RGBA Shl 12) & $000F

						Self.Data[Offset]   = Red
						Self.Data[Offset+1] = Green
						Self.Data[Offset+2] = Blue
						Self.Data[Offset+3] = Alpha

						Offset :+ 4
					Next
				Next

			Case DDD_DDS_RGB888
				Offset = 0
				For Y = 0 To Height-1
					For X = 0 To Width-1
						Self.Data[Offset+2] = Self.Stream.ReadByte()
						Self.Data[Offset+1] = Self.Stream.ReadByte()
						Self.Data[Offset]   = Self.Stream.ReadByte()

						Offset :+ 3
					Next
				Next

			Case DDD_DDS_RGB565
				Offset = 0
				For Y = 0 To Height-1
					For X = 0 To Width-1
						RGBA  = Self.Stream.ReadShort()
						Red   = (RGBA Shl 10) & $001F
						Green = (RGBA Shl  5) & $03E0
						Blue  =  RGBA         & $7C00

						Self.Data[Offset]   = Red
						Self.Data[Offset+1] = Green
						Self.Data[Offset+2] = Blue

						Offset :+ 3
					Next
				Next

			Case DDD_DDS_DXT1
				Self.Stream.Read(Self.Data, Size)

			Case DDD_DDS_DXT3
				Self.Stream.Read(Self.Data, Size)

			Case DDD_DDS_DXT5
				Self.Stream.Read(Self.Data, Size)
		End Select
	End Method
	
	Method SetTexImage:Int(Target:Int)
		Self.ReadImage(Self.Width, Self.Height)

		If Self.SurfaceDesc.PixelFormat.Flags & DDD_DDPF_RGB Then
			' Uncompressed
			glTexImage2D(Target, 0, Self.Components, Self.Width, Self.Height, ..
			             0, Self.Components, GL_UNSIGNED_BYTE, Self.Data)
		Else
			' Compressed
			If Width < 8 Then Size = 8
			glCompressedTexImage2D(Target, 0, Self.Components, Self.Width, ..
			                       Self.Height, 0, Self.Size, Self.Data)
		EndIf
	End Method
	
	Method SetMIPMaps:Int(Target:Int)
		Local Level:Int, Width:Int, height:Int, Size:Int

		Width  = Self.Width
		Height = Self.Height
		Size   = Self.Size

		For Level = 1 To Self.SurfaceDesc.MipMapCount
			Self.ReadImage(Width, Height, Size)

			If Self.SurfaceDesc.PixelFormat.Flags & DDD_DDPF_RGB Then
				' Uncompressed
				glTexImage2D(Target, Level-1, Self.Components, Width, Height, ..
				             0, Self.Components, GL_UNSIGNED_BYTE, Self.Data)
			Else
				' Compressed
				If Width < 8 Then Size = 8
				glCompressedTexImage2D(Target, Level-1, Self.Components, Width, Height, ..
				                       0, Size, Self.Data)
			EndIf

			If glGetError() <> 0 Then Return False
			
			Width  = Width  Shr 1
			Height = Height Shr 1
			Size   = Size   Shr 2 
		Next

		Return True
	End Method

	Method SetTexture:Int(Target:Int)
		If Self.SurfaceDesc.Caps.Caps1 & DDD_DDSCAPS_MIPMAP Then
			Return Self.SetMIPMaps(Target)
		Else
			Return Self.SetTexImage(Target)
		EndIf
	End Method

	Function Load:TTexture(URL:Object)
		Local Loader:TDDSLoader

		Loader = New TDDSLoader

		Loader.Stream = LittleEndianStream(ReadStream(URL))
		If Not Loader.Stream Then Return Null

		' Check Signature
		If Loader.Stream.ReadInt() <> DDD_DDS_MAGIC Then
			Loader.Stream.Close()
			Return Null
		EndIf

		' Load Surface Format Header
		Loader.SurfaceDesc = New TDDS_DDSURFACEDESC2
		Loader.SurfaceDesc.Read(Loader.Stream)

		' Check Header
		If Not Loader.CheckHeader() Then
			Loader.Stream.Close()
			Return Null
		EndIf

		' Check Width and Height
		Loader.Width  = Loader.SurfaceDesc.Width
		Loader.Height = Loader.SurfaceDesc.Height

		TTexture.AdjustTexSize(Loader.Width, Loader.Height)
		If (Loader.Width <> Loader.Height) Or ..
		   (Loader.Width <> Loader.SurfaceDesc.Width) Or ..
		   (Loader.Height <> Loader.SurfaceDesc.Height) Then

			Loader.Stream.Close()
			Return Null
		EndIf

		' Check PixelFormat
		If Not Loader.GetPixelFormat()
			Loader.Stream.Close()
			Return Null
		EndIf
		
		' Create Texture
		Loader.Texture = New TTexture

		If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP Then
			' Cubemap
			glBindTexture(GL_TEXTURE_CUBE_MAP, Loader.Texture.TextureID)

			' Positive X
			If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP_POSITIVEX Then
				If Not Loader.SetTexture(GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT) Then
					Loader.Texture.Remove()
					Loader.Stream.Close()
					Return Null
				EndIf
			EndIf

			' Negative X
			If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP_NEGATIVEX Then
				If Not Loader.SetTexture(GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT) Then
					Loader.Texture.Remove()
					Loader.Stream.Close()
					Return Null
				EndIf
			EndIf

			' Positive Y
			If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP_POSITIVEY Then
				If Not Loader.SetTexture(GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT) Then
					Loader.Texture.Remove()
					Loader.Stream.Close()
					Return Null
				EndIf
			EndIf

			' Negative Y
			If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP_NEGATIVEY Then
				If Not Loader.SetTexture(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT) Then
					Loader.Texture.Remove()
					Loader.Stream.Close()
					Return Null
				EndIf
			EndIf

			' Positive Z
			If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP_POSITIVEZ Then
				If Not Loader.SetTexture(GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT) Then
					Loader.Texture.Remove()
					Loader.Stream.Close()
					Return Null
				EndIf
			EndIf

			' Negative Z
			If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP_NEGATIVEZ Then
				If Not Loader.SetTexture(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT) Then
					Loader.Texture.Remove()
					Loader.Stream.Close()
					Return Null
				EndIf
			EndIf
		Else
			glBindTexture(GL_TEXTURE_2D, Loader.Texture.TextureID)
			If Not Loader.SetTexture(GL_TEXTURE_2D) Then
				Loader.Texture.Remove()
				Loader.Stream.Close()
				Return Null
			EndIf
		EndIf

		' Set RenderModes
		If Loader.SurfaceDesc.Caps.Caps1 & DDD_DDSCAPS_MIPMAP Then
			Loader.Texture.AddRenderMode(DDD_TEXTURE_MIPMAP)
		EndIf

		If Loader.SurfaceDesc.Caps.Caps2 & DDD_DDSCAPS2_CUBEMAP Then
			Loader.Texture.AddRenderMode(DDD_TEXTURE_CUBEMAP)
		EndIf

		' Close Stream and return loaded Texture
		Loader.Stream.Close()
		Return Loader.Texture
	End Function
End Type