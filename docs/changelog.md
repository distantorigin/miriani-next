# Miriani-Next Changelog

## Version 4.0.17 (In Progress)
### New
- Add airlock cycling music.
- Include "You notify flight control..." messages in spam reduction mode.
- Remove the config alias for conf.
- Added pimpslap and new hoot sounds.

## Version 4.0.16
### New
- Channel history is now infinite, automatically saving and reloading through restarts. Buffer orderings are automatically saved and restored. Up to 10,000 messages are loaded into each buffer at startup, at which point messages beyond that will be lazy-loaded as you browse. Messages are saved to a channel_history_<world-id>..db file in your main MUSHclient directory. Bugs are sure to be afoot. Consider this to be entirely experimental.
- Added memory only mode for channel history that will always bypass the database.
- Added sounds to an action figure machine on Templar
- Added sound for bongo social
- Added sounds for quiet mode.
- Added spacesuit jet end sound.
- Gag soundpack ping spam in even more places for purposes of logging.

### Changed
- Changed spacesuit jet start sound.

## Version 4.0.15
### New
- Added sounds to a new action figure prize machine on NegraCaja.
- Added experimentalTLS support to MUSHclient. Enable it from the world preferences connection screen.
  - To enable, check the TLS Encryption checkbox and change the port from 1234 to 1443. Proxiani users should change the hostname to toastsoft.net.
- Added a new lg command interface to control the log manager plugin:
  - lg view opens today's log in your text editor
  - lg view <days> opens the log from N days ago
  - lg find <text> searches all logs with paginated, selectable results
  - lg stats shows log statistics (file count, size, lines, date range)
  - lg toggle enables/disables logging
- Added an RP buffer, which currently stores emotes and custom socials.
- Clean up baby triggers.
- Add originating_from_emote, which is used to check if a sound or line of text is originating from an emote.
- Emotes no longer trigger sounds.

### Fixed
- Updated the code so mission counters actually increases the number of missions instead of staying at absolute 0. I may also make it actually tell you it increases, but right now you can see total number of missions with the counters command
- Restored the ability to 'Find Output' in the accessible output window.
- The accessible output window will now relay events to its associated world while its in focus. This addresses the commonly seen problem where ambiance and other things wouldn't stop when moving away from the window if the output window was the current tab.
- The Lore import sound will now play when you have multiple files waiting.

### Removed
- Vlog alias

## Version 4.0.14

### New
- Added the notification of the Dev Metaf channel to the launch notifications of the soundpack. As mentioned in the message, this channel is for dev chatter only and will be changed if used for anything other than discussions of code or dev work. If you are interested in deving for the SP, this is also a good channel to express interest.

### Fixed
- Fixed sounds for archaeology when using directional, and non-directional scanners, especially in places where the sound wouldn't play if the artifact had a remote possibility or some variant of the fact of being nearby.
- Fixed storage bags for diving gear, armor storage, and spacesuit bags so they have a sound when wearing and removing. Note this won't work for custom items at this time.
- Fixed the point calculator helper for point units that don't have "portable point unit" in the name.

## Version 4.0.13

### Fixed
- Changed storage bag use to actually play a sound if the color was prefixed by an rather than just a.

### New
- Disable the autosay keyboard shortcut by default (Ctrl+Shift+A).
- Moved chuckle sound to socials/male and added a chuckle to socials/female.
- Added second female chuckle sound

### Fixed
- Call buffercheck() when moving to the top or bottom of a buffer. This will resolve issues where moving to the end of history and then backward might result in random placement instead of the item you expect.
- Fixed an issue where no artifact nearby would not play a sound due to an invalid trigger.
- Fixed an issue where launching atmospheric salvagers, among other things, would play the ship exit sound.

## Version 4.0.12

### New
- Omit soundpack_ping hooks from logs.
- Began adding sounds for air hockey. Right now they are copied from VIPMud but this will change on a future update.
- Sound for itsatrap and why socials.
- Play cannon sounds for gumdrop launchers.

### Fixed
- Fixed a bug where the airlock chime would play the ship enter sector sound when someone entered the airlock
- Fixed a sound error that was displayed to all users when Cert orders were completed on the marketplace.
- Made the its a trap social not play the sector exit sound when typing "itsatrap me"
- Fixed an error where the sound wouldn't play for Gadzook ships entering and leaving the sector

## Version 4.0.11

### New
- Add sounds for the green Santa Box (red alert jingle bells). You can set which version you hear from within the sound variants menu by typing conf variant.
- The accessible output window now properly associates to each world.
- The accessible output window now shows the world's name in the title.
- The accessible output window can no longer be closed and will hide itself instead upon users pressing CTRL+F4 (similarly to tabbing out of it).
- The accessibel output window now automatically instantiates itself.
- Added an option to clear the accessibel output window from the menu bar.
- Added new shock and headshake sounds, changed beep3 to bonk.
- Boosted the volume of mlaugh1 and added flap sound.
- Removed roundTime2 sound, as people were complaining about it.
- Added a new roundtime sound.
- Added new male giggle sound and two new theme music sounds.
- Moved scream sounds out of neuter and renamed them to various shrieks because I didn't account for people being obnoxious screaming on channels.
- Added new fart, poke and nudge sounds.
- Added new rountime and failed command sounds.
- Swapped the hoot sound for a much shorter one.
- Added new stun baton sounds and a new message board post sound.
- Added new beep sound and new oops sound.
- Added airguitar and new quack sounds.

### Fixed
- CTRL+Tab now works (regardless of your conf gen tab settings).
- The option to automatically launch the accessible output window has been inverted to toggle whether we *do not* open the output window.

### Changed
- The changelog will no longer prompt to save when it's closed.

## Version 4.0.10

### New
- Added bounce social sounds.
- Added sounds for the beep social as requested by Gage.
- Over a dozen new social sounds, added new fuzzy creature death screams, modified the ship relay channel sound to not be the same used for direct say, plus a bit of housekeeping.
- Social sounds for khan, spoon, frog, and no.
- Sound for toilets flushing.
- Sound for things being removed from you.
- Sound for leaving someone behind (You seem to have left X behind!)
- Sound for receiving coal from Santa.
- Sound for announcements from hosts.
- Sounds for fuzzy creatures slinking, being hit, and being killed.
- Sound for tunnel rats being shot.

### Changed
- The male snicker sound has been updated.

### Fixed
- The sound for another ship landing in front of you will now be played while on an asteroid.

## Version 4.0.09

### New
- Add find functionality (ctrl+f, f3, shift+f3) to the accessible output window. Regular expression searching is currently a work-in-progress.
- Added a label for the regexp help button in the default MUSHclient find dialog.

### Fixed
- Don't disable ECO_AUTOVSCROLL in the accessibel output window. This may address some of the selection issues some have been having.
- Add an extra clause for "into the airlock" to ensure follow directional audio says out instead of enter.

## Version 4.0.08

###new
- Added a buffer option for the Newbie channel.
- Properly categorize carbon dioxide as a gas for purposes of counting. (Thanks Rose for catching this!)
- Add atmospheric debris transfer messages to the reduce spam option.
- Add a new option to 'conf gen' to make alt+space show exits instead of current history item. (Defaults to on)
- Record the exits in each room for use in things such as alt+space.
- Added sounds for the headdesk and mock socials.
- Moved some more baby sounds under the babies audio group.

### Fixed
- Fixed the asteroid hauling counter.

### Changed
- Alert klaxons are no longer completely suppressed when reduce flavor text is enabled. The text will always be gagged by default, and will play its corresponding sound.

## Version 4.0.07

### New
- Private comms from link recipients (mainly names containing "service" or "recipient") now play a different sound instead of the standard private comm sound. Examples include: Auction Service, combat mission notification service, communication loopback recipient, etc.
- Added an option under 'conf general' to control whether service comms bypass foreground sounds (defaults to off). Service comms now respect the foreground sounds setting by default, unlike regular private comms.
- Social sounds for screech, slowclap, and golfclap. (Thanks Jason!)

### Changed
- Alternate audio detection is now automatic. The soundpack checks for the `sounds/alternate/` folder at startup and uses alternate sounds when available, eliminating the need for manual configuration. The "Access alternative audio files" option has been removed.

### Fixed
- Fixed counters reset to properly display output.

## Version 4.0.06

### New
- Expanded the counters system (as seen in archaeology) to track multiple activities: spatial artifacts, asteroids hauled, missions completed, debris salvaged (atmospheric, space, aquatic, and gas variants), and planetary mining expeditions.
- Added a counters command for easy access: 'counters' displays all activity counters, 'counters reset' resets all counters, 'counters reset <name>' resets a specific counter.
- Added an option to toggle whether counter values are displayed when the activity completes (defaults to off).
- Added an option to reset all counters upon startup or updating (defaults to on).
- Added a sound for snatching artifacts from space.

## Version 4.0.05

### New
- Asteroid mining manufacturing facilities now have a sound for completing things. (Thanks Mark!)
- Added a new lift ambience.
- Private organization and courier channels now have buffers.
- Added history buffer aliases: spr (read), spc (copy), sps (switch), and SPHB (buffer back/forward, among other things). Primarily added for VIP Mud soundpack compatibility and user-friendliness.
- Added relativity drive frequency option under 'conf ship'.
- Added various batch scripts for developers.

## Version 4.0.04

### New
- You can now add a file to the sounds/miriani/comm/ directory that will be played for a particular metafrequency channel. Name the file using either the channel's given label, or the frequency number without periods, and it will be played instead of the standard metaf.ogg. For example, 707.ogg will be played for channel 7.07. 50000.ogg would be played for 500.00, etc. If you have channel 7.07 labeled soundpack, you could also use soundpack.ogg instead of 707.ogg.
- We now automatically set your courier company when viewing output from the INFO command, and the courier channel will now play a sound accordingly.
- SOOC now has a dedicated sound.
- Users on the dev channel will now see the updated files in addition to the main changelog if 'conf gen 4' is enabled.
- Changelog is now available in markdown.
- Scanning now plays a sound for starships being on the surface of an asteroid.

### Fixed
- The sound trigger for last stun shot (eject).

## Version 4.0.03

### New
- Added atmospheric vehicle descent trigger sound.
- Added air pocket trigger - "You are thrown back against your seat as the craft hits an air pocket in the atmosphere and then breaks free." now plays a wind sound effect.
- Complete updater system overhaul - now uses an external update.exe binary written in Golang instead of the LuaJit-based system:
  - Simplified update commands: just type 'update' to check and install, or press CTRL+U.
  - Channel switching support: 'update switch dev' or 'update switch stable'. For an up-to-date list of channels, type 'update switch' by itself to be sent to a menu-based interface
  - Automatic updater installation and manifest generation if missing
  - The updater can also act as an installer, allowing you to download the latest version of a stable or dev build on a new machine.
- Plugin requirements system - automatically loads and manages required plugins. Missing plugins show with clickable links to enable them. Required plugins are re-added upon the plugin list changing, ensuring a unified set of core plugins.
  - Reinstall latest version of the updater with 'update reinstall'.
- Added an admin message sound.
- Added ice water crystals sound effect for Santa boxes.
- Added the directional TTS audio files from the Miriani Soundpack for VIP Mud, which get played when you follow someone.
- Added conf gen 8, to control follow directional audio.
- Developer plugin with 'spreload' command to quickly reload all plugins.
- A brand new accessible output window, built directly into MUSHclient. Type 'conf gen 11' or press tab to learn more.
  - Note: This feature is compiled directly into MUSHclient and is controlled via the ActivateAccessibelOutput() scripting function. It is intended to bridge the gap on VIP Mud functionality that simply cannot be replicated via plugins, such as typing directly into the output notepad. More work on this is ongoing.

### Changed
- Improved trigger patterns for better name matching in various events (standing, sitting, group actions, etc).
- Debris impacting the hull now plays youHit6.ogg instead and shows the corresponding message.

### Fixed
- Aquatic salvagre stop.
- Planetary mining infinite loop when finding mineral pockets.
- Alternate audio variant selection now works correctly.
- Organization channel detection works properly again with tr channels.
- Info bar no longer clears unexpectedly.
- Asteroid mining warnings detect more accurately.
- Interrupt on follow (in conf reader) now works correctly, and also works for being dragged.
- Lore printing sound.
- Blade unsheath sound.

### Removed
- Legacy index-v5.manifest and old Lua-based updater system.

## Version 4.0.02

Note: This release was initially going to be the debut for the new updater, but I'm pushing this ahead of time to get some bug fixes and nice-to-have features out there. Lots of work is going on behind the scenes on:
- Brand new updater that runs outside of MUSHclient, coming in version 4.0.03. Much more stable and quick.
- Socials framework
- Splitting all extras into MUSHclient plugins
- And more! Primarily, lots of technical debt catchup and reorganization of files.

### New
- Added sounds for various RP Shenanigans (credit to the Miriani Soundpack for VIP Mud):
  - Blade combat sounds: unsheathing, sheathing, stabbing, swiping, slashing, blocking, and wiping blades clean
  - Slime machine/puddle interaction sounds: slime hits and puddle splats
  - Paint canister explosion sounds
- Added missing theme music and cleared out the mission music files for mission complete.
- Added MUSHclient builtin help to the default world file. You may access it with the 'mchelp' command.
- URLs will now become visually clickable with the mouse in the primary world tab.
- Sound variant selection system that let's you set the variant for a sound. These are different versions of a sound that may either be legacy or preferred by certain users. The sounds that you can set initially include shipa ccelerate, ship decelerate, and archaeology artifact detected.
- Added 2 new accelerate and decelerate sounds for ships.
- Added back old archaeology artifact sound as a variant option
- Added flight control sector number substitution option (migrated from VIP Mud soundpack). Enable under "conf helpers" to show sector numbers instead of sector names in flight control messages (e.g., "Flight control in sector 15" instead of Miriani.)
- Added an experimental, potentially useless option in conf gen to make the tab key shift focus to the output window. There are some caveats, which may or may not have resolution in the future:
  - This overrides tab autocomplete, and there's no way to map another key to do that instead.
  - MUSHclient doesn't provide a way to intercept keys when focused on a notepad, which makes it impossible for us to bind to tab or shift+tab in this area. Thus, once you've pressed tab, you'll need to press ctrl+1 or ctrl+tab to snap back to the input field.
  - This requires a full client restart when enablign and disabling the option.
- Got rid of the announcement in MUSH Reader that mentions speech being initialized.
- New sound for asteroid hauling begin, line start, line end, anchor start, anchor end, and ship anchor. Reworked gagging of lines a bit here as well.
- The output tab is now read only by default.
- The installer executable now looks for Dropbox and forces the install to go to local documents instead, similarly to OneDrive.
- If escape is set to send @abort to the game, it will now send 0 when in conf and other menus. This has the side effect of resulting in an invalid selection if there's nothing to go back to, but it's all the same in the end, really.
- Design channel sounnd.
- Output will now automatically truncate ~40% once it reaches around 1 MB in size.
- Add log_manager, a plugin I've written that sets up sane logging defaults:
  - All logs go to a logs\WorldName folder
  - Under each world, logs are organized under year\month\day.txt.
  - For example, my Miriani log for today is under: logs\miriani\2025\10\19 October 2025.txt.
  - Normally, MUSHclient will log an entire session to the same log file, never reopening the log when the date changes until you close the entire client. This can easily become useless when you stay connected for multiple days, since MUSHclient will never try to write a new dated file (if you have it set up this way, which most do not). To combat this, we ensure the log file is rotated exactly at midnight via timers, closing it and reopening the new file.
  - Basic alias: vlog to open the current log, vlog <number of days ago> to open the log from <x> days ago. This will also force the current log to be written to disk.
  - Closes the log file when you disconnect, reopens it when you reconnect.
- Add several new rocky planet ambiances.
- Add a lift ambiance (thanks Mark for the sound suggestion and Claude Code for various audio editing shenanigans)
- Added a basic archaeology artifact counter. More to come for other activities soon.
- You can now press Ctrl+F8 to toggle whether the client speaks incoming text while the world is out of focus.

### Changed
- The output tab will no longer promtp you to save when you close it.
- MUSHclient will no longer prompt you to "Save internal variables" when you close the world. Saving is now automatic.
- MUSHclient will no longer prompt you to save the world file separtely from the internal variables. Instead, the only prompt you will receive is if all worlds have been closed and you're attempting to close MUSHclient itself.
- The point calculator should now save through reloads. (We're just saving in variables here, so if it's not saving, you should ensure MUSHclient's worlds\plugins\state folder is populating with data.)
- Moved flight control scanner trigger from communication.lua to devices.lua.
- Debris impacting the hull now plays youHit6.ogg instead and shows the corresponding message.
- You can now use F8 to toggle speech, instead of Ctrl+Shift+F12
- Disabled some of the babywave triggers until I finish the big socials update.

### Fixed
- Re-added aquatic salvager move sound.
- Reloading toastush.xml while logged in will no longer result in the URL catcher being disabled. Primarily seen when updating via the updater.
- Archaeology nothing nearby sound now plays.
- Conf now matches correctly to some of the newer menus.
- Triggers for tubing and cabling in asteroi dmining should be slightly more reliable.

## Version 4.0.01

### New
- Reorganized configuration menu with new "Helpers and Extras" category:
  - Moved archaeology helper options (buried artifact depth tracker and direction calculator) from general category to helpers
  - Moved point calculator from general category to helpers
- Added additional asteroid mining sounds:
  - Cable and tubing attachment/detachment sounds
  - Reactor activation/deactivation sounds
  - Additional drill sounds
  - Additional micro sealer sound
  - Warning sounds for equipment failures (coolant leaks, drill bit issues, contamination)
  - Ramp end sound
- Reset scan filter capture when you move, to prevent oddities where the state might get stuck. (Commonly seen when duplicate lines appear.)
- Archaeology directional helper now plays artifactHere sound when you arrive at the artifact coordinates.
- SMC <ship class> now gets handled by Miriani-Next if Proxiani isn't being used, since the in-game version doesn't support arguments.
- If .run_updater is present in the main directory, we now run the updater at startup. Primarily used by the installer to prompt an update at first run.
- Play cancel sound when conf matches fail.
- Enable Camera buffer by default for new users.
- Replicate external camera and droid camera lines, as to trigger on them as if the action happened in your own room. This is a way to both get the camera sound and reliably trigger on things performed via camera, rather than needing custom triggers for each action or loosening up regular expressions.
- Disable keypad in world preferences by default.

### Changed
- Suppress the source from external camera and droid messages in output. The location is still included in the mesage when reviewed in the camera buffer.
- Replaced the archaeology artifact found sound.

### Fixed
- Don't perform any parsing before printing and storing say messages.
- Menus now play the prompt sound when matching to multiple items.
- GMU notifications now play if there is only one of a thing detected.
- Conf no longer errors upon not being able to match to an option name.

### Removed
- Jumpgate sounds that were too long or too short.

## Version 4.0.beta.6

### New
- Replaced the dialog-based configuration system with a new menu-based one. This menu behaves in the same manner as any menu on Miriani itself--it supports number-based selection, entering part of the name of a selection, or @abort to back out.
- Removed most of the volume categories from the settings available in F10. Now, volume is split among the following groups:
  - Master: Influences all volumes. Other volume groups are multiplied by this value.
  - Sounds: All sound effects throughout.
  - Environment: Ambiences, loops, potentially other things in the future.
- Added automatic login feature with dedicated configuration category. Configure username and password under conf AUTO LOGIN, then enable auto login to automatically connect when you see the "Username:" prompt. Automatically selects character 1 from the menu. MUSHclient already has auto login, but there was no way to ensure the soundpack would be registered before it fired, so here we are.
- Added sound offsets for various categories. Currently these are hardcoded, although they could become configurable later:
  - Computer: -5% from default volume
  - Notifications: -15% from default volume
  - Combat: -5% from default volume
- Point tracking for license, combat, and organization points; enable under conf gen.
- Tracking system for starship contributions:
  - Tracks contributions received from players with name, amount, and frequency
  - CONTRIBS command displays sorted list of contributors (highest to lowest)
  - CONTRIBS CLEAR resets all contribution data
  - Plays sound when receiving contributions
  - Contributions buffer enabled by default to track all received contributions
- Sound for receiving credits from another player.
- You can now toggle various sound categories on and off from within the configuration menu. Keep in mind that this list populates as sounds play, so if a category you expect isn't there, try playing a sound that might be in the corresponding category first.
- Shift+escape now resets the info bar in addition to its existing functionality.
- Overhauled the configuration system to write to worlds/settings/toastush.conf rather than saving the configuration as a variable in MUSHclient's state. This will allow you to easily transfer configurations between clients or backup a known good config for later.
- Added optional, experimental formatting of scan output, which allows you to filter scans to be shown on a single line, similarly to the VIP Mud soundpack. Off by default, you can enable this under the ship category in config.
- Replaced the scu alias. Now, this will force a single-line scan on demand if you choose to keep the option disabled.
- Added a buffer for recent scans. Using a scan filter alias will not add to this buffer, only initiating a scan with the sc/scan command.
- Added 'sca' alias for atmospheric composition and 'scn' for natural resources on planets.
- Shift+escape resets scan state.
- Upgrade binary to MUSHclient 5.07-pre, based off of the tip of the current MUSHclient release tree (last updated in Aug 2025). Updater users will not receive this as part of the update process, and are encouraged but do not need to download the new executable from https://github.com/nickgammon/mushclient/releases, under the latest_commit (release) section.
- Added grand total to contribs.
- Added scan sounds from Miriani 7.
- Add background1 through background5.ogg, which get played when FTL and jumpgate jumps complete and the ship finishes launching. (Previously jumpgates played the move decelerate sound.)
- Add 29 new beep sounds.
- Add experimental code to the updater that will automatically reload any file that gets updated if the file is located under worlds\plugins. This will only work for updates moving forward after you've installed this version.
- Add baby sounds. (Credit goes to the Miriani Soundpack for VIP MUD. This is a direct migration and should operate the same.)
- Bias drive now has sounds.
- Added a sound for auction bids and add bids to an Auction history buffer. Sales will happen as soon as I have a sound.
- Add a sound for attempting to use a drive while it's still recharging.
- Add four new FTL and jumpgate sounds.
- Added wind sound for atmospheric instability.
- Migrate master volume and mute to the config file.
- Press F2 to open the changelog.
- Added whisper support with dedicated sounds (whisperSent.ogg for sending whispers, whisperTo.ogg for receiving whispers directed at you).
- Added optional whisper buffer to track whispers separately (disabled by default, enable in conf BUFFERS).

### Changed
- Renamed the toastush:config command to just conf, or config. (toastush:config still works for now, but will be removed later.)
- Remove variable-based config migration code.
- Master volume now initializes at 60% instead of 100.
- No longer play a sound when in the middle of a wormhole. This was previously ship/move/flash.ogg.
- Enable a wider swath of history buffers by default.
- Standardized the grammar in the configuration menu labels.
- Update metafrequency to 7.07 instead of 0.07, for Toastush-NG users to report bugs.
- Lower asteroid rover ramp sounds by 25%.
- Anomaly detection sound reverted to older version from Miriani 7.
- The sound for being out of range has been reverted to the VIP Mud sound.
- Interrupt on scan coordinates now provides three options: everything, only for starships, or off. We default to starships.
- Remove "Launch complete." from spam reduction mode and replace it with the background sound and a random beep.

### Fixed
- Contribs no longer greedily eats any other contribution commands.
- Require baby names to be alphanumeric, as to prevent communicators from triggering baby sounds. (This still won't stop it from triggering for players, though. Don't be that guy. Or do. No judgment.)
- No longer try to play the weapon action sound if the outcome was unknown.
- Starmap filters work once again.
- Info bar now resets in more places.
- Ship locked on has been reverted to the classic sound. I accidentally wiped it out when merging classic in with main. Hurray regressions!
- Set the minimum number of shots to 7 instead of 8 for the bardenium counter, which should, in theory, fix the double shot remaining on the ravager.
- Fish warning in aquatic salvager now plays warning instead of scoop.
- Using scan filter commands without arguments will now properly filter after choosing a target from the menu.
- Scan filter commands are now case insensitive.
- More say fixes, I'm not really sure anymore...
- The Lore Computer print sound now works for any kind of paper.
- Checking coordinates no longer throws an error.
- Heartbeat stun sound ends properly.

### Removed
- Interrupt on focus screen reader option.
- Computer voice files and the corresponding option.

## Version 4.0.beta.5

### New
- Aquatic salvaging sounds for movement, scoop, fish encounters and probably more at the current time of writing.
- Enhanced Channel History plugin with quick buffer system:
  - Alt+Q: Cycle through favorited buffers endlessly
  - Alt+Shift+Q: Add/remove current buffer from favorited buffers/quick list
  - Quick list persists across client restarts
- Add planetary mining triggers. Credit for tunnel rats goes to the pull request here: https://github.com/PsudoDeSudo/Toastush/issues/5
- Add sound for drifting off to sleep (disconnecting while on the ground and/or furniture).
- Removed classic mode and merged all classic sounds with the Toastush default.
- Delete classic_miriani directory at startup.
- Added automatic detection and cleanup of conflicting sound files (removes non-numbered when numbered variants exist).
- Improved audio device switching with proactive health monitoring and automatic recovery.

### Fixed
- Audio device switching now uses position-based detection to catch stuck playback and WASAPI output issues.
- Fixed the say trigger to match on names with mixed capitalization beyond the first letter (i.e. Cedric McKinley)
- Properly format says that are in all uppercase.
- Don't play weapon firing sound for empty space when using the ravager's laser turret.
- Don't play weapon firing if you only have a single laser turret (probably related to the above change).
- OICIC <person> no longer gets caught by the shout trigger.
- Force all sounds to stereo (again). This flag got removed in the audio system overhaul. Ahem.

### Changed
- Updated poke/nudge triggers to play sound when it's you performing the social.

## Version 4.0.beta.4

### New
- Rewrite computer announcement handling to exist in a single trigger, using a table for the various strings that should be matched.
- Shortened "Shots remaining" in the bardenium counter to just "Shots" and experimentally made it display before the firing announcement, rather than after.
- Added 10 more keyboard and announcement sounds.
- Added separate sounds for the computer reporting things. Previously this just used the announcement sound.
- Play the punch sound for sock/slug/hit.
- Add weapon power up/power down to classic Miriani sounds.
- Add new display sounds that get used by the records, ships, cargo, damage, arsenal, and status commands.
- New connect sound.
- Play collapse/yawn socials when somebody disconnects.
- Sanitation drone sounds.
- Use weapon soundpack hooks instead of matching on messages manually. This should hopefully make them much more reliable for any kind of weapon, regardless of its name.
- Added static sounds for communicators and metafrequencies.

### Changed
- Shorten private comms to only say [Player Name] instead of [Private | Player Name].
- Poke/nudge socials will only trigger when you've been targeted.

### Fixed
- Show "Person yells" instead of "Person yell" and add support for the shout/holler versions.
- Don't trigger say on flirt.
- Clear focus and scan from info bar on launch/land. Previously this only cleared upon FTL, and unreliably so.
- Say history, OOC, and other channels will no longer trigger the speech routine.
- Say trigger now gets caught when seen via camera or droid remote.
- Malformed say messages appearing in the say buffer.
- "Asks you" will now trigger the direct say sound.
- Bardenium counter no longer announces twice.

## Version 4.0.beta.3

### New
- Rewrite bardenium shot counter by dynamically dividing available bardenium by the number of cannons announced in the firing message. Bugs are sure to be afoot with this one.
- Added a debug mode to subject yourself to spammy debug messages and errors. Enable under 'toastush:config general'
- Organization name is now gathered dynamically to trigger properly on the channel name. To set your org name, type 'tr channels' and it'll be set for you automatically.

### Fixed
- Org sound now plays for messages that don't contain text (i.e. comm socials).
- Completely rewrote say triggers to be more robust; also fixes a scripting error.

### Changed
- Canceled the experiment and reverted classic engine sounds to the V7 version

## Version 4.0.beta.2

### New
- Enable gag flavor text by default.
- Enable Cannon shot counter by default.
- Enable archaeology digging tracker by default.
- Added cease digging sound
- Replace requesting clearance to land/launch in classic mode.
- Added message board sound triggers and imported missing message board sound files (NewPost1-7.ogg, UnreadPosts.ogg).
- Message board notifications now play random new post sounds (NewPost1-7.ogg) when receiving new messages.
- Urgent message board notifications now play UnreadPosts.ogg for multiple unread messages when logging in.
- Began work on a script to generate the manifest out of MUSHclient, which should make life a lot easier.

### Changed
- Experimentally change relativity sounds in classic mode to V6.

### Fixed
- Suppress unable to play audio messages, need to add a debug mode to reenable them.
- Pickaxe now uses shovel sound and properly counts depth when tracking artifacts.

## Version 4.0 (Initial Release)

### New
- Rewritten audio system, featuring smarter muting, foreground sound support, dynamic category adding, and more.
- Foreground Sounds (fsounds), a mode that will force sounds to only play while the session is foregrounded. You can enable this by typing fsounds, through toastush:config, or by pressing ctrl+F9.
- Allow certain high priority sounds through fsounds mode. Currently these are private comms and direct says.
- Aaaannnnd...added a new sound for says that are targeted directly at you.
- Play the say sound for targeted says that aren't sent to you.
- Add targeted says to the say buffer, even if they aren't specifically at you.
- Plugins can now broadcast various messages to create, remove, or modify audio groups from within Toastush itself.
- Enabled automatic device switching for audio devices via Audio.CONST.config.device_default.
- Flight control messages now use soundpack hooks to properly clean message formatting. Flight announcements like "A flight monitor announces, Ship detected" are now cleaned to just show "Ship detected".
- Fixed classic_miriani sound randomization to properly handle numbered variants (laser1-laser30, etc).
- Improved sound file finding to prevent randomization on already-numbered files. This would often manifest in things like unable to play insect2.ogg messages.
- Volume adjusting now has a sound.
- Audio mute now has a sound.
- Printing files from a Lore computer now has a sound.
- Players connecting, disconnecting, or reconnecting in the room now has a sound.
- Audio Style preference, available under toastush:config general or by typing toastush:classic. The only two preferences are Modern or Classic. Classic captures many of the old sounds from the circa 2012 era and earlier, restoring things such as: channel sounds, starship engine sounds, the multitudes of laser sounds, cannon sounds, target lock and many Lore computer sounds.
- (output_functions.xml) Re-added the boundary sound when the start or end of history is reached.
- (channel_history.xml) Add support for buffer names containing numbers.
- (channel_history.xml) Alt+Enter: Open a URL in the current message if there is one, otherwise open world configuration.
- (channel_history.xml) Alt+Shift+1-0: Jump to first through tenth buffer.
- (channel_history.xml) Alt+Shift+` (grave accent, also works without shift): If you have text typed in the command window, try to jump to a buffer starting with that text. Press the command with an empty window to return to where you were before the last jump, effectively allowing you to flip between two buffers.
- (channel_history.xml) Alt+Backslash: If you have text typed in the command window, searches toward the bottom of the current buffer for that text. Add Shift to search toward the top of the buffer. If a match is found, focus jumps to that message.
- (channel_history.xml) Alt+Shift+Enter: Copy current buffer to a notepad.
- (channel_history.xml) Alt+Shift+T: Toggle timestamp announcements.
- Optimized audio cleanup routines, which should hopefully make sounds a little bit more snappy.
- Enhanced audio resource management with proper stream cleanup and memory optimization.
- Forced laser and cannon sounds to pan randomly.
- Added automatic ASCII character translation to prevent MOO server from dropping non-ASCII characters. Smart quotes, dashes, ellipsis, and non-breaking spaces are automatically converted to ASCII equivalents when sending commands.
- Enhanced direct say trigger to handle "says to you" syntax in addition to existing "[to you]" format.
- Added an option under 'toastush:config reader' to interrupt speech for scan coordinates. This will reintroduce the old functionality found in many soundpacks where scanning anything would be interrupted almost immediately to read the coordinates. A 100ms delay has been added, which should allow most speech systems to read part of the name of the item before jumping to the coordinates themselves. These values may be tweaked.
- Added an option under buffer config to separate metafrequency channels into a buffer for each frequency.
- Added a sound for successful soundpack registration.
- Escape to @abort (rather than clear input).
- Stop all sounds immediately with shift+escape.
- Added pulse emitter sounds (LoadEMPulse1-3.ogg, EmptyEmitter.ogg) for loading energy packs and empty pulse emitters.
- Added triggers for pulse emitter loading and emptying sounds.
- Added "There are no damaged components" sound.
- Enhanced direct say triggers to support "asks you", "exclaims to you", and complex formats like "hesitates briefly before saying to you".
- General communication channels now display as [General] instead of [General Communication] for cleaner output.
- Added focus coordinates and last scanned coordinates to the status bar. Focus coordinates show "Focus: x,y,z (Target Name)" and scan coordinates show "Scan: x,y,z" in the info bar (Alt+Shift+I).
- Added destination finder coordinates to the status bar. Shows "Dest: x,y,z" when using destination finder commands.
- Destination coordinates automatically clear from status bar when ship finishes jumping (wormhole/relativity) or landing.

### Changed
- Changed plugin name to toastush_ng, bumped version to 4.0, and now register soundpack as Toastush-NG.
- (updater.xml) Update URL now points at Toastush-NG repository.
- Migrated alt+shift+A to ctrl+L. With auto device switching, this keystroke should largely be a thing of the past, however.
- Alt+F10 (toggle sound mute) is now F9.
- Settings variable renamed from "secret_settings" to "toastush_settings".
- Starship relay messages now consistently show as [shipname] format instead of [Starship | shipname].

### Fixed
- Don't show Short-range Communication as "Short".
- Clear focus from info bar when we see the ship is no longer in the sector.
- Bardenium shot counter now works correctly in all weapon configurations.
- Spellchecker now plays the prompt sound.

### Removed
- Removed aliases 'smc' and 'sma' from starmap filters, as these are now commands inside the game.
- @paste alias
- worlds/plugins/ClientLock.xml
- worlds/plugins/Text_To_Speech.xml
- worlds/plugins/timer.xml
- worlds/plugins/Timestamps.xml
- worlds/plugins/gmcp_handler.xml
- worlds/plugins/local_edit.xml

## Version 3.1.74

### New
- Added spooky Halloween morphing sound!
- Nonbinary socials will now have a 50% chance at playing from the binary genders.
- Various RP related sounds. Mostly pertaining to water.
- Added the ability for Toastush to prompt you with the update command when outdated. Should hopefully keep people informed about updates.
- Added a special ambiance for the awkward moments you are stunned and helpless.
- Added the paralyzed clock to the info bar--or status bar. For screen reader users, press alt+shift+I to view.
- Renamed all misc/cash.ogg files to be lowercase. Not sure how they became capitalized.
- More RP sounds.
- Added a sound for long range beacons detected by ship.
- Various RP-related sounds.

### Changed
- Fixed the cannon shot tracker so that it rounds up to the nearest integer. This should solve odd-numbered cannon rooms. Per usual, use the weapon command in any cannon room to set the shots.
- Fixed starship relay buffer capturing only name.
- Fixed stun/healing weapons firing at 100% volume.
- Removed audio options prompting for stereo or mono. Audio is now always stereo.

### Fixed
- toastush:changes should now properly open the changelog.
- Fixed bug with initializing MCP. Apparently it exists after all!
- F1 now pulls up Toastush settings.
- Updated MCP implementation-- despite the fact that Miri doesn't seem to utilize it anymore. Its the thought that counts.
- Various RP-related sounds.
- Fixed various triggers in misc dealing with general sounds that did not work after a change of directories.
- Updated menu and prompt strings to trigger sound.
- Increased priority level of public address communication trigger to avoid conflicts with the "say" trigger.
- Bumped minor version number due to non-compatibility with version 3.0.

## Version 3.0

### Changed
- Edit updater code in various locations so that it indexes individual files without erroneously creating directories.
- Update constants.lua values to point to proper directories. There goes those bugs I was afraid of.
- Update the say trigger in `communication.lua` to be more forgiving. More importantly, text with certain punctuation that has been long lost to my failing memory will no longer cause a recursion depth error.
- Various organizational changes. Let's hope nothing weird breaks.

## Version 2.8

### Fixed
- Fixed old combat sounds playing at 100% volume. Thanks to Taylor Simon for reporting!
- Hopefully fixed issue that muted the pack when updating.
- Fixed bug with ship relay.

## Version 2.7

### New
- Added key binding: ALT+SHIFT+I to read out the info bar.
- Added the key bind: ALT+SHIFT+A to initialize (or reload) audio settings. This is helpful in cases where the soundcard or device changes.
- Added a minimal mode. Minimal mode deactivates the majority of triggers, leaving only communications and configurable gags. Type Toastush:minimal to toggle it.
- Added three new audio groups: ship, computer, vehicle.
- Added the @paste/@post alias for pasting blocks of text.
- New sounds for footsteps and various RP things.
- Fixed regular laser/cannon sounds that broke with pirate day filter update. Hee hee!
- Let computer announcement work with pirate day filters.
- Long awaited HG lift.
- Fixed bugs with footstep and added transporter sounds.
- Some pool related RP sounds.
- Suborbital pods.
- Various new ambiances.
- Fixed the world's oldest bug with festive lasers.
- Pulse weaponry sounds.
- Various RP enhancing sounds.
- SHIFT+F10 cycles back through audio buffers.
- Let certain events appear properly in the log.
- Sounds for gas and aquatic salvaging.
- Fixed no sound with multiple certificate purchases.
- Activity sounds for asteroid mining.
- Set the ability to specify different file extensions for alternate sound files. Adjust the variable named ALT_EXTENSION in plugins/Miriani/constants.lua accordingly.

### Changed
- Edited the config menu significantly. Users should go through the menu and adjust settings accordingly. Split options into different categories, added a new option for printing the word 'unchanged' before coordinates.
- Separated audio for ship-based combat to the ship audio buffer. Renamed the previous combat buffer to melee to denote the difference.
- Added one option for downloading updates while idle.

### Fixed
- Fixed sound not playing with starships exiting sectors.
- Possibly fixed an issue with Jaws echoing text that is presented on white on black. Changed the default color for it. Users should change default foreground and background if they're having similar issues.
- Patched bug that played social after social volume was lowered to 0%. Thanks to Cody Ley for reporting!
- Enabling proxiani will now disable Toastush starmap commands.
- Patched bug with socials not playing properly on metafs.
- Fixed bug that occasionally dropped audio after changing audio devices.
- Fixed minor bug with cannons.
- Fixed bugs with atmo combat vehicles.
- Fixed bug with sound not playing for characters with double capitalizations in their surnames.
- Minor changes to the feel of config menu.

## Version 2.6

### New
- Disabled the F1 windows help keystroke (There's no real reason to keep this enabled while Microsoft no longer supports it.)
- Configurable hyperlink colors.
- Configurable colors for the infobar.
- Added star wave-warped sound.
- Added hooks buffer (Possibly useful for developers).
- Added various configurable colors through the config menu.
- Added the ability to go back in the config menu with escape.
- Buckling sounds.
- Reinstated handheld radio sounds. Not sure how they got lost again.
- Added some more socials.
- Jetting in space sounds.
- Added the ability to access alternate audio files for any given sound trigger. Simply create the sounds/alternate directory and locate any files there.
  - Note that the file must be named exactly to the one indicated in the soundpack and the file extension must match that of the given soundpack extension, (as of this time .ogg).
- Atmo sounds.
- Added sounds for Praelor boarding.
- Added sounds for various Praelor lifeforms.
- Added sounds for lifts. Only the most important changes.
- Added a new audio group for loops (separate from ambiances).
- Added optional alerts for stores, dig sites, and pending updates. See Toastush:config audio.
- Added a buffer for the design channel.
- Added the alias Toastush:updater-reload to easily reload the updater.
- Added the alias Toastush:register to reissue registration command.
- Added the macro ALT+SHIFT+U to open recent URLs.
- Renamed link buffer to URL (It's more intuitive).
- Reset the ping timer for the info-bar.

### Changed
- Computer detection sounds for wormholes, anomalies, and nebulae.
- Patch for updater to create new directories properly.
- Added sounds for Praelor boarding.
- Added sounds for various Praelor lifeforms.

### Fixed
- Fixed relay sound/buffer.
- Minor bug fix with archaeology.
- Fixed bug with lowered/raised sales in the tradesman market.
- Various fixes to the updater where capitalization kept files from being recreated.
- Increased index manifest version.
- Added clean-up code for version 2.6.2 and below in janitor code.
- Patched bug with indexer that didn't hash files. Whoops.
- Fixed a bug with the updater that sometimes failed to create directories.

## Version 2.5

### New
- Updated manifest version, no longer using v2.
- Added marine planet underwater ambiance and water airlock sounds.
- Added some asteroid ambiance.
- Added some station ambiances.

### Fixed
- Fixed indexer bug that concatenated bad links for sounds depending on capitalization.
- Various bug fixes with archaeology.

### Added
- Added ambiance for starship rooms.

## Version 2.2

### New
- Added the framework for playing ambiance. Sounds to come.
- Added the Toastush option to open the changelog in a notepad after applying updates.
- Added the alias Toastush:changes to open the changelog directly.

### Changed
- Changed the wording (minimally) of secondary lock options to be less confusing.
- Changed computer voice and roundtime options to be under audio options. (It just makes more sense this way.)

## Version 2.0

### New
- Official release.

### Changed
- Various bug fixes from version 1.2 (too numerous to list).
- Added the option to initialize audio as either stereo or mono.
- Allow audio groups to be configured outside of secretpack.
