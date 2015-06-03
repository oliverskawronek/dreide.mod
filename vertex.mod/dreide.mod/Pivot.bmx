SuperStrict

Import brl.linkedlist
Import "Entity.bmx"

Type TPivot Extends TEntity
	Global List : TList

	Method Render()
	End Method

	Method New()
		Self.Class  = DDD_ENTITY_PIVOT
		Self.Name   = "Unnamed Pivot"

		TPivot.List.AddLast(Self)
	End Method

	Method Remove()
		TPivot.List.Remove(Self)
		TEntity.List.Remove(Self)
	End Method
End Type