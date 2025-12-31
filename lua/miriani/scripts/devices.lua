-- @module devices
-- Device sounds and notifications

-- Sector name to number mapping table (from VIP Mud soundpack)
sector_numbers = {
  ["Central Jumpgate Hub"] = 0,
  ["Satus"] = 1,
  ["Ono"] = 2,
  ["Harboria"] = 3,
  ["Savius"] = 4,
  ["Stallax"] = 5,
  ["Ascension"] = 6,
  ["Narth Polus"] = 7,
  ["Intrepid"] = 8,
  ["Autumn"] = 9,
  ["Shivaldi"] = 10,
  ["Universal End"] = 11,
  ["Bellerophon"] = 12,
  ["Triskaideka"] = 13,
  ["Interlition"] = 14,
  ["Miriani"] = 15,
  ["Expedocious"] = 16,
  ["Groombridge"] = 17,
  ["Omnivincere"] = 18,
  ["Venitia"] = 19,
  ["Tartarus"] = 20,
  ["Solaris"] = 21,
  ["Barnard's Star"] = 22,
  ["Apophyllite"] = 23,
  ["Alliance High Guard Command"] = 24,
  ["Pegasus"] = 25,
  ["Polaris"] = 26,
  ["Ophiuchus"] = 27,
  ["Kerensky"] = 28,
  ["Malta"] = 29,
  ["Outreach"] = 30,
  ["Porta"] = 31,
  ["Infinitus Astrum"] = 32,
  ["Adaukerisicka"] = 33,
  ["Strages"] = 34,
  ["Casus"] = 35,
  ["Dombrowski"] = 36,
  ["Perspicuus Astrum"] = 37,
  ["Lacuna"] = 38,
  ["Lucksburg"] = 39,
  ["Vetus Fragminis"] = 40,
  ["Omega Sector"] = 115,
}

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   name="MessageBoardNewMessage"
   group="devices"
   match="^A.+message board reader beeps quietly, indicating to you that there is a new message.+\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/newPost")</send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardNewMessageDetailed"
   group="devices"
   match="^A message board reader beeps quietly, indicating to you that there is a new message in (.+?)\. It was posted by (.+?) with the subject (.+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("device/newPost")
   print_color({"New board post in %1. Posted by %2: Subject: ", "default"}, {"%3", "board"})
   channel(name, "New board post in %1. Posted by %2: Subject: %3", {"board"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardToggle"
   group="devices"
   match="^A.+message board reader will (now|no longer) notify you of new messages\.$"
   regexp="y"
   send_to="12"
  >
  <send>if "%1" == "now" then
    mplay("miriani/device/activate")
  else
    mplay("miriani/device/deactivate")
  end
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="DeviceActivateDeactivate"
   group="devices"
   match="^You (?:re)?(activate|deactivate) .+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/%1", "communication")</send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardUnreadPosts"
   group="devices"
   match="^(There are new messages in.+\.|A.+message board reader beeps urgently, notifying you that there are new messages in .+\.)$"
   regexp="y"
   send_to="12"
  >
  <send>play("miriani/device/UnreadPosts.ogg")</send>
  </trigger>

  <trigger
   enabled="y"
   name="FlightControlScanner"
   group="devices"
   match="^(?:A|From).* flight control scanner \w+, &quot;(.+?)&quot;$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   local scanner_name = GetVariable("fc_scanner_name") or "flight control"
   local message = "%1"
 
   local clean_message = message:gsub("^A .+flight control scanner.+announces, ", ""):gsub("^From .* flight control scanner .*, ", "")

   -- If fc_sector_numbers option is enabled, substitute sector names with numbers
   if config:get_option("fc_sector_numbers").value == "yes" then
     -- Try to find and replace sector names with numbers
     for sector_name, sector_num in pairs(sector_numbers) do
       -- Pattern 1: "Flight control in [sector name]"
       clean_message = clean_message:gsub("Flight control in " .. sector_name, "Flight control in Sector " .. sector_num)
       -- Pattern 2: "[ship] to [sector name] flight control"
       clean_message = clean_message:gsub("to " .. sector_name .. " flight control", "to sector " .. sector_num .. " flight control")
     end
   end

   print_color({clean_message, "flight"})
   channel("flight", clean_message, {"flight"})

   if string.find (clean_message, "we detect.+Ontanka") then
     mplay ("comm/praelorInbound", "communication")
   end -- if praelor activity
   mplay ("comm/flight", "communication")

   -- Clear the stored scanner name
   DeleteVariable("fc_scanner_name")
  </send>
  </trigger>

  <trigger
   enabled="y"
   match="^.+ beeps quietly, indicating that there (is|are) (new files|a new file) to import\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/lore/import")</send>
  </trigger>

  <trigger
   enabled="y"
   name="LoreComputerPrint"
   group="devices"
   match="^Several short bleeps emit from .+ Lore computer.+followed by .+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/lore/Print", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   name="LoreTechTracking"
   group="devices"
   match="^Via the TransLink network, the LoreTech device &quot;(.+?)&quot; reports current location pinpointed (.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("device/lore/track")
   print_color({"%1", "computer"}, {" %2", "default"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="LoreIncomingFile"
   group="devices"
   match="^Your (.+?) suddenly beeps quietly, indicating a new incoming file\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/lore/file")</send>
  </trigger>

  <trigger
   enabled="y"
   name="LoreTransLinkActivated"
   group="devices"
   match="^(.+?) beeps (quietly|twice in rapid succession), indicating that its TransLink tracking functionality has been activated(?:.+?)?\."
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%2" == "quietly" then
    mplay ("device/lore/beep")
   else
    mplay ("device/lore/unauthTrack")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="LoreTrackingDenied"
   group="devices"
   match="^Tracking authorization refused from LoreTech device &quot;.+?\.&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/lore/deny")</send>
  </trigger>

  <trigger
   enabled="y"
   name="LicenseCombatPointsInRange"
   group="devices"
   match="^You access .+ and note you have ([0-9,.]+) license points? and ([0-9,.]+) combat points?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Parse current point values
   local license_pts = tonumber((string.gsub("%1", ",", "")))
   local combat_pts = tonumber((string.gsub("%2", ",", "")))

   -- Calculate differences
   local license_diff = 0
   local combat_diff = 0

   local last_license = GetVariable("last_license_points")
   if last_license then
    local last_lp = tonumber(last_license)
    if last_lp then
     license_diff = license_pts - last_lp
    end
   end

   local last_combat = GetVariable("last_combat_points")
   if last_combat then
    local last_cp = tonumber(last_combat)
    if last_cp then
     combat_diff = combat_pts - last_cp
    end
   end

   -- Store current values for next time
   SetVariable("last_license_points", tostring(license_pts))
   SetVariable("last_combat_points", tostring(combat_pts))

   -- Play sound
   mplay("device/lore/track")

   -- Build output with original text
   local output = "%0"

   -- Append difference if enabled and non-zero
   if config:get_option("show_point_calculations").value == "yes" then
    if license_diff ~= 0 or combat_diff ~= 0 then
     output = output .. " " .. string.format("The difference since last check is %.1f license points and %.1f combat points.", license_diff, combat_diff)
    end
   end

   print(output)
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="LicenseCombatPointsOutOfRange"
   group="devices"
   match="^You access.+ and note you had ([0-9,.]+) license points? and ([0-9,.]+) combat points?\. This information was current as of (.+?)\. No new information can be obtained until you return to communications range\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Parse current point values (out-of-range)
   local license_pts = tonumber((string.gsub("%1", ",", "")))
   local combat_pts = tonumber((string.gsub("%2", ",", "")))

   -- Calculate differences
   local license_diff = 0
   local combat_diff = 0

   local last_license = GetVariable("last_license_points")
   if last_license then
    local last_lp = tonumber(last_license)
    if last_lp then
     license_diff = license_pts - last_lp
    end
   end

   local last_combat = GetVariable("last_combat_points")
   if last_combat then
    local last_cp = tonumber(last_combat)
    if last_cp then
     combat_diff = combat_pts - last_cp
    end
   end

   -- Store current values for next time
   SetVariable("last_license_points", tostring(license_pts))
   SetVariable("last_combat_points", tostring(combat_pts))

   -- Play sound
   mplay("device/lore/track")

   -- Build output with original text
   local output = "%0"

   -- Append difference if enabled and non-zero
   if config:get_option("show_point_calculations").value == "yes" then
    if license_diff ~= 0 or combat_diff ~= 0 then
     output = output .. " " .. string.format("The difference since last check is %.1f license points and %.1f combat points.", license_diff, combat_diff)
    end
   end

   print(output)
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="InternalCamera"
   group="devices"
   match="^(\(.+)\) (.+)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Filter out context messages from spellcheck
   if string.sub("%1", 1, 9) == "(Context:" then
     print("%0")
     return
   end
   mplay ("device/camera")
SetVariable("last_camera_line", "%2")
     if config:get_option("internal_camera").value == "no" then
    replicate_line("%2")
   end -- if filtering camera
   channel ("camera", "%0", {"camera"})
</send>
  </trigger>

  <trigger
   enabled="y"
   name="ExternalCamera"
   group="devices"
   match="^\[From Outside\] (.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("device/camera")
   SetVariable("last_camera_line", "%2")
if config:get_option("external_camera").value == "no" then
    replicate_line("%1")
   end -- if
   channel("camera", "%0", {"camera"})
     </send>
  </trigger>

  <trigger
   enabled="y"
   name="DroidCameraFeed"
   group="devices"
   match="^From your droid's camera, you see[.]{3}$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   cameraFeed = true
   mplay ("device/camera")
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="Snapshot"
   group="devices"
   match="^.+? takes? a snapshot of .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/snapshot")</send>
  </trigger>

  <trigger
   enabled="y"
   name="RadioDetect"
   group="devices"
   match="^A small handheld radio receiver beeps twice, indicating the detection of a radio transmission\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/radio/detect")</send>
  </trigger>

  <trigger
   enabled="y"
   name="RadioConnect"
   group="devices"
   match="^.+? plugs? a small handheld radio receiver into a console.(?: It beeps in confirmation and begins recording\.)?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/radio/connect")</send>
  </trigger>

  <trigger
   enabled="y"
   name="RadioDisconnect"
   group="devices"
   match="^A small handheld radio receiver gives a series of beeps and automatically unplugs from the console\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/radio/disconnect")</send>
  </trigger>

  <trigger
   enabled="y"
   name="DroidShutdown"
   group="devices"
   match="^(?:\w+ the droid|An internal stun turret) suddenly (?:slumps|begins) (?:over|to) (?:as \w+ mechanical systems begin to shut|power) down\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/shutdown")</send>
  </trigger>

  <trigger
   enabled="y"
   name="DroidPowerUp"
   group="devices"
   match="^(?:\w+ the droid|An internal stun turret) suddenly powers back up\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/powerUp")</send>
  </trigger>

  <trigger
   enabled="y"
   name="PlanetarySurveyor"
   group="devices"
   script="gagline"
   match="^You activate .+? planetary surveyor and begin scanning the area\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
   mplay("device/surveyer")
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="DestinationFinder"
   group="devices"
   match="^(.+?)\s+(.+?)\s+(\d+, \d+, \d+)\s*$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   -- Capture destination finder coordinates for infobar
   local destination = "%1"
   local sector = "%2"
   local coords = "%3"

   -- Skip the header line
   if destination ~= "Destination" then
    infobar("dest", "Dest: " .. coords)
   end
  </send>
  </trigger>

<trigger
   enabled="y"
   group="misc"
   script="gagline"
   match="^You begin to merrily float off into the great unknown\.$"
   regexp="y"
   omit_from_output="y"
   send_to="12"
  >
  <send>mplay("device/jetStart")</send>
  </trigger>
<trigger
   enabled="y"
   group="misc"
   script="gagline"
   match="^You arrive at your new coordinates\.$"
   regexp="y"
   omit_from_output="y"
   send_to="12"
  >
  <send>mplay("device/jetEnd")</send>
  </trigger>

  </triggers>
]=])
