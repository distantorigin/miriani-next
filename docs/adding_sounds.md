# Adding Sounds to Miriani-Next

This guide shows you how to add new sound files to the soundpack and share them with others.

## Table of Contents

- [What You Need to Know First](#what-you-need-to-know-first)
- [What You Need](#what-you-need)
- [First-Time Git Setup](#first-time-git-setup)
- [The Simple Version (6 Steps)](#the-simple-version-6-steps)
- [Understanding the Batch Files](#understanding-the-batch-files)
- [Keeping Your Copy Up to Date](#keeping-your-copy-up-to-date)
- [Troubleshooting](#troubleshooting)

---

## What You Need to Know First

### What is Git?
Git is a program that tracks changes to files over time. It's like "track changes" in Microsoft Word, but for entire folders of files. It lets you save snapshots of your work and go back to earlier versions if needed.

### What is GitHub?
GitHub is a website where people store projects using Git. You're probably reading this document there. The Miriani-Next soundpack lives on GitHub at:
https://github.com/distantorigin/miriani-next

**Important:** The `main` branch on GitHub is the development release. When you push changes to the main branch, those changes become part of the dev release that other users can update to and use immediately.

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
2. The download should start automatically - you'll get a file like `Git-2.43.0-64-bit.exe`
3. Double-click the installer file
4. Click "Next" on every screen - don't change anything, the defaults are fine
5. Wait for it to finish installing (takes about 30 seconds)
6. Click "Finish"

To check if Git is working:

1. Press Windows key + R
2. Type: `cmd`
3. Press Enter - this opens a window called Command Prompt
4. Type: `git --version` (the hyphens are important!)
5. Press Enter

What you should see:
```
git version 2.43.0.windows.1
```
(the version number may be different)

If you see this instead:
```
'git' is not recognized as an internal or external command
```
Then Git didn't install correctly. Try installing again, and make sure to close and reopen Command Prompt after installing.

---

### 2. The Soundpack Files

You need the soundpack files on your computer using Git.

How to clone the repository:

1. Open Command Prompt (Win + R, type 'cmd', press Enter)
2. Type: `cd Documents` (this goes to your Documents folder)
3. Type: `git clone https://github.com/distantorigin/miriani-next.git miriani-next-dev`
4. Press Enter
5. Wait for it to finish - you'll see lines of text as it downloads
6. When it's done, the path is: `C:\Users\YourName\Documents\miriani-next-dev`
   - Replace YourName with your actual Windows username

**IMPORTANT: Keep Development Separate**

This `miriani-next-dev` folder is ONLY for development work (adding sounds, editing scripts, testing changes). DO NOT use it as your personal game installation or mix it with your personal files.

Why?
- This folder contains Git tracking files (the `.git` folder) that track all changes
- MUSHclient will modify configuration files when you run it, which can create unwanted changes in Git
- You don't want to accidentally commit your personal settings, worlds, or character data

Best practice:
- Use `miriani-next-dev` ONLY for adding/testing sounds and making changes
- Keep your personal Miriani-Next installation in a separate folder for actual gameplay (e.g., `C:\Users\YourName\Documents\Miriani-Next`)
- Don't store personal worlds, character data, or custom scripts in the dev folder

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

## First-Time Git Setup

Before you can save changes with Git, you need to tell Git who you are. This is a one-time setup that you only need to do ONCE on your computer.

### Set Your Identity

Open Command Prompt and type these two commands:

```
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Replace "Your Name" with your actual name and "you@example.com" with your email address.

Example:
```
git config --global user.name "Jane Smith"
git config --global user.email "jane@example.com"
```

Why do I need this?
- Git uses this information to record who made each change
- It's required before you can commit (save) any changes
- The --global flag means you only need to set this once for your entire computer

To check if it worked:
```
git config --global user.name
git config --global user.email
```

You should see your name and email printed back to you.

If you skip this step, you'll see an error like "Please tell me who you are" when you try to commit changes.

---

## The Simple Version (6 Steps)

If you just want to add sounds without understanding all the details:

### Step 0: Run setup-dev.bat (First Time Only)

Before adding your first sound, you need to run this once:

1. Navigate to your miriani-next-dev folder
2. Go to the `development\` folder
3. Double-click `setup-dev.bat`

What it does: Tells Git to ignore your personal MUSHclient settings files so they don't get shared with others. MUSHclient will automatically edit configuration files when its launched, so testing changes may be enough to edit these things in a way that is undesirable.

You only need to do this ONCE, the first time you start working with the soundpack.

**Important:** Before you start adding sounds each session, you should update your local copy to get the latest changes from other maintainers. See the [Keeping Your Copy Up to Date](#keeping-your-copy-up-to-date) section for details on when and how to do this.

---

### Step 1: Put your sound file in the right folder

All sounds go in: `sounds\miriani\[category]\`

Sound categories:
- `activity\` - Crafting, trading, non-combat actions
- `ambiance\` - Background environmental sounds
- `combat\` - Weapons, explosions, damage, stunning, fuzzies, Praelor troops
- `comm\` - Communication device sounds
- `device\` - Equipment and gadget sounds
- `misc\` - Everything else
- `music\` - Theme music
- `ship\` - Starship sounds (engines, jumps, docking)
- `social\` - Emotes and social interactions
- `steps\` - Footsteps
- `vehicle\` - Salvagers, ACVs, rovers, etc
- `wrongExit\` - Invalid exit sounds

Example: You want to add an explosion sound for grenades.
1. Go to your miriani-next-dev folder
2. Navigate to: `sounds\miriani\combat\`
3. Create a new folder called `explosions\` (if it doesn't exist)
4. Copy your grenade1.ogg file into that folder
5. Ensure the file and folder names always start with a lowercase letter. The final path: `sounds\miriani\combat\explosions\grenade1.ogg`
---

### Step 2: Tell the soundpack when to play your sound

Which Lua file do I edit?
- Combat sounds → `lua\miriani\scripts\combat.lua`
- Ship sounds → `lua\miriani\scripts\ship.lua`
- Communication → `lua\miriani\scripts\comm.lua`
- Social/emotes → `lua\miriani\scripts\social.lua`
- Not sure? Search for similar sounds in the files or use best judgment

How to add a trigger:

1. Open the appropriate Lua file in Notepad
2. Find a similar existing trigger (search for `<trigger` in the file)
3. Copy an existing trigger and modify it

Example - adding a grenade explosion:

Find this kind of section in `combat.lua`:
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
- `match=` is the game text that triggers the sound
- If you wish to omit the text from output, add `omit_from_output="y"` in the vicinity of the match line.
- `mplay("combat/explosions/grenade1", "combat")` is the path to your sound
  - Path starts AFTER `sounds/miriani/`
  - NO .ogg extension!
  - So `sounds\miriani\combat\explosions\grenade1.ogg` becomes `combat/explosions/grenade1`
  - If you wish to pick randomly from a numbered set of sounds, just use the sound file. SO if you want the soundpack to pick between grenade1, grenade2, and grenade3, the path should be `combat/explosions/grenade`
  - You don't always need to use a group--many sounds do not have appropriate categories sent via the mplay script, and that's okay. The group has no correlation to the folder name.
---

### Step 3: Test your sound

1. Find and double-click mushclient.exe in your miriani-next folder
2. Connect to Miriani and play the game
3. Do the action that should trigger your sound (throw a grenade, etc.)
4. Did the sound play?
   - YES -> Great! Move to Step 4
   - NO -> Press Tab to open the output window and look for error messages. Ensure you have also enabled `conf dev debug` to see error messages when sound files can't be found.

Common reasons sounds don't play:
- Wrong file path in `mplay()`
- Typo in the trigger pattern
- Sound file is corrupted (try playing it in VLC/Winamp/etc) - if this is the case, you may not see a debug error inside the client.
- File isn't actually .ogg format

---

### Step 4: Save your changes with commit.bat

1. Under the miriani-next-dev folder, go to the `development\` folder
2. Double-click `commit.bat`
3. A console window will appear. This step saves a "snapshot" of your changes so you can share them later.

What you'll see:

```
Current changes:
M  lua/miriani/scripts/combat.lua
?? sounds/miriani/combat/explosions/grenade1.ogg

What would you like to do?
  1. Commit all changes
  2. Commit specific files
  3. Show detailed changes (git diff)
  4. Cancel

Enter your choice (1-4):
```

What those symbols mean:
- M = Modified (you changed an existing file)
- ?? = New file (Git doesn't know about it yet)
- A = Added (Git is tracking this new file)
- D = Deleted (you removed a file)

4. Type: `1` (commit all changes)
5. Press Enter

Now it asks for a message:

```
Enter commit message:
```

6. Type a description of what you did: `Add grenade explosion sound`
7. Press Enter

You'll see a bunch of Git output. Success looks like this:

```
[main a1b2c3d] Add grenade explosion sound
 2 files changed, 15 insertions(+)
 create mode 100644 sounds/miriani/combat/explosions/grenade1.ogg
[OK] Changes committed successfully

Would you like to push to remote? (y/n):
```

About pushing to remote:

What is "remote"?
- The remote is the GitHub repository location (https://github.com/distantorigin/miriani-next)
- When you cloned the repository, Git automatically configured this remote location with the name "origin"
- "Pushing" means uploading your saved changes from your computer to GitHub

Should I push?
- Type `y` if you want to share your changes with everyone else
- Your changes will be uploaded to GitHub where other maintainers can access them
- Only push when you're confident your changes are ready

If you see errors instead:
```
[ERROR] Failed to commit!
```

This means something went wrong. Copy the error message and check the Troubleshooting section below.

---

## Understanding the Batch Files

The `development\` folder has three batch files:

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
- You'll type the filenames: `sounds/miriani/combat/grenade1.ogg lua/miriani/scripts/combat.lua`

Option 3: Show detailed changes
- Shows you exactly what changed in each file (line by line)
- Good when: You want to review your changes before saving

Option 4: Cancel
- Exits without doing anything
- Good when: You realized you're not ready to commit yet

About the "push to remote" prompt:

At the end, it asks:

```
Would you like to push to remote? (y/n):
```

What is "remote"?
- The remote is the GitHub repository location (https://github.com/distantorigin/miriani-next)
- When you cloned the repository, Git automatically configured this remote location with the name "origin"
- This is where the soundpack lives online and where other maintainers get updates from

What is "pushing"?
- Pushing uploads your saved changes from your computer to the GitHub repository
- This makes your changes available to everyone else
- Your changes go to the main branch on GitHub

Should I push?
- Type `y` if you want to share your changes with everyone
- Your changes will be uploaded to GitHub where other maintainers can access them
- Only push when you're confident your changes are ready and tested

---

### bump-version.bat

What it does: Creates a new version number/tag for releases.

When to run it: When you want to increase the version number. This is for maintainers only. Don't run this unless you're preparing an official release.

---

## Keeping Your Copy Up to Date

When multiple people work on the soundpack, changes happen all the time. Someone might add new sounds, fix triggers, or update scripts while you're working on your own changes. To avoid conflicts and make sure you're working with the latest version, you need to regularly update your local copy with changes from GitHub.

### When Should I Run git pull?

You should update your local copy in these situations:

1. **At the start of each work session** - Before you start adding sounds or making changes
2. **Before running commit.bat** - Especially if you haven't worked on the soundpack in a few days
3. **When another maintainer tells you they pushed changes** - Someone might say "I just added combat sounds, pull before you push"
4. **If you get an error when trying to push** - Sometimes you need to pull first to get the latest changes

Think of it like this: You're working on a shared document. Before you add your changes, you want to make sure you have the latest version that includes everyone else's edits.

---

### How to Pull Changes

Here's how to update your local copy with the latest changes from GitHub:

1. Open Command Prompt (Win + R, type `cmd`, press Enter)
2. Navigate to your miriani-next-dev folder:
   ```
   cd C:\Users\YourName\Documents\miriani-next-dev
   ```
   (Replace YourName with your actual Windows username)
3. Run the pull command:
   ```
   git pull
   ```
4. Press Enter and wait for it to finish

What successful output looks like:

```
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 8 (delta 4), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (8/8), done.
From https://github.com/distantorigin/miriani-next
   a1b2c3d..e4f5g6h  main       -> origin/main
Updating a1b2c3d..e4f5g6h
Fast-forward
 lua/miriani/scripts/combat.lua           | 15 +++++++++++++
 sounds/miriani/combat/explosion1.ogg     | Bin 0 -> 45231 bytes
 2 files changed, 15 insertions(+)
```

What this means:
- `remote: ...` - Downloading changes from GitHub
- `Updating a1b2c3d..e4f5g6h` - Moving your local copy forward
- `Fast-forward` - This is good! It means your changes can be smoothly merged
- The file list shows what changed (combat.lua was modified, a sound file was added)

If your copy is already up to date, you'll see:

```
Already up to date.
```

This means there are no new changes to download. You're good to go!

---

### Best Practice Workflow

Follow this order to avoid problems:

1. **PULL FIRST** - Run `git pull` to get the latest changes
2. **Add your sounds** - Copy files, edit triggers, etc.
3. **Test them** - Make sure everything works
4. **Commit** - Run `commit.bat` to save your changes
5. **Push** - Upload your changes to GitHub

Why this order matters:
- If you add sounds without pulling first, someone else might have already modified the same files
- You could create a conflict that's harder to fix later
- Pulling first ensures you're building on the latest version

---

### What If There's a Conflict?

Sometimes, you and another maintainer edit the same part of the same file. When you try to pull, Git doesn't know which version to keep. This is called a **merge conflict**.

What a merge conflict looks like:

```
Auto-merging lua/miriani/scripts/combat.lua
CONFLICT (content): Merge conflict in lua/miriani/scripts/combat.lua
Automatic merge failed; fix conflicts and then commit the result.
```

**DON'T PANIC!** This is normal and fixable.

What a merge conflict means:
- You changed lines 50-55 in combat.lua
- Someone else also changed lines 50-55 in combat.lua
- Git doesn't know which changes to keep, so it's asking you to decide

What to do:
1. **Don't try to fix it yourself if you're not comfortable** - This is advanced Git territory
2. **Your changes are NOT deleted** - Git has saved everything, nothing is lost
3. **Contact the repository maintainer** - Tell them you got a merge conflict and need help
4. **Provide details** - Tell them what file has the conflict and what you were working on

The maintainer will help you resolve the conflict. They might:
- Walk you through fixing it
- Ask you to send them your changes so they can merge them manually
- Help you use Git tools to resolve it

Remember: Merge conflicts are a normal part of collaborative work. Every developer encounters them. Don't feel bad about asking for help!

---

### What If I Have Uncommitted Changes?

If you try to pull when you have unsaved changes, you might see this error:

```
error: Your local changes to the following files would be overwritten by merge:
        lua/miriani/scripts/combat.lua
Please commit your changes or stash them before you merge.
Aborting
```

What this means:
- You edited combat.lua but haven't committed those changes yet
- Git is protecting you from losing your work
- It won't pull until you save your changes

Solution:
1. **Commit your changes first** - Run `commit.bat` to save what you've been working on
2. **Then pull** - After committing, run `git pull` again
3. **Now it should work** - Your committed changes will be merged with the new changes

Why Git does this:
- Git wants to make sure you don't lose any work
- Once you commit, Git has a saved snapshot of your changes
- Then it can safely merge the new changes with yours

---

### Quick Reference

**Update your local copy:**
```
git pull
```

**Check if you need to pull:**
```
git status
```

If you see "Your branch is behind 'origin/main'", you need to pull.

**When to pull:**
- Start of each work session
- Before committing after a break
- When told by another maintainer
- If push fails

**Remember:**
- Pull BEFORE you start working
- Commit BEFORE you pull (if you have changes)
- Don't panic if you see a conflict - ask for help!

---

## Troubleshooting

### "Please tell me who you are" or "Author identity unknown"

Problem: Git doesn't know your name and email.

What you'll see:
```
*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

Solution:
This happens when you haven't configured your Git identity. See the [First-Time Git Setup](#first-time-git-setup) section above and run those two commands.

---

### "fatal: not a git repository"

Problem: You're trying to run Git commands in a folder that isn't a Git repository.

What you'll see:
```
fatal: not a git repository (or any of the parent directories): .git
```

Solution:
1. Make sure you cloned the repository using `git clone` (don't download the ZIP file)
2. Make sure you're in the correct folder (should be `miriani-next-dev`)
3. Check if the `.git` folder exists in your miriani-next-dev folder (it's hidden by default)
   - In Windows Explorer, go to View > Show > Hidden items to see it

---

### "git is not recognized as an internal or external command"

Problem: Git isn't installed, or isn't in your PATH.

Solution:
1. Install Git from https://git-scm.com/download/win
2. Important: After installing, close ALL Command Prompt windows
3. Open a new Command Prompt
4. Try `git --version` again

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
3. Try running `commit.bat` again

---

### "Failed to push" or Authentication Failed

Problem: Git can't authenticate you to push to GitHub.

Common causes:
- You don't have permission to push to the repository (you're not a maintainer)
- Your GitHub credentials aren't configured
- You need to use a Personal Access Token instead of a password

Solution:

If you're not a maintainer:
- You'll see an error like "Permission denied" or "Authentication failed"
- Contact the repository owner to get maintainer access

If you are a maintainer:
1. GitHub no longer accepts passwords for Git operations
2. You need to set up a Personal Access Token:
   - Go to GitHub Settings > Developer settings > Personal access tokens
   - Generate a new token with "repo" permissions
   - Use this token as your password when Git asks
3. Or set up SSH authentication (more advanced):
   - Follow GitHub's guide: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

---

### My sound doesn't play in-game

Problem: The trigger isn't working.

Check these things:

1. Is the file path correct?
   - Open Command Prompt
   - `cd /d C:\path\to\miriani-next-dev`
   - `dir sounds\miriani\combat\explosions\grenade1.ogg`
   - You should see the file listed. If you see "File Not Found", the path is wrong.

2. Does the .ogg file play?
   - Open the file in VLC or Winamp
   - If it doesn't play, the file might be corrupted or not actually .ogg format

3. Does the trigger pattern match?
   - Copy the exact text from the game when the action happens
   - Compare it to your `match=` pattern
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

1. Open Command Prompt (Win + R, type `cmd`, Enter)
2. Navigate to the development folder:
   ```
   cd documents\miriani-next-dev\development
   ```
3. Run the batch file by typing its name:
   ```
   commit.bat
   ```
   
Now you can see the output and interact with it.

---

### "Permission denied" or "Access denied"

Problem: Windows is blocking Git from accessing files.

Solution:
- Run Command Prompt as Administrator (right-click Command Prompt → "Run as administrator")
- Make sure the miriani-next-dev folder isn't in a protected location (like `C:\Program Files`)
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

### Can I add WAV or MP3 files instead of OGG?

No, the soundpack only supports OGG. Convert your files first using Audacity or an online converter.

---