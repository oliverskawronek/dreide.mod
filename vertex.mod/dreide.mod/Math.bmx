SuperStrict

Import BRL.Math

Type TMatrix4
	Function SetZero(Matrix:Float[])
		Local I : Int

		Rem
			| 0 0 0 0 |
			| 0 0 0 0 |
			| 0 0 0 0 |
			| 0 0 0 0 |
		End Rem

		For I = 0 To 15
			Matrix[I] = 0.0
		Next
	End Function

	Function SetIdentity(Matrix:Float[])
		Rem
			| 1 0 0 0 |
			| 0 1 0 0 |
			| 0 0 1 0 |
			| 0 0 0 1 |
		End Rem

		TMatrix4.SetZero(Matrix)
		Matrix[ 0] = 1.0
		Matrix[ 5] = 1.0
		Matrix[10] = 1.0
		Matrix[15] = 1.0
	End Function
End Type

Type TQuaternion
	Function Scale(Q:Float[], Scalar:Float, R:Float[])
		R[0] = Q[0] * Scalar
		R[1] = Q[1] * Scalar
		R[2] = Q[2] * Scalar
		R[3] = Q[3] * Scalar
	End Function

	Function Add(A:Float[], B:Float[], R:Float[])
		R[0] = A[0]+B[0]
		R[1] = A[1]+B[1]
		R[2] = A[2]+B[2]
		R[3] = A[3]+B[3]
	End Function

	Function Length:Float(Q:Float[])
		Return Sqr(Q[0]*Q[0]+Q[1]*Q[1]+Q[2]*Q[2]+Q[3]*Q[3])
	End Function

	Function Normalize(Q:Float[], R:Float[])
		Local Length  : Float, ..
		      RLength : Float
		
		Length = TQuaternion.Length(Q)
		If Length = 0.0 Then Length = 1.0
		RLength = 1.0/Length
		
		R[0] = Q[0]*RLength
		R[1] = Q[1]*RLength
		R[2] = Q[2]*RLength
		R[3] = Q[3]*RLength
	End Function

	Function Dot:Float(Q:Float[])
		Return Q[0]*Q[0] + Q[1]*Q[1] + Q[2]*Q[2] + Q[3]*Q[3]
	End Function

	Function Slerp(A:Float[], B:Float[], R:Float[], T:Float)
		Local Temp : Float[4], ..
		      D    : Float, ..
		      B2   : Float, ..
		      OM   : Float, ..
		      SI   : Float, ..
		      C0   : Float, ..
		      C1   : Float

		MemCopy(Temp, B, 16)
		D = TQuaternion.Dot(B)
		B2 = 1-T

		If D<0 Then
			Temp[0] = -Temp[0]
			Temp[1] = -Temp[1]
			Temp[2] = -Temp[2]
			Temp[3] = -Temp[3]
			D = -D
		EndIf

		If D < (0.9999) Then
			OM = ACos(D)
			SI = Sin(OM)
			C0 = Sin(T*OM)/SI
			C1 = Sin(B2*OM)/SI
		Else
			C0 = T
			C1 = B2
		EndIf

		TQuaternion.Scale(A, C1, R)
		TQuaternion.Scale(Temp, C0, Temp)
		TQuaternion.Add(R, Temp, R)
	End Function
End Type

Type TFrustum
	Function SetPerspective(Matrix:Float[], Zoom:Float, Aspect:Float, Near:Float, ..
	                        Far:Float)
		Local FPN : Float, ..
		      NMF : Float

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

		Matrix[ 0] = Zoom/Aspect
		Matrix[ 1] = 0.0
		Matrix[ 2] = 0.0
		Matrix[ 3] = 0.0

		Matrix[ 4] = 0.0
		Matrix[ 5] = Zoom
		Matrix[ 6] = 0.0
		Matrix[ 7] = 0.0

		Matrix[ 8] = 0.0
		Matrix[ 9] = 0.0
		Matrix[10] = FPN/NMF
		Matrix[11] = 2*FPN/NMF

		Matrix[12] = 0.0
		Matrix[13] = 0.0
		Matrix[14] = -1.0
		Matrix[15] = 0.0
	End Function
	
	Function SetOrtho(Matrix:Float[], Zoom:Float, Left:Float, Right:Float, ..
	                  Bottom:Float, Top:Float, Near:Float, Far:Float)

		Local RML : Float, ..
		      TMB : Float, ..
		      FMN : Float

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

		Matrix[ 0] = 2.0/RML
		Matrix[ 1] = 0.0
		Matrix[ 2] = 0.0
		Matrix[ 3] = 0.0

		Matrix[ 4] = 0.0
		Matrix[ 5] = 2.0/TMB
		Matrix[ 6] = 0.0
		Matrix[ 7] = 0.0

		Matrix[ 8] = 0.0
		Matrix[ 9] = 0.0
		Matrix[10] = -2.0/FMN
		Matrix[11] = 0.0

		Matrix[12] = -((Right+Left)/RML)
		Matrix[13] = -((Top+Bottom)/TMB)
		Matrix[14] = -((Far+Near)/FMN)
		Matrix[15] = 1.0
	End Function
End Type