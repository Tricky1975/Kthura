// Lic:
//   Program.cs
//   Kthura Quick Project Creation Setup
//   version: 18.09.02
//   Copyright (C) 2018 Jeroen P. Broks
//   This software is provided 'as-is', without any express or implied
//   warranty.  In no event will the authors be held liable for any damages
//   arising from the use of this software.
//   Permission is granted to anyone to use this software for any purpose,
//   including commercial applications, and to alter it and redistribute it
//   freely, subject to the following restrictions:
//   1. The origin of this software must not be misrepresented; you must not
//      claim that you wrote the original software. If you use this software
//      in a product, an acknowledgment in the product documentation would be
//      appreciated but is not required.
//   2. Altered source versions must be plainly marked as such, and must not be
//      misrepresented as being the original software.
//   3. This notice may not be removed or altered from any source distribution.
// EndLic
﻿using System.Collections.Generic;
using TrickyUnits;
using System;
using Gtk;

namespace QuickKthuraProjectSetupWizard
{
    class MainClass
    {
        static MainWindow win;
        static VBox MainBox;
        static Dictionary<string, TextView> Fields = new Dictionary<string, TextView>();
        static Dictionary<string, Button> Browse = new Dictionary<string, Button>();
        static Dictionary<Button, string> Browse2Source = new Dictionary<Button, string>();
        static Button Action;

        static void DirBrowser(object sender, EventArgs args){
            string filename;
            var frombutton = (Button)sender;
            var from = Browse2Source[frombutton];
            var fcd = new FileChooserDialog("Choose Directory", win, FileChooserAction.SelectFolder, "Select", ResponseType.Accept, "Cancel", ResponseType.Close);
            fcd.SelectMultiple = false;
            var r = fcd.Run(); // This opens the window and waits for the response
            //bool alright = false;
            if (r == (int)ResponseType.Accept)
            {
                filename = fcd.Filename;
                Fields[from].Buffer.Text = filename;
                //alright = true;
            }
            fcd.Destroy(); // The dialog does not automatically close when clicking the buttons, so you have to manually close it with this

        }

        static void AddField(string codename, string showname, bool dirbrowser=false){
            var sbox = new HBox();
            var ilab = new Label(showname);
            var itxt = new TextView();
            var ibrw = new Button("Browse");
            var ibox = new HBox();
            sbox.SetSizeRequest(500, 25);
            ilab.SetSizeRequest(250, 25);
            ibox.SetSizeRequest(250, 25);
            itxt.SetSizeRequest(250, 25);
            ibrw.SetSizeRequest(60, 25);
            ibox.BorderWidth = 1;
            ilab.Justify=Justification.Left;
            sbox.ResizeChildren();
            sbox.Add(ilab);
            sbox.Add(ibox);
            ibox.Add(itxt);
            Fields[codename] = itxt;
            if (dirbrowser) {
                itxt.SetSizeRequest(190, 25);
                ibox.Add(ibrw);
                Browse[codename] = ibrw;
                Browse2Source[ibrw] = codename;
                ibrw.Clicked += DirBrowser;
            }
            MainBox.Add(sbox);

        }

        static void InitMainBox(){
            MainBox = new VBox();
            MainBox.Add(new Label("This is only a very quick wizard which can help you to quickly set up a Kthura project.\nPlease note, Kthura cannot tell from the Kthura Maps where the textures\nand other stuff it needs are located\n(this to make sure you can make your game fully portable),\nso when you use Kthura in your game,\nyou'll need to configure it properly."));
            AddField("*KTHURA", "Kthura Folder", true);
            AddField("*Project", "Project Name:");
            AddField("*Copyright", "Copyright and License notice:");
            AddField("*Meta", "MetaFields for Kthura levels");
            AddField("MAPS", "Maps Folder",  true);
            MainBox.Add(new Label("NOTE!\nIf you do not use the Lua/Python exporter,\nleave these field blank,\nand make sure you NEVER use the same directory for this\n as where your maps are stored."));
            AddField("EXPORT.LUA", "Lua export folder:",true);
            AddField("EXPORT.PYTHON", "Python export folder:",  true);
            AddField("*Textures", "Kthura texture folder:", true);
            Action = new Button("Generate your Kthura Project");
            MainBox.Add(Action);
            win.Add(MainBox);
        }

        public static void Main(string[] args)
        {
            MKL.Version("Kthuta Quick Project Setup - Program.cs","18.09.02");
            MKL.Lic    ("Kthuta Quick Project Setup - Program.cs","ZLib License");
            Application.Init();
            win = new MainWindow();
            win.SetSizeRequest(500, 400);
            win.Title = "Quick Kthura Setup Wizard";
            InitMainBox();
            win.ShowAll();
            Application.Run();
        }
    }
}
