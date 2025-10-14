# Miriani-Next

# Table of Contents

- [About This Project](#about-this-project)
- [New in Miriani-Next](#new-in-miriani-next)
  - [Audio & Configuration](#audio--configuration)
  - [Gameplay Enhancements](#gameplay-enhancements)
  - [Communication & Buffers](#communication--buffers)
  - [Quality of Life](#quality-of-life)
  - [Technical Improvements](#technical-improvements)
- [Installation](#installation)
  - [Option 1: Installer (Recommended)](#option-1-installer-recommended)
  - [Option 2: Manual Installation](#option-2-manual-installation)
- [Getting Started](#getting-started)
  - [Output and error windows](#output-and-error-windows)
    - [History Buffers](#history-buffers)
    - [Output Reviewing Functions](#output-reviewing-functions)
  - [Automatic Logging](#automatic-logging)
  - [Post-Installation Steps](#post-installation-steps)
  - [Auto Login](#auto-login)
  - [Configuration](#configuration)
  - [Why Move Away from VIP Mud?](#why-move-away-from-vip-mud)
  - [AI-Generated Content (AIGC)](#ai-generated-content-aigc)
- [Sound Attribution](#sound-attribution)
- [Contributions](#contributions)
  - [Adding Custom Scripts](#adding-custom-scripts)
  - [Fixes and Enhancements](#fixes-and-enhancements)
- [Support](#support)
- [License](#license)

Miriani-Next is a MUSHclient soundpack implementation specifically designed for [Miriani](https://toastsoft.net/). This soundpack enhances your gameplay experience by providing immersive audio feedback and modern conveniences. Miriani-Next runs on Windows and is easy to set up, allowing you to jump into the pilot seat with better sound and communication capabilities.

## About This Project

Miriani-Next is a successor to the excellent work done by Erick Rosso on [Toastush](https://github.com/PsudoDeSudo/Toastush). With the advent of agentic coding tools, work is currently underway to migrate popular features from the VIP Mud soundpack to MUSHclient, making them more performant and maintainable.

## New in Miriani-Next

**Audio & Configuration**
- Completely rewritten audio system with smarter muting, foreground sound support, and dynamic category management
- New menu-based configuration system (replaces the old dialog boxes in Toastush) with intuitive number-based or text selection. Type 'conf' to get started
- Simplified volume controls: Master, Sounds, and Environment categories
- Foreground sounds mode (Ctrl+F9) - only play sounds when MUSHclient is active

**Gameplay Enhancements**
- Automatic login with character selection
- Point tracking for license, combat, and organization points
- Starship contributions tracker with CONTRIBS command to view past contributions
- Archaeology depth tracker and compass for directional scanners
- 'smc <ship class>' or 'smc <number>.<class>' to see the closest ship of <class>, for users that don't use Proxiani
- Enhanced scan system with single-line formatting, filters, and scan history buffer, inspired by the Miriani Soundpack for VIP Mud and feedback from beta testers
- Baby sounds
- Bias drive, aquatic salvaging, planetary mining, and sanitation drone sounds
- Message board notifications with sound effects

**Communication & Buffers**
- Enhanced Channel History plugin with quick buffer cycling (Alt+Q)
- Favorite buffers system for quick access to commonly-used buffers
- Improved say triggers with better name matching and formatting
- Communicator and metafrequency static sounds
- Option to separate messages into a buffer for each metafrequency channel
- Many new buffers that can be enabled from 'conf buffers'

**Quality of Life**
- Info bar (Alt+Shift+I) shows focus, scan, and destination coordinates
- F2 opens changelog, F9 toggles mute, Shift+Escape stops all sounds
- many          classic sounds from Miriani 6 and Miriani 7 merged into the default soundpack
- 40+ new sound effects including beeps, announcements, weapons, and more

**Technical Improvements**
- Upgraded to MUSHclient 5.07-pre
- Configuration is now saved to an external file for easy backup/transfer
- Enhanced the handheld weapon system using soundpack hooks for better reliability
- Automatic ASCII character translation for special characters, such as smart quotes, apostrophes, etc. Never worry about the MOO stripping your punctuation again!

## Installation

### Option 1: Installer (Recommended)

1. Download the latest installer from the [releases page](https://codeberg.org/miriani-next/miriani-next/releases).
2. Run `Miriani-Next-Setup-X.X.X.exe` and follow the installation wizard.
3. The installer will:
   - Install all necessary files
   - Optionally install Visual C++ Redistributables (if needed)
   - Create desktop and start menu shortcuts
   - Set up the application in your chosen directory
4. (Optional) Configure your `worlds/Miriani.mcl` file to connect to `localhost` on port `1234` if you're using Proxiani.
5. (Optional) Set up the Proxiani server by visiting the [Proxiani GitHub page](https://github.com/PsudoDeSudo/proxiani) for the latest supported versions and detailed setup instructions.

### Option 2: Manual Installation

1. Download the latest version from [here](https://codeberg.org/miriani-next/miriani-next/archive/main.zip).
2. Extract the `miriani-next-main.zip` file to a location of your choice.
3. Navigate to the extracted folder and run `mushclient.exe` to launch MUSHclient.
4. (Optional) Configure your `worlds/Miriani.mcl` file to connect to `localhost` on port `1234` if you're using Proxiani.
5. (Optional) Set up the Proxiani server by visiting the [Proxiani GitHub page](https://github.com/PsudoDeSudo/proxiani) for the latest supported versions and detailed setup instructions.

## Getting Started

Below are some common questions that you may have when starting out. Special attention is given to VIP Mud specifically, although we encourage questions from all. If you're confused, join metafrequency channel 7.07 and someone will help you out.

If you're transitioning from the original Toastush soundpack, you should use the latest installer. The installer contains a migration tool, which will prompt you to move Toastush settings and state files. Ensure you have MUSHclient closed first before doing this.

Miriani-Next contains numerous configuration options that Toastush doesn't. In addition, the configuration system has been completely redesigned from the ground up. As a result, all settings from old Toastush installations may not fully transfer. Optimistically, you should expect at least some loss of configuration fidelity when migrating. Realistically it may not work at all. Very little time has been dedicated to testing this extensively, since reconfiguring the soundpack is a relatively painless process.

Remember that this soundpack is rapidly evolving and problems may occur. We'll do our best to address these as quickly as possible. This said, I'm only one person and I'm presently the only developer. Please have patience as we grow! (And do consider contributing your expertise if you know things, too.)

### Output and error windows

MUSHclient doesn't have an output area in the same way that VIP Mud does; it can have an output notepad, which is what Miriani-Next uses to save the world's output to an easily reviewable location.
VIP Mud users may be used to pressing Tab to enter the output area--in MUSHclient, the tab key acts as autocomplete. This feature analyzes recent output and rapidly finishes words or names for you. If you're using a screen reader, the autocompletion will be read automatically.

To access the output notepad, press Ctrl+Tab. To switch back to the main window, press it again.

Unlike VIP Mud, MUSHclient also doesn't have a dedicated log for errors. If you encounter errors, they'll initially appear as a dialog, but will also be logged to the output window. A checkbox in the error dialog allows you to tell MUSHclient to only log errors there instead of interrupting gameplay in the future. Similarly, debug messages for soundpack developers are also sent here.

To read output while in the main window, you're encouraged to use history buffers or output functions. There are many of these that you can configure under 'conf buffers', but we've enabled a suite of them by default. For more information, skip to the Output Buffers section below. The 'next:help' command may contain more up-to-date information.

Every so often, your output notepad may fill up and no more text will be added. Much like the primary world tab, you can press Ctrl+F4 to close the output window. Miriani-Next will automatically regenerate it upon the next line of text that's sent.

#### History Buffers

**Note**: For the most up-to-date list of keystrokes for buffer controls, type 'next:help' in Miriani-Next or review the info for the Channel History plugin in MUSHclient's plugins screen, accessible via Ctrl+Shift+P.

| Shortcut                   | Action                                                                        |
| -------------------------- | ----------------------------------------------------------------------------- |
| Alt + 1–0                  | Read 1st–10th latest message; double press = copy, triple press = paste       |
| Alt + Up / Down            | Read next / previous message in buffer                                        |
| Alt + Left / Right         | Move between your various buffers                                             |
| Alt + Shift + Left / Right | Reorder the currently selected buffer by moving it left or right              |
| Alt + Page Up / Down       | Move ±10 messages                                                             |
| Alt + Home / End           | Move to top or end of buffer                                                  |
| Alt + Space                | Repeat current message                                                        |
| Alt + Shift + Space        | Copy current message                                                          |
| Alt + Enter                | Open URL in the current message. If no URL, jump to MUSHclient's world config |
| Alt + Shift + 1–0          | Jump to 1st–10th buffer                                                       |
| Alt + Shift + `            | Jump to buffer starting with typed text or flip between buffers               |
| Alt + Backslash            | Search buffer for typed text (Add Shift to search from top instead of bottom) |
| Alt + Shift + Enter        | Copy current buffer to a notepad                                              |
| Alt + Shift + T            | Toggle timestamp announcements when reading history                           |
| Alt + Q                    | Cycle between quick buffers                                                   |
| Alt + Shift + Q            | Add/remove buffer from your quick list                                        |

---

#### Output Reviewing Functions

The following keystrokes will help you review and manipulate output.

| Shortcut                   | Action                                                                                                   |
| -------------------------- | -------------------------------------------------------------------------------------------------------- |
| Ctrl + 1–0                 | Read the last 1 to 10 lines of output. Press twice to copy, thrice to paste into the command input field |
| Ctrl + Tab                 | Switch between output and input windows                                                                  |
| Ctrl + Shift + U           | Move to the previous line                                                                                |
| Ctrl + Shift + O           | Move to the next line                                                                                    |
| Ctrl + Shift + Y           | Move to top                                                                                              |
| Ctrl + Shift + N           | Move to last line                                                                                        |
| Ctrl + Shift + H           | Read which line is currently focused                                                                     |
| Ctrl + Alt + Enter         | Toggle interrupt speech upon pressing Enter                                                              |
| Ctrl + Alt + O             | Toggle the output notepad on and off                                                                     |
| Ctrl + Shift + Space       | Begin selecting lines. Press it again to copy                                                            |
| Ctrl + Shift + Alt + Space | Same as above, but will put a space between each line when copied                                        |
| Ctrl + Shift + Alt + S     | Snapshot of the current output                                                                           |

### Automatic Logging

Logging is a work in progress! Ideally, this will be handled entirely for you behind the scenes, so please stay tuned for more information.

### Post-Installation Steps

Unlike the Miriani Soundpack for VIP Mud, no configuration is needed after installation, beyond the settings you'd like to change for your in-game experience in the 'conf' command. We assume a safe set of defaults for everyone—if you feel something should be turned on or off out of the box, let us know.

### Auto Login

Typically, the Miriani Soundpack for VIP Mud will use your VIP Mud character name and password for its auto login system.

Unfortunately, while MUSHclient has an auto login system, it's impossible to retrieve your provided credentials. For the soundpack to work properly upon logging in, we need to tell Miriani that the soundpack is in use, and this must occur before we send your username and password. This ensures Miriani will send environmental information when you first connect.

To navigate this complexity, Miriani-Next has its own login system, which you can configure under 'conf auto'.

### Configuration

All configuration for Miriani-Next is saved in the `worlds\settings` folder. This includes auto login credentials, so be careful! If you use auto login and are sharing your configurations, delete the auto_login.conf file first. Additionally, ensure that your Miriani-Next folder is in a safe place if you're using a shared machine.

Miriani-Next is not responsible for client configuration (connection info, fonts, etc.). These are managed by MUSHclient and exist in both:

* Global prefs file: `mushclient_prefs.sqlite`, `mushclient.ini`
* World file: `worlds\Miriani.MCL`

### Why Move Away from VIP Mud?

VIP Mud has been the traditional choice for Miriani players for good reason - the **Miriani Soundpack for VIP Mud** (previously known as the Offline Cloud Soundpack) is stellar. It continues to provide an incredibly rich, immersive audio experience that makes the game come alive. For years, it's been the gold standard for Miriani gameplay.

However, VIP Mud itself comes with significant limitations that make it increasingly problematic:

- **Dead Technology**: VIP Mud is written in VB6 (Visual Basic 6), which reached end-of-life in 2008. The runtime dependencies are legacy components that Windows may stop supporting at any time. Even if the current maintainer were to continue doing so, there are no modern development tools, debuggers, or libraries that work with VB6

 - **Performance Problems**: VIP Mud suffers from poor performance that impacts gameplay. The performance issues were so severe that they led to the creation of tools like [Proxiani](https://github.com/tms88/proxiani), which acts as a local proxy to work around VIP Mud's performance limitations.

- **Limited Trigger System**: VIP Mud has a hard limit on the number of triggers you can create, which severely restricts how complex your soundpack or automation can be. This artificial limitation forces compromises in functionality.

- **Commercial Software for a Niche Market**: VIP Mud is commercial software. Who pays for MUD clients these days? Most MUD clients are free and open source, making this an increasingly hard sell. In fact, every other single popular client that's still maintained is completely free.

- **Abandoned Development**: VIP Mud is no longer actively maintained. The original owner transferred it to someone else, but no meaningful updates have been made, which should concern anyone continuing to use the software. There have been only 3 major version releases since 2008 (1.0, 1.1, and 2.0). Nearly two decades of stagnation while still charging the same price does not bode well for the future

- **No Modern Scripting**: VIP Mud lacks support for modern scripting languages like Lua, Python, or JavaScript. This makes it difficult for players to customize their experience or add new features without diving into the outdated, proprietary scripting language

MUSHclient, in contrast, is free, open source, actively maintained, and supports Lua scripting out of the box. This makes it a far more future-proof platform for Miriani players. Our goal is to bring the same stellar experience from the VIP Mud soundpack to this more sustainable platform. While MUSHclient still lacks some modern features, such as built-in TLS, work is ongoing to find solutions to this. MUSHclient has a much richer catalog of plugins and features, and doesn't require knowledge of a proprietary, esoteric scripting language to maintain.

### AI-Generated Content (AIGC)

This project leverages modern agentic AI coding tools to accelerate development and feature migration. However, we take code quality seriously:

- **All AI-generated code is reviewed**: Every piece of AI-generated content goes through human review before being committed to the repository.
- **Testing and validation**: AIGC is tested to ensure it works correctly and integrates properly with existing systems. Updates are carefully tested in a small group of alpha testers prior to being pushed to the public.
- **Quality over speed**: While AI helps us move faster, we prioritize code quality, maintainability, and the user experience.

We believe in transparency about our development process. The combination of AI assistance and human oversight allows us to rapidly migrate features from the VIP Mud soundpack while maintaining high standards.

These scripts are **not** vibe-coded; while ~70% of the codebase is written by AI, commits are not blindly accepted and the process remains collaborative. Outside of the development process, the codebase is routinely reviewed for cruft or AI "slop". We prioritize security and performance over feature bloat.

**Disclaimer**: I don't actively play the game anymore, so things may break and I may be slow to fix them. If you're interested in helping maintain the soundpack, please let me know! This is a community project.

## Sound Attribution

We stand on the shoulders of giants. This project utilizes sounds from the following sources:

- [Zapsplat](https://www.zapsplat.com)
- [Pixabay](https://pixabay.com/)
- Miriani6 (Liam Erven, Chris Nestrud, and others)
- Miriani 7
- MTMiriani
- Miriani Soundpack for VIP Mud

We extend our gratitude to these projects for providing high-quality audio resources.

Additionally, immense thanks goes to my initial testers that put up with numerous questions and many hours of bug-hunting: Gage Vieraah, Ryan Salvatore, Mark Sainsbury, Jason Harkness, Hannah Holloway, Buck Hadford, and Alan Nez.

## Contributions

We welcome contributions to Miriani-Next! To contribute:

1. **Adding Custom Scripts**:
   - Create a new file in the project directory titled `extras-<user>.lua`, replacing `<user>` with your username or handle.
   - Include your custom scripts in this file.

2. **Fixes and Enhancements**:
   - Before submitting a Pull Request (PR), please open an issue describing the problem or enhancement you plan to address. This helps us discuss potential changes and reduces the likelihood of merge conflicts.

## Support

For any issues, questions, or feedback, feel free to open an issue on this repository. If you'd like to talk to other Miriani-Next users, tune a metafrequency communicator to channel 7.07 in-game.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.