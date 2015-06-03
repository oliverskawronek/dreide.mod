SuperStrict

Import "Entity.bmx"
Import "HardwareInfo.bmx"
Import "Math.bmx"

' RenderMode
Const DDD_CAMERA_CLEARZBUFFER : Int = %000000000010, .. ' Clear DepthBuffer
      DDD_CAMERA_CLEARCBUFFER : Int = %000000000100, .. ' Clear ColorBuffer
      DDD_CAMERA_FOGENABLE    : Int = %000000001000, ..
      DDD_CAMERA_FOGLINEAR    : Int = %000000010000, ..
      DDD_CAMERA_FOGEXP       : Int = %000000100000, ..
      DDD_CAMERA_FOGEXP2      : Int = %000001000000, ..
      DDD_CAMERA_FILL         : Int = %000010000000, ..
      DDD_CAMERA_WIRE         : Int = %000100000000, ..
      DDD_CAMERA_DEPTHSORTING : Int = %001000000000

' CameraZoom
Const DDD_CAMERA_FOV45:Float = 2.41421366, .. ' 1.0/Tan(45.0/2.0)
      DDD_CAMERA_FOV90:Float = 1.00000000     ' 1.0/Tan(90.0/2.0)

Type TCamera Extends TEntity
	Field RenderMode : Int
	Field Viewport   : Int[4]
	Field Frustum    : Float[16]
	Field ClearColor : Float[4]
	Field FogColor   : Float[4]
	Field FogRange   : Float[2]
	
	Method New()
		Self.Class      = DDD_ENTITY_CAMERA
		Self.Name       = "Unntitled Camera"
		Self.Visible    = False
		
		Self.RenderMode = DDD_CAMERA_CLEARZBUFFER ..
		                  | DDD_CAMERA_CLEARCBUFFER ..
		                  | DDD_CAMERA_FOGEXP2 ..
		                  | DDD_CAMERA_FILL ..
		                  | DDD_CAMERA_WIRE
		Self.ViewPort   = [0, 0, THardwareInfo.ScreenWidth, ..
		                         THardwareInfo.ScreenHeight]
		TFrustum.SetPerspective(Self.Frustum, DDD_CAMERA_FOV45, ..
		                        THardwareInfo.ScreenWidth/THardwareInfo.ScreenHeight, ..
		                        1.0, 1000.0)
		Self.ClearColor = [0.0, 0.0, 0.0, 1.0]
		Self.FogColor   = [0.0, 0.0, 0.0, 1.0]
		Self.FogRange   = [1.0, 1000.0]
	End Method
	
	Method SetRenderMode(RenderMode:Int)
		Self.RenderMode = RenderMode
	End Method

	Method AddRenderMode(RenderMode:Int)
		Self.RenderMode :| RenderMode
	End Method

	Method RemoveRenderMode(RenderMode:Int)
		Self.RenderMode :& (~RenderMode)
	End Method
	
	Method SetViewport(X:Int, Y:Int, Width:Int, Height:Int)
		Self.Viewport[0] = X
		Self.Viewport[1] = Y
		Self.Viewport[2] = Width
		Self.Viewport[3] = Height
	End Method
	
	Method SetFrustum(Matrix4x4:Byte Ptr)
		MemCopy(Self.Frustum, Matrix4x4, 64)
	End Method

	Method SetClearColor(R:Float, G:Float, B:Float, A:Float=1.0)
		Self.ClearColor[0] = R
		Self.ClearColor[1] = G
		Self.ClearColor[2] = B
		Self.ClearColor[3] = A
	End Method

	Method SetFogColor(R:Float, G:Float, B:Float, A:Float=1.0)
		Self.FogColor[0] = R
		Self.FogColor[1] = G
		Self.FogColor[2] = B
		Self.FogColor[3] = A
	End Method
	
	Method SetFogRange(Near:Float, Far:Float)
		Self.FogRange[0] = Near
		Self.FogRange[1] = Far
	End Method

	Method Render(Camera:TEntity=Null)
		Local Entity : TEntity
	
		' Scissortest
		If Self.Viewport[0] <> 0 Or Self.Viewport[1] <> 0 ..
		   Or Self.Viewport[2] <> THardwareInfo.ScreenWidth ..
		   Or Self.Viewport[3] <> THardwareInfo.ScreenHeight Then

			glEnable(GL_SCISSOR_TEST)
			glScissor(Self.Viewport[0], Self.Viewport[1], Self.Viewport[2], ..
			          Self.Viewport[3])
		Else
			glDisable(GL_SCISSOR_TEST)
		EndIf
		
		' Viewport
		glViewport(Self.Viewport[0], Self.Viewport[1], Self.Viewport[2], ..
		           Self.Viewport[3])

		' Frustum
		glMatrixMode(GL_PROJECTION)
		glLoadMatrixf(Self.Frustum)
		
		' Z Buffer-Clearing
		If Self.RenderMode & DDD_CAMERA_CLEARZBUFFER Then
			glEnable(GL_DEPTH_TEST)
			glDepthFunc(GL_LEQUAL)
			glClear(GL_DEPTH_BUFFER_BIT)
		Else
			glDisable(GL_DEPTH_TEST)
		EndIf
		
		' ColorBuffer-Clearing
		If Self.RenderMode & DDD_CAMERA_CLEARCBUFFER Then
			glClearColor(Self.ClearColor[0], Self.ClearColor[1], ..
			             Self.ClearColor[2], 1.0)
			glClear(GL_COLOR_BUFFER_BIT)
		EndIf
		
		' Fog
		If Self.RenderMode & DDD_CAMERA_FOGENABLE Then
			glEnable(GL_FOG)

			' FogMode
			Select Self.RenderMode & (DDD_CAMERA_FOGLINEAR ..
			       | DDD_CAMERA_FOGLINEAR ..
			       | DDD_CAMERA_FOGEXP ..
			       | DDD_CAMERA_FOGEXP2)

				Case DDD_CAMERA_FOGLINEAR
					glFogi(GL_FOG_MODE, GL_LINEAR)

				Case DDD_CAMERA_FOGEXP
					glFogi(GL_FOG_MODE, GL_EXP)

				Case DDD_CAMERA_FOGEXP2
					glFogi(GL_FOG_MODE, GL_EXP2)
			End Select

			glFogfv(GL_FOG_COLOR, Self.FogColor)   ' Set FogColor
			glFogf(GL_FOG_START, Self.FogRange[0]) ' Set FogStart
			glFogf(GL_FOG_END, Self.FogRange[1])   ' Set FogEnd
		Else
			glDisable(GL_FOG)
		EndIf
		
		' Transformation
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()
		
		' Position
		glTranslatef(-Self.Position[0], -Self.Position[1], -Self.Position[2])

		' Scale
		glScalef(Self.Scale[0], Self.Scale[1], Self.Scale[2])
		
		' Rotation
		glRotatef(-Self.Rotation[0], Self.Rotation[1], Self.Rotation[2], ..
		          Self.Rotation[3])
		
		' Render Entities
		For Entity = EachIn TEntity.List
			If (Entity.Class = DDD_ENTITY_MESH ..
			    Or Entity.Class = DDD_ENTITY_MD3) ..
			   And Entity.Visible = True Then

				glPushMatrix()
				Entity.Render(Self)
				glPopMatrix()
			EndIf
		Next
	End Method
End Type