-- Scan table
scantable = {
  a = "Atmospheric Composition",
  c = "Coordinates",
  d = "Distance",
  g = "Cargo",
  h = "Hull Damage",
  i = "IFF",
  l = "Classification",
  m = "Composition",
  n = "Natural Resources",
  o = "Occupancy",
  p = "Power",
  r = "Surface Conditions",
  s = "Identifiable Power Sources",
  t = "Type",
  u = "Hostile Military Occupation",
  v = "Average Component Damage",
  w = "Weapons",
  y = "Integrity",
  z = "Size"
} -- scantable

-- Starmap table:
starmaptable = {
  a = "Asteroid",
  A = "Accelerator",
  b = "Blockade",
  c = "Combat Drone",
  C = "Control Beacon",
  d = "Debris",
  e = "Relic",
  E = "Pellets",
  f = "Artifact",
  i = "Interdictor",
  j = "Jumpgate",
  l = "Missile",
  L = "Satellite",
  m = "Moon",
  M = "Private Moon",
  o = "Mobile Platform",
  p = "Planet",
  P = "Private Planet",
  r = "Star",
  s = "Starship",
  t = "Space Station",
  T = "Private Space Station",
  u = "Unknown",
  w = "Wormhole",
  x = "Proximity Weapon",
  y = "Dry Dock",
  Y = "Buoys"
 } -- starmaptable

-- Scan data storage
scanData = {}

-- Scan format templates
-- Template variables available:
-- Starship: name, ship_type, alliance, organization, newbie, distance, coordinates, hull_damage, average_component_damage, power, weapons, occupancy, number_of_occupants, cargo, iff, pilot_status, courier_ship_status
-- Planet: object_name, classification, distance, coordinates, natural_resources, atmospheric_composition, surface_conditions, hostile_military_occupation
-- Moon: object_name, classification, distance, coordinates, orbiting, natural_resources, atmospheric_composition
-- Station: object_name, distance, coordinates, integrity, occupancy, identifiable_power_sources
-- Asteroid: object_name, size, distance, coordinates, composition, starships, landing_beacons
-- Star: object_name, classification, distance, coordinates
-- Debris: object_name, type, size, distance, coordinates
-- Weapon/Probe/Interdictor/Blockade: object_name, distance, coordinates, damage, available_charge, launched_by
scanTemplates = {
  Starship = "{newbie}{name} ({ship_type}) is {distance} units away. Hull {hull_damage}, Avg dmg {average_component_damage}. Power {power}, Weapons {weapons}. {number_of_occupants}{occupancy}. Alliance {alliance}. {organization}{cargo}{coordinates}",
  Planet = "{object_name}: {classification} planet {distance} units away, at {coordinates}. {natural_resources}{atmospheric_composition}{surface_conditions}{hostile_military_occupation}",
  Moon = "{object_name}: {classification} moon {distance} units away, orbiting {orbiting}. {coordinates}. {natural_resources}{atmospheric_composition}",
  Station = "{object_name}: Station {distance} units away, at {coordinates}. {integrity}{occupancy}{identifiable_power_sources}",
  Asteroid = "{object_name}: {size} asteroid {distance} units away. {composition}{starships}{landing_beacons}{coordinates}",
  Star = "{object_name}: Class {classification} star {distance} units away, at {coordinates}",
  Debris = "{object_name}: {type} {distance} units away, at {coordinates}",
  Weapon = "{object_name}: {distance} units distant. {damage}{available_charge}{launched_by}{coordinates}",
  Probe = "{object_name}: {distance} units distant. {launched_by}{coordinates}",
  Interdictor = "{object_name}: {distance} units distant. {launched_by}{coordinates}",
  Blockade = "{object_name}: {distance} units distant. {launched_by}{coordinates}",
  Unknown = "{object_name}: {distance} units away, at {coordinates}"
}

-- Helper function to convert field names to template keys
local function fieldToKey(fieldName)
  -- Convert "Hull Damage" to "hull_damage", etc.
  return string.lower(string.gsub(fieldName, " ", "_"))
end

-- Format scan data using template
function formatScanOutput()
  -- Determine object type from collected data
  local objectType = "Unknown"

  if scanData.weapons or scanData.hull_damage then
    objectType = "Starship"

    -- Parse ship name, type, alliance, organization, and newbie status from object_name
    -- Format examples:
    -- The ten-person battlecruiser "Testing" (Red) [Organization: SomeCorp] [N]
    -- The ten-person battlecruiser "Testing" (Red) [N]
    -- The ten-person battlecruiser "Testing" (Red) [Organization: SomeCorp]
    -- The ten-person battlecruiser "Testing" (Red)
    if scanData.object_name then
      local line = scanData.object_name

      -- Extract newbie status [N] at the end
      local newbie = string.match(line, "%[N%]%s*$")
      if newbie then
        scanData.newbie = "New pilot. "
        line = string.gsub(line, "%s*%[N%]%s*$", "")
      end

      -- Extract organization
      local org = string.match(line, "%[Organization:%s*(.-)%]%s*$")
      if org then
        scanData.organization = "Org: " .. org .. ". "
        line = string.gsub(line, "%s*%[Organization:.-%]%s*$", "")
      end

      -- Now parse ship type, name, and alliance
      local shipType, shipName, alliance = string.match(line, "^[Tt]he%s+(.-)%s+\"([^\"]+)\"%s+%((.+)%)%s*$")
      if not shipName then
        -- Try without "The" prefix
        shipType, shipName, alliance = string.match(line, "^(.-)%s+\"([^\"]+)\"%s+%((.+)%)%s*$")
      end
      if shipName then
        scanData.name = shipName
        scanData.ship_type = shipType
        scanData.alliance = alliance
      else
        -- Fallback: use object_name as ship name if we couldn't parse it
        scanData.name = scanData.object_name
        scanData.ship_type = "unknown"
        scanData.alliance = "Unknown"
      end
    end

    -- Process occupancy to extract number of occupants
    if scanData.occupancy and scanData.occupancy ~= "" then
      -- Check if it's a simple state (Empty, Filled, etc.) or a list of names
      if scanData.occupancy ~= "Empty" and scanData.occupancy ~= "Filled" and
         scanData.occupancy ~= "Invalid reading" and scanData.occupancy ~= "Underfilled" then
        -- Count names separated by commas
        local count = 0
        for _ in string.gmatch(scanData.occupancy, "[^,]+") do
          count = count + 1
        end
        -- Check for " and " which indicates 2 occupants when there's only 1 comma
        if count == 1 and string.find(scanData.occupancy, " and ") then
          count = 2
        end
        scanData.number_of_occupants = count .. " occupants. "
      end
    end

    -- Process cargo - skip "Indeterminate"
    if scanData.cargo == "Indeterminate" then
      scanData.cargo = nil
    elseif scanData.cargo then
      scanData.cargo = "Cargo: " .. scanData.cargo .. ". "
    end

    -- Process power - handle "Unknown"
    if scanData.power and string.find(scanData.power, "Unknown") then
      scanData.power = "Charge Unknown"
    end

  elseif scanData.object_type == "Video Probe" or scanData.object_type == "Interdictor" then
    objectType = scanData.object_type == "Video Probe" and "Probe" or "Interdictor"
  elseif scanData.classification and string.match(scanData.classification or "", "[OBAFGKM]") then
    objectType = "Star"
  elseif scanData.orbiting then
    objectType = "Moon"
  elseif scanData.atmospheric_composition then
    objectType = "Planet"
  elseif scanData.integrity then
    objectType = "Station"
  elseif scanData.composition then
    objectType = "Asteroid"
  elseif scanData.size and not scanData.composition then
    objectType = "Debris"
  elseif scanData.damage then
    objectType = "Weapon"
  end

  -- Get template for this object type from config (with fallback to hardcoded)
  local template = scanTemplates.Unknown
  if config and config.get_option then
    local configKey = "scan_format_" .. string.lower(objectType)
    local opt = config:get_option(configKey)
    if opt and opt.value then
      template = opt.value
    else
      -- Fallback to hardcoded template
      template = scanTemplates[objectType] or scanTemplates.Unknown
    end
  else
    template = scanTemplates[objectType] or scanTemplates.Unknown
  end

  -- Replace placeholders with actual data
  -- Use simple find/replace approach to avoid pattern issues
  local output = template

  -- Handle distance units (singular vs plural)
  if scanData.distance then
    local distance_units = (scanData.distance == "1") and "unit" or "units"
    scanData.distance_units = distance_units
  end

  -- Format specific fields with proper punctuation
  if scanData.natural_resources then
    scanData.natural_resources = "Natural resources: " .. scanData.natural_resources .. ". "
  end
  if scanData.atmospheric_composition then
    scanData.atmospheric_composition = "Atmospheric composition: " .. scanData.atmospheric_composition .. ". "
  end
  if scanData.surface_conditions then
    scanData.surface_conditions = "Surface conditions: " .. scanData.surface_conditions .. ". "
  end
  if scanData.hostile_military_occupation then
    scanData.hostile_military_occupation = "Hostile military occupation: " .. scanData.hostile_military_occupation .. ". "
  end
  if scanData.integrity then
    scanData.integrity = "Integrity: " .. scanData.integrity .. ". "
  end
  if scanData.identifiable_power_sources then
    scanData.identifiable_power_sources = "Power sources: " .. scanData.identifiable_power_sources .. ". "
  end
  if scanData.composition then
    scanData.composition = "Composition: " .. scanData.composition .. ". "
  end
  if scanData.starships then
    scanData.starships = "Starships: " .. scanData.starships .. ". "
  end
  if scanData.landing_beacons then
    scanData.landing_beacons = "Landing beacons: " .. scanData.landing_beacons .. ". "
  end
  if scanData.launched_by then
    scanData.launched_by = "Launched by: " .. scanData.launched_by .. ". "
  end
  if scanData.available_charge then
    scanData.available_charge = "Available charge: " .. scanData.available_charge .. ". "
  end
  if scanData.coordinates then
    scanData.coordinates = "Coordinates: " .. scanData.coordinates .. "."
  end

  for key, value in pairs(scanData) do
    if value and value ~= "" and key ~= "in_scan" and key ~= "object_type" and key ~= "potential_object_name" then
      local placeholder = "{" .. key .. "}"
      local replacement = tostring(value)

      -- Plain text replacement using string positions
      local pos = 1
      while true do
        local start_pos, end_pos = string.find(output, placeholder, pos, true) -- true = plain text search
        if not start_pos then break end
        output = string.sub(output, 1, start_pos - 1) .. replacement .. string.sub(output, end_pos + 1)
        pos = start_pos + string.len(replacement)
      end
    end
  end

  -- Remove remaining placeholders (ones without data) and clean up spacing
  output = string.gsub(output, "{[^}]+}", "")
  output = string.gsub(output, "%.%s*%.", ".")  -- Remove double periods
  output = string.gsub(output, "%.%s+%.", ".")  -- Remove double periods with spaces
  output = string.gsub(output, ",%s*,", ",")    -- Remove double commas
  output = string.gsub(output, "%.%s*,", ".")   -- Remove ", " after period
  output = string.gsub(output, "%s+at%s*$", "") -- Remove trailing "at" with no coords
  output = string.gsub(output, "%s+at%s+%.", ".") -- Remove "at ."
  output = string.gsub(output, "%s+is%s+units", " units") -- Remove "is units"
  output = string.gsub(output, "\"\"", "")      -- Remove empty quotes
  output = string.gsub(output, "%(%)%s*", "")   -- Remove empty parens

  -- Clean up multiple spaces and trailing periods
  output = string.gsub(output, "%s+", " ")
  output = string.gsub(output, "%.%s*%.", ".")
  output = string.gsub(output, "%s*%.$", "")
  output = Trim(output)

  return output
end

-- Central function to initiate a scan
function shipscan(target, filterField)
  -- Initialize scan state
  scanData = {}
  scanData.in_scan = true  -- Mark that we're in a scan

  if filterField then
    scan = filterField
    scanFiltering = true
  else
    scanFiltering = false
    scan = ""
  end

  -- Enable scan triggers immediately
  EnableTriggerGroup("scan_triggers", true)

  if target and target ~= "" then
    Send("scan " .. target)
  else
    Send("scan")
  end
end

-- Function to end scan and reset state
-- Safe to call multiple times
function endScan()
  scanData = {}
  scanFiltering = false
  scan = ""
  -- Disable scan triggers until next scan
  -- Safe to call even if already disabled
  EnableTriggerGroup("scan_triggers", false)
end

-- Manual reset function
function resetScan()
  endScan()
end

ImportXML([=[
<triggers>

  <!-- Capture lines that look like object names (start with capital letter or "The") -->
  <trigger
   name="capture_potential_object_name"
   enabled="n"
   group="scan_triggers"
   match="^(?:The |[A-Z])[A-Za-z0-9 ]+.*$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="95"
   keep_evaluating="y"
  >
  <send>
   local line = "%0"

   -- Only process if we're in a scan
   if not scanData.in_scan then
     return
   end

   -- Check if this is an error message - if so, end scan and let it through
   local errorPatterns = {
     "^Nothing was detected at those coordinates%.$",
     "^That object was not found%.$",
     "^You'll have better results scanning in space%.$",
     "^That is now out of scanning range%.$",
     "^Your sensors are unable to scan those coordinates%.$",
     "^General sector report for ",
          "^You'll have better results scanning in space%.$",
     "^I don't understand that%.$",
     "^Invalid selection%.$"
   }

   for _, pattern in ipairs(errorPatterns) do
     if string.match(line, pattern) then
       endScan()
       print(line)
       return
     end
   end

   -- Skip if we already have an object name
   if scanData.object_name then
     return
   end

   -- Skip if line contains a colon (it's a field, already handled)
   if string.find(line, ":") then
     return
   end

   -- Skip blank lines
   if string.match(line, "^%s*$") then
     print(line)
     return
   end

   -- Store as potential object name (will be confirmed by dash line)
   scanData.potential_object_name = line

   local useFormatting = false
   if config and config.get_option then
     local opt = config:get_option("scan_formatting")
     if opt and opt.value then
       useFormatting = (opt.value == "yes")
     end
   end

   if scanFiltering or useFormatting then
     -- Gag the line (we'll show it in formatted output if needed)
   else
     print(line)
   end
  </send>
  </trigger>

  <!-- Handle all dash lines during scans -->
  <trigger
   name="capture_object_name_dashes"
   enabled="n"
   group="scan_triggers"
   match="^-+$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
   keep_evaluating="y"
  >
  <send>
   -- Check if we have a potential object name to confirm
   if scanData.potential_object_name then
     local dashCount = string.len("%0")
     local potentialName = scanData.potential_object_name

     -- For ships, check if dashes match up to the parenthesis
     local nameBeforeParen = string.match(potentialName, "^(.-)%s+%(")
     if nameBeforeParen then
       local nameLen = string.len(nameBeforeParen)
       if dashCount == nameLen then
         scanData.object_name = potentialName
         scanData.potential_object_name = nil
       end
     else
       -- For non-ships, check if dashes match the entire line
       local lineLen = string.len(potentialName)
       if dashCount == lineLen then
         scanData.object_name = potentialName
         scanData.potential_object_name = nil
       end
     end
   end

   -- Determine if we should use formatting/filtering
   local useFormatting = false
   if config and config.get_option then
     local opt = config:get_option("scan_formatting")
     if opt and opt.value then
       useFormatting = (opt.value == "yes")
     end
   end

   -- Check if this is the ending dash line (after Distance field)
   if scanData.distance then
     -- Save state before clearing
     local shouldGag = scanFiltering or useFormatting
     -- End the scan
     endScan()
     if shouldGag then
       -- Gag the line
     else
       print("%0")
     end
   elseif scanFiltering or useFormatting then
     -- Gag all dash lines when formatting/filtering
   else
     print("%0")
   end
  </send>
  </trigger>

  <!-- Capture special object types: Video Probe, Interdictor, Blockade, etc -->
  <trigger
   name="capture_special_objects"
   enabled="n"
   group="scan_triggers"
   match="^(Video Probe|Interdictor|Blockade|Automated Laser Turret|Space Mine|Push Pulse)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="50"
   keep_evaluating="y"
  >
  <send>
   local line = "%0"

   -- Store object type and name
   scanData.object_type = "%1"
   scanData.object_name = line

   local useFormatting = false
   if config and config.get_option then
     local opt = config:get_option("scan_formatting")
     if opt and opt.value then
       useFormatting = (opt.value == "yes")
     end
   end

   if scanFiltering or useFormatting then
     -- Gag the line
   else
     print(line)
   end
  </send>
  </trigger>


  <trigger
   enabled="n"
   group="scan_triggers"
   match="^(Hull Damage|Average Component Damage|Occupancy|Weapons|Power|Cargo|Coordinates|Classification|Natural Resources|Atmospheric Composition|Composition|Integrity|Identifiable Power Sources|IFF|Surface Conditions|Hostile Military Occupation|Size|Type|Distance|Damage|Orbiting): (.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  sequence="90"
  keep_evaluating="y"
  >
  <send>
   -- Store scan data
   local fieldName = "%1"
   local fieldValue = "%2"

   local key = string.lower(string.gsub(fieldName, " ", "_"))
   scanData[key] = fieldValue

   -- Track last scanned coordinates and update status bar
   if fieldName == "Coordinates" then
     lastScannedCoords = fieldValue
     local coords = string.gsub(lastScannedCoords, "[()]", "")  -- Strip parentheses
     infobar("scan", "Scan: " .. coords)

     -- Auto-interrupt TTS on coordinates with delay (only when not filtering/formatting)
     local useFormatting = false
     if config and config.get_option then
       local opt = config:get_option("scan_formatting")
       if opt and opt.value then
         useFormatting = (opt.value == "yes")
       end
     end

     local scanInterrupt = false
     if config and config.get_option then
       local opt = config:get_option("scan_interrupt")
       if opt and opt.value then
         scanInterrupt = (opt.value == "yes")
       end
     end

     if not (scanFiltering or useFormatting) and scanInterrupt then
       -- Check if it's a starship (only interrupt for starships)
       local isStarship = scanData.weapons or scanData.hull_damage

       if isStarship then
         local coords = string.gsub(fieldValue, "[()]", "")  -- Strip parentheses

         -- Use coroutine for delay
         local wait = require("wait")
         wait.make(function()
           wait.time(0.1)  -- Wait 100ms
           Execute("tts_interrupt " .. coords)
         end)
       end
     end -- if scan_interrupt
   end -- if coordinates

   -- Determine if we should use formatting
   local useFormatting = false
   if config and config.get_option then
     local opt = config:get_option("scan_formatting")
     if opt and opt.value then
       useFormatting = (opt.value == "yes")
     end
   end

   -- If we don't have an object name yet, use potential_object_name as fallback
   if not scanData.object_name and scanData.potential_object_name then
     scanData.object_name = scanData.potential_object_name
     scanData.potential_object_name = nil
   end

   -- Handle output based on mode
   if scanFiltering then
     -- Filtering mode (sch/sco/etc): only show the matching field
     if scan == fieldName then
       print(fieldName .. ": " .. fieldValue)
       speech_interrupt(fieldValue)
       mplay("ship/computer/scan", "other")
       if fieldName == "Hull Damage" or fieldName == "Distance" then
         if fieldValue == "1" or string.sub(fieldValue, 1, 2) == "1%" then
           mplay("ship/computer/oneUnit", "notification")
         end
       end
       scanData.field_found = true
     end
     -- Check if we're at the last field (Distance)
     if fieldName == "Distance" then
       -- Check if the requested field was found
       if not scanData.field_found then
         print("That object does not have a " .. scan .. " field.")
         mplay("ship/computer/nothingToScan", "other")
         mplay("cancel", "notification")
       end
       -- Don't clear scanFiltering/scan yet - wait for the ending dash line
     end
   elseif useFormatting then
     -- Formatting mode: gag all fields, output formatted line at end
     if fieldName == "Distance" then
       local formatted = formatScanOutput()
       print(formatted)
       speech_interrupt(formatted)
       mplay("ship/computer/scan", "other")
       if fieldValue == "1" then
         mplay("ship/computer/oneUnit", "notification")
       end
       -- Don't clear scanData yet - wait for the ending dash line
     end
     -- All other fields: do nothing (gagged by omit_from_output)
   else
     -- Normal mode: show all fields
     print(fieldName .. ": " .. fieldValue)
     if fieldName == "Distance" then
       mplay("ship/computer/scan", "other")
       if fieldValue == "1" then
         mplay("ship/computer/oneUnit", "notification")
       end
       -- Don't clear scanData yet - wait for dash trigger to clear it
     end
   end
  </send>
  </trigger>

  <!-- Error handling triggers - end scan on failures -->
  <trigger
   enabled="y"
   group="computer"
   match="^Nothing was detected at those coordinates\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^That object was not found\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^You'll have better results scanning in space\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^That is now out of scanning range\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^Your sensors are unable to scan those coordinates\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^General sector report for "
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="starmap"
   match="^(?:(\w+ Space|Midway Point|Sector \d+): .+?|a .+? starship simulator) \(.+?\)\s?(?:\[Outside (Communications Range|Local Space)\])?\s?(\[(Explored|Unexplored)\])?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   if (not searchingScan) then
    return print("%0")
  end -- if

   EnableTrigger("starmap_filter", true)
  </send>
  </trigger>

  <trigger
   name="starmap_filter"
   group="starmap"
   match="^([A-Z][a-z]+?\s?[A-Za-z\s]*?): (.+)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>

    if (scan == "")
    or (scan == "%1")
    or (string.gsub("%1", "s$", "") == scan) then

    starmap  = {}

    -- strip out the trailing conjunction
    local names = string.gsub("%2", "%),? and", "%),")

    -- separate the names
    names = string.gsub(names, "%s%b()", "")
    -- Add the names to a table
    names = utils.split(names, ",")

    -- parse the coordinates now
    local count, tmp = 1, {}
    for word in string.gmatch("%2", "%b()") do
     -- strip all the punctuations from the digits.
     tmp["x"] = string.gsub(
      string.match(word, "%p%d+%p%s"), "%p", "")

    tmp["y"] = string.gsub(
      string.match(word, "%s%d+%p%s"), "%p", "")

    tmp["z"] = string.gsub(
      string.match(word, "%s%d+%)"), "%p", "")

     -- override starmap name with scan type if not ship
     if scan ~= "Starship" then
      names[count] = "%1"
     end -- if not ship

     -- Save to our global starmap table.
     starmap[count] = {
      x = tonumber(tmp["x"]),
      y = tonumber(tmp["y"]),
      z = tonumber(tmp["z"]),
      name = names[count],
      number = count
     } -- starmap table
     -- Increment the count
     count = count + 1
    end -- for loop
   searchingScan = false

   end -- if

   if "%1" == "Current Coordinates" then
    EnableTrigger("starmap_filter", false)

    if searchingScan and scan ~= "" then
     print ("No "..scan.." found.")
     searchingScan = false
     scan = nil
return 0
    end -- if

    -- Return if coordinates could not be retrieved.
    if "%2" == "(unknown)" then
      return print("Unable to retrieve your coordinates.")
    end -- if unknown coordinates

    -- Handle the sorting of starmap.
    -- First save our coordinates
    local coordinates = {
     x = string.gsub(
      string.match("%2", "%(%d+"), "%p", ""),
     y = string.gsub(
      string.match("%2", "%s%d+%p%s"), "%p", ""),
     z = string.gsub(
      string.match("%2", "%d+%)"), "%p", "")
    }

    -- convert to integer
    coordinates["x"] = tonumber(coordinates["x"])
    coordinates["y"] = tonumber(coordinates["y"])
    coordinates["z"] = tonumber(coordinates["z"])

    -- Calculate the distance
    for i, v in ipairs(starmap) do
     v.distance = math.floor(math.sqrt(math.pow (coordinates["x"]-v.x, 2) + math.pow(coordinates["y"]-v.y, 2) + math.pow(coordinates["z"]-v.z, 2)))
    end -- for loop

    -- Sort the distance
    table.sort(starmap, function(k1, k2) return k1.distance &lt; k2.distance end)

    -- Interrupt speech so users can see the information faster.
    Execute("tts_stop")
    -- Display the sorted results
    local matches, range = 0, 0
    for i,v in ipairs(starmap) do

     -- declare output in scope in order to have it default with each iteration
     local output

     if classFilter and string.find(string.lower(v.name), classFilter) then
            output = string.format("(%d, %d, %d) - (%s: %d) - (%s) - (Distance: %d)", v.x, v.y, v.z, scan, v.number, Trim(v.name), v.distance)
      matches = matches + 1
     elseif (not classFilter) then
            output = string.format("(%d, %d, %d) - (%s: %d) - (%s) - (Distance: %d)", v.x, v.y, v.z, scan, v.number, Trim(v.name), v.distance)
     end -- if

     if output ~= nil and starmap[i].distance ~= 0 then
      print (Trim(output))

      -- mplay a sound for range
      if range == 0 and v.distance == 1 then
       range = 1
       mplay("ship/computer/oneUnit", "other")
      end -- range
     end -- if output
    end -- for loop

    -- delete classFilter if set and print match count
    if classFilter then
     print (matches, " Matches.")
     classFilter = nil
    end -- if classFilter
    scan = nil
   end -- if Current Coordinates
  </send>
  </trigger>


</triggers>
<aliases>
  <!-- Catch scan/sc commands (but not filter aliases like sch, sco, etc) -->
  <alias
   enabled="y"
   group="computer"
   match="^s(?:can|c)$|^s(?:can|c)\s+(.+)$"
   regexp="y"
   send_to="12"
   sequence="200"
  >
  <send>
   shipscan("%1")
  </send>
  </alias>

  <!-- Filter aliases -->
  <alias
   enabled="y"
   group="computer"
   match="^sc([acdghilmnoprstuvwyz]|\.help)(?:\s+(.+))?$"
   ignore_case="y"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == ".help" then
     local tprint = require("tprint")
     print("Valid switches:")
     tprint(scantable)
     return
   end

   local filterField = scantable[string.lower("%1")]
   if filterField then
     shipscan("%2", filterField)
   else
     print("Unknown scan filter: %1")
   end
  </send>
  </alias>

  <alias
   enabled="y"
   group="starmap"
   match="^sm([AbdCeEfijlLmMopPrstTuwxyY]|\.help|\.count)(\s\w+)?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>

   local count_ships
   if ("%1" == ".help") then
    local tprint = require ("tprint")
    print("Valid switches:")
    tprint(starmaptable)
    print("- sm.count to generate starmap breakdown summary.")
    return 0
   elseif ("%1" == ".count") then
    count_ships = true
   end -- if help

   searchingScan = true
   scan = ""

   if (not count_ships) then
    scan = string.gsub("%1", "%a+",
     function (letter)
      return starmaptable[letter]
     end -- function
    ) -- replacement

    if "%2" ~= "" then
     classFilter = string.lower(Trim("%2"))
    end -- if
   end -- if

   Execute ("starmap")
  </send>
  </alias>

  <!-- Reset scan state manually -->
  <alias
   enabled="y"
   group="computer"
   match="^sc\.reset$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   resetScan()
  </send>
  </alias>

</aliases>
]=])