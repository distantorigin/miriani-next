-- Compatibility shim for installations updating from a version that loaded
-- Text Tones as a standalone module. The implementation now lives in
-- communication.lua, which fills this shared table later during startup.
player_text_tones = player_text_tones or {}
return player_text_tones
