-- @module init
-- Instantiates the soundpack namespace.
-- Imports all dependencies.

-- Author: Erick Rosso
-- Last updated 2024.08.09

---------------------------------------------

local path = require("pl.path")

local scripts = "lua/miriani/scripts"

-- Dependencies:
local Config = require(scripts .."/include/config")
config = Config()
notify = require(scripts .."/include/notify")

-- Table of dependencies.
local namespace = {
  "sounds", -- specific audio functions.
  "constants", -- Global constants
  "options", -- global options
  "hooks", -- Miriani soundpack hooks:
  "misc", -- misc triggers without any specific categorization
  "market", -- tradesman market procedures
  "gags", -- text throttle
  "ship", -- starship-related procedures
  "computer", -- Starship computer
  "combat", -- combat procedures
  "starmap_scan", -- starmap and scan routines
  "communication", -- Communication
  "vehicles", -- vehicles
  "archaeology", -- archaeology
  "hauling", -- asteroid hauling
  "asteroid_mining", -- Asteroid mining.
  "planetary_mining", -- Planetary mining.
  "contributions", -- Credit contribution tracking
  "babies", -- Baby emotes and sounds
  "sound_conflict_detector", -- Sound file conflict detection and cleanup
  "devices", -- Device sounds and notifications (message board readers, etc.)
  "dialog_handlers", -- Dialog system input handlers
-- "mcp", -- MCP protocol
} -- namespace


table.foreach(namespace,
function (i, mod)
  require(string.format("%s/%s", scripts , mod))
end )

-- Cleanup legacy classic_miriani directory if it exists
local classic_dir = path.join(config:get("SOUND_DIRECTORY"), "classic_miriani")
if path.isdir(classic_dir) then
  local utils = require("pl.utils")
  local result, err = utils.execute("rmdir /s /q \"" .. classic_dir .. "\"")
  if config:get_option("debug_mode").value == "yes" then
    if result == 0 then
      notify("info", "Removed legacy classic_miriani directory")
    else
      notify("important", "Failed to remove classic_miriani directory: " .. tostring(err))
    end
  end
end

-- Check and cleanup sound file conflicts
check_and_cleanup_sound_conflicts()
     
