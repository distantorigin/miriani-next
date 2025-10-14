# MirianiNext

MirianiNext is a MUSHclient soundpack implementation specifically designed for [Miriani](https://toastsoft.net/). This soundpack enhances your gameplay experience by providing immersive audio feedback. MirianiNext runs on Windows and is easy to set up, allowing you to jump into the pilot seat with better sound and communication capabilities.

## About This Project

MirianiNext is a successor to the excellent work done by Eric Rosso on [Toastush](https://github.com/PsudoDeSudo/Toastush). With the advent of agentic coding tools, work is currently underway to migrate popular features from the VIP Mud soundpack to MUSHclient, making them more performant and maintainable.

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

## Features

### Miriani-Next Highlights

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

**Note**: There is not yet a self-extracting installer with a desktop icon. Manual installation is required for now.

1. Download the latest version from [here](https://codeberg.org/miriani-next/miriani-next/archive/main.zip).
2. Extract the `miriani-next-main.zip` file to a location of your choice.
3. Navigate to the extracted folder and run `mushclient.exe` to launch MUSHclient.
4. (Optional) Configure your `worlds/Miriani.mcl` file to connect to `localhost` on port `1234` if you're using Proxiani.
5. (Optional) Set up the Proxiani server by visiting the [Proxiani GitHub page](https://github.com/PsudoDeSudo/proxiani) for the latest supported versions and detailed setup instructions.

## Sound Attribution

We stand on the shoulders of giants. This project utilizes sounds from the following sources:

- [Zapsplat](https://www.zapsplat.com)
- [Pixabay](https://pixabay.com/)
- Miriani6 (Liam Erven, Chris Nestrud, and others)
- Miriani 7
- MTMiriani

We extend our gratitude to these projects for providing high-quality audio resources.

Additionally, immense thanks goes to my initial testers that put up with my numerous questions and many hours of bug-hunting: Gage Vieraah, Ryan Salvatore, Mark Sainsbury, Jason Harkness, Hannah Holloway, Buck Hadford, and Alan Nez.

## Contributions

We welcome contributions to MirianiNext! To contribute:

1. **Adding Custom Scripts**:
   - Create a new file in the project directory titled `extras-<user>.lua`, replacing `<user>` with your username or handle.
   - Include your custom scripts in this file.

2. **Fixes and Enhancements**:
   - Before submitting a Pull Request (PR), please open an issue describing the problem or enhancement you plan to address. This helps us discuss potential changes and reduces the likelihood of merge conflicts.

## Support

For any issues, questions, or feedback, feel free to open an issue on this repository. If you'd like to talk to other MirianiNext users, tune a metafrequency communicator to channel 7.07 in-game.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.