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

ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="computer"
   match="^(Hull Damage|Average Component Damage|Occupancy|Weapons|Power|Cargo|Coordinates|Classification|Natural Resources|Atmospheric Composition|Composition|Integrity|Identifiable Power Sources|IFF|Surface Conditions|Hostile Military Occupation|Size|Type|Distance): (.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  sequence="100"
  >
  <send>
   if "%1" == "Distance" then
    mplay("ship/computer/scan", "other")
   if "%2" == "1" then
     mplay("ship/computer/oneUnit", "notification")
    end -- nested if
   end -- if

   -- Track last scanned coordinates and update status bar
   if "%1" == "Coordinates" then
     lastScannedCoords = "%2"
     local coords = string.gsub(lastScannedCoords, "[()]", "")  -- Strip parentheses
     infobar("scan", "Scan: " .. coords)

     -- Auto-interrupt TTS on coordinates with delay
     if config:get_option("scan_interrupt").value == "yes" then
       local coords = string.gsub("%2", "[()]", "")  -- Strip parentheses

       -- Use coroutine for delay
       local wait = require("wait")
       wait.make(function()
         wait.time(0.1)  -- Wait 100ms
         Execute("tts_interrupt " .. coords)
       end)
     end -- if scan_interrupt
   end -- if coordinates

   if (not searchingScan) then
     return print("%0")
    end -- if

   if scan == "%1" then
    print("%1: %2")
    speech_interrupt("%2")
    scan = nil
   end -- if
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
  <alias
   enabled="y"
   group="computer"
   match="^sc([acdghilmnoprstuvwyz]|\.help)(\s.*)?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == ".help" then
    local tprint = require ("tprint")
    Note("Valid switches:")
    tprint(scantable)
    return 0
   end -- if help

   searchingScan = true

   scan = string.gsub("%1", "%a+",
    function(letter)
     return scantable[letter]
    end -- function
   ) -- scan 

   Execute ("scan %2")
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

</aliases>
]=])