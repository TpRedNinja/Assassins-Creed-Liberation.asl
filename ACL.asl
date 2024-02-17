// Assassins crreed liberation remastered autosplitter made by TpRedNinja
// People who helped me: Akilogames, DeathHound, Mysterion and his tutorial, a lot of people from the speedrun tool development discord server

state("ACLiberation", "steam")
{
    int percentage: 0x02C0EC88, 0x280, 0x10, 0x2CC; // detects overall completion % value
    int menu: 0x02BCB4C0, 0x80, 0xC0, 0x4DC; // detects if you're in a menu or in-game/cutscene. 32756 when in pause menu or loading & main, any other number below when not, note when selecting save it's below 32756.
    int pausemenu: 0x2C0EDD0; // detects if you're in the pause menu. 1 for if you are 0 if you aren't
    int IGT: 0x2C0D0B0; // somehow game time is 4 bytes idk why.
    // Note IGT // it will pause if the pause menu is open or if you go back to the main menu
    // int mainmenu: 0x02BC5D48, 0x818, 0x678, 0xF9C; // tells whether you're in the main menu or not, currently useless as it only shows 1 number all the time
    int IsLoading: 0x02BDAC70, 0xBB0, 0xA28, 0x10, 0xF58; // detects if you're in the loading screen or not, 1 for is 0 for not, IGT goes on during unskippable cutscene and cutscene isn't considered loading
    int currency: 0x02C26C80, 0x478, 0xB0, 0x98; // detects currency, becomes 4294967295 when loading into the game but changes back, but when leaving the game it becomes ??
    int cutscene: 0x02BC8010, 0x748, 0x2E0, 0xC8, 0x78; // detects skippable and nonskippable cutscenes
    /*Notes for cutscene: 3 is in-game as a child and after the second mission with assassin persona,- 
    6 is skippable as a child. 8 is nonskippable as all personas or just assassin. Got 123 when starting 2nd mission before the unskippable. -
    When swapped to slave persona was 1 in the game and 23 as skippable. -
    When as a lady persona 1 in the game, 138 for skippable cutscene, 1 back in the game after the mission of getting the clothes-
    (and 160 and 132 in the game and) during skippable cutscene of getting clothes for the slave that you rescued and at the end of the mission-
    101 during skippable cutscene first mission after being able to free roam 5 in tailing mission it's now 5 in free roam*/
}

state("ACLiberation", "UbisoftConnect")
{
    int percentage: 0x02BC5F00, 0x2D0, 0xEC;
    int menu: 0x02BC7F50, 0x74C; // same condition as steam 
    int pausemenu: 0x02C0ED10; // just an address does changing persona's screen as paused
    int IGT: 0x02C0CF00, 0xE8; // steam was just an address Ubisoft is a full-on pointer
    // int mainmenu:; currently, I can't find, maybe I can find but seems kinda useless currently
    int IsLoading: 0x02C26F98, 0x0, 0x200;
    int currency: 0x02C26BC0, 0xB0, 0x98;
    // int cutscene:;
}

startup
{
    // credit to Deathhound on discord for allowing me to copy some of the code from the re2r autosplitter. was very helpful in making this.
    // ubisoft connect hash id: SHA256: 7a4b62b1ebe7ce7b5a54d7265ba8a0e1a3151c6c3ab87342506d359429c075c9
    vars.aclubisoftconnect = new byte[32]{0x7a, 0x4b, 0x62, 0xb1, 0xeb, 0xe7, 0xce, 0x7b, 0x5a, 0x54, 0xd7, 0x26, 0x5b, 0xa8, 0xa0, 0xe1, 0xa3, 0x15, 0x1c, 0x6c, 0x3a, 0xb8, 0x73, 0x42, 0x50, 0x6d, 0x35, 0x94, 0x29, 0xc0, 0x75, 0xc9};
    // steam hash id: SHA256: 87836d1759dd4dae57eff66aa170c07c4c5e6b817632379e493d2929adebe947
    vars.aclsteam = new byte[32]{0x87, 0x83, 0x6d, 0x17, 0x59, 0xdd, 0x4d, 0xae, 0x57, 0xef, 0xf6, 0x6a, 0xa1, 0x70, 0xc0, 0x7c, 0x4c, 0x5e, 0x6b, 0x81, 0x76, 0x32, 0x37, 0x9e, 0x49, 0x3d, 0x29, 0x29, 0xad, 0xeb, 0xe9, 0x47};
    // calculates the hash id for the current module credit to the re2r autosplitter & deathHound on discord for this code 
    Func<ProcessModuleWow64Safe, byte[]> CalcModuleHash = (module) => {
        print("Calculating hash of " + module.FileName);
        byte[] checksum = new byte[32];
        using (var hashFunc = System.Security.Cryptography.SHA256.Create())
            using (var fs = new FileStream(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
                checksum = hashFunc.ComputeHash(fs);
        return checksum;
    };
    vars.CalcModuleHash = CalcModuleHash;
    // Asks the user if they want to change to game time if the comparison is set to real time on startup.
    if(timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show(
            "This Autosplitter has a load removal Time without loads. "+
            "LiveSplit is currently set to display and compare against Real Time (including loads).\n\n"+
            "Would you like the timing method to be set to Game Time?",
            "Assassin's Creed 3: Liberation Remastered | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
    };
}

init
{
    // Detecting the game version based on SHA-256 hash
    byte[] checksum = vars.CalcModuleHash(modules.First());    
    if (Enumerable.SequenceEqual(checksum, vars.aclsteam) )
        version = "steam";
    else if(Enumerable.SequenceEqual(checksum, vars.aclubisoftconnect)) 
        version = "Ubisoft Connect";
}

update
{}

start
{
    //starts when first skippable cutscene appears should be no delay
    if(current.IsLoading == 0 && current.menu < 32756 && current.IGT > 0 && current.percentage == 0) {
        return true;
    }
}

split
{
    //splits after every mission that gives you percentage note some missions dont have a end mission screen so make sure you have enough splits
    if(current.percentage > old.percentage) {
        return true;
    }
}

isLoading

{
    /*detects address if it equals 1 as well if the game time is pasued as well as the menu equaling 32756 
    as the timer should only pause during loading screens not any menu which is why we have pausemenu to be 0 as that equals false 
    and we dont want the pause menu or anything else that the game considers pausemenu to pause the timer
    pauses during loading screens,condition to pause during a unskippable is at the bottom just add a || and do (current.cutscene == 8) */
    if(current.IsLoading == 1 && current.IGT == old.IGT && current.menu == 32756 && current.pausemenu == 0){
        return true;
      } else
      {
          return false;
      }

}



//(current.cutscene == 8 ) 
