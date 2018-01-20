# Kthura map editor (BlitzMax)

This is the source code of the Kthura map editor. This is a simple object based map system written in BlitzMax.
It should work on OS X, Windows and Linux are untested, though I don't expect trouble in Windows, and for Linux... Well BlitzMax officially supports Linux, but the BlitzMax and Linux have never been good friends (for good reasons).

At the current stage I did not have the time to fully document this, plus the system is officially still in development.

To import the Kthura map system into your own map you can best go to http://github.com/Tricky1975/TrickyMods as Kthura can be found there as a fully set up BlitzMax module, plus the other modules you need to compile Kthura (as well the modules as the editor) can be found there.

## Notes for Mac Users:
- As of version 15.09.22 the Kthura Map Editor requires at least 10.6 (Snow Leopard) to run, 10.7 (Lion) or later is actually recommended.
- A way to get out of these requirements is by compiling Kthura in a MacOS version prior to Snow Leopard. 
- The Text Editor requires at least 10.4 (Tiger) to run at the present time, however after the next update of that the same restriction as goes for the Text Editor
- The modules have no restriction, since they basically "adapt" to the OS X version on which you compile them 

If you want you can import the other two files as well. You also might want to choose for http://trickymods.tbbs.nl where fully setup BlitzMax modules have already been created for you (and there are other modules in there as well you need to compile any file in this repository anyway) :-P


## Notes for users of Brucey's BlitzMax-NG
- At this moment Kthura only works in the OFFICIAL Blitzmax, and thus not in NG. 
- I do have research planned to see if I can get Kthura to work in NG, however this is not a plan for the short term. 
- Of course if you want to try if you can get Kthura to work, I won't stop you ;)
 


## Deprecation notes:

As you can see Kthura has been written in BlitzMax. The status of BlitzMax looks to me as... neglected. Abandoned... you name it what you want. I can't get the newest version compiled in Windows anymore (thankfully an older version I have still works), and never got any response how to solve that. My Mac compiler is the latest version and still works, but for how long as Apple has done very nasty things to XCode causing the BlitzMax compiler to malfunction, and the question is when Apple pulls its next stunt. Linux support has always been a downright disaster in BlitzMax, and so on. It's a pity such a wonderful set up language looks like it's about to die, but I actually feared this to happen from the moment BlitzMax entered the open source. Brucey's BlitzMax NG is unfortunately not an option. It requires the original BlitzMax to get compiled itself. That will get me some chicken-and-the-egg problems in the future, unless a pre-compiled version will be released somewhere, and even then I've no idea how big that community is and if it's viable enough to put its future on. At this moment, I don't wanna risk it.
Kthura is however a too important tool for me to drop, so whatever happens, I'll do anything to make Kthura live, still its future is nevertheless a bit uncertain. As long as my Mac compiler works Kthura might live the way it did... at least the editor. Since the editor uses the same modules as you do when you import it in a BlitzMax project... hey cool.

One feature has to be deprecated though and *will* disappear once Kthura's time has come to be obligated to be rewritten in a different language (it will remain in the BlitzMax version), and that's the animated texture loading through .frames files. The reason is simple, that feature uses the LoadAnimImage function which only languages in the Blitz family appear to support. I don't wanna go through too much hassle to port that to other languages especially not since not all libraries out there support all required features for this. The PICBUNDLE and JPBF support that has been put into Kthura lately, has been set up in order to cover this up. My 63 Fires of Lung project relies pretty heavily on this for this very reason.

## Funny sidenote

For now I only use Blitz to maintain what I still need to maintain and to write a few quick generators. The final serious big project to be done with it is "The Fairy Tale REVAMPED", which is a remake of the original "The Fairy Tale" game which I originally wrote in BlitzBasic and was the first big project to be written by me in the Blitz family. I guess the circle is round as my Blitz adventure ended the way it began ;)
