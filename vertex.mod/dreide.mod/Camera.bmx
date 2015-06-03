Strict

Import brl.linkedlist
Import "Error.bmx"
Import "Entity.bmx"
Import "HardwareInfo.bmx"

' Render-Modes
Const DDD_CAMERA_PERSPECTIVE  = %000000000001
Const DDD_CAMERA_ORTHOGONAL   = %000000000010
Const DDD_CAMERA_CLEARZBUFFER = %000000000100
Const DDD_CAMERA_CLEARCOLOR   = %000000001000
Const DDD_CAMERA_FOGENABLE    = %000000010000
Const DDD_CAMERA_FOGLINEAR    = %000000100000
Const DDD_CAMERA_FOGEXP       = %000001000000
Const DDD_CAMERA_FOGEXP2      = %000010000000
Const DDD_CAMERA_SCISSORTEST  = %000100000000
Const DDD_CAMERA_FILL         = %001000000000
Const DDD_CAMERA_WIRE         = %010000000000
Const DDD_CAMERA_DEPTHSORTING = %100000000000

' Camera-Zoom
Const DDD_CAMERA_FOV45:Float = 2.41421366 ' 1.0/Tan(45.0/2.0)
Const DDD_CAMERA_FOV90:Float = 1.00000000 ' 1.0/Tan(90.0/2.0)

Type TCamera Extends TEntity
	Global List : TList

	Field RenderMode     : Int
	Field Frustum        : TFrustum
	Field Viewport       : Int[4]
	Field Zoom           : Float
	Field Range          : Float[2]
	Field ClearColor     : Float[4]
	Field FogColor       : Float[4]
	Field FogRange       : Float[2]

	Method SetDepthSorting(Enable:Int)
		If Enable Then
			' Enable Depthsorting
			Self.RenderMode :| DDD_CAMERA_DEPTHSORTING
		Else
			' Disable Depthsorting
			Self.RenderMode :& (~DDD_CAMERA_DEPTHSORTING)
		EndIf
	End Method

	Method GetDepthSorting:Int()
		Return (Self.RenderMode & DDD_CAMERA_DEPTHSORTING) = DDD_CAMERA_DEPTHSORTING
	End Method

	Method SetProjMode(ProjMode:Int)
		Select ProjMode
			' Perspective Projection
			Case DDD_CAMERA_PERSPECTIVE
				Self.RenderMode :| DDD_CAMERA_PERSPECTIVE
				Self.RenderMode :& (~DDD_CAMERA_ORTHOGONAL)
				Self.UpdateFrustum()

			' Orthogonal Projection
			Case DDD_CAMERA_ORTHOGONAL
				Self.RenderMode :| DDD_CAMERA_ORTHOGONAL
				Self.RenderMode :& (~DDD_CAMERA_PERSPECTIVE)
				Self.UpdateFrustum()

			Default
				TDreiDeError.DisplayError("Projectmode is not supported!")
		End Select
	End Method

	Method GetProjMode:Int()
		Return Self.RenderMode & (DDD_CAMERA_PERSPECTIVE | DDD_CAMERA_ORTHOGONAL)
	End Method

	Method SetClearMode(Mode:Int)
		' Clear every rendering the depthbuffer
		If Mode & DDD_CAMERA_CLEARZBUFFER Then
			Self.RenderMode :| DDD_CAMERA_CLEARZBUFFER
		Else
			Self.RenderMode :& (~DDD_CAMERA_CLEARZBUFFER)
		EndIf

		' Clear every rendering the fragmentbuffer
		If Mode & DDD_CAMERA_CLEARCOLOR Then
			Self.RenderMode :| DDD_CAMERA_CLEARCOLOR
		Else
			Self.RenderMode :& (~DDD_CAMERA_CLEARCOLOR)
		EndIf
	End Method

	Method GetClearMode:Int()
		Return Self.RenderMode & (DDD_CAMERA_CLEARZBUFFER | DDD_CAMERA_CLEARCOLOR)
	End Method

	Method SetFogMode(Mode:Int)
		If Mode & DDD_CAMERA_FOGENABLE Then
			' Enable Fog
			Self.RenderMode :| DDD_CAMERA_FOGENABLE
			Mode :& (~DDD_CAMERA_FOGENABLE)
		Else
			' Disable Fog
			Self.RenderMode :& (~DDD_CAMERA_FOGENABLE)
		EndIf

		Select Mode
			' Linear Fog / f = (end - z) / (end - start)
			Case DDD_CAMERA_FOGLINEAR
				Self.RenderMode :| DDD_CAMERA_FOGLINEAR
				Self.RenderMode :& (~DDD_CAMERA_FOGEXP)
				Self.RenderMode :& (~DDD_CAMERA_FOGEXP2)

			' Exponential Fog / f = e^(-density*z)
			Case DDD_CAMERA_FOGEXP
				Self.RenderMode :| DDD_CAMERA_FOGEXP
				Self.RenderMode :& (~DDD_CAMERA_FOGLINEAR)
				Self.RenderMode :& (~DDD_CAMERA_FOGEXP2)

			' Exponential 2 Fog / f = e^(-density*z)^2
			Case DDD_CAMERA_FOGEXP2
				Self.RenderMode :| DDD_CAMERA_FOGEXP2
				Self.RenderMode :& (~DDD_CAMERA_FOGLINEAR)
				Self.RenderMode :& (~DDD_CAMERA_FOGEXP)

			Default
				TDreiDeError.DisplayError("Fogmode is Not supported!")
		End Select
	End Method

	Method GetFogMode:Int()
		Return Self.RenderMode & (DDD_CAMERA_FOGENABLE ..
		                          | DDD_CAMERA_FOGLINEAR ..
		                          | DDD_CAMERA_FOGEXP ..
		                          | DDD_CAMERA_FOGEXP2)
	End Method

	Method SetFillMode(Mode:Int)
		If Mode & DDD_CAMERA_FILL Then
			' Enable Polygonfilling
			Self.RenderMode :| DDD_CAMERA_FILL
		Else
			' Disable Polygonfilling
			Self.RenderMode :& (~DDD_CAMERA_FILL)
		EndIf

		If Mode & DDD_CAMERA_WIRE Then
			' If Polygonfilling disable then render polygon as lines
			Self.RenderMode :| DDD_CAMERA_WIRE
		Else
			' If Polygonfilling disable then render polygon as points
			Self.RenderMode :& (~DDD_CAMERA_WIRE)
		EndIf
	End Method

	Method GetFillMode:Int()
		Return Self.RenderMode & (DDD_CAMERA_FILL | DDD_CAMERA_WIRE)
	End Method

	Method SetViewport(X:Int, Y:Int, Width:Int, Height:Int)
		If (X => 0) And (Y => 0) And (Width > 0) And (Height > 0) Then
			If (X = 0) And (Y = 0) And (Width = THardwareInfo.ScreenWidth) And ..
			   (Height = THardwareInfo.ScreenHeight) Then
				Self.RenderMode :& (~DDD_CAMERA_SCISSORTEST)
			Else
				Self.RenderMode :| DDD_CAMERA_SCISSORTEST
			EndIf
			Self.Viewport = [X, Y, Width, Height]
			Self.UpdateFrustum()
		Else
			TDreiDeError.DisplayError("Viewport resultion is not supported!")
		EndIf
	End Method

	Method GetViewport(X:Int Var, Y:Int Var, Width:Int Var, Height:Int Var)
		X      = Self.Viewport[0]
		Y      = Self.Viewport[1]
		Width  = Self.Viewport[2]
		Height = Self.Viewport[3]
	End Method

	Method GetViewportX:Int()
		Return Self.Viewport[0]
	End Method

	Method GetViewportY:Int()
		Return Self.Viewport[1]
	End Method

	Method GetViewportWidth:Int()
		Return Self.Viewport[2]
	End Method

	Method GetViewportHeight:Int()
		Return Self.Viewport[3]
	End Method

	Method SetZoom(Zoom:Float)
		If Zoom > 0.0 Then
			Self.Zoom = Zoom
			Self.UpdateFrustum()
		Else
			TDreiDeError.DisplayError("Zoom have to be greater than 0.0!")
		EndIf
	End Method

	Method GetZoom:Float()
		Return Self.Zoom
	End Method

	Method SetRange(Near:Float, Far:Float)
		If (Near > 0.0) And (Far > Near) Then
			Self.Range[0] = Near
			Self.Range[1] = Far
			Self.UpdateFrustum()
		Else
			TDreiDeError.DisplayError("Range is not supported!")
		EndIf
	End Method

	Method GetRange(Near:Float Var, Far:Float Var)
		Near = Self.Range[0]
		Far  = Self.Range[1]
	End Method

	Method GetRangeNear:Float()
		Return Self.Range[0]
	End Method

	Method GetRangeFar:Float()
		Return Self.Range[1]
	End Method

	Method UpdateFrustum()
		' Set Projection-Mode
		Select Self.RenderMode & (DDD_CAMERA_PERSPECTIVE | DDD_CAMERA_ORTHOGONAL)
			Case DDD_CAMERA_PERSPECTIVE
				Self.Frustum.SetPerspective(Self.Zoom, Float(Self.Viewport[2])/..
				                            Float(Self.Viewport[3]), Self.Range[0], ..
				                            Self.Range[1])

			Case DDD_CAMERA_ORTHOGONAL
				Self.Frustum.SetOrtho(Self.Zoom, Float(Self.Viewport[0]), Float(Self.Viewport[2]), ..
				                      Float(Self.Viewport[1]), Float(Self.Viewport[3]), ..
				                      Self.Range[0], Self.Range[1])
		End Select

	End Method

	Method SetClearColor(Red:Float, Green:Float, Blue:Float)
		Self.ClearColor[0] = Red
		Self.ClearColor[1] = Green
		Self.ClearColor[2] = Blue
	End Method

	Method GetClearColor(Red:Float Var, Green:Float Var, Blue:Float Var)
		Red   = Self.ClearColor[0]
		Green = Self.ClearColor[1]
		Blue  = Self.ClearColor[2]
	End Method

	Method GetClearRed:Float()
		Return Self.ClearColor[0]
	End Method

	Method GetClearGreen:Float()
		Return Self.ClearColor[1]
	End Method

	Method GetClearBlue:Float()
		Return Self.ClearColor[2]
	End Method

	Method SetFogColor(Red:Float, Green:Float, Blue:Float)
		Self.FogColor[0] = Red
		Self.FogColor[1] = Green
		Self.FogColor[2] = Blue
	End Method

	Method GetFogColor(Red:Float Var, Green:Float Var, Blue:Float Var)
		Red   = Self.FogColor[0]
		Green = Self.FogColor[1]
		Blue  = Self.FogColor[2]
	End Method

	Method GetFogRed:Float()
		Return Self.FogColor[0]
	End Method

	Method GetFogGreen:Float()
		Return Self.FogColor[1]
	End Method

	Method GetFogBlue:Float()
		Return Self.FogColor[2]
	End Method

	Method SetFogRange(Near:Float, Far:Float)
		If (Near > 0.0) And (Far > Near) Then
			Self.FogRange[0] = Near
			Self.FogRange[1] = Far
		Else
			TDreiDeError.DisplayError("Range is not supported!")
		EndIf
	End Method

	Method GetFogRange(Near:Float Var, Far:Float Var)
		Near = Self.FogRange[0]
		Far  = Self.FogRange[1]
	End Method

	Method GetFogRangeNear:Float()
		Return Self.FogRange[0]
	End Method

	Method GetFogRangeFar:Float()
		Return Self.FogRange[1]
	End Method

	Method Project:Int(X3D:Float, Y3D:Float, Z3D:Float, ..
	                   X2D:Float Var, Y2D:Float, Z2D:Float)
	
		
	End Method

	Method Render()
		Local ParentList:TList, Parent:TEntity, Entity:TEntity

		' Check for Scissortest
		If Self.RenderMode & DDD_CAMERA_SCISSORTEST Then
			glEnable(GL_SCISSOR_TEST)
			glScissor(Self.Viewport[0], Self.Viewport[1], Self.Viewport[2], Self.Viewport[3])
		Else 
			glDisable(GL_SCISSOR_TEST)
		EndIf

		' Set Viewport
		glViewport(Self.Viewport[0], Self.Viewport[1], Self.Viewport[2], Self.Viewport[3])

		glMatrixMode(GL_PROJECTION)
		glLoadMatrixf(Self.Frustum.Projection.Components)

		' Z Buffer-Clearing enabled?
		If Self.RenderMode & DDD_CAMERA_CLEARZBUFFER Then
			glEnable(GL_DEPTH_TEST)
			glDepthFunc(GL_LEQUAL)
			glClear(GL_DEPTH_BUFFER_BIT)
		EndIf

		' ColorBuffer-Clearing enabled?
		If Self.RenderMode & DDD_CAMERA_CLEARCOLOR Then
			glClearColor(Self.ClearColor[0], Self.ClearColor[1], Self.ClearColor[2], 1.0)
			glClear(GL_COLOR_BUFFER_BIT)
		EndIf

		If Self.RenderMode & DDD_CAMERA_FOGENABLE Then
			glEnable(GL_FOG)

			' Select FogMode
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

		' Set Transformation
		glMatrixMode(GL_MODELVIEW)
		If Self.Parent Then
			ParentList = CreateList()

			Parent = Self.Parent
			Repeat
				ParentList.AddFirst(Parent)
				Parent = Parent.Parent
			Until Not Parent

			glLoadIdentity()
			For Parent = EachIn ParentList
				glMultMatrixf(Parent.Transformation.InvMatrix.Components)
			Next

			glMultMatrixf(Self.Transformation.Matrix.Components)
		Else
			glLoadMatrixf(Self.Transformation.InvMatrix.Components)
		EndIf

		' Render all visible renderable Entitys
		For Entity = EachIn TEntity.List
			If (Entity.Class = DDD_ENTITY_MESH) Or ..
			   (Entity.Class = DDD_ENTITY_MD3) And ..
			   Entity.Visible Then

				glPushMatrix()
				Entity.Render()
				glPopMatrix()
			EndIf
		Next
	End Method

	Method New()
		Self.Class  = DDD_ENTITY_CAMERA
		Self.Name   = "Unnamed Camera"

		Self.RenderMode = DDD_CAMERA_PERSPECTIVE ..
		                  | DDD_CAMERA_CLEARZBUFFER ..
		                  | DDD_CAMERA_CLEARCOLOR ..
		                  | DDD_CAMERA_FOGEXP2 ..
		                  | DDD_CAMERA_FILL ..
		                  | DDD_CAMERA_WIRE
		Self.Frustum    = New TFrustum
		Self.Viewport   = [0, 0, THardwareInfo.ScreenWidth, THardwareInfo.ScreenHeight]
		Self.Zoom       = DDD_CAMERA_FOV45
		Self.Range      = [1.0, 1000.0]
		Self.ClearColor = [0.0, 0.0, 0.0, 1.0]
		Self.FogColor   = [0.0, 0.0, 0.0, 1.0]
		Self.FogRange   = [1.0, 1000.0]

		Self.Frustum.Transformation = Self.Transformation
		Self.UpdateFrustum()


		TCamera.List.AddLast(Self)
	End Method

	Method Remove()
		TCamera.List.Remove(Self)
		TEntity.List.Remove(Self)
	End Method
End Type