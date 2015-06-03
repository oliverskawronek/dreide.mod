SuperStrict

Import brl.math
Import "Error.bmx"

Rem
	Note:

	glLoadIdentity()
	glTranslatef(TX, TY, TZ)
	glRotatef(Pitch, 1.0, 0.0, 0.0)
	glRotatef(Yaw,   0.0, 1.0, 0.0)
	glRotatef(Roll,  0.0, 0.0, 1.0)
	glScalef(SX, SY, SZ)
	
	is equal to

	T.SetTranslate(TX, TY, TZ)
	R.SetRotate(Pitch, Yaw, Roll)
	S.SetScale(SX, SY, SZ)
	T.MultMatrix(R, M)
	M.MultMatrix(S, M)
	glLoadMatrixf(M.Components)

	The multiply sequence is reversed to the OpenGL Sequence, becouse
	you can calculate faster global matrices by multiply parent matrix with
	self local matrix.

	The consequence of this is, that SetRotate, SetTranslate etc. are set
	a transposed matrix.
End Rem

Type TVector4
	Field Components : Float[4]
	
	Method SetZero()
		Self.Components[0] = 0.0
		Self.Components[1] = 0.0
		Self.Components[2] = 0.0
		Self.Components[3] = 0.0
	End Method

	Method Scale(Scalar:Float, Result:TVector4 Var)
		Result.Components[0] = Self.Components[0]*Scalar
		Result.Components[1] = Self.Components[1]*Scalar
		Result.Components[2] = Self.Components[2]*Scalar
		Result.Components[3] = Self.Components[3]*Scalar
	End Method

	Method GetLength:Float()
		Return Sqr(Self.Components[0]*Self.Components[0] + ..
		           Self.Components[1]*Self.Components[1] + ..
		           Self.Components[2]*Self.Components[2] + ..
		           Self.Components[3]*Self.Components[3])
	End Method

	Method Normalize(Result:TVector4 Var)
		Local Length:Float, RLength:Float

		Length = Self.GetLength()
		If Length = 0.0 Then
			Result.SetZero()
		Else
			' Faster as divinding by Length
			RLength = 1.0/Length
			Result.Scale(RLength, Result)
		EndIf
	End Method

	Method GetDotProduct:Float(Vector:TVector4 Var)
		Return Self.Components[0]*Vector.Components[0] + ..
		       Self.Components[1]*Vector.Components[1] + ..
		       Self.Components[2]*Vector.Components[2] + ..
		       Self.Components[3]*Vector.Components[3]
	End Method

	Method CrossProduct(Vector:TVector4 Var, Result:TVector4 Var)
		Result.Components[0] = Self.Components[1]*Vector.Components[2] - ..
		                       Self.Components[2]*Vector.Components[1]

		Result.Components[1] = Self.Components[2]*Vector.Components[0] - ..
		                       Self.Components[0]*Vector.Components[2]

		Result.Components[2] = Self.Components[0]*Vector.Components[1] - ..
		                       Self.Components[1]*Vector.Components[0]

		If (Self.Components[3] = 0.0) And (Vector.Components[3] = 0.0) Then
			Result.Components[3] = 0.0
		Else
			Result.Components[3] = 1.0
		EndIf 
	End Method

	Method MultMatrix(Matrix:TMatrix4, Result:TVector4 Var)
		Result.Components[0] = Self.Components[0]*Matrix.Components[0, 0] + ..
		                       Self.Components[1]*Matrix.Components[1, 0] + ..
		                       Self.Components[2]*Matrix.Components[2, 0] + ..
		                       Self.Components[3]*Matrix.Components[3, 0]

		Result.Components[1] = Self.Components[0]*Matrix.Components[0, 1] + ..
		                       Self.Components[1]*Matrix.Components[1, 1] + ..
		                       Self.Components[2]*Matrix.Components[2, 1] + ..
		                       Self.Components[3]*Matrix.Components[3, 1]

		Result.Components[2] = Self.Components[0]*Matrix.Components[0, 2] + ..
		                       Self.Components[1]*Matrix.Components[1, 2] + ..
		                       Self.Components[2]*Matrix.Components[2, 2] + ..
		                       Self.Components[3]*Matrix.Components[3, 2]

		Result.Components[3] = Self.Components[0]*Matrix.Components[0, 3] + ..
		                       Self.Components[1]*Matrix.Components[1, 3] + ..
		                       Self.Components[2]*Matrix.Components[2, 3] + ..
		                       Self.Components[3]*Matrix.Components[3, 3]
	End Method
End Type

Type TMatrix4
	Field Components : Float[4, 4]

	Method SetZero()
		Rem
			| 0 0 0 0 |
			| 0 0 0 0 |
			| 0 0 0 0 |
			| 0 0 0 0 |
		End Rem

		Self.Components[0, 0] = 0.0 ; Self.Components[0, 1] = 0.0
		Self.Components[0, 2] = 0.0 ; Self.Components[0, 3] = 0.0
		Self.Components[1, 0] = 0.0 ; Self.Components[1, 1] = 0.0
		Self.Components[1, 2] = 0.0 ; Self.Components[1, 3] = 0.0
		Self.Components[2, 0] = 0.0 ; Self.Components[2, 1] = 0.0
		Self.Components[2, 2] = 0.0 ; Self.Components[2, 3] = 0.0
		Self.Components[3, 0] = 0.0 ; Self.Components[3, 1] = 0.0
		Self.Components[3, 2] = 0.0 ; Self.Components[3, 3] = 0.0
	End Method

	Method SetIdentity()
		Rem
			| 1 0 0 0 |
			| 0 1 0 0 |
			| 0 0 1 0 |
			| 0 0 0 1 |
		End Rem

		Self.Components[0, 0] = 1.0 ; Self.Components[0, 1] = 0.0
		Self.Components[0, 2] = 0.0 ; Self.Components[0, 3] = 0.0
		Self.Components[1, 0] = 0.0 ; Self.Components[1, 1] = 1.0
		Self.Components[1, 2] = 0.0 ; Self.Components[1, 3] = 0.0
		Self.Components[2, 0] = 0.0 ; Self.Components[2, 1] = 0.0
		Self.Components[2, 2] = 1.0 ; Self.Components[2, 3] = 0.0
		Self.Components[3, 0] = 0.0 ; Self.Components[3, 1] = 0.0
		Self.Components[3, 2] = 0.0 ; Self.Components[3, 3] = 1.0
	End Method

	Method SetScale(X:Float, Y:Float, Z:Float)
		Rem
			| X 0 0 0 |
			| 0 Y 0 0 |
			| 0 0 Z 0 |
			| 0 0 0 1 |
		End Rem

		Self.Components[0, 0] = X   ; Self.Components[0, 1] = 0.0
		Self.Components[0, 2] = 0.0 ; Self.Components[0, 3] = 0.0
		Self.Components[1, 0] = 0.0 ; Self.Components[1, 1] = Y
		Self.Components[1, 2] = 0.0 ; Self.Components[1, 3] = 0.0
		Self.Components[2, 0] = 0.0 ; Self.Components[2, 1] = 0.0
		Self.Components[2, 2] = Z   ; Self.Components[2, 3] = 0.0
		Self.Components[3, 0] = 0.0 ; Self.Components[3, 1] = 0.0
		Self.Components[3, 2] = 0.0 ; Self.Components[3, 3] = 1.0
	End Method

	Method SetTranslate(X:Float, Y:Float, Z:Float)
		Rem
			| 1 0 0 0 |
			| 0 1 0 0 |
			| 0 0 1 0 |
			| X Y Z 1 |
		End Rem

		Self.Components[0, 0] = 1.0 ; Self.Components[0, 1] = 0.0
		Self.Components[0, 2] = 0.0 ; Self.Components[0, 3] = 0.0
		Self.Components[1, 0] = 0.0 ; Self.Components[1, 1] = 1.0
		Self.Components[1, 2] = 0.0 ; Self.Components[1, 3] = 0.0
		Self.Components[2, 0] = 0.0 ; Self.Components[2, 1] = 0.0
		Self.Components[2, 2] = 1.0 ; Self.Components[2, 3] = 0.0
		Self.Components[3, 0] = X   ; Self.Components[3, 1] = Y
		Self.Components[3, 2] = Z   ; Self.Components[3, 3] = 1.0
	End Method

	Method SetAxisAngle(Angle:Float, X:Float, Y:Float, Z:Float)
		Local QW:Float, QX:Float, QY:Float, QZ:Float, SineHalfAngle:Float
		Local XX:Float, XY:Float, XZ:Float, XW:Float
		Local YY:Float, YZ:Float, YW:Float, ZZ:Float, ZW:Float

		Rem
			q = (cos(a/2), xsin(a/2), ysin(a/2), zsin(a/2))		

			| 1-2(YY+ZZ) 2(XY+ZW)   2(XZ-YW)   0 |
			| 2(XY-ZW)   1-2(XX+ZZ) 2(YZ+XW)   0 |
			| 2(XZ+YW)   2(YZ-XW)   1-2(XX+YY) 0 |
			| 0          0          0          1 |
		End Rem

		SineHalfAngle = Sin(Angle*0.5)
		QW = Cos(Angle*0.5)
		QX = X*SineHalfAngle
		QY = Y*SineHalfAngle
		QZ = Z*SineHalfAngle

		XX = QX*QX ; XY = QX*QY ; XZ = QX*QZ ; XW = QX*QW
		YY = QY*QY ; YZ = QY*QZ ; YW = QY*QW ; ZZ = QZ*QZ
		ZW = QZ*QW

		Self.Components[0, 0] = 1.0-2.0*(YY+ZZ)
		Self.Components[1, 0] = 2.0*(XY-ZW)
		Self.Components[2, 0] = 2.0*(XZ+YW)
		Self.Components[3, 0] = 0.0

		Self.Components[0, 1] = 2.0*(XY+ZW)
		Self.Components[1, 1] = 1.0-2.0*(XX+ZZ)
		Self.Components[2, 1] = 2.0*(YZ-XW)
		Self.Components[3, 1] = 0.0

		Self.Components[0, 2] = 2.0*(XZ-YW)
		Self.Components[1, 2] = 2.0*(YZ+XW)
		Self.Components[2, 2] = 1.0-2.0*(XX+YY)
		Self.Components[3, 2] = 0.0

		Self.Components[0, 3] = 0.0
		Self.Components[1, 3] = 0.0
		Self.Components[2, 3] = 0.0
		Self.Components[3, 3] = 1.0
	End Method

	Method SetRotate(Pitch:Float, Yaw:Float, Roll:Float)
		Local Temp:TMatrix4, Temp2:TMatrix4

		Rem
			Pitch:        Yaw:          Roll:

			| 1 0 0 0 |   | Y 0 Y 0 |   | R R 0 0 |
			| 0 P P 0 |   | 0 1 0 0 |   | R R 0 0 |
			| 0 P P 0 |   | Y 0 Y 0 |   | 0 0 1 0 |
			| 0 0 0 1 |   | 0 0 0 1 |   | 0 0 0 1 |


			(reduce calculating extreme!)

			Roll x Yaw:        (Roll x Yaw) x Pitch:

			        | Y 0 Y |           | 1 0 0 |
			        | 0 1 0 |           | 0 P P |
			        | Y 0 Y |           | 0 P P |
			+-------+-------+   +-------+-------+
			| R R 0 | A R A |   | A A A | A B B |
			| R R 0 | A R A |   | A A A | A B B |
			| 0 0 1 | Y 0 Y |   | A 0 A | A B B |
		End Rem

		Temp  = New TMatrix4
		Temp2 = New TMatrix4

		' Self = Roll x Yaw
		Self.SetRoll(Roll)
		Temp.SetYaw(Yaw)

		Temp2.Components[0, 0] = Self.Components[0, 0]*Temp.Components[0, 0]
		Temp2.Components[0, 1] = Self.Components[0, 1]
		Temp2.Components[0, 2] = Self.Components[0, 0]*Temp.Components[0, 2]

		Temp2.Components[1, 0] = Self.Components[1, 0]*Temp.Components[0, 0]
		Temp2.Components[1, 1] = Self.Components[1, 1]
		Temp2.Components[1, 2] = Self.Components[1, 0]*Temp.Components[0, 2]

		Temp2.Components[2, 0] = Temp.Components[2, 0]
		Temp2.Components[2, 1] = 0.0
		Temp2.Components[2, 2] = Temp.Components[2, 2]

		' Self = (Roll x Yaw) x Pitch
		Temp.SetPitch(Pitch)

		Self.Components[0, 0] = Temp2.Components[0, 0]
		Self.Components[0, 1] = Temp2.Components[0, 1]*Temp.Components[1, 1]+ ..
		                        Temp2.Components[0, 2]*Temp.Components[2, 1]
		Self.Components[0, 2] = Temp2.Components[0, 1]*Temp.Components[1, 2]+ ..
		                        Temp2.Components[0, 2]*Temp.Components[2, 2]

		Self.Components[1, 0] = Temp2.Components[1, 0]
		Self.Components[1, 1] = Temp2.Components[1, 1]*Temp.Components[1, 1]+ ..
		                        Temp2.Components[1, 2]*Temp.Components[2, 1]
		Self.Components[1, 2] = Temp2.Components[1, 1]*Temp.Components[1, 2]+ ..
		                        Temp2.Components[1, 2]*Temp.Components[2, 2]

		Self.Components[2, 0] = Temp2.Components[2, 0]
		Self.Components[2, 1] = Temp2.Components[2, 2]*Temp.Components[2, 1]
		Self.Components[2, 2] = Temp2.Components[2, 2]*Temp.Components[2, 2]
	End Method

	Method SetPitch(Angle:Float)
		Local QW:Float, QX:Float, XX:Float, XW:Float

		If Angle = 0.0 Then
			Self.SetIdentity()
			Return
		EndIf

		Rem
			q = (cos(a/2), sin(a/2), 0, 0)		

			| 1 0      0     0 |
			| 0 1-2XX  2XW   0 |
			| 0 2(-XW) 1-2XX 0 |
			| 0 0      0     1 |
		End Rem

		QW = Cos(Angle*0.5)
		QX = Sin(Angle*0.5)
		XX = QX*QX
		XW = QX*QW

		Self.Components[0, 0] = 1.0
		Self.Components[1, 0] = 0.0
		Self.Components[2, 0] = 0.0
		Self.Components[3, 0] = 0.0

		Self.Components[0, 1] = 0.0
		Self.Components[1, 1] = 1.0-2.0*XX
		Self.Components[2, 1] = 2.0*(-XW)
		Self.Components[3, 1] = 0.0

		Self.Components[0, 2] = 0.0
		Self.Components[1, 2] = 2.0*XW
		Self.Components[2, 2] = 1.0-2.0*XX
		Self.Components[3, 2] = 0.0

		Self.Components[0, 3] = 0.0
		Self.Components[1, 3] = 0.0
		Self.Components[2, 3] = 0.0
		Self.Components[3, 3] = 1.0
	End Method

	Method SetYaw(Angle:Float)
		Local QW:Float, QY:Float, YY:Float, YW:Float

		If Angle = 0.0 Then
			Self.SetIdentity()
			Return
		EndIf

		Rem
			q = (cos(a/2), 0, sin(a/2), 0)		

			| 1-2YY 0 2(YW) 0 |
			| 0     1 0     0 |
			| 2YW   0 1-2YY 0 |
			| 0     0 0     1 |
		End Rem

		QW = Cos(Angle*0.5)
		QY = Sin(Angle*0.5)
		YY = QY*QY
		YW = QY*QW

		Self.Components[0, 0] = 1.0-2.0*YY
		Self.Components[1, 0] = 0.0
		Self.Components[2, 0] = 2.0*YW
		Self.Components[3, 0] = 0.0

		Self.Components[0, 1] = 0.0
		Self.Components[1, 1] = 1.0
		Self.Components[2, 1] = 0.0
		Self.Components[3, 1] = 0.0

		Self.Components[0, 2] = 2.0*(-YW)
		Self.Components[1, 2] = 0.0
		Self.Components[2, 2] = 1.0-2.0*YY
		Self.Components[3, 2] = 0.0

		Self.Components[0, 3] = 0.0
		Self.Components[1, 3] = 0.0
		Self.Components[2, 3] = 0.0
		Self.Components[3, 3] = 1.0
	End Method

	Method SetRoll(Angle:Float)
		Local QW:Float, QZ:Float, ZZ:Float, ZW:Float

		If Angle = 0.0 Then
			Self.SetIdentity()
			Return
		EndIf

		Rem
			q = (cos(a/2), 0, 0, sin(a/2))		

			| 1-2ZZ   2ZW   0 0 |
			| 2*(-ZW) 1-2ZZ 0 0 |
			| 0       0     1 0 |
			| 0       0     0 1 |
		End Rem

		QW = Cos(Angle*0.5)
		QZ = Sin(Angle*0.5)
		ZZ = QZ*QZ
		ZW = QZ*QW

		Self.Components[0, 0] = 1.0-2.0*ZZ
		Self.Components[1, 0] = 2.0*(-ZW)
		Self.Components[2, 0] = 0.0
		Self.Components[3, 0] = 0.0

		Self.Components[0, 1] = 2.0*ZW
		Self.Components[1, 1] = 1.0-2.0*ZZ
		Self.Components[2, 1] = 0.0
		Self.Components[3, 1] = 0.0

		Self.Components[0, 2] = 0.0
		Self.Components[1, 2] = 0.0
		Self.Components[2, 2] = 1.0
		Self.Components[3, 2] = 0.0

		Self.Components[0, 3] = 0.0
		Self.Components[1, 3] = 0.0
		Self.Components[2, 3] = 0.0
		Self.Components[3, 3] = 1.0
	End Method

	Method Transpose(Result:TMatrix4 Var)
		Rem
			| a b c d | -> | a e i m |
			| e f g h |    | b f j n |
			| i j k l |    | c g k o |
			| m n o p |    | d h l p |
		End Rem

		Result.Components[0, 0] = Self.Components[0, 0]
		Result.Components[0, 1] = Self.Components[1, 0]
		Result.Components[0, 2] = Self.Components[2, 0]
		Result.Components[0, 3] = Self.Components[3, 0]
		Result.Components[1, 0] = Self.Components[0, 1]
		Result.Components[1, 1] = Self.Components[1, 1]
		Result.Components[1, 2] = Self.Components[2, 1]
		Result.Components[1, 3] = Self.Components[3, 1]
		Result.Components[2, 0] = Self.Components[0, 2]
		Result.Components[2, 1] = Self.Components[1, 2]
		Result.Components[2, 2] = Self.Components[2, 2]
		Result.Components[2, 3] = Self.Components[3, 2]
		Result.Components[3, 0] = Self.Components[0, 3]
		Result.Components[3, 1] = Self.Components[1, 3]
		Result.Components[3, 2] = Self.Components[2, 3]
		Result.Components[3, 3] = Self.Components[3, 3]
	End Method

	Method RTInvert(Result:TMatrix4 Var)
		Self.Transpose(Result)
		
		Result.Components[3, 0] = -(Self.Components[3, 0]*Result.Components[0, 0]+ ..
		                            Self.Components[3, 1]*Result.Components[1, 0]+ ..
		                            Self.Components[3, 2]*Result.Components[2, 0]+ ..
		                            Self.Components[3, 3]*Result.Components[3, 0])

		Result.Components[3, 1] = -(Self.Components[3, 0]*Result.Components[0, 1]+ ..
		                            Self.Components[3, 1]*Result.Components[1, 1]+ ..
		                            Self.Components[3, 2]*Result.Components[2, 1]+ ..
		                            Self.Components[3, 3]*Result.Components[3, 1])

		Result.Components[3, 2] = -(Self.Components[3, 0]*Result.Components[0, 2]+ ..
		                            Self.Components[3, 1]*Result.Components[1, 2]+ ..
		                            Self.Components[3, 2]*Result.Components[2, 2]+ ..
		                            Self.Components[3, 3]*Result.Components[3, 2])
	End Method

	Method OrthoNormalize(Result:TMatrix4 Var)
		Local Length:Float, RLength:Float

		Rem
			| a b c d |
			| e f g h | 
			| i j k l |
			| m n o p |
		End Rem

		' Normalize (i, j, k, l)
		Length = Sqr(Self.Components[3, 0]+ ..
		             Self.Components[3, 1]+ ..
		             Self.Components[3, 2]+ ..
		             Self.Components[3, 3])

		If Length = 0.0 Then
			Result.Components[3, 0] = 0.0
			Result.Components[3, 1] = 0.0
			Result.Components[3, 2] = 0.0
			Result.Components[3, 3] = 0.0
		Else
			RLength = 1.0/Length
			Result.Components[3, 0] = Self.Components[3, 0]*RLength
			Result.Components[3, 1] = Self.Components[3, 1]*RLength
			Result.Components[3, 2] = Self.Components[3, 2]*RLength
			Result.Components[3, 3] = Self.Components[3, 3]*RLength
		EndIf

		' (a, b, c, d) = CrossProduct((e, f, g, h), (i, j, k, l))
		Result.Components[0, 0] = Self.Components[1, 1]*Result.Components[2, 2]- ..
		                          Self.Components[1, 2]*Result.Components[2, 1]

		Result.Components[0, 1] = Self.Components[1, 2]*Result.Components[2, 0]- ..
		                          Self.Components[1, 0]*Result.Components[2, 2]

		Result.Components[0, 2] = Self.Components[1, 0]*Result.Components[2, 1]- ..
		                          Self.Components[1, 1]*Result.Components[2, 0]

		If (Self.Components[1, 3] = 0.0) And (Result.Components[2, 3] = 0.0) Then
			Result.Components[0, 3] = 0.0
		Else
			Result.Components[0, 3] = 1.0
		EndIf

		' Normalize (a, b, c, d)
		Length = Sqr(Result.Components[0, 0]+ ..
		             Result.Components[0, 1]+ ..
		             Result.Components[0, 2]+ ..
		             Result.Components[0, 3])

		If Length = 0.0 Then
			Result.Components[0, 0] = 0.0
			Result.Components[0, 1] = 0.0
			Result.Components[0, 2] = 0.0
			Result.Components[0, 3] = 0.0
		Else
			RLength = 1.0/Length
			Result.Components[0, 0] = Result.Components[0, 0]*RLength
			Result.Components[0, 1] = Result.Components[1, 1]*RLength
			Result.Components[0, 2] = Result.Components[2, 2]*RLength
			Result.Components[0, 3] = Result.Components[3, 3]*RLength
		EndIf

		' (e, f, g, h) = CrossProduct((i, j, k, l), (a, b, c, d))
		Result.Components[1, 0] = Self.Components[2, 1]*Result.Components[0, 2]- ..
		                          Self.Components[2, 2]*Result.Components[0, 1]

		Result.Components[1, 1] = Self.Components[2, 2]*Result.Components[0, 0]- ..
		                          Self.Components[2, 0]*Result.Components[0, 2]

		Result.Components[1, 2] = Self.Components[2, 0]*Result.Components[0, 1]- ..
		                          Self.Components[2, 1]*Result.Components[0, 0]

		If (Result.Components[2, 3] = 0.0) And (Result.Components[0, 3] = 0.0) Then
			Result.Components[1, 3] = 0.0
		Else
			Result.Components[1, 3] = 1.0
		EndIf

		' (m, n, o, p)
		Result.Components[3, 0] = Self.Components[3, 0]
		Result.Components[3, 1] = Self.Components[3, 1]
		Result.Components[3, 2] = Self.Components[3, 2]
		Result.Components[3, 3] = Self.Components[3, 3]
	End Method

	Method MultMatrix(Matrix:TMatrix4 Var, Result:TMatrix4 Var)
		Local Row:Int, Column:Int
		
		For Row = 0 To 3
			For Column = 0 To 3
				Result.Components[Row, Column] = ..
				   Self.Components[Row, 0]*Matrix.Components[0, Column] + ..
				   Self.Components[Row, 1]*Matrix.Components[1, Column] + ..
				   Self.Components[Row, 2]*Matrix.Components[2, Column] + ..
				   Self.Components[Row, 3]*Matrix.Components[3, Column]
			Next
		Next
	End Method
End Type

Type TTransformation
	Field Matrix       : TMatrix4
	Field InvMatrix    : TMatrix4
	Field RotateMatrix : TMatrix4

	Field Scale        : Float[3]
	Field Rotation     : Float[3]
	Field Position     : Float[3]

	Method New()
		Self.Matrix       = New TMatrix4
		Self.InvMatrix    = New TMatrix4
		Self.RotateMatrix = New TMatrix4

		' Faster as Self.Scale = [1.0, 1.0, 1.0]
		Self.Scale[0] = 1.0
		Self.Scale[1] = 1.0
		Self.Scale[2] = 1.0

		' Faster as Self.Rotation = [0.0, 0.0, 0.0]
		Self.Rotation[0] = 0.0
		Self.Rotation[1] = 0.0
		Self.Rotation[2] = 0.0

		' Faster as Self.Position = [0.0, 0.0, 0.0]
		Self.Position[0] = 0.0
		Self.Position[1] = 0.0
		Self.Position[2] = 0.0

		Self.Matrix.SetIdentity()
		Self.InvMatrix.SetIdentity()
		Self.RotateMatrix.SetIdentity()
	End Method

	Method UpdateMatrices()
		MemCopy(Self.Matrix.Components, Self.RotateMatrix.Components, 3*4*4)

		' Faster as Self.Matrix.RTINvert(Self.MatrixInv)
		Self.InvMatrix.Components[0, 0] = Self.RotateMatrix.Components[0, 0]
		Self.InvMatrix.Components[0, 1] = Self.RotateMatrix.Components[1, 0]
		Self.InvMatrix.Components[0, 2] = Self.RotateMatrix.Components[2, 0]

		Self.InvMatrix.Components[1, 0] = Self.RotateMatrix.Components[0, 1]
		Self.InvMatrix.Components[1, 1] = Self.RotateMatrix.Components[1, 1]
		Self.InvMatrix.Components[1, 2] = Self.RotateMatrix.Components[2, 1]

		Self.InvMatrix.Components[2, 0] = Self.RotateMatrix.Components[0, 2]
		Self.InvMatrix.Components[2, 1] = Self.RotateMatrix.Components[1, 2]
		Self.InvMatrix.Components[2, 2] = Self.RotateMatrix.Components[2, 2]

		' Set Position
		Self.Matrix.Components[3, 0] = Self.Position[0]
		Self.Matrix.Components[3, 1] = Self.Position[1]
		Self.Matrix.Components[3, 2] = Self.Position[2]

		Self.InvMatrix.Components[3, 0] = -Self.Position[0]
		Self.InvMatrix.Components[3, 1] = -Self.Position[1]
		Self.InvMatrix.Components[3, 2] = -Self.Position[2]

		' Set Scale
		If Self.Scale[0] <> 1.0 Then
			Self.Matrix.Components[0, 0] :* Self.Scale[0]
			Self.Matrix.Components[0, 1] :* Self.Scale[0]
			Self.Matrix.Components[0, 2] :* Self.Scale[0]

			Self.InvMatrix.Components[0, 0] :* Self.Scale[0]
			Self.InvMatrix.Components[0, 1] :* Self.Scale[0]
			Self.InvMatrix.Components[0, 2] :* Self.Scale[0]
		EndIf

		If Self.Scale[1] <> 1.0 Then
			Self.Matrix.Components[1, 0] :* Self.Scale[1]
			Self.Matrix.Components[1, 1] :* Self.Scale[1]
			Self.Matrix.Components[1, 2] :* Self.Scale[1]

			Self.InvMatrix.Components[1, 0] :* Self.Scale[1]
			Self.InvMatrix.Components[1, 1] :* Self.Scale[1]
			Self.InvMatrix.Components[1, 2] :* Self.Scale[1]
		EndIf

		If Self.Scale[2] <> 1.0 Then
			Self.Matrix.Components[2, 0] :* Self.Scale[2]
			Self.Matrix.Components[2, 1] :* Self.Scale[2]
			Self.Matrix.Components[2, 2] :* Self.Scale[2]

			Self.InvMatrix.Components[2, 0] :* Self.Scale[2]
			Self.InvMatrix.Components[2, 1] :* Self.Scale[2]
			Self.InvMatrix.Components[2, 2] :* Self.Scale[2]
		EndIf
	End Method
End Type

Type TFrustum
	Field Projection     : TMatrix4
	Field Transformation : TTransformation
	Field ClipPlanes     : Float[6, 4]
	
	Method SetPerspective(Zoom:Float, Aspect:Float, Near:Float, Far:Float)
		Local FPN:Float, NMF:Float

		Rem
			|  Zoom                              |
			| ------   0        0         0      |
			| aspect                             |
			|                                    |
			|   0     Zoom      0         0      |
			|                                    |
			|               Far+Near  2*Far+Near |
			|   0      0    --------  ---------- |
			|               Near-Far   Near-Far  |
			|                                    |
			|   0      0       -1         0      |
		End Rem

		FPN = Far+Near
		NMF = Near-Far

		Self.Projection.Components[0, 0] = Zoom/Aspect
		Self.Projection.Components[0, 1] = 0.0
		Self.Projection.Components[0, 2] = 0.0
		Self.Projection.Components[0, 3] = 0.0

		Self.Projection.Components[1, 0] = 0.0
		Self.Projection.Components[1, 1] = Zoom
		Self.Projection.Components[1, 2] = 0.0
		Self.Projection.Components[1, 3] = 0.0

		Self.Projection.Components[2, 0] = 0.0
		Self.Projection.Components[2, 1] = 0.0
		Self.Projection.Components[2, 2] = FPN/NMF
		Self.Projection.Components[2, 3] = 2*FPN/NMF

		Self.Projection.Components[3, 0] = 0.0
		Self.Projection.Components[3, 1] = 0.0
		Self.Projection.Components[3, 2] = -1.0
		Self.Projection.Components[3, 3] = 0.0

		Self.UpdatePlanes()
	End Method

	Method SetOrtho(Zoom:Float, Left:Float, Right:Float, ..
	                            Bottom:Float, Top:Float, ..
	                            Near:Float, Far:Float)

		Local RML:Float, TMB:Float, FMN:Float

		Rem
			|    2*Zoom                                 |
			|  ----------         0            0      0 |
			|  Right-Left                               |
			|                                           |
			|                   2*Zoom                  |
			|      0          ----------       0      0 |
			|                 Top-Bottom                |
			|                                           |
			|                               -2*Zoom     |
			|      0              0         --------  0 |
			|                               Far-Near    |
			|                                           |
			|   Right+Left    Top+Bottom    Far+Near    |
			| - ----------  - ----------  - --------  1 |
			|   Right-Left    Top-Bottom    Far-Near    |
		End Rem

		RML = Right-Left
		TMB = Top-Bottom
		FMN = Far-Near

		Self.Projection.Components[0, 0] = 2.0/RML
		Self.Projection.Components[0, 1] = 0.0
		Self.Projection.Components[0, 2] = 0.0
		Self.Projection.Components[0, 3] = 0.0

		Self.Projection.Components[1, 0] = 0.0
		Self.Projection.Components[1, 1] = 2.0/TMB
		Self.Projection.Components[1, 2] = 0.0
		Self.Projection.Components[1, 3] = 0.0

		Self.Projection.Components[2, 0] = 0.0
		Self.Projection.Components[2, 1] = 0.0
		Self.Projection.Components[2, 2] = -2.0/FMN
		Self.Projection.Components[2, 3] = 0.0

		Self.Projection.Components[3, 0] = -((Right+Left)/RML)
		Self.Projection.Components[3, 1] = -((Top+Bottom)/TMB)
		Self.Projection.Components[3, 2] = -((Far+Near)/FMN)
		Self.Projection.Components[3, 3] = 1.0

		Self.UpdatePlanes()
	End Method

	Method UpdatePlanes()
		Local ClipMatrix:TMatrix4, Index:Int, Length:Float, RLength:Float

		ClipMatrix = New TMatrix4
		Self.Projection.MultMatrix(Self.Transformation.Matrix, ClipMatrix)

		' Right Plane
		Self.ClipPlanes[0, 0] = ClipMatrix.Components[3, 0]-ClipMatrix.Components[0, 0] ' X
		Self.ClipPlanes[0, 1] = ClipMatrix.Components[3, 1]-ClipMatrix.Components[0, 1] ' Y
		Self.ClipPlanes[0, 2] = ClipMatrix.Components[3, 2]-ClipMatrix.Components[0, 2] ' Z
		Self.ClipPlanes[0, 3] = ClipMatrix.Components[3, 3]-ClipMatrix.Components[0, 3] ' D

		' Left Plane
		Self.ClipPlanes[1, 0] = ClipMatrix.Components[3, 0]+ClipMatrix.Components[0, 0] ' X
		Self.ClipPlanes[1, 1] = ClipMatrix.Components[3, 1]+ClipMatrix.Components[0, 1] ' Y
		Self.ClipPlanes[1, 2] = ClipMatrix.Components[3, 2]+ClipMatrix.Components[0, 2] ' Z
		Self.ClipPlanes[1, 3] = ClipMatrix.Components[3, 3]+ClipMatrix.Components[0, 3] ' D

		' Bottom Plane
		Self.ClipPlanes[2, 0] = ClipMatrix.Components[3, 0]+ClipMatrix.Components[1, 0] ' X
		Self.ClipPlanes[2, 1] = ClipMatrix.Components[3, 1]+ClipMatrix.Components[1, 1] ' Y
		Self.ClipPlanes[2, 2] = ClipMatrix.Components[3, 2]+ClipMatrix.Components[1, 2] ' Z
		Self.ClipPlanes[2, 3] = ClipMatrix.Components[3, 3]+ClipMatrix.Components[1, 3] ' D

		' Top Plane
		Self.ClipPlanes[3, 0] = ClipMatrix.Components[3, 0]-ClipMatrix.Components[1, 0] ' X
		Self.ClipPlanes[3, 1] = ClipMatrix.Components[3, 1]-ClipMatrix.Components[1, 1] ' Y
		Self.ClipPlanes[3, 2] = ClipMatrix.Components[3, 2]-ClipMatrix.Components[1, 2] ' Z
		Self.ClipPlanes[3, 3] = ClipMatrix.Components[3, 3]-ClipMatrix.Components[1, 3] ' D

		' Back Plane
		Self.ClipPlanes[4, 0] = ClipMatrix.Components[3, 0]-ClipMatrix.Components[2, 0] ' X
		Self.ClipPlanes[4, 1] = ClipMatrix.Components[3, 1]-ClipMatrix.Components[2, 1] ' Y
		Self.ClipPlanes[4, 2] = ClipMatrix.Components[3, 2]-ClipMatrix.Components[2, 2] ' Z
		Self.ClipPlanes[4, 3] = ClipMatrix.Components[3, 3]-ClipMatrix.Components[2, 3] ' D

		' Front Plane
		Self.ClipPlanes[5, 0] = ClipMatrix.Components[3, 0]+ClipMatrix.Components[2, 0] ' X
		Self.ClipPlanes[5, 1] = ClipMatrix.Components[3, 1]+ClipMatrix.Components[2, 1] ' Y
		Self.ClipPlanes[5, 2] = ClipMatrix.Components[3, 2]+ClipMatrix.Components[2, 2] ' Z
		Self.ClipPlanes[5, 3] = ClipMatrix.Components[3, 3]+ClipMatrix.Components[2, 3] ' D

		' Normalize all Planes
		For Index = 0 To 5
			Length = Sqr(Self.ClipPlanes[Index, 0]+ ..
			             Self.ClipPlanes[Index, 1]+ ..
			             Self.ClipPlanes[Index, 2])

			If Length = 0.0 Then
				Self.ClipPlanes[Index, 0] = 0.0
				Self.ClipPlanes[Index, 1] = 0.0
				Self.ClipPlanes[Index, 2] = 0.0
				Self.ClipPlanes[Index, 3] = 0.0
			Else
				RLength = 1.0/Length
				Self.ClipPlanes[Index, 0] :* RLength
				Self.ClipPlanes[Index, 1] :* RLength
				Self.ClipPlanes[Index, 2] :* RLength
				Self.ClipPlanes[Index, 3] :* RLength
			EndIf
		Next 
	End Method

	Method New()
		Self.Projection     = New TMatrix4
		Self.Transformation = Null
	End Method
End Type