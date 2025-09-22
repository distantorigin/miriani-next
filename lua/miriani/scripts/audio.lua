
-- Audio configuration for LUA Audio system
-- Volume values are now in percentage (0-100) instead of decimal fractions
-- Pan values range from -100 to 100 (left to right)
-- Frequency is removed as LUA Audio doesn't use it

local audio = {
  notification = {volume=15, pan=0},
  ambiance = {volume=20, pan=0},
  melee = {volume=20, pan=0},
  communication = {volume=30, pan=0},
  loop = {volume=30, pan=0},
  master = {volume=50, pan=0},
  other = {volume=25, pan=0},
  socials = {volume=30, pan=0},
  ship = {volume=25, pan=0},
  computer = {volume=25, pan=0},
  vehicle = {volume=25, pan=0},
} -- audio

return audio