SuperStrict

Import brl.system
Import brl.max2d
Import brl.glmax2d
?Linux
	Import "-lX11"
	Import "-lXxf86vm"
?
Import pub.opengl

Type TDreiDeError
	Function DisplayError(Message:String)
		' Display Message
		Notify(Message, True)

		' Destroy RenderConext
		EndGraphics()

		End
	End Function
End Type