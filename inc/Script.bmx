Type TLuaSPOT ' BLD: Object SPOT\nObject used for spot placement and showing

	Field ME:TKthuraObject ' BLD: This object is assigned by the editor prior to calling the spot functions. This way the script can act upon the spot accordingly. Notable fields<ul><li>X</li><li>Y</li><li>Tag (this value in this tag must be unique or Kthura will crash out completely!)</li></ul>
	
	Method DrawMe() ' BLD: Draws a marker on screen where the spot is located
	If Not ME Return CSay("? ERROR! A DrawMe request was done, while SPOTS.ME is currently not in use")
	DrawSpot ME,ME.R,ME.G,ME.B
	End Method
	
	End Type
	
Global LuaSPOT:TLuaSpot = New tluaspot
GALE_Register luaspot,"SPOT"

Type TLuaTags ' BLD: Object TAGS\nObject used for tagging issues

	Function Exists(Tag$) ' BLD: Returns 1 if the tag exists and 0 if the tag does not exist. Please note Lua deems both values true, so you need to make an explicit check
	Return MapContains(Kthmap.tagmap,tag)
	End Function
	
	End Type
	
GALE_Register New tluatags,"TAGS"