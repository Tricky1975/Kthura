# Executables

The Kthura editor was never designed to live in your application folder, but only in a folder with FULL READ AND WRITE access.
I really recommend you that before you download anything here you reserve a special folder solely for Kthura

The Map Editor requires in the folder in which the application in installed to have a "Projects" folder and a Script Folder.
The script folder should contain the file "Libraries.GLL" and the subfolders "Projects" and "Use"

The Projects folder is where you set up a file for Kthura to set up a project file. Such a file contains the data were to store the maps and where the textures are written. Kthura is set up with the idea in mind JCR6 will eventually be used to merge everything together in one big JCR6 file the game using the Kthura maps can use.
The scripts folder may contain scripts Kthura can use in order to add some stuff Kthura would normally not support. The scripting language used is Lua. Kthura uses the GALE preprocessor for Lua adding a bit of extra functionality to Lua too.



The Kthura Text editor is basically a program to "hack" a Kthura file. A Kthura map file is actually nothing more than a JCR6 file with 3 files packed in it of which 2 plain text files and one in a binary stringmap. This editor allows you to edit the plain text just in a simple text editor without having to unpack, edit and repack everything. Saves times :)
It also has a quick editor for the stringmap editor, which is just a "one-record" database only containing string values. This program does (of course) require more knowledge of how Kthura works, but I think it's not that hard to understand.



Proper documentation is not yet available. I do plan to write it eventually, but my schedule does not allow to do it yet. Of course, nothing should stop you from writing some stuff yourself if you figured Kthura out. Things may be a little different since Kthura is object based in stead of tile based, but I don't think you'll experience too much trouble digging into it :)
