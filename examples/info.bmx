Framework brl.blitz
Import vertex.dreide

Rem
	Please make sure, that you have "Build GUI App" disabled
End Rem

TDreiDe.Graphics3D(100, 100, 0, 0, False)

TDreiDe.DisplayStatus()
Print ""
THardwareInfo.DisplayInfo()

Input("Press Enter: ")
EndGraphics()
End