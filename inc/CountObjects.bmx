Function SMINC(sm:StringMap,t$)
Local A=sm.value(t).toint()+1
MapInsert sm,t,A+""
End Function

Function CountObjects()
Local sm:StringMap = New StringMap
Local k$,o:TKthuraObject
' Prepare
kthmap.totalremap
' Grand total
MapInsert sm,"ZZZZ.Grand Total",CountList(kthmap.fullobjectlist)+""
' Labelled stuff
For k=EachIn MapKeys(kthmap.Labelmap)
	If Not k
		MapInsert sm,"Unlabelled",""+CountList(kthmap.labelmap.list(k))	
	Else
		MapInsert sm,"Labelled ~q"+k+"~q",""+CountList(kthmap.labelmap.list(k))
		EndIf
	Next
' Tagged stuff & kinds
For o=EachIn kthmap.fullobjectlist
	If o.tag SMINC sm,"Tagged" Else SMINC sm,"Untagged"
	SMINC sm,"Kind "+o.kind
	Next	
' All counted produce some results
Local szh = 0
For k=EachIn MapKeys(sm)
	If szh<Len(k) szh=Len k
	Next
Local szs$,altk$
For Local i=0 Until szh szs:+" "; Next
For k=EachIn MapKeys(sm)
	altk = k
	If Prefixed(altk,"ZZZZ.") altk=Replace(altk,"ZZZZ.","     ")
	csay Right(szs+altk,szh)+": "+sm.value(k)
	Next
End Function
