# Miriani-Next

# Table of Contents

- [About This Project](#about-this-project)
- [Installation](#installation)
  - [Online vs Offline Installers](#online-vs-offline-installers)
- [Getting Started](#getting-started)
  - [Post-Installation Steps](#post-installation-steps)
  - [Reviewing Output](#reviewing-output)
    - [Accessible Output Window](#accessible-output-window)
    - [History Buffers](#history-buffers)
    - [Output Navigation Functions](#output-navigation-functions)
  - [Errors](#errors)
  - [Auto Login](#auto-login)
  - [Automatic Logging](#automatic-logging)
- [Updates](#updates)
  - [Checking for Updates](#checking-for-updates)
  - [Automatic Updates](#automatic-updates)
  - [Update Channels](#update-channels)
  - [Switching Channels](#switching-channels)
  - [Troubleshooting Update Issues](#troubleshooting-update-issues)
- [Configuration](#configuration)
  - [Configuration Options Reference](#configuration-options-reference)
- [Commands Reference](#commands-reference)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [What's New in Miriani-Next](#whats-new-in-miriani-next)
- [Why Move Away from VIP Mud?](#why-move-away-from-vip-mud)
- [Design Philosophy](#design-philosophy)
- [AI-Generated Content (AIGC)](#ai-generated-content-aigc)
- [Contributions](#contributions)
- [Sound Attribution](#sound-attribution)
- [Support](#support)
- [License](#license)

Miriani-Next is a MUSHclient client package specifically designed for [Miriani](https://toastsoft.net/). It provides audio feedback and modern conveniences for Miriani gameplay. Miriani-Next runs on Windows and is easy to set up.

## About This Project

Miriani-Next is a successor to the excellent work done by Erick Rosso on [Toastush](https://github.com/PsudoDeSudo/Toastush). With the advent of agentic coding tools, work is currently underway to migrate popular features from the VIP Mud soundpack to MUSHclient, making them more performant and maintainable.

Remember that this client package is rapidly evolving and problems may occur. We'll do our best to address these as quickly as possible. This said, I'm only one person and I'm presently the only developer. Please have patience as we grow! (And do consider contributing if you have relevant skills.)

If you're confused about anything, join metafrequency channel 7.07 in-game and someone will help you out.

## Installation

1. Download the `miriani.exe` launcher from the [releases page](https://github.com/distantorigin/next-launcher/releases)
2. Run `miriani.exe`
3. The launcher will guide you through initial installation and updates

The launcher handles everything automatically - installation, updates, channel selection (stable/dev), and migration from older versions. It will install Miriani-Next to your Documents folder by default.

**Proxiani Users**: The launcher automatically detects Proxiani and updates world files accordingly. If you're using Proxiani, make sure it's running before launching Miriani-Next. See the [Proxiani GitHub page](https://github.com/PsudoDeSudo/proxiani) for Proxiani setup.

### Online vs Offline Installers

There are two versions of the installer available:

- **miriani.exe** (Online Installer): A small download that fetches the latest files from the internet during installation. This is the recommended choice for most users, and is housed in a separate repository.
- **miriani-<version>.exe** (Offline Installer): A larger download that contains everything needed to install without an internet connection. Use this if you have unreliable internet or need to install on a computer without network access. You can find these on the [miriani-Next releases page](https://github.com/distantorigin/miriani-next/releases).

Both installers work the same way - the only difference is whether files are downloaded during installation or already included.

## Getting Started

If you're transitioning from the original Toastush client package, you should use the latest installer. The installer contains a migration tool, which will prompt you to move Toastush settings and state files. Ensure you have MUSHclient closed first before doing this.

Miriani-Next contains numerous configuration options that Toastush doesn't. In addition, the configuration system has been completely redesigned from the ground up. As a result, all settings from old Toastush installations may not fully transfer. Optimistically, you should expect at least some loss of configuration fidelity when migrating. Realistically it may not work at all. Very little time has been dedicated to testing this extensively, since reconfiguring the client package is a relatively painless process.

### Post-Installation Steps

Unlike the Miriani Soundpack for VIP Mud, no configuration is needed after installation beyond the settings you'd like to change via the `conf` command. We assume safe defaults for everyone.

**Required: Type `INFO` after your first login.** Miriani-Next needs to detect your organization and courier company to play the correct sounds for those channels. Just type `INFO` once after connecting - it reads your organization from the output and saves it automatically. If you skip this, organization and courier channel sounds won't work.

### Reviewing Output

There are two ways to review game output:

#### Accessible Output Window

A read-only text field containing up to 500,000 lines of complete game output. Use this when you need to review everything that happened - all messages in chronological order.

- **Press Tab** to switch to the output window, Tab again to return to input
- First time you press Tab, you'll be prompted to enable this behavior (or enable via `conf general tab`)
- When Tab switching is enabled, autocomplete moves to **Ctrl+Space**
- **Ctrl+F** to search within the output
- Start typing to automatically return to input

You can set the output window to launch automatically under **World Preferences > Output**. The line limit is also adjustable there.

#### History Buffers

Categorized message buffers that let you review specific types of messages without leaving the input area. Messages are automatically sorted by type (communication, combat, private messages, flight control, etc.).

- **Alt+Left/Right** - Switch between buffers (e.g., from "Communication" to "Combat")
- **Alt+Up/Down** - Navigate through messages in the current buffer
- **Alt+1-0** - Jump to the 1st-10th most recent message
- **Alt+Q** - Cycle through your "quick buffers" (favorites)

Configure which buffers are enabled under `conf buffers`. By default, useful buffers like Communication, Combat, and Private comms are enabled.

#### Output Navigation Functions

Keyboard shortcuts for quickly reading recent output without leaving input or switching windows:

- **Ctrl+1-0** - Read the last 1-10 lines (double-press to copy, triple-press to paste)
- **Ctrl+Shift+U/O** - Move to previous/next line
- **Ctrl+Shift+Y/N** - Jump to top/bottom of output
- **Ctrl+Shift+H** - Read the currently focused line
- **Ctrl+Shift+Space** - Begin selecting lines (press again to copy)

These are useful for quick checks ("what just happened?") without fully switching context.

**When to use which:** The output window gives you everything in one place - useful for reading back many pages or searching. History buffers let you quickly check specific channels (e.g., "what did flight control say?") without wading through combat spam. Output functions are for quick glances at recent lines. Use all three as needed.

### Errors

There's no separate error window in MUSHclient. Errors initially appear as a dialog, but are also logged to the accessible output window. A checkbox in the error dialog lets you suppress future popups. Debug messages for developers also appear in the output window.

### Auto Login

Typically, the Miriani Soundpack for VIP Mud will use your VIP Mud character name and password for its auto login system.

Unfortunately, while MUSHclient has an auto login system, it's impossible to retrieve your provided credentials. For the client package to work properly upon logging in, we need to tell Miriani that Miriani-Next is in use, and this must occur before we send your username and password. This ensures Miriani will send environmental information when you first connect.

To navigate this complexity, Miriani-Next has its own login system, which you can configure under `conf auto_login` (or `conf auto` for short).

### Automatic Logging

Miriani-Next includes an automatic logging system that handles everything for you. Logs are automatically rotated daily at midnight and organized in a structured directory:

```
logs/<world>/<year>/<month>/<day> <Month> <year>.txt
```

**Log Management Commands** (use the `lg` command):
- `lg view` - Opens today's log in your default text editor
- `lg view <days>` - Opens the log from N days ago (e.g., `lg view 3` for 3 days ago)
- `lg find <text>` - Searches all logs for specific text with paginated, interactive results
- `lg stats` - Shows statistics (total files, size, lines, date range)
- `lg toggle` - Enables or disables logging
- `lg help` - Shows available commands

The search feature (`lg find`) scans all logs and presents results in an interactive menu where you can select a match to open that log file at the relevant line.

## Updates

Miriani-Next includes a built-in update system that keeps your client package current with the latest features and fixes.

### Checking for Updates

There are several ways to check for and install updates:

- **Press Ctrl+U** while in MUSHclient to check for and install updates. This is a shortcut for the `update` command.
- **Type `update check`** to see if updates are available without installing them

When updates are found, you'll be prompted to install them. Some updates may require MUSHclient to restart - you'll be notified if this is needed.

### Automatic Updates

Miriani-Next can update automatically based on your preferences in `conf general`:

- **Automatically apply updates quietly at login**: Updates install silently when you connect to the game
- **Automatically apply updates while idle**: Updates install when you're idle
- **Play a sound for pending updates**: Get an audio alert when updates are ready (only for stable releases)

### Update Channels

Updates come from one of two channels:

- **Stable**: Tested releases that have been verified by alpha testers. This is the default and recommended for most players.
- **Dev**: The latest development code with new features and fixes. Updates come more frequently but may occasionally have issues.

Additionally, more channels may be made available as needed--thes etake the form of new branches in this repository.

You can switch channels at any time without losing your settings. You will not, however, be able to switch to another channel if that would downgrade your version.

### Switching Channels

The easiest way to switch channels is using the batch files in your Miriani-Next folder:

- **Switch to Stable.bat** - Switch to the stable channel for tested releases
- **Switch to Dev.bat** - Switch to the dev channel for the latest features
- **Switch to Any Channel.bat** - Opens an interactive menu to choose your channel

You can also switch channels from within the client by typing `update switch` for an interactive menu, or `update switch stable` or `update switch dev` to switch directly.

### Troubleshooting Update Issues

If you encounter problems updating from within MUSHclient, you can run the updater directly:

1. Close MUSHclient completely
2. Navigate to your Miriani-Next folder (usually in Documents\Miriani-Next)
3. Double-click **update.exe** to run the updater outside of MUSHclient

This is particularly helpful for users running MUSHclient in a virtual machine that shares folders with the host computer, as permission issues can sometimes prevent inline updates from completing properly.

For a full list of update commands, see the [Commands Reference](#commands-reference) section.

## Configuration

Miriani-Next uses an interactive, menu-based configuration system. Access it by typing `conf` or pressing **F1**.

**Configuration Command Syntax**:
- `conf` - Opens the main configuration menu showing all categories
- `conf <category>` - Jumps directly to a category (e.g., `conf ship`, `conf buffers`)
- `conf <category> <option>` - Directly edits a specific option (e.g., `conf ship secondary` for secondary lock sounds)

**Main Configuration Categories**:
- **general** - General Settings (roundtime, escape behavior, DND mode, wake on red, foreground sounds, updates)
- **auto login** - Auto Login credentials and settings (shortcut: `conf auto`)
- **ship** - Starship Options (scan formatting, drive frequency, secondary lock sounds)
- **room** - Room and Environment (ambiance, digsite detector, praelor counter)
- **helpers** - Helpers and Extras (archaeology helper, counters, point calculations)
- **screen reader** - Screen Reader Integration (interrupt settings for different events)
- **gags** - Spam and Gag Filters (spam reduction, combat messages, camera feeds)
- **socials** - Social Sounds (master toggle and subcategories for different social types)
- **scan formats** - Configure Scan Templates (customizable output for different object types)
- **buffers** - Output Buffers (25+ toggle options for communication channels)
- **colors** - Color Customization (14 color picker options for UI elements)
- **audio groups** - Toggle Sound Categories (dynamic list of discovered sound groups)
- **sound variants** - Sound Variants (select alternate versions of specific sounds)
- **developer** - Developer Options (debug mode, sound buffer, hooks buffer)

**File Storage**:

All configuration for Miriani-Next is saved in the `worlds\settings` folder:
- `toastush.conf` - Main configuration (only stores user-modified values)
- `auto_login.conf` - Auto login credentials (saved separately)

**Security Note**: These files include auto login credentials if enabled. If you're sharing configurations, delete the `auto_login.conf` file first. Keep your Miriani-Next folder secure on shared machines.

**Client Configuration**:

Miriani-Next is not responsible for MUSHclient configuration (connection info, fonts, window settings). These are managed by MUSHclient and exist in:
* Global prefs: `mushclient_prefs.sqlite`, `mushclient.ini`
* World file: `worlds\Miriani.MCL`

### Configuration Options Reference

**General Settings** (`conf general`)
- **Automatically open changelog after updates**: Opens the changelog in a notepad window automatically after updates are applied. Know what changed without manually checking.
- **Automatically apply updates quietly at login**: The launcher will check for and install updates silently when you log in, without prompting. If disabled, you'll be notified but need to manually confirm updates.
- **Automatically apply updates while idle**: Allows the launcher to apply updates while you're idle in-game. Updates won't interrupt active gameplay.
- **Play a sound for pending updates**: Plays an alert sound when updates are available. Alerts you to pending updates without watching console output.
- **Play beep sound on keep-alive messages**: Plays a beep when the server sends keepalive messages (the periodic "pings" to keep your connection alive). Most users leave this off.
- **Play a sound when roundtime is up**: Plays a sound when your roundtime expires (after actions that prevent immediate movement/combat). Know when you can act again without checking prompts.
- **Use Escape key to send @abort command**: Pressing Escape sends the `@abort` command to cancel ongoing actions. If disabled, Escape only clears your command input or closes dialogs.
- **Use Tab to activate output window instead of tab completion**: Changes Tab key behavior - when enabled, Tab switches to the output window instead of doing tab completion. Screen reader users benefit from frequent scrollback access.
- **Alt+Space shows exits instead of current history item**: When enabled, Alt+Space displays room exits. When disabled, it reads the current history buffer message instead.
- **Do Not Disturb mode (stops all sounds and TTS)**: Do Not Disturb mode silences all sounds and TTS output. Stay quiet while remaining connected.
- **Disable DND mode when ship goes to red alert (Wake on Red)**: Automatically disables DND when your ship goes to red alert (combat). Combat sounds break through even in quiet mode.
- **Restrict sounds to only when window has focus**: Sounds only play when MUSHclient has focus. Prevents sounds from playing while you're working in other applications.
- **Link Recipients (Auction Service, combat mission notification service, etc) bypass foreground sounds**: Link recipient messages (Auction Service, combat mission notifications, etc.) ignore the foreground sounds setting and always play. Never miss important announcements.
- **Play direction sounds when following or being dragged**: Plays directional audio cues when you're following someone or being dragged. Track movement direction without reading every line.

**Auto Login** (`conf auto_login`)
- **Enable automatic login when connecting to the game**: Automatically sends your username and password when connecting to the game. The client package's login system ensures Miriani receives proper initialization before credentials are sent.
- **Username for auto login (use underscores for spaces)**: Your character name. Use underscores (_) instead of spaces (e.g., `John_Smith` for "John Smith").
- **Password for auto login**: Your password. Stored in `auto_login.conf` - keep this file secure and exclude it when sharing configurations.

**Starship Options** (`conf ship`)
- **Print formatted single-line scan output instead of raw multi-line output**: Reformats scan output into single lines using customizable templates (see Scan Templates below). Makes scans much easier to read and parse, especially with screen readers. Compare raw multi-line output vs. formatted: "The Artemis (Interceptor) is 523 units away, at 12, 15, 7."
- **Relativity drive frequency**: Audio frequency for the relativity drive sound effect (default: 44100 Hz). Adjust if the sound is too high/low pitched for your preference.
- **Play a different sound for unfocus locks**: Plays a different sound for secondary (unfocused) weapons locks versus primary locks. Distinguish which weapons system is targeting.
- **Print 'unchanged' before coordinates if the target has not moved since its last scan**: Adds "unchanged" before coordinates if the target hasn't moved since last scan. Track whether targets are stationary or moving.
- **Print remaining cannon shots (use WEAPON command in weapon room to initialize)**: Displays remaining cannon ammunition after each shot. Use the WEAPON command in a weapon room first to initialize the counter.

**Room and Environment** (`conf room`)
- **Play background ambiances**: Plays ambient environmental sounds based on your location (space station hum, planet atmosphere, etc.). Adds immersion but can be distracting during intense gameplay.
- **Print the number of insectoids detected in a room**: Displays the total number of insectoids (praelor) detected in the current room. Quickly assess threat level.
- **Play a sound when detecting a digsite**: Plays an alert sound when you enter a room with an archaeology digsite. Locate dig sites while exploring.
- **Play a sound when detecting stores**: Plays an alert sound when entering rooms with stores. Find shops while exploring unfamiliar stations.

**Helpers and Extras** (`conf helpers`)
- **Buried artifact depth tracker**: Tracks the depth of buried artifacts during archaeology digs. Displays depth automatically as you dig so you know when you're close.
- **Calculate direction from scanner instead of showing coordinates**: Converts directional scanner coordinates into compass directions (north, southwest, etc.) instead of showing raw X/Y/Z values. Easier to navigate with.
- **Display counter values when activities are completed**: Announces counter values when activities complete (e.g., "5 artifacts found today"). Shows your progress at a glance.
- **Reset activity counters at startup**: Resets all activity counters (artifacts, missions, debris, etc.) when the client package loads. Leave disabled if you want cumulative long-term tracking.
- **Show sector numbers instead of names in flight control messages**: Flight control messages show sector numbers (Sector 15) instead of sector names (Sol Sector). Better if you memorize sectors by number.
- **Show point difference calculations when using your portable point unit**: When checking your portable point unit, displays the difference in points since last check ("+5 combat points"). Tracks point gains easily.

**Screen Reader Integration** (`conf screen reader`)
- **Interrupt speech for public address (PA) messages**: Public address announcements interrupt screen reader speech immediately. Never miss important station-wide announcements.
- **Interrupt speech when detecting insectoid activity**: Insectoid detection messages interrupt speech immediately. Critical for combat awareness - you'll hear praelor warnings right away.
- **Interrupt speech for scan coordinates**: Controls speech interruption for scan results. Options: "starships" (interrupt only for ship scans), "everything" (interrupt for all scans), "off" (never interrupt).
- **Interrupt speech when following**: Movement messages interrupt speech when following someone or being dragged. Know immediately when you're moving.

**Spam and Gag Filters** (`conf gags`)
- **Reduce spam by gagging flavored text**: Gags repetitive "flavor text" messages that don't affect gameplay. Reduces clutter without hiding important information.
- **Gag external camera output**: Hides external camera feed output. Reduce spam if you don't use cameras.
- **Gag internal camera output**: Hides internal camera (turret/droid) feed output.
- **Gag friendly (non-praelor) sector combat messages**: Gags combat messages for non-praelor enemies in space. Reduces spam during sector combat while keeping praelor alerts visible.

**Social Sounds** (`conf socials`)
- **Enable all social sounds (master toggle)**: Master toggle for all social sounds. When disabled, no social sounds will play regardless of category settings. Disable if you find social sounds distracting.
- **Laughter (laugh, giggle, chuckle, etc)**: Sounds for laugh, giggle, chuckle, snicker, cackle, etc. The most common social category.
- **Distress (cry, sob, moan, etc)**: Sounds for cry, sob, moan, whimper, sigh, etc. Emotional distress socials.
- **Reflex (cough, sneeze, yawn, etc)**: Sounds for cough, sneeze, yawn, hiccup, gasp, etc. Involuntary bodily reactions.
- **Bodily (fart, burp, belch, etc)**: Sounds for fart, burp, belch, etc. Crude humor socials (toggle if you prefer less silly sounds).
- **Physical (punch, kick, clap, etc)**: Sounds for punch, kick, clap, snap, stomp, etc. Physical action socials.
- **Novelty (animals, musical, memes, etc)**: Sounds for animals (meow, bark, moo), musical (hum, sing), and memes (dab, yeet). Fun but potentially annoying - disable if you prefer serious gameplay.
- **Uncategorized**: Miscellaneous social sounds that don't fit other categories. Each individual social can be toggled within these categories.

**Scan Templates** (`conf scan_formats`)
Customize the output format for different scan object types (starships, planets, stations, etc.). Each template uses variables like `{name}`, `{distance}`, `{coordinates}`, etc. to build the output string. For example, the starship template might be: `{name} ({ship_type}) is {distance} units away at {coordinates}`. Modify these to show only the information you care about or reorder elements. Variables available for each object type vary - check the code comments in options.lua for the full list.

**Output Buffers** (`conf buffers`)
Channel history separates different message types into dedicated buffers that you can browse independently using Alt+Left/Right. Toggle which buffers you want:
- **Communication (all channels)**: All channels combined (usually want this on)
- **Private communication**: Private messages, pages, tells
- **Combat**: Combat messages and alerts
- **General communication**: General communication channel
- **URLs (http, mailto, gofer, etc)**: All URLs (http, mailto, gofer links, etc.) in one place
- **Camera feeds (droids, internal turrets, external camera)**: External camera, turret feeds, droid vision
- **Tradesman market**: Market announcements and trades
- **Metafrequency**: All metafrequency channels (or use separate buffers below)
- **Flight control**: Flight control messages and docking requests
- **Say communication**: In-room say messages
- **Whispers**: Whispered messages
- **OOC communication (ROOC, SOOC, OOC channel)**: Out-of-character channels (ROOC, SOOC, OOC)
- **Ship-to-ship communication**: Ship communication
- **Public address speaker (PA)**: PA announcements
- **Alliance communication**: Alliance channel
- **Message boards**: Board posts and notifications
- **Chatter communication**: Chatter channel
- **Starship computer messages**: Starship computer messages
- **Architectural design channel**: Architectural design channel
- **Credit contributions**: Credit contribution messages
- **Auctions**: Auction service
- **Organization channel**: Organization channel
- **Courier company channel**: Courier company channel
- **Newbie Channel**: Newbie help channel
- **Starship Scans**: Starship scans (separate from other output)
- **Roleplay**: Roleplay channel
- **Separate metafrequency buffers by frequency/label**: Creates individual buffers for each metafrequency channel/label instead of one combined buffer. Monitor multiple frequencies separately (e.g., buffer for 7.07, buffer for 10.5, etc.).

**Color Customization** (`conf colors`)
Opens a color picker to customize text colors for different message types (combat, communication, flight control, etc.) and UI elements (info bar, hyperlinks). Visually distinguish message categories at a glance.

**Sound Categories** (`conf audio groups`)
Miriani-Next discovers audio categories dynamically as sounds play (Starship, Vehicle, Activity, Combat, Environment, etc.). Toggle entire categories on/off. For example, disable "Environment" to silence all ambient sounds without affecting starship or combat sounds. Categories are discovered during gameplay - new categories appear as you encounter new sound types.

**Sound Variants** (`conf sound variants`)
Some sounds have multiple versions you can choose from:
- **Ship acceleration/deceleration**: Different engine sound variants
- **Vehicle acceleration/deceleration**: Ground vehicle engine variants
- **Archaeology artifact**: Different "discovery" sound effects
- **Jingle bells**: Holiday sound variants
Select your preferred version for each. Adds variety and personalization without requiring custom sound files.

**Developer Options** (`conf developer`)
- **Debug notifications (missing audio files, etc)**: Shows debug notifications for missing audio files, trigger errors, and other development issues. Enable if you're developing scripts or troubleshooting problems. Creates extra noise for normal users.
- **Sound Playback History**: Creates a buffer showing all recently played sounds with their file names and playback details. Identify which sound file corresponds to which action.
- **Hooks buffer**: Shows hook executions (when triggers fire special events). For developers creating extensions or debugging trigger interactions.

## Commands Reference

This section documents all major commands available in Miriani-Next.

**Configuration**
- `conf` - Open main configuration menu
- `conf <category>` - Jump to specific category (e.g., `conf ship`, `conf buffers`)
- `conf <category> <option>` - Directly edit an option (e.g., `conf general roundtime`)

**Log Management**
- `lg view` - Open today's log
- `lg view <days>` - Open log from N days ago (e.g., `lg view 3`)
- `lg find <text>` - Search all logs for text
- `lg stats` - Show log statistics
- `lg toggle` - Enable/disable logging
- `lg help` - Show log command help

**Activity Tracking**
- `counters` - Display all activity counters
- `counters reset` - Reset all counters
- `counters reset <name>` - Reset specific counter
- `contribs` - View starship contribution history
- `contribs clear` - Clear contribution history

**Scan Commands**
- `sc<letter>` - Filter by attribute (e.g., `sca` for atmosphere, `scn` for natural resources)
- `scu` - Force single-line scan output
- `smc <class>` - Show closest ship of specified class (e.g., `smc interceptor`)
- `sc.help` - View scan filter options
- `sc.reset` - Reset scan state
- `sm.help` - View starmap filter options

**Updates**
- `update` - Check and install updates
- `update switch <channel>` - Switch update channel (dev/stable)
- `update check` - Check for updates without installing
- `update help` - Show update command help

**Sound Control**
- `dnd` - Toggle Do Not Disturb mode (blocks all sounds)
- `dnd on` / `dnd off` - Explicitly enable/disable DND mode
- `fsounds` - Toggle foreground sounds (sounds only when window has focus)
- `next:minimal` or `next:min` - Toggle minimal mode (disables most triggers)

**Information**
- `whatsnew` or `next:changes` - View changelog
- `next:help` - Display help information
- `next:info` - Show version and information

**Text-to-Speech (Screen Readers)**
- `tts` - Toggle TTS on/off (also F8)
- `ftts` - Toggle focus-based TTS (Ctrl+F8) - controls whether speech stops when you switch windows
- `subst add <text>==<replacement>` - Replace text with something else when spoken (e.g., `subst add HP==health points`)
- `subst remove <text>` - Remove a substitution
- `subst list` - List all substitutions
- `subst clear` - Clear all substitutions
- `subst on` / `subst off` - Enable/disable substitutions
- `subst save` - Save substitutions to disk

**Developer**
- `spreload` - Reload all plugins (for developers)

## Keyboard Shortcuts

Complete reference of keyboard shortcuts. For the most up-to-date list, type `next:help` in-game.

**Audio**
| Shortcut | Action |
|----------|--------|
| F9 | Toggle global mute |
| Ctrl+F9 | Toggle foreground sounds |
| F10 / Shift+F10 | Cycle audio groups forward/backward |
| F11 / F12 | Decrease/increase current group volume |
| Ctrl+L | Reinitialize audio (useful when switching soundcards) |
| Ctrl+D | Toggle Do Not Disturb mode |

**Configuration & Help**
| Shortcut | Action |
|----------|--------|
| F1 | Open configuration menu (`conf`) |
| F2 | View changelog |

**Screen Reader (TTS)**
| Shortcut | Action |
|----------|--------|
| F8 | Toggle TTS on/off |
| Ctrl+F8 | Toggle focus-based TTS |

**Channel History (Buffers)**
| Shortcut | Action |
|----------|--------|
| Alt+1–0 | Read 1st–10th latest message (double press = copy, triple = paste) |
| Alt+Up/Down | Read next/previous message |
| Alt+Left/Right | Switch between buffers |
| Alt+Shift+Left/Right | Reorder current buffer |
| Alt+PageUp/PageDown | Jump ±10 messages |
| Alt+Home/End | Jump to top/bottom of buffer |
| Alt+Space | Repeat current message |
| Alt+Shift+Space | Copy current message |
| Alt+Enter | Open URL in message (or world config if no URL) |
| Alt+Shift+1–0 | Jump to 1st–10th buffer |
| Alt+` | Jump to buffer by typed text (or flip between last two) |
| Alt+Backslash | Search buffer for typed text (Shift = search from top) |
| Alt+Shift+Enter | Copy current buffer to notepad |
| Alt+Shift+T | Toggle timestamp announcements |
| Alt+Q | Cycle through quick buffers |
| Alt+Shift+Q | Add/remove buffer from quick list |

**Output Window**
| Shortcut | Action |
|----------|--------|
| Ctrl+1–0 | Read last 1–10 lines (double = copy, triple = paste) |
| Ctrl+Tab | Switch between output and input windows |
| Ctrl+Shift+U/O | Move to previous/next line |
| Ctrl+Shift+Y/N | Move to top/bottom |
| Ctrl+Shift+H | Read currently focused line |
| Ctrl+Alt+Enter | Toggle interrupt speech on Enter |
| Ctrl+Alt+O | Toggle output notepad |
| Ctrl+Shift+Space | Begin selecting lines (press again to copy) |
| Ctrl+Shift+Alt+Space | Select with spaces between lines |
| Ctrl+Shift+Alt+S | Snapshot current output |

**General**
| Shortcut | Action |
|----------|--------|
| Alt+Shift+U | Open last URL |
| Alt+Shift+I | Read info bar |
| Escape | Close dialog / clear command text / send @abort (configurable) |
| Shift+Escape | Reset sounds and trigger groups |
| Tab/Shift+Tab | Activate accessible output (when enabled) |
| Ctrl+Space | Tab completion (when Tab activates output) |

## What's New in Miriani-Next

See the [changelog](docs/changelog.md) for a comprehensive list of changes since Toastush 3.0.

**Major Features**
- Terminal-based configuration system (`conf`) - navigate menus with number or text selection
- Automatic daily log rotation with full-text search (`lg find`)
- Enhanced scan system with filters, single-line formatting, and scan history
- Channel history with infinite scrollback, quick buffer cycling (Alt+Q), and search
- Automatic login with character selection
- Do Not Disturb mode with wake-on-red-alert option

**Audio**
- Rewritten audio engine with foreground-only mode (Ctrl+F9) and dynamic categories
- 40+ new sound effects from Miriani 6, Miriani 7, and various sound libraries
- Sound variant system for selecting alternate versions of specific sounds

**Gameplay Tools**
- Activity counters (artifacts, missions, asteroids, debris types)
- Starship contributions tracker (`contribs`)
- Point tracking (license, combat, organization)
- Archaeology helper with depth tracking

**Quality of Life**
- Automatic ASCII character translation (smart quotes, em dashes, etc.)
- Info bar shows focus, scan results, and destination coordinates
- Separate metafrequency buffers option
- Configuration saved to external files for easy backup

**MUSHclient Platform**
- Upgraded to MUSHclient 5.07
- **TLS/SSL encryption (alpha)**: OpenSSL 3.x integration for secure connections
- Accessible output window for screen readers
- Modern SQLite3 and Zlib libraries

## Why Move Away from VIP Mud?

VIP Mud has been the traditional choice for Miriani players for good reason - the **Miriani Soundpack for VIP Mud** (previously known as the Offline Cloud Soundpack) provides comprehensive audio feedback for game events, navigation, and combat. For years, it's been the gold standard for Miriani gameplay.

However, VIP Mud itself comes with significant limitations that make it increasingly problematic:

- **Dead Technology**: VIP Mud is written in VB6 (Visual Basic 6), which reached end-of-life in 2008. The runtime dependencies are legacy components that Windows may stop supporting at any time. Even if the current maintainer were to continue doing so, there are no modern development tools, debuggers, or libraries that work with VB6

- **Storage Requirements**: VB6 doesn't natively support modern audio formats like OGG Vorbis. While VB6 applications can use ActiveX controls or COM components to add this functionality, VIP Mud's closed architecture doesn't expose these capabilities to soundpack developers. The result is a forced reliance on WAV and MP3 files, neither of which is lean and still retains reasonable quality. VIP Mud's lack of extensibility means you're stuck with what the client provides out of the box. The practical impact: the Miriani Soundpack for VIP Mud weighs in at approximately 850 MB compared to 200 MB for equivalent OGG versions, over 4 times larger for audio that sounds effectively identical during gameplay

 - **Performance Problems**: VIP Mud suffers from poor performance that impacts gameplay. The performance issues were so severe that they led to the creation of tools like [Proxiani](https://github.com/tms88/proxiani), which acts as a local proxy to work around VIP Mud's performance limitations.
- **Commercial Software for a Niche Market**: VIP Mud is commercial software. Who pays for MUD clients these days? Most MUD clients are free and open source, making this an increasingly hard sell. In fact, every other single popular client that's still maintained is completely free.

- **Abandoned Development**: VIP Mud is no longer actively maintained. The original owner transferred it to someone else, but no meaningful updates have been made, which should concern anyone continuing to use the software. There have been only 3 major version releases since 2008 (1.0, 1.1, and 2.0). Nearly two decades of stagnation while still charging the same price does not bode well for the future

- **No Modern Scripting**: VIP Mud lacks support for modern scripting languages like Lua, Python, or JavaScript. This makes it difficult for players to customize their experience or add new features without diving into the outdated, proprietary scripting language.

MUSHclient, in contrast, is free, open source, [semi-actively maintained](https://github.com/nickgammon/mushclient/commits), and supports Lua scripting. This makes it a more sustainable platform for Miriani players. Our goal is to bring the comprehensive feature set from the VIP Mud soundpack to MUSHclient. MUSHclient has a rich catalog of plugins and doesn't require knowledge of a proprietary scripting language.

## Design Philosophy

These principles guide how we build and maintain this client package:

- **Sounds are information, not decoration.** Audio cues should convey useful game state. We avoid loud, jarring, or overly long sounds. Channel/communication sounds should be brief (under half a second).

- **Preserve the character of the game.** We believe gags should reduce redundancy, not strip personality. Gagging "The computer announces," before every message is fine - it's repetitive. Gagging atmospheric station descriptions removes immersion. If flavor text must go, replace it with a sound that captures the mood.

- **Never alter the game's words.** We don't shorten or paraphrase output. "I am beginning the repair of your hyperdrive. I estimate 30 minutes remaining." should never become "Repairing hyperdrive 30m". We believe the game's writing is part of its identity.

- **Everything is configurable.** If a feature might annoy someone, we make it toggleable. Baby sounds, social sounds, specific gags - users decide. Our preferences aren't everyone's preferences.

- **Performance is priority.** Feedback should feel instant. Anything that might lag gets extra attention - slow operations shouldn't block gameplay or make the client feel sluggish.

- **Convention guides, but doesn't rule.** We follow patterns from established client packages where they make sense - new users shouldn't have to relearn everything. But we don't copy bad ideas just because they're familiar. Innovate over stagnate.

## AI-Generated Content (AIGC)

This project leverages modern agentic AI coding tools to accelerate development and feature migration. However, we take code quality seriously:

- **All AI-generated code is reviewed**: Every piece of AI-generated content goes through human review before being committed to the repository.
- **Testing and validation**: AIGC is tested to ensure it works correctly and integrates properly with existing systems. Updates are carefully tested in a small group of alpha testers prior to being pushed to the public.
- **Quality over speed**: While AI helps us move faster, we prioritize code quality, maintainability, and the user experience.

We believe in transparency about our development process. The combination of AI assistance and human oversight allows us to rapidly migrate features from the VIP Mud soundpack while maintaining high standards.

These scripts are **not** [vibe-coded](https://en.wikipedia.org/wiki/Vibe_coding); while ~70% of the codebase is AI-generated, commits are not blindly accepted and the process remains collaborative. Outside of the development process, the codebase is routinely reviewed for cruft or AI "slop". We prioritize security and performance over feature bloat.

**Disclaimer**: I don't actively play the game anymore, so things may break and I may be slow to fix them. If you're interested in helping maintain the client package, please let me know! This is a community project.

## Contributions

We welcome contributions to Miriani-Next! To contribute:

1. **Adding Custom Scripts**:
   - Create a new file in the project directory titled `extras-<user>.lua`, replacing `<user>` with your username or handle.
   - Include your custom scripts in this file.

2. **Fixes and Enhancements**:
   - Before submitting a Pull Request (PR), please open an issue describing the problem or enhancement you plan to address. This helps us discuss potential changes and reduces the likelihood of merge conflicts.

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

## Support

For any issues, questions, or feedback, feel free to open an issue on this repository. If you'd like to talk to other Miriani-Next users, tune a metafrequency communicator to channel 7.07 in-game.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
