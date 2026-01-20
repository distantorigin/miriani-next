-- Scan table
scantable = {
  a = "Average Component Damage",
  c = "Coordinates",
  d = "Distance",
  h = "Hull Damage",
  i = "IFF",
  l = "Classification",
  m = "Composition",
  n = "Natural Resources",
  o = "Occupancy",
  p = "Identifiable Power Sources",
  r = "Surface Conditions",
  s = "Cargo",
  t = "Type",
  u = "Hostile Military Occupation",
  w = "Weapons",
  y = "Integrity",
  z = "Size"
} -- scantable

-- Starmap table:
starmaptable = {
  a = "Asteroid",
  A = "Accelerator",
  b = "Blockade",
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

-- NOTE: Scan format templates are defined in options.lua as configurable options
-- (scan_format_starship, scan_format_planet, etc.) and accessed via config:get_option()

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
  elseif scanData.object_name == "Artifact" then
    objectType = "Artifact"
  elseif scanData.damage then
    objectType = "Weapon"
  end

  -- Get template for this object type from config
  local template = "{object_name}: {distance} units away, at {coordinates}"  -- Default fallback
  if config and config.get_option then
    local configKey = "scan_format_" .. string.lower(objectType)
    local opt = config:get_option(configKey)
    if opt and opt.value then
      template = opt.value
    end
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
    scanData.coordinates = format_coords(scanData.coordinates)
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
function shipscan(target, filterField, forceFormatting)
  -- Initialize scan state
  scanData = {}
  pendingScan = true  -- Mark that we're waiting for scan output
  inActiveScan = false  -- Not in active scan yet
  EnableTrigger("prescan_potential_name", true)
  firstDashLength = nil  -- Will store the length of the first dash line

  if filterField then
    scan = filterField
    scanFiltering = true
  else
    scanFiltering = false
    scan = ""
  end

  -- Force formatting mode if requested (for scu command)
  if forceFormatting then
    scanData.force_formatting = true
  end

  -- Don't enable scan triggers yet - wait for first dash line

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
  pendingScan = false
  inActiveScan = false
  firstDashLength = nil
  -- Disable scan triggers until next scan
    EnableTriggerGroup("scan_triggers", false)
    EnableTrigger("prescan_potential_name", false)
end

ImportXML([=[
<triggers>

  <!-- Scan Start Detection: Capture potential object names before we're in active scan -->
  <trigger
   name="prescan_potential_name"
   enabled="n"
   group="ship"
   match="^([a-zA-Z]{1}[\(\)\[\]\{\}a-zA-Z0-9'&quot; -:,]{1,99})$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="101"
   keep_evaluating="y"
  >
  <send>
   local line = "%0"

   -- Only capture if we're waiting for a scan to start
   if not pendingScan or inActiveScan then
     return
   end

   -- Skip blank lines
   if string.match(line, "^%s*$") then
     return
   end

     -- Store as potential object name for the next dash line to validate
   scanData.potential_object_name = line

   local useFormatting = scanData.force_formatting or false
   if not useFormatting and config and config.get_option then
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

  <!-- Scan Start Detection: Validate first dash line and enable scan processing -->
  <trigger
   name="scan_start_dash_validator"
   enabled="y"
   group="computer"
   match="^-+$"
   regexp="y"
   send_to="14"
   sequence="10"
   keep_evaluating="y"
  >
  <send>
   local line = "%0"

   -- Only validate if we're waiting for a scan to start
   if not pendingScan or inActiveScan then
     return
   end

   -- Check if we have a potential object name to validate
   if not scanData.potential_object_name then
     return
   end

   local dashCount = string.len(line)
   local potentialName = scanData.potential_object_name

   -- For starships, check if dashes match up to the parenthesis (not including what's after)
   local nameBeforeParen = string.match(potentialName, "^(.-)%s+%(")
   local isValid = false

   if nameBeforeParen then
     -- Starship: dash length should match name before parenthesis
     local nameLen = string.len(nameBeforeParen)
     if dashCount == nameLen then
       isValid = true
     end
   else
     -- Non-starship: dash length should match entire line
     local lineLen = string.len(potentialName)
     if dashCount == lineLen then
       isValid = true
     end
   end

   if isValid then
     -- We've confirmed this is a real scan! Activate scan processing
     inActiveScan = true
     pendingScan = false
     firstDashLength = dashCount
     scanData.object_name = potentialName
     scanData.potential_object_name = nil

     -- Check if this is a special object type and set object_type
     local specialTypes = {
       "Video Probe",
       "Interdictor",
       "Blockade",
       "Automated Laser Turret",
       "Space Mine",
       "Push Pulse"
     }
     for _, specialType in ipairs(specialTypes) do
       if potentialName == specialType then
         scanData.object_type = specialType
         break
       end
     end

     -- Now enable the scan triggers to process the scan data
     EnableTriggerGroup("scan_triggers", true)
     EnableTrigger("prescan_potential_name", false)
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
   -- Only process if we're in an active scan
   if not inActiveScan then
     return
   end
   local dashCount = string.len("%0")

   -- Check if we have a potential object name to confirm (for multi-object scans)
   if scanData.potential_object_name then
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
   local useFormatting = scanData.force_formatting or false
   if not useFormatting and config and config.get_option then
     local opt = config:get_option("scan_formatting")
     if opt and opt.value then
       useFormatting = (opt.value == "yes")
     end
   end

   -- Check if this is the ending dash line (matches first dash line length)
   if firstDashLength and dashCount == firstDashLength then
     -- This is the ending dash line - scan is complete
mplay("ship/computer/scan", "other")
     -- Always generate and store formatted output
     local formatted = formatScanOutput()

     -- Store in scan channel buffer (but not when filtering)
     if not scanFiltering then
       channel("scan", formatted, {"scan"})
     end

     -- Output formatted version if useFormatting is enabled (but not when filtering)
     if useFormatting and not scanFiltering then
       print(formatted)
       speech_interrupt(formatted)
     end

     -- Check if we were filtering and the field wasn't found
     if scanFiltering and not scanData.field_found then
       local message = "I couldn't find a field named '" .. scan .. "'."
       print(message)
       speech_interrupt(message)
       mplay("ship/computer/noScan", "notification")
     end

     --local shouldGag = scanFiltering or useFormatting
     -- End the scan
     endScan()
     --if shouldGag then
       -- Gag the line
     --else
--       print("%0")
     --end
   elseif scanFiltering or useFormatting then
     -- Gag all dash lines when formatting/filtering
   else
     print("%0")
   end
  </send>
  </trigger>

  <!-- Capture special object types: Video Probe, Interdictor, Blockade, etc -->
  <trigger
   enabled="n"
   group="scan_triggers"
   match="^(Hull Damage|Average Component Damage|Occupancy|Weapons|Power|Cargo|Coordinates|Classification|Natural Resources|Atmospheric Composition|Composition|Integrity|Identifiable Power Sources|IFF|Surface Conditions|Hostile Military Occupation|Size|Type|Distance|Starships|Damage|Orbiting): (.+?)$"
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
     local useFormatting = scanData.force_formatting or false
     if not useFormatting and config and config.get_option then
       local opt = config:get_option("scan_formatting")
       if opt and opt.value then
         useFormatting = (opt.value == "yes")
       end
     end

     local scanInterruptMode = "off"
     if config and config.get_option then
       local opt = config:get_option("scan_interrupt")
       if opt and opt.value then
         scanInterruptMode = opt.value  -- "starships", "everything", or "off"
       end
     end

     if not (scanFiltering or useFormatting) and scanInterruptMode ~= "off" then
       local shouldInterrupt = false

       if scanInterruptMode == "everything" then
         shouldInterrupt = true
       elseif scanInterruptMode == "starships" then
         -- Check if it's a starship (only interrupt for starships)
         local isStarship = scanData.weapons or scanData.hull_damage
         shouldInterrupt = isStarship
       end

       if shouldInterrupt then
         local coords = format_coords(fieldValue)

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
   local useFormatting = scanData.force_formatting or false
   if not useFormatting and config and config.get_option then
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
       if fieldName == "Coordinates" then
         speech_interrupt(format_coords(fieldValue))
       else
         speech_interrupt(fieldValue)
       end
       mplay("ship/computer/scan", "other")
       if fieldName == "Distance" then
         if fieldValue == "1" then
           mplay("ship/computer/oneUnit", "notification")
         end
       end
	     	 if fieldName == "Starships" then
          mplay("ship/computer/starship", "notification")
end          
       scanData.field_found = true
      end
          elseif useFormatting then
     -- Formatting mode: gag all fields, output formatted line at end
     if fieldName == "Distance" then
       if fieldValue == "1" then
        mplay("ship/computer/oneUnit", "notification")
       end
     end
  	 if fieldName == "Starships" then
          mplay("ship/computer/starship", "notification")
end          
     else
     -- Normal mode: show all fields
     print(fieldName .. ": " .. fieldValue)
     if fieldName == "Distance" then
       if fieldValue == "1" then
         mplay("ship/computer/oneUnit", "notification")
       end
      end
	  	     	 if fieldName == "Starships" then
          mplay("ship/computer/starship", "notification")
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
   match="^General sector report for (.+)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   endScan()
   print("%1	")
   mplay("ship/computer/scan")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="starmap"
   match="^(?:Galactic Coordinates: \(.+?\)|(?:\w+ Space|Midway Point|Sector \d+|\w+ Sector): .+? \(.+?\)|a .+? starship simulator \(.+?\))\s?(?:\[Outside (Communications Range|Local Space)\])?\s?(\[(Explored|Unexplored)\])?$"
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
   enabled="n"
   group="starmap"
   match="^([A-Z][A-Za-z\s]+): (.+)$"
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
      -- Check if we should show this match based on nearestIndex
      local shouldShow = true
      if nearestIndex then
       -- Only show if this is the Nth match we want
       shouldShow = (matches == nearestIndex)
      end -- if nearestIndex

      if shouldShow then
       print (Trim(output))

       -- mplay a sound for range
       if range == 0 and v.distance == 1 then
        range = 1
        mplay("ship/computer/oneUnit", "other")
       end -- range

       -- If we have a nearestIndex, stop after showing this match
       if nearestIndex and matches == nearestIndex then
        break
       end -- if nearestIndex
      end -- if shouldShow
     end -- if output
    end -- for loop

    -- delete classFilter if set and print match count
    if classFilter then
     if not nearestIndex then
      print (matches, " Matches.")
     elseif nearestIndex and matches &lt; nearestIndex then
      -- User requested Nth match but there weren't enough matches
      print ("Only found " .. matches .. " match(es).")
     end -- if not nearestIndex
     classFilter = nil
    end -- if classFilter

    -- Reset nearestIndex flag
    if nearestIndex then
     nearestIndex = nil
    end -- if nearestIndex

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
   ignore_case="y"
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
   match="^sc([acdhilmnoprstuwyz]|\.help)(?:\s+(.+))?$"
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

  <!-- Scan with forced formatted output -->
  <alias
   enabled="y"
   group="computer"
   match="^scu$|^scu\s+(.+)$"
   regexp="y"
   send_to="12"
   sequence="50"
  >
  <send>
   -- Trigger a new scan with forced formatting mode
   shipscan("%1", nil, true)
  </send>
  </alias>

  <!-- Nearest ship by class filter - must come before general starmap alias -->
  <alias
   enabled="y"
   group="starmap"
   match="^smc\s+(?:(\d+)\.)?(\w+)$"
   regexp="y"
   send_to="12"
   sequence="50"
  >
  <send>
   -- Parse optional index (e.g., "2.muz" or just "muz")
   local index = "%1"
   local className = "%2"

   -- Set up nearest-only class filter
   searchingScan = true
   scan = "Starship"
   classFilter = string.lower(Trim(className))

   -- Set which match to show (default to 1 if not specified)
   if index ~= "" then
    nearestIndex = tonumber(index)
   else
    nearestIndex = 1
   end

   Execute("starmap")
  </send>
  </alias>

  <alias
   enabled="y"
   group="starmap"
   match="^sm([AabCdDeEfijlLmMopPrstTuwxyY]|\.help|\.count)(\s\w+)?$"
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
    print("- smc [class name] to show only the nearest ship matching that class.")
    print("- smc [N].[class name] to show the Nth nearest ship matching that class.")
    return 0
   elseif ("%1" == ".count") then
    count_ships = true
   elseif ("%1" == "c" and "%2" == "") then
    -- smc without arguments should be sent to the game
    return Send("smc")
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
   endScan()
  </send>
  </alias>

</aliases>
]=])