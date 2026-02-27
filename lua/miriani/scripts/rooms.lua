-- @module rooms
-- Room and direction related constants, utilities, and triggers for ambiance and movement
--
-------------------------------------------------------------------------------
-- ADDING AMBIANCES
-------------------------------------------------------------------------------
--
-- Sound files go in: sounds/miriani/ambiance/
-- Format: .ogg (e.g., cave.ogg, starship_unknown.ogg)
--
-- For sound variants (randomly selected), name them with numbers:
--   cr1.ogg, cr2.ogg, cr3.ogg  -- mplay() picks one at random
--
-- There are three ways to map a room to an ambiance, checked in this order:
--
-- 1. EXACT ROOM NAME (roomNames table)
--    Use when a specific room title should play a specific sound.
--    Matching is case-insensitive.
--
--    Example - add to roomNames.general:
--      ["My Custom Room"] = "mySound",  -- plays ambiance/mySound.ogg
--
--    Example - add to roomNames.starship (only checked on starships):
--      ["Engine Core"] = "eng",
--
-- 2. PATTERN MATCHING (roomPatterns table)
--    Use when multiple rooms share a naming pattern.
--    Patterns use Lua pattern syntax (not regex).
--    Matching is case-insensitive.
--
--    Example - add to roomPatterns.general:
--      {"Tunnel", "cave"},      -- any room containing "Tunnel"
--      {"^Storage", "storage"}, -- rooms starting with "Storage"
--      {"Lab$", "science"},     -- rooms ending with "Lab"
--
-- 3. ROOM TYPE (roomTypes table)
--    Fallback based on the environment's roomtype flag from the game.
--    Only used if no exact name or pattern matched.
--
--    Example - add to roomTypes.starship:
--      turret = "weapon",  -- roomtype "turret" plays weapon.ogg
--
-- FALLBACK DEFAULTS:
--   If nothing matches, these defaults apply:
--   - starship: starship_unknown.ogg
--   - station: quarters.ogg
--   - planet: planet.ogg (with terrain-specific variants for marine, rocky, etc.)
--   - space: spaceSuit.ogg
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Helper: Case-insensitive table lookup
-------------------------------------------------------------------------------
local function findCaseInsensitive(tbl, key)
  if not tbl or not key then return nil end
  -- Try exact match first (faster)
  if tbl[key] then return tbl[key] end
  -- Fall back to case-insensitive search
  local lowerKey = string.lower(key)
  for k, v in pairs(tbl) do
    if string.lower(k) == lowerKey then
      return v
    end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Room type to ambiance mappings (for environment.roomtype values)
-------------------------------------------------------------------------------
roomTypes = {
  starship = {
    cr = "cr",
    eng = "eng",
    storage = "storage",
    weapons = "weapon",
    repair = "eng",
    bay = "bay",
    corridor = "corridor",
    stateroom = "stateroom",
    medical = "medical",
    airlock = "airlock",
    pool = "pool",  -- mplay picks randomly from pool1, pool2, pool3
    observation = "observation",
    brig = "brig",
    crawlspace = "crawlspace",
    unknown = "starship_unknown",
  },

  planet = {
    garage = "garage",
    pool = "pool",
    hottub = "pool",
    observation = "observation",
    unknown = "planet_unknown",
    security = "security",
    lp = "landingpad",
  },

  station = {
    garage = "garage",
    pool = "pool",
    hottub = "pool",
    observation = "observation",
    unknown = "station_unknown",
    security = "security",
    lp = "landingpad",
  },

  room = {
    asteroid = "asteroidSurface",
    apartment = "quarters",
  },
}

-------------------------------------------------------------------------------
-- Room name to ambiance mappings (exact matches)
-- Both tables are checked for all environments (general first, then starship)
-------------------------------------------------------------------------------
roomNames = {
  starship = {
    ["Airlock"] = "airlock",
    ["Bias Drive Housing"] = "biasHousing",
    ["Brig"] = "brig",
    ["Bridge"] = "cr",
    ["Bzzr Oton Bznit Gran"] = "potate",
    ["Cafeteria"] = "stateroom",
    ["Cargo Bay"] = "storage",
    ["Combat Drone Bay"] = "combatDroneBay",
    ["Common Area"] = "commonArea",
    ["Control Center"] = "cr",
    ["Control Room"] = "cr",
    ["Docking Bay"] = "dockingBay",
    ["Duct"] = "duct",
    ["Fighter Bay"] = "bay",
    ["Fighter Rearm"] = "starship_unknown",
    ["Fighter's Lounge"] = "starship_unknown",
    ["Gym"] = "stateroom",
    ["Hallway"] = "corridor",
    ["Hydroponics Bay"] = "dockingBay",
    ["Library"] = "quarters",
    ["Pool"] = "pool",
    ["Starship Docking Bay"] = "dockingBay",
    ["Targetting Control Center"] = "observation",
    ["Vehicle Docking Bay"] = "bay",
    ["Wellness Center"] = "medical",
  },

  general = {
    ["A Suborbital Pod"] = "ITPN",
    ["Artificial Garden"] = "planet",
    ["Asteroid Rover Control Center"] = "asteroidRover",
    ["Atmospheric Combat Vehicle Control Room"] = "acv",
    ["Atmospheric Salvager Cockpit"] = "salvager",
    ["Beach"] = "ocean",
    ["Clearing"] = "planet",
    ["Crater Rim"] = "volcano",
    ["Decontamination Chamber"] = "decontamination",
    ["Dig Site"] = "digSite",
    ["Empty Space"] = "spaceSuit",
    ["Escalator"] = "escalator",
    ["Gas Giant Salvager Cockpit"] = "salvager",
    ["Idyllic Park"] = "planet",
    ["Indoor Pool"] = "pool",
    ["Large Wooden Dock"] = "ocean",
    ["Lower Walkway"] = "deneii",
    ["Moon Surface"] = "volcano",
    ["Operating Room"] = "medical",
    ["Outdoor Pool"] = "pool",
    ["Petunia's Proximity Weapons"] = "shadius",
    ["Pilot's Lounge"] = "pilotsLounge",
    ["Pitch Black"] = "cave",
    ["Public Docking Bay"] = "landingpad",
    ["Recovery Room"] = "quarters",
    ["Sandy Clearing"] = "planet",
    {"Small Wooden Ferry"} = "ferry",
    ["Starship Computer Services"] = "shadius",
    ["Swimming Pool"] = "pool",
    ["The Gift Garage"] = "planet",
    ["Transport Pod"] = "ITPN",
    ["Twisty Corridor"] = "shadius",
    ["Uncle Lyle's Lock Liquidation"] = "shadius",
  },
}

-------------------------------------------------------------------------------
-- Room name pattern matching (checked after exact matches)
-- Each entry is {pattern, sound} where pattern is a Lua pattern
-- Both tables are checked for all environments (general first, then starship)
-------------------------------------------------------------------------------
roomPatterns = {
  starship = {
    {"Battery ", "weapon"},
    {"^Battle", "weapon"},
    {"^Combat", "weapon"},
    {"Corridor", "corridor"},
    {"Deck", "deck"},
    {"^Engineering", "eng"},
    {"Hangar", "garage"},
    {"^Living Quarters", "quarters"},
    {"^Medical ", "medical"},
    {"^Observation ", "observation"},
    {"Repair and Rearm", "repAndRearm"},
    {"^Room ", "quarters"},
    {"^Stateroom ", "stateroom"},
    {"^Storage", "storage"},
    {"^Weapons", "weapon"},
    {"Bedroom", "quarters"},
  },

  general = {
    {"Sandy Beach", "ocean"},
    {"Cave", "cave"},
    {"^Cell", "brig"},
    {"Cockpit$", "salvager"},
    {"Docking", "landingpad"},
    {"Escape Pod$", "escapePod"},
    {"Garage", "garage"},
    {"Hangar", "garage"},
    {"Lake", "lake"},
    {"Landing", "landingpad"},
    {"Launch Pad", "landingpad"},
    {"Mission", "mission"},
    {"Parking", "garage"},
    {"Pilo.- Lounge", "pilotsLounge"},
    {"River", "lake"},
    {"^Sector .+ Central Jumpgate Hub$", "spaceSuit"},
    {"Shady", "shadius"},
    {"Starship Simulators", "simShop"},
    {"Starship Storage", "garage"},
    {"^Transport Pod .+ to ", "ITPN"},
    {"Tunnel", "cave"},
  },
}

-------------------------------------------------------------------------------
-- Direction word to sound file mappings (for follow/drag sounds)
-------------------------------------------------------------------------------
directionSounds = {
  north = "north",
  south = "south",
  ["into the airlock"] = "out",
  east = "east",
  west = "west",
  northeast = "northeast",
  northwest = "northwest",
  southeast = "southeast",
  southwest = "southwest",
  up = "up",
  down = "down",
  into = "enter",
  out = "out",
  through = "go",
}

-------------------------------------------------------------------------------
-- Room name extraction (for ambiance matching)
-- Extracts clean room name from various formats:
--   [RoomName]
--   ["ShipName" RoomName]
--   [ZoneName; RoomName]
-- Also sets global zoneName for zone-specific ambiance (e.g., Deneii, Apartment)
-------------------------------------------------------------------------------

-- Global zone name for zone-specific ambiance
zoneName = nil

-- Exits tracking for alt+space functionality
current_exits = nil

-- Peering flag to prevent ambiance changes when peering into another room
peering = false

function extractRoomName(rawName)
  -- Starship format: "ShipName" RoomName - extract after the closing quote
  local afterQuote = string.match(rawName, '^".-"%s*(.+)$')
  if afterQuote then
    zoneName = nil  -- Starships don't have zone names in this format
    return afterQuote
  end

  -- Other format: ZoneName; RoomName - extract zone and room separately
  local zone, room = string.match(rawName, '^(.-)%s*;%s*(.+)$')
  if zone and room then
    zoneName = zone
    return room
  end

  -- Plain room name, no zone
  zoneName = nil
  return rawName
end

-------------------------------------------------------------------------------
-- Direction calculation utilities (for coordinate-based navigation)
-------------------------------------------------------------------------------

function calculateDirection2d(you, target)
  local tx, ty = tonumber(target.x), tonumber(target.y)
  local yx, yy = tonumber(you.x), tonumber(you.y)
  local dx, dy = tx - yx, ty - yy
  local dxa, dya = math.abs(dx), math.abs(dy)
  local distance = math.max(dxa, dya)
  local dir = {}

  if distance > 0 then
    if dx ~= 0 then table.insert(dir, (distance > 1 and dxa or '') .. (dx > 0 and 'E' or 'W')) end
    if dy ~= 0 then table.insert(dir, (distance > 1 and dya or '') .. (dy > 0 and 'S' or 'N')) end
  else
    table.insert(dir, 'Here')
  end

  return { dx = dx, dy = dy, dir = table.concat(dir, ' '), distance = distance }
end

function calculateDirection3d(you, target)
  local tx, ty, tz = tonumber(target.x), tonumber(target.y), tonumber(target.z)
  local yx, yy, yz = tonumber(you.x), tonumber(you.y), tonumber(you.z)
  local dx, dy, dz = tx - yx, ty - yy, tz - yz
  local dxa, dya, dza = math.abs(dx), math.abs(dy), math.abs(dz)
  local distance = math.max(dxa, dya, dza)
  local dir = {}

  if distance > 0 then
    if dx ~= 0 then table.insert(dir, (distance > 1 and dxa or '') .. (dx > 0 and 'E' or 'W')) end
    if dy ~= 0 then table.insert(dir, (distance > 1 and dya or '') .. (dy > 0 and 'S' or 'N')) end
    if dz ~= 0 then table.insert(dir, (distance > 1 and dza or '') .. (dz > 0 and 'D' or 'U')) end
  else
    table.insert(dir, 'Here')
  end

  return { dx = dx, dy = dy, dz = dz, dir = table.concat(dir, ' '), distance = distance }
end

function isHere2d(first, second)
  return first.x == second.x and first.y == second.y
end

function isHere3d(first, second)
  return first.x == second.x and first.y == second.y and first.z == second.z
end

-------------------------------------------------------------------------------
-- Environment handling
-- Parses environment flags from game output and stores them globally
-------------------------------------------------------------------------------

-- Global environment table (set by set_environment trigger)
environment = nil

function set_environment(name, line, wc)
  -- Track previous power state to detect power up/down
  local wasUnpowered = environment and environment.unpowered

  environment = {}

  environment.name = name
  environment.line = line
  SetVariable("last_environment_line", line)

  -- iterate through a table of flags
  -- and set all to true.
  -- split any deliminated tags and make them into their own truth value.

  for _, flag in ipairs(wc) do
    local names = utils.split(flag, " ")
    table.foreach(names,
    function(_, value)
      environment[string.lower(value)] = true
    end ) -- foreach
  end -- for

  -- Debug output is enabled
  if config:get_option("debug_mode").value == "yes" then
    local flags = {}
    for k, v in pairs(environment) do
      if k ~= "name" and k ~= "line" and v == true then
        table.insert(flags, k)
      end
    end
    if #flags > 0 then
      notify("info", "Environment [" .. name .. "]: " .. table.concat(flags, ", "))
    end
  end

  -- Store roomtype for use by room_title trigger (ambiance played by room_title after roomName is set)
  environment.roomtype = wc[#wc]

  -- Immediately update ambiance when power state changes (no room title sent for power up/down)
  local isUnpowered = environment.unpowered
  if wasUnpowered ~= isUnpowered then
    playAmbiance(environment.roomtype)
  end
end -- set_environment

-------------------------------------------------------------------------------
-- Ambiance playback logic
-- Determines and plays appropriate ambient sound based on environment/room
--
-- Architecture:
--   shouldPlayAmbiance() - checks all blocking conditions (stun, DND, focus, etc.)
--   computeAmbianceFile() - determines what file to play based on environment
--   updateAmbiance() - single entry point, call when ANY relevant state changes
-------------------------------------------------------------------------------

-- Track current ambiance to avoid repeating
currentAmbianceFile = nil

-- Normalize background_ambiance option value (handles legacy "yes"/"no" values)
function getAmbianceMode()
  local val = config:get_option("background_ambiance").value
  if val == "yes" then return "focused" end
  if val == "no" then return "off" end
  return val
end

-- Check all conditions that would block ambiance playback
function shouldPlayAmbiance()
  if not environment then return false end
  if cameraFeed then return false end
  if stunned then return false end
  if config:is_dnd() then return false end
  local mode = getAmbianceMode()
  if mode == "off" then return false end
  if mode == "focused" and not focusWindow then return false end
  return true
end

-- Determine what ambiance file should play based on current environment
-- Returns nil if no appropriate ambiance found
function computeAmbianceFile()
  if not environment then return nil end

  local file = nil
  local roomtype = environment.roomtype or environment.name or "unknown"
  local names = utils.split(roomtype, " ")
  local rname = string.lower(names[#names])

  -- Debug: trace all calls
  if config and config:get_option("debug_mode").value == "yes" then
    notify("info", string.format("computeAmbianceFile: roomtype='%s', rname='%s', roomName='%s'",
      tostring(roomtype), tostring(rname), tostring(roomName)))
  end

  -- Priority 1: Special states that override everything
  if environment.lift then
    file = "lift"
  elseif environment.unpowered then
    file = "starship_unpowered"
  end

  -- Priority 2: Room name matching (exact matches first, then patterns)
  -- This allows specific room names to override generic environment sounds
  if (not file) and roomName then
    -- Debug: show what we're matching against
    if config and config:get_option("debug_mode").value == "yes" then
      local match = findCaseInsensitive(roomNames.general, roomName)
      notify("info", string.format("Ambiance room name matching: roomName='%s', match=%s",
        tostring(roomName), tostring(match)))
    end

    -- Check general exact matches (applies to all environments)
    file = findCaseInsensitive(roomNames.general, roomName)

    -- Check starship exact matches if on a starship
    if (not file) and environment.name == "starship" then
      file = findCaseInsensitive(roomNames.starship, roomName)
    end

    -- Check general patterns (case-insensitive)
    if (not file) and roomPatterns.general then
      local lowerRoomName = string.lower(roomName)
      for _, pattern in ipairs(roomPatterns.general) do
        if string.find(lowerRoomName, string.lower(pattern[1])) then
          file = pattern[2]
          break
        end
      end
    end

    -- Check starship patterns if on a starship (case-insensitive)
    if (not file) and environment.name == "starship" then
      if roomPatterns.starship then
        local lowerRoomName = string.lower(roomName)
        for _, pattern in ipairs(roomPatterns.starship) do
          if string.find(lowerRoomName, string.lower(pattern[1])) then
            file = pattern[2]
            break
          end
        end
      end
    end

    -- Shadius ambiance only plays indoors
    if file == "shadius" and not environment.indoors then
      file = nil
    end
  end

  -- Priority 3: Room type mapping (from environment.roomtype)
  if (not file) and rname ~= "unknown" then
    if environment.name == "starship" then
      file = roomTypes.starship[rname]
    elseif environment.name == "station" then
      file = roomTypes.station[rname]
    elseif environment.name == "planet" then
      file = roomTypes.planet[rname]
    elseif roomTypes[environment.name] then
      file = roomTypes[environment.name][rname]
    end
  end

  -- Priority 4: Environment-based fallbacks
  if not file then
    if environment.name == "starship" then
      file = "starship_unknown"
    elseif environment.name == "station" then
      file = "quarters"
    elseif environment.name == "space" then
      file = "spaceSuit"
    elseif environment.name == "room" then
      if environment.ITPN then
        file = "ITPN"
      elseif zoneName then
        local lowerZone = string.lower(zoneName)
        if lowerZone == "deneii" then
          file = "deneii"
        elseif string.find(lowerZone, "apartment") then
          file = "quarters"
        end
      end
    elseif environment.name == "planet" then
      if environment.marine then
        file = "marine"
      elseif environment.rocky and environment.outdoors then
        file = "rocky"
      elseif environment.river then
        file = environment.outdoors and "lake" or "indoorRiver"
      elseif environment.digsite then
        file = environment.indoors and "cave" or "digSite"
      elseif environment.terrestrial and environment.outdoors then
        file = "terrestrial"
      elseif environment.transterrestrial and environment.outdoors then
        file = "transterrestrial"
      elseif environment.ice and environment.outdoors then
        file = "ice"
      elseif environment.outdoors then
        file = "planet"
      end
    elseif environment.name == "vehicle" then
      file = "vehicle"
    end
  end

  return file
end

-- Single entry point for ambiance updates
-- Call this whenever any relevant state changes (room, stun, DND, focus, etc.)
function updateAmbiance()
  local fade = 0.8

  if not shouldPlayAmbiance() then
    if currentAmbianceFile then
      stop("ambiance", nil, 1, fade)
      currentAmbianceFile = nil
    end
    return
  end

  local file = computeAmbianceFile()

  if file then
    if file ~= currentAmbianceFile then
      currentAmbianceFile = file
      SetVariable("last_ambiance_file", file)
      mplay("ambiance/"..file, "ambiance", 1, nil, 1, 1, fade)
    end
  else
    if currentAmbianceFile then
      stop("ambiance", nil, 1, fade)
      currentAmbianceFile = nil
    end
  end
end

-- Restore ambiance after plugin reload
-- Uses saved ambiance file, bypasses environment checks since state may not be fully restored
function restoreAmbiance()
  -- Only restore if we were logged in
  if GetVariable("logged_in") ~= "1" then return end

  local file = GetVariable("last_ambiance_file")
  if not file then return end

  -- Basic checks that don't depend on environment state
  if config:is_dnd() then return end
  local mode = getAmbianceMode()
  if mode == "off" then return end
  if mode == "focused" and not focusWindow then return end

  currentAmbianceFile = file
  mplay("ambiance/"..file, "ambiance", 1, nil, 1, 1, 0.8)
end

-- Legacy wrapper for backwards compatibility
function playAmbiance(roomtype)
  updateAmbiance()
end

function getCurrentAmbiance()
  return currentAmbianceFile
end

function clearAmbiance()
  currentAmbianceFile = nil
end

-------------------------------------------------------------------------------
-- Room title trigger
-------------------------------------------------------------------------------
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   name="room_title"
   script="playstep"
   group="misc"
   keep_evaluating="y"
   match="^\[([A-Za-z0-9 ;:\-'&quot;]+)\](( \([^)]+\))*)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   -- Skip room processing when peering into another room
   if peering then return end

   room = "%0"
   SetVariable("last_room", room)
   cameraFeed = nil
   roomName = extractRoomName("%1")

   if config:get_option("debug_mode").value == "yes" then
     notify("info", string.format("room_title trigger: room='%s', roomName='%s', environment=%s, has_digsite=%s, has_store=%s",
       tostring(room),
       tostring(roomName),
       tostring(environment ~= nil),
       tostring(environment and environment.digsite or false),
       tostring(environment and environment.store or false)))
   end

   -- Clear archaeology infobar when leaving digsite (regardless of digsite_detector option)
   if config:get_option("archaeology_helper_dig").value == "yes"
   and environment
   and (buried_artifact or artifact_room) then
     if not environment.digsite then
       buried_artifact, artifact_room = nil
       infobar_t["arch"] = nil
     end -- if
   end -- if

   if config:get_option("digsite_detector").value == "yes"
   and environment then

     if environment.digsite then
       if (not digsite) then mplay("activity/archaeology/digsite", "notification", 1) end
       digsite = true
     elseif digsite then
       digsite = nil
      end -- if
   end -- if

   if config:get_option("store_detector").value == "yes"
   and environment then

     if environment.store then
       if config:get_option("debug_mode").value == "yes" then
         notify("info", string.format("Store detector: room='%s', store='%s', equal=%s", tostring(room), tostring(store), tostring(room == store)))
       end
       if room ~= store then mplay("misc/store", "notification", 1) end
       store = room
     elseif store then
       store = false
      end -- if
   end -- if


   if liftroom and liftroom ~= room then
     liftroom = nil
     stop("loop")
   end -- if

   -- Re-evaluate ambiance now that roomName is set
   -- This allows room name matching to work (set_environment runs before room title)
   if environment and environment.roomtype then
     playAmbiance(environment.roomtype)
   end

  </send>
  </trigger>

  <trigger
   enabled="y"
   name="exits_tracker"
   match="^You (?:can go (nowhere|.+)|see nowhere obvious to go)\.$"
   regexp="y"
   send_to="14"
   keep_evaluating="y"
  >
  <send>
   -- Reset peering flag after exits line
   peering = false

   local exits_string = "%1"
   current_exits = {}

   -- Parse exits if we have any (not "nowhere" or empty)
   if exits_string ~= "" and exits_string ~= "nowhere" then
     -- Remove "and" and split by commas and spaces
     exits_string = exits_string:gsub(" and ", ", ")

     -- Split by comma and extract direction words
     for exit in exits_string:gmatch("[%w]+") do
       table.insert(current_exits, exit)
     end
   end
  </send>
  </trigger>

</triggers>
]=])
