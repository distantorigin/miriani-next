
-- Audio configuration for LUA Audio system
-- Volume values are in percentage (0-100)
-- Pan values range from -100 to 100 (left to right)
--
-- New simplified volume system:
-- - master: Global master volume (applied to everything)
-- - sounds: Main game sounds (combat, ships, UI, etc.)
-- - environment: Ambient loops and background sounds
-- - All other categories use fixed offsets applied to the sounds volume

local audio = {
  sounds = {volume=60, pan=0},
  environment = {volume=50, pan=0},
}

-- Fixed volume offsets (applied as: master * (category + offset))
-- These are relative adjustments to the base category volume
audio.offsets = {
  notification = -15,    -- Quieter beeps/alerts
  communication = 0,     -- Same as sounds
  computer = -10,        -- Ship computer slightly quieter
  ship = 0,              -- Ship sounds same as sounds
  melee = -5,            -- Combat slightly quieter
  socials = 0,           -- Socials same as sounds
  vehicle = 0,           -- Vehicle sounds same as sounds
  other = 0,             -- Other sounds same as sounds
}

-- Map groups to their base category (defaults to "sounds" if not listed)
audio.category_map = {
  ambiance = "environment",
  loop = "environment",
}

return audio