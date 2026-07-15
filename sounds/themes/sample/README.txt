Sample Sound Theme
==================

This is an example theme folder. To add sounds, create subfolders
mirroring the structure under sounds/miriani/.

For example, to add an alternate ship acceleration sound:
  sounds/themes/sample/ship/move/accelerate1.ogg

To add an alternate combat hit sound:
  sounds/themes/sample/combat/hit1.ogg

Theme modes (set in theme.json):
  "additive"  - Theme sounds are pooled with the default sounds.
                Both may play randomly.
  "replace"   - Theme sounds fully replace matching default sounds.
                Defaults are used for anything the theme doesn't cover.

Declaring your own socials
--------------------------
If your theme adds a social the base pack doesn't already know about,
declare it in theme.json under a "socials" block. Each entry needs a
category (used for the on/off toggle grouping), and can optionally
set "sound" to a different filename stem than the social name.

Gender variants are picked up from folder placement, so drop the
audio into whichever of social/male, social/female, or social/neuter
you actually have files for. Neuter files play for every character
when no gender-specific variant exists.

You can also add shorthand action names under "social_aliases".

See the "socials" and "social_aliases" blocks in this folder's
theme.json for a working example.

Enable this theme in-game: conf theme
