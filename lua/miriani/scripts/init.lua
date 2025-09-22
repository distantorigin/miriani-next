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
  "salvaging", -- Atmospheric salvaging.
  "asteroid_mining", -- Asteroid mining.
-- "mcp", -- MCP protocol
} -- namespace


table.foreach(namespace,
function (i, mod)
  require(string.format("%s/%s", scripts , mod))
end )
     
