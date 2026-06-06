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

Enable this theme in-game: conf theme
