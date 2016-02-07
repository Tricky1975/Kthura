# History of Kthura

The version numbers are in Ubuntu style. Meaning they are formatted yy.mm.dd

- 15.01.01: Official start of Kthura 
- 15.07.29: Github script set up
- 15.07.29: Modify alpha ignore bug fixed
- 15.08.01: Export to png and jpg now supported
- 15.08.01: Git scripted updated with the possibility to keep this changelog up to date :)
- 15.08.01: Tiny bug in that updater fixed (doh!)
- 15.08.01: (FIX) Export now only works if the canvas is visible. Otherwise the editor will produce undesirable behavior!
- 15.08.04: Drawing routines now allows CSpots (which is all object of which the "kind" is prefixed with an $)
- 15.08.04: Scripting engine there. Does it work?
- 15.08.04: Fixed up issue non-detection of custom spots
- 15.08.04: Fixed bug not saving the object's colors.
- 15.08.05: Fixed the unreadable error messages bug
- 15.08.05: General Data can now be edited in a Kthura map (if you were wondering about that empty data file inside a Kthura JCR6 file, now you got it) :)
- 15.08.16: First version considered in 'Alpha' (though earlier releases exist, this is where the project has been declared safe enough to use, though keep in mind that stuff may still be subject to change)
- 15.08.16: Documentation has been adapted to this new status in all three modules. (I will only make this notice in the core, but this one and the previous one goes for all mods in Kthura).
- 15.08.16: Quick data access within a Kthura map done
- 15.08.16: BUGFIX: The actor pic synchronizer returned null if a picture was already loaded. This has been fixed as it had to return the memory reference of the loaded picture already. (Trying to save memory, don't you sometimes just hate it) :)
- 15.08.16: BUGFIX: Auto hotspot bottom center for single pic actors. I forgot to set this right ;)
- 15.08.17: Fixed quit error not working in Windows 
- 15.08.17: Fixed unreadble console in windows
- 15.08.17: Small cosmetic change in the text editor
- 15.08.17: Windows exes released as well
- 15.08.23: Area effect support
- 15.08.23: Relabel
- 15.08.23: Two bugs did pop up which have low priority, but they are noted in my GitHub repository as issues #12 and #13
- 15.08.27: Fixed the issues with the "Relabel" feature.
- 15.08.27: Fixed a bug regarding coordinate checking inside a tiledarea or zone
- 15.09.02: Just synced with the new license utility
- 15.09.08: Fixed alpha bug in modifier
- 15.09.11: Added support for rotation on obstacles
- 15.09.11: Added support for insertion points for tiled areas
- 15.09.11: There was an issue in the repository. Is it fixed now?
- 15.09.12: Added KT_Copy tool. An command line tool that can create new maps out of portions of existing maps.
- 15.09.14: "Rotten Objects" scanner now also scans the zones.
- 15.09.16: Fixed "IngoreBlocks" ignoring bug
- 15.09.22: Added color support to Obstacles and Tiled Areas
- 15.09.22: Added animated texturing support
- 15.09.22: Kthura now requires MacOS X 10.6 (Snow Leopard) at least to run 10.7 (Lion) is recommended (unless you compile the editor yourself in an OS version prior to Snow Leopard). (For Windows there are no additional version restrictions).
- 15.09.22: Deprecated a few older setups meant for animation, but it was clear they were not going to be used from the start. The saver ignores them now. The loader still sees them, but will throw a warning. After "Star Story" has been finished it's very likely to be removed form the loader as well.
- 15.09.22: Fixed #26
- 15.09.23: Fixed #28 ( https://github.com/Tricky1975/Kthura/issues/28 )
- 15.09.26: Enhanced the Lua Scripting API inside the editor
- 15.09.28: Boundary support
- 15.09.29: Fixed #29
- 15.09.29: Fixed #30
- 15.09.29: Fixed #22
- 15.10.01: Radius in script spotting support
- 15.10.02: Fixed radius issue in Lua
- 15.10.03: Fixed #32
- 15.10.09: File Tables now also saved in zlib format
- 15.10.09: Odd stuff happening, needs to be sorted out
- 15.10.09: Some trouble with the Git Updater fixed.

(One Important Note To Self:
NEVER and I repeat NEVER use MaxIDE to modify Shell Scripts. Unix appears to be allergic for that!!!)

- 15.10.09: Fixed a faulty item in this very file.
- 15.10.11: Fixed #33
- 15.10.12: Core, load, save support for multi-map. I only need to test this and to adept the editor to this.
- 15.10.12: Read [this commit](https://github.com/Tricky1975/Kthura/commit/ca9dedc9b609838bba5826695b895291d5d36189)
- 15.10.15: Insert to position support
- 15.10.15: Windows build does now also support Multi-Map (I was too lazy to update the Windows version earlier. Sorry).
- 15.10.21: Fixed #39 (Coloring ignore bug in Tiled Areas)
- 15.10.22: Fixed #40
- 15.11.06: I added support for WalkTo to return True or False depending if a WalkTo request was possible or not.
- 15.11.09: Removed the deprecated InitFile and place the current version in.
- 16.01.07: Scaling support
- 16.01.10: '*ALL*' support in showing and hiding by label
- 16.10.10: Fixed issue #43
- 16.02.07: Added color selector support
