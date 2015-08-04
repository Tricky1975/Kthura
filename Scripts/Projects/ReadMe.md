# Project script files

In this folder you can store script files tied to a Kthura project.

At the present time only Custum spots are supported.


## Setup
If you have a project named MyProject, then in this folder there must be a file named MyProject.lua (if it has custom spots or other custom stuff that is).
The custom spot scripts should be in functions named after the custom point and have the elements "Place" and "Show"
```lua
  -- Like this
  function CSpot_MySpot_Place(x,y)   -- Place spots for $MySpot. Please note that x and y are received as strings. Something I cannot do anything about sorry
  --[... my code ...]
  end
  
  function CSpot_MySpot_Show(ID,x,y)  -- Place spots for $MySpot. Please note that ID, x and y are received as strings. Something I cannot do anything about sorry.
  --[... my code ...]
  end
```  

I need to note that ID is the ID Kthura uses without you knowing it. It will not refer to the tag. These IDs can fluxuate every time a Kthura map is being loaded (especially after new objects were added or removed in earlier editing sessions). You must solely use that to identify the object Kthura has to handle. Also when it comes to spots, the draw feature is only used by the editor not by the Kthura core, so in your game the spots will not be seen. They are rather intended as spots your game can use to do stuff with Kthura itself does not support.

I'm afraid that's all the help I can give you now. Some more documentation might be uploaded later. :)
