# Adding Sounds to Miriani-Next

This guide shows you how to add new sound files to the soundpack and share them with others.

## Table of Contents

- [What You Need to Know First](#what-you-need-to-know-first)
- [What You Need](#what-you-need)
- [The Simple Version (5 Steps)](#the-simple-version-5-steps)
- [The Detailed Version](#the-detailed-version)
- [Understanding the Batch Files](#understanding-the-batch-files)
- [For Contributors: Sharing Your Sounds](#for-contributors-sharing-your-sounds)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## What You Need to Know First

### What is Git?
Git is a program that tracks changes to files over time. It's like "track changes" in Microsoft Word, but for entire folders of files. It lets you save snapshots of your work and go back to earlier versions if needed.

### What is GitHub?
GitHub is a website where people store projects using Git. The Miriani-Next soundpack lives on GitHub at:
https://github.com/distantorigin/miriani-next

### What are these batch files?
Batch files (ending in .bat) are simple scripts that run commands for you. Instead of typing complicated Git commands yourself, you just run a batch file and answer simple questions like "What did you change?" It does the technical things for you.

### Do I need to be a programmer?
No. If you can:
- Copy files into folders
- Type text into a prompt
- Follow step-by-step instructions

Then you can add sounds. No coding experience required.

---

## What You Need

### 1. Git (the version tracking program)

To install Git:

1. Go to this website: https://git-scm.com/download/win
2. The download should start automatically - you'll get a file like 'Git-2.43.0-64-bit.exe
3. Double-click the installer file
4. Click "Next" on every screen - don't change anything, the defaults are fine
5. Wait for it to finish installing (takes about 30 seconds)
6. Click "Finish"

To check if Git is working:

1. Press Windows key + R
2. Type: 'cmd
3. Press Enter - this opens a window called Command Prompt
4. Type: 'git --version' (the hyphens are important!)
5. Press Enter

What you should see:
git version 2.43.0.window.1 (replace with your version number)

If you see this instead:
'git' is not recognized as an internal or external command
Then Git didn't install correctly. Try installing again, and make sure to close and reopen Command Prompt after installing.

---

### 2. The Soundpack Files

You need the soundpack files on your computer.

Method 1: Download the ZIP file (recommended for beginners)

1. Go to: https://github.com/distantorigin/miriani-next
2. Look for a green button that says "Code" - click it
3. In the menu that appears, click "Download ZIP"
4. Windows will download a file called miriani-next-main.zip
5. Find that ZIP file (probably in your Downloads folder)
6. Right-click the ZIP file and choose "Extract All..."
7. Choose where to extract it - I recommend something like : C:\Users\YourName\documents\miriani-next-dev
   - Replace YourName with your actual Windows username
   
8. Click "Extract"

Method 2: Clone with Git (if you're comfortable with Git)

1. Open Command Prompt (Win + R, type 'cmd', press Enter)
2. Type: 'cd Documents' (this goes to your Documents folder)
3. Type: 'git clone https://github.com/distantorigin/miriani-next.git miriani-next-dev' Press Enter
5. Wait for it to finish - you'll see lines of text as it downloads
6. When it's done, the path is: 'C:\Users\YourName\Documents\miriani-next
---

### 3. Sound Files in OGG Format

The soundpack uses .ogg audio files (not .wav or .mp3).

Why OGG?
- Smaller file size than WAV
- Better quality than MP3 at the same size
- Free and open format

If you have WAV or MP3 files:

Convert them to OGG using one of these:
- Audacity (free program): https://www.audacityteam.org/
  - Open your sound → File → Export → Export as OGG
- Online converter: https://cloudconvert.com/mp3-to-ogg
  - Upload your file -> Convert -> Download

---

### 4. A Text Editor (Optional but Helpful)

You'll be editing Lua script files. You can use:
- Notepad (already on your computer - good enough)
- Notepad++ (free, better than Notepad): https://notepad-plus-plus.org/
- VS Code (free, most advanced): https://code.visualstudio.com/

---

## The Simple Version (5 Steps)

If you just want to add sounds without understanding all the details:

### Step 1: Put your sound file in the right folder

All sounds go in: 'sounds\miriani\[category]\
Sound categories:
- 'activity\' - Crafting, trading, non-combat actions
- 'ambiance\' - Background environmental sounds
- 'combat\' - Weapons, explosions, damage, stunning, fuzzies, Praelor troops
- 'comm\' - Communication device sounds
- 'device\' - Equipment and gadget sounds
- 'misc\' - Everything else
- 'music\' - Theme music
- 'ship\' - Starship sounds (engines, jumps, docking)
- 'social\' - Emotes and social interactions
- steps\ - Footsteps
- vehicle\ - Salvagers, ACVs, rovers, etc
- 'wrongExit\' - Invalid exit sounds

Example: You want to add an explosion sound for grenades.
1. Go to your miriani-next folder (where you extracted it)
2. Navigate to: 'sounds\miriani\combat\3. Create a new folder called 'explosions\' (if it doesn't exist)
4. Copy your grenade1.ogg file into that folder
5. Final path: 'sounds\miriani\combat\explosions\grenade1.ogg
---

### Step 2: Tell the soundpack when to play your sound

Which Lua file do I edit?
- Combat sounds → 'lua\miriani\scripts\combat.lua- Ship sounds → 'lua\miriani\scripts\ship.lua- Communication → 'lua\miriani\scripts\comm.lua- Social/emotes → 'lua\miriani\scripts\social.lua- Not sure? Search for similar sounds in the files or use best judgment

How to add a trigger:

1. Open the appropriate Lua file in Notepad
2. Find a similar existing trigger (search for \<trigger in the file)
3. Copy an existing trigger and modify it

Example - adding a grenade explosion:

Find this kind of section in 'combat.lua':
```
<trigger
 enabled="y"
 group="combat"
 match="^Some game text pattern here"
 regexp="y"
 send_to="14"
>
<send>mplay("combat/some/path", "combat")</send>
</trigger>
```

Add your own after it:
```
<trigger
 enabled="y"
 group="combat"
 match="^The grenade explodes"
 regexp="y"
 send_to="14"
>
<send>mplay("combat/explosions/grenade1", "combat")</send>
</trigger>
```
Important notes:
- match= is the game text that triggers the sound
- mplay("combat/explosions/grenade1", "combat")' is the path to your sound
  - Path starts AFTER 'sounds/miriani/
  - NO .ogg extension!
  - So 'sounds/miriani/combat/explosions/grenade1.ogg' becomes 'combat/explosions/grenade1
  - If you wish to pick randomly from a numbered set of sounds, just use the sound file. SO if you want the soundpack to pick between grenade1, grenade2, and grenade3, the path should be 'combat/explosions/grenade'
  - You don't always need to use a group--many sounds do not have appropriate categories sent via the mplay script, and that's okay. The group has no correlation to the folder name.
---

### Step 3: Test your sound

1. Find and double-click mushclient.exe in your miriani-next folder
2. Connect to Miriani and play the game
3. Do the action that should trigger your sound (throw a grenade, etc.)
4. Did the sound play?
   - YES -> Great! Move to Step 4
   - NO -> Press Tab to open the output window and look for error messages. Ensure you have also enable ''conf dev debug' to see error messages when souhnd files can't be found.

Common reasons sounds don't play:
- Wrong file path in mplay()- Typo in the trigger pattern
- Sound file is corrupted (try playing it in VLC/Winamp/etc)
- File isn't actually .ogg format

---

### Step 4: Save your changes with commit.bat

1. Under the Miriani-Next-Dev folder, go to the Development folder.
2. Click on commit.bat.
3. A console window will appear. This step saves a "snapshot" of your changes so you can share them later.

What you'll see:

Current changes:
M  lua/miriani/scripts/combat.lua
?? sounds/miriani/combat/explosions/grenade1.ogg

What would you like to do?
  1. Commit all changes
  2. Commit specific files
  3. Show detailed changes (git diff)
  4. Cancel

Enter your choice (1-4):

What those symbols mean:
- M = Modified (you changed an existing file)
- ?? = New file (Git doesn't know about it yet)
- A = Added (Git is tracking this new file)
- D = Delete
4.. Type: '1' (commit all changes)
5. Press Enter

Now it asks for a message:

Enter commit message:


6. Type a description of what you did: 'Add grenade explosion sound7. Press Enter

You'll see a bunch of Git output. Success looks like this

[main a1b2c3d] Add grenade explosion sound
 2 files changed, 15 insertions(+)
 create mode 100644 sounds/miriani/combat/explosions/grenade1.ogg
[OK] Changes committed successfully

Would you like to push to remote? (y/n):

IMPORTANT: Type 'n' and press Enter (unless you're a project maintainer with direct access)

If you see errors instead:
[ERROR] Failed to commit!@

This means something went wrong. Copy the error message and check the Troubleshooting section below.

---

## Understanding the Batch Files

The 'development\' folder has three batch files:

### setup-dev.bat

What it does: Tells Git to ignore your personal MUSHclient settings files so they don't get shared with others.

When to run it: Once, the first time you start adding sounds.

---

### commit.bat

What it does: Saves your changes as a "commit" (a snapshot) in Git.

When to run it: After you've added sounds and tested them.

The four options explained:

Option 1: Commit all changes
- Saves everything you changed
- Good when: You added multiple sounds/files and want to save them all together

Option 2: Commit specific files
- Lets you pick which files to save
- Good when: You changed several things but only want to save some of them right now
- You'll type the filenames: 'sounds/miriani/combat/grenade1.ogg lua/miriani/scripts/combat.lua
Option 3: Show detailed changes
 - Shows you exactly what changed in each file (line by line)
- Good when: You want to review your changes before saving

Option 4: Cancel
- Exits without doing anything
- Good when: You realized you're not ready to commit yet

About the "push to remote" prompt:

At the end, it asks:

Would you like to push to remote? (y/n):

What is "pushing"?
Pushing uploads your changes to GitHub so others can see them. (This will push to the main branch, which makes changes live in the dev branch.)

Should I push?
- Type 'n' if you're a contributor (most people) - you'll create a Pull Request instead
- Type 'y' if you're a maintainer with direct write access to the repository and want to make your changes to everyone else

When in doubt, type 'n'.

---

### bump-version.bat

What it does: Creates a new version number/tag for releases.

When to run it: When you want to increase the version number. This is for maintainers only. Don't run this unless you're preparing an official release.

---

## Troubleshooting

### "git is not recognized as an internal or external command"

Problem: Git isn't installed, or isn't in your PATH.

Solution:
1. Install Git from https://git-scm.com/download/win
2. Important: After installing, close ALL Command Prompt windows
3. Open a new Command Prompt
4. Try 'git --version' again

---

### "Failed to commit"

Problem: Git encountered an error while saving your changes.

Common causes:
- Your commit message was empty - you must type something
- No changes to commit - you didn't actually change any files
- File permissions issue

Solution:
1. Look at the error message for clues
2. Make sure you actually changed files
3. Try running 'commit.bat' again

---

### "Failed to push"

Problem: You don't have permission to push directly to the repository.

This is NORMAL for contributors that don't have maintainer access!

Solution:
Don't push directly to 'origin'. Instead:
1. Fork the repository (see Step 2 in "For Contributors")
2. Add your fork as a remote
3. Push to YOUR fork: 'git push myfork main4. Create a Pull Request

---

### My sound doesn't play in-game

Problem: The trigger isn't working.

Check these things:

1. Is the file path correct?
   - Open Command Prompt
   - 'cd /d C:\path\to\miriani-next   - 'dir sounds\miriani\combat\explosions\grenade1.ogg   - You should see the file listed. If you see "File Not Found", the path is wrong.

2. Does the .ogg file play?
   - Open the file in VLC or Winamp
   - If it doesn't play, the file might be corrupted or not actually .ogg format

3. Does the trigger pattern match?
   - Copy the exact text from the game when the action happens
   - Compare it to your match= pattern
   - Even one wrong letter/space will break it!

4. Check the output window in MUSHclient:
   - Press Ctrl + Tab to open the output window
   - Look for error messages like "Could not find sound file"
   - This tells you exactly what went wrong

---

### "The batch file closes immediately"

Problem: You double-clicked the .bat file and it closed before you could see anything.

Solution:
Try to not double-click the batch files. Run them from Command Prompt instead:

1. Open Command Prompt (Win + R, type 'cmd', Enter)
2. Navigate to the development folder:
      cd documents\miriani-next-dev\development
      3. Run the batch file by typing its name:
      commit.bat
   
Now you can see the output and interact with it.

---

### "Permission denied" or "Access denied"

Problem: Windows is blocking Git from accessing files.

Solution:
- Run Command Prompt as Administrator (right-click Command Prompt → "Run as administrator")
- Make sure the miriani-next folder isn't in a protected location (like C:\Program Files)
- Check if antivirus is blocking Git
- Make sure no other program has the files open (close MUSHclient, close Notepad, etc.)

---

### Do I need to run setup-dev.bat?

Only once, the first time. It prevents your personal MUSHclient settings from being tracked by Git.

If you forget to run it, it's not a big deal - just be careful not to commit mushclient.ini or mushclient.sqlite.

---

### What's the difference between commit and push?

- Commit = Save a snapshot locally (only on your computer)
- Push = Upload your commits to GitHub (so others can see them)

Think of it like:
- Commit = Packing a box
- Push = Shipping the box

---

### How do I update my local copy with the latest changes?

If other people have made changes to the soundpack and you want to get them:

git pull

This downloads the latest changes from GitHub and merges them with your local copy.

---

### Can I add WAV or MP3 files instead of OGG?

No, the soundpack only supports OGG. Convert your files first using Audacity or an online converter.

---