
ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="misc"
   match="^Username:$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
  if GetVariable("logged_in") == "0" then
    Send("REGISTER_SOUNDPACK "..registry.." | "..VERSION.."")
  mplay("music/theme", "other")
-- Auto login functionality
if config:get_option("auto_login").value == "yes" then
  local username = config:get_option("auto_login_username").value
  local password = config:get_option("auto_login_password").value
  local menu_number = 1

  if username and username ~= "" then
    if password and password ~= "" then
      -- Send connect command with username, password, and menu_hnumber
      Send("connect " .. username .. " " .. password .. " " .. menu_number .. "")

      if config:get_option("debug_mode").value == "yes" then
        notify("info", "Auto login: Sent credentials for " .. username)
      end
    else
      -- Just send the username if no password is set
      Send(username)
      
      if config:get_option("debug_mode").value == "yes" then
        notify("info", "Auto login: Sent username " .. username .. " (no password configured)")
      end
    end
  else
    if config:get_option("debug_mode").value == "yes" then
      notify("info", "Auto login enabled but no username configured")
    end
  end
end
end
  </send>
  </trigger>

  <trigger
   enabled="y"
     group="misc"
   match="^(Logged in\!|\*{3} (?:Connected|Redirecting (?:old|new) connection to this port) \*{3})$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>EnableTrigger("url_catcher", true)
  SetVariable("logged_in", 1)
  register()
endScan()</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^(([A-Z][a-z]+ ?)+) (?!stands?|sits?)(\w+) (?:in from the .+?|into the .+?|through the .+?|north|northeast|east|southeast|south|southwest|west|northwest|up|down|out)(?: on a .+?| of the ship)?\.$"
   regexp="y"
   omit_from_output="y"
   keep_evaluating="y"
   send_to="14"
   sequence="100"
  >
  <send>foundstep, footstep = false, string.gsub ("%3", "%a+",
    function (walk)
     return walkStyle[walk]
    end -- function replace walk
    ) -- string replacement

   for k,v in pairs (walkStyle) do
    if footstep == v then
     foundstep = true
    break
          end -- if
   end -- for loop

   if (not foundstep) then
     print("%0")
   elseif "%1" ~= "You" then
    -- others move around you.
    print("%0")
    playstep ()
   else
    -- Your movement will be picked up by room_title
    -- But still print it!
    endScan()
    print("%0")
    -- Play bounce social sound if bouncing
    if footstep == "bounce" then
     mplay("social/neuter/bounce", "socials")
    end -- if bounce
   end -- if movement</send>
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
  <send>mplay("steps/jet")</send>
  </trigger>

  <trigger
   enabled="y"
   name="room_title"
   script="playstep"
   group="misc"
   keep_evaluating="y"
   match="^\[(.+?)\]( (\((indoors|outdoors)\))? ?(\(([\d, ]+)\))? ?(\((hostile environment|aquatic environment)\))? ?(\(riding a .+?\))?)?$"
     regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   room = "%0"
   cameraFeed = nil

   if config:get_option("debug_mode").value == "yes" then
     notify("info", string.format("room_title trigger: room='%s', environment=%s, has_digsite=%s, has_store=%s",
       tostring(room),
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

  </send>
  </trigger>


  <trigger
   enabled="y"
   group="misc"
   match="^(You can't go that way|That exit appears to be blocked|[A-Z][A-Za-z0-9\s,-]+ is closed)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   <send>
   if environment and environment.name then
    mplay ("wrongExit/"..environment.name)
   end -- if environment
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][A-Za-z0-9\s,;-]+ to the \w+ slides (open|closed) with a hiss\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/door%1")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^A keypad beeps negatively\. The door doesn't budge\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/deny")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You press a few keys on a keypad\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/keyboard")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\[Type lines of input; use `\.' to end\.\]$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/paste")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\[Type a line of input or '@abort' to abort the command\.\]$"
   regexp="y"
   send_to="12"
   sequence="75"
  >
  <send>mplay("misc/prompt")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="\[Enter &quot;yes&quot; or &quot;no&quot;\]$"
   regexp="y"
   send_to="12"
   sequence="75"
  >
  <send>mplay("misc/prompt")</send>
  </trigger>


  <trigger
   enabled="y"
   group="misc"
   match="^>> Command Aborted <<$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/cancel")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Invalid \w+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/cancel")
  endScan()</send>
  </trigger>


  <trigger
   enabled="y"
   group="misc"
   match="^(\(.+\)) (.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  sequence="100"
  >
  <send>
   -- Filter out context messages from AI
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
   group="misc"
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
   group="misc"
   match="^A small handheld radio receiver beeps twice, indicating the detection of a radio transmission\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/radio/detect")</send>
  </trigger>
<trigger
   enabled="y"
   group="misc"
   match="^.+? plugs? a small handheld radio receiver into a console.(?: It beeps in confirmation and begins recording\.)?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/radio/connect")</send>
  </trigger>
<trigger
   enabled="y"
   group="misc"
   match="^A small handheld radio receiver gives a series of beeps and automatically unplugs from the console\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/radio/disconnect")</send>
  </trigger>
<trigger
   enabled="y"
   group="misc"
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
   group="misc"
   match="^(I don't understand that|You should stand up first)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/command")
   endScan()
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   script="gagline"
   match="^The door opens and allows [\w\s]+ to pass\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("misc/bioDoor")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][\w\s]+? (stand|sit|pull|leap)(?:s)? (?:(?:[A-Z]?[a-zA-Z\s]+ )?to \w+ feet|up|feet|down(?: (?:on|at) .+?)?)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local fName = "%1"
   if string.find (fName, "pull")
 or string.find (fName, "leap") then
    fName = "stand"
   end -- if

   mplay ("misc/"..fName)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
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
   group="misc"
   match="^Your (.+?) suddenly beeps quietly, indicating a new incoming file\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/lore/file")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
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
   group="misc"
   match="^Tracking authorization refused from LoreTech device &quot;.+?\.&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/lore/deny")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^A small console nearby flashes for your attention\. .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/mail")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][\w\s]+? (coalesces into being nearby|suddenly steps from the background)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/hosts/arrive")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][\w\s]+? (dissolves into billions of constituent particles and disperses into a hitherto unnoticed breeze|suddenly seems to disappear into the background)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/hosts/leave")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Digging through your belongings reveals no such thing\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/notFound")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? suddenly (flickers into existence|vanishes)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == "vanishes" then
    mplay ("device/simulator/end")
   else
    mplay ("device/simulator/start")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You (?:find yourself )?disconnect(?:ed)? from (?:your avatar|the simulator as the simulated starship is destroyed)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/simulator/end")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\*{3} You have entered a starship simulator\. To exit, please type END\. \*{3}$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/simulator/start")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][\w\s]+? crumple(?:s)? .+? and throw(?:s)? it away\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("misc/crumble")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][\w\s]+? (?:push(?:es)?|pull(?:s)?|flip(?:s)?) a (?:heavy|small) (?:switch,|lever) (?:away from .+?,|towards? .+?,)?.+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/lever")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? press(?:es)? a (?:large (?:red|green|purple|yellow) (?:reset)?\s?button|button, calling up the damage report|large button embossed with the stylized image of a mailbox|button to cancel the current autopilot program|button to scan for recent wormhole activity|button on an? &quot;.+?&quot; key|large button marked CYCLE|button to deploy the starship's asteroid anchor|conveniently placed button on the wall).*?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/keyPress")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Game Change: .+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/change")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? (?:begins? following .+?|takes? control of .+? group|gestures? .+?, (?:who|which) promptly joins? (?:your|.+?'s) group)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/joins")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^[A-Z][\w\s]+? (?:indicate(?:s)?|inform(?:s)?|leave(?:s)?) .+(?:group|that \w+ no longer wish(?:es)? (?:\w+|for \w+?) to follow \w+)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/disband")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You (?:receive|earn) a?\s?[0-9,.]+?[0-9]{2} credits? .+?\."
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/cash")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^(?:\w+ the droid|An internal stun turret) suddenly (?:slumps|begins) (?:over|to) (?:as \w+ mechanical systems begin to shut|power) down\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/shutdown")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^(?:\w+ the droid|An internal stun turret) suddenly powers back up\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/powerUp")</send>
  </trigger>

  <trigger
   name="interruptFollow"
   group="misc"
   match="^You follow [A-Z][a-z]+[\s\w]+ (north|south|east|west|northeast|northwest|southeast|southwest|up|down|into the airlock|into|out|through)(.*)\.$"
   regexp="y"
   enabled="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Map direction words to sound file names
   local direction_map = {
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
     through = "go"
   }

   local direction = string.lower("%1")
   local sound_file = direction_map[direction]

   if sound_file and config:get_option("follow_direction_sounds").value == "yes" then
     -- Play the direction sound with interrupt (interrupts previous direction announcements)
     mplay("misc/directions/" .. sound_file, "direction", true)
   end -- sound
   if config:get_option("follow_interrupt").value == "yes" then
     Execute("tts_stop")
   end -- follow interrupt
   print("%0")</send>
  </trigger>

  <trigger
   name="interruptDrag"
   group="misc"
   match="^(.+?) drags you (north|south|east|west|northeast|northwest|southeast|southwest|up|down|into|out|through)(.*)\.$"
      enabled="y"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Map direction words to sound file names
   local direction_map = {
     north = "north",
     south = "south",
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
     through = "go"
   }

   local direction = string.lower("%2")
   local sound_file = direction_map[direction]

   if sound_file and config:get_option("follow_direction_sounds").value == "yes" then
     -- Play the direction sound with interrupt (interrupts previous direction announcements)
     mplay("misc/directions/" .. sound_file, "direction", true)
   end -- sound
   if config:get_option("follow_interrupt").value == "yes" then
     Execute("tts_stop")
   end
   print("%0")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You remove (?:part of)?\s?your .+? (?:from a .+? storage bag)?\s?and (.+?)\."
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == "put it on" then
    return mplay("device/suitOn")
   else
    return mplay("device/suitOff")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You access.+portable point unit and note you have ([0-9,.]+) license points? and ([0-9,.]+) combat points?\.$"
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
   group="misc"
   match="^Your private organization has ([0-9,.]+) inter-organization cooperation points?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Parse org points
   local org_pts = tonumber((string.gsub("%1", ",", "")))
   local org_diff = 0

   -- Calculate difference if we have a previous value
   local last_org = GetVariable("last_org_points")
   if last_org then
    local last_op = tonumber(last_org)
    if last_op then
     org_diff = org_pts - last_op
    end
   end

   -- Store current value for next time
   SetVariable("last_org_points", tostring(org_pts))

   -- Build output with original text
   local output = "%0"

   -- Append difference if enabled and non-zero
   if config:get_option("show_point_calculations").value == "yes" and org_diff ~= 0 then
    output = output .. " " .. string.format("The difference since last check is %.1f Org Points.", org_diff)
   end

   print(output)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You access.+portable point unit and note you had ([0-9,.]+) license points? and ([0-9,.]+) combat points?\. This information was current as of (.+?)\. No new information can be obtained until you return to communications range\.$"
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
   group="misc"
   match="^Additionally, your private organization had ([0-9,.]+) inter-organization cooperation points?\. This information was current as of (.+?)\. No new information can be obtained until you return to communications range\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Parse org points (out-of-range continuation)
   local org_pts = tonumber((string.gsub("%1", ",", "")))
   local org_diff = 0

   -- Calculate difference if we have a previous value
   local last_org = GetVariable("last_org_points")
   if last_org then
    local last_op = tonumber(last_org)
    if last_op then
     org_diff = org_pts - last_op
    end
   end

   -- Store value for next time
   SetVariable("last_org_points", tostring(org_pts))

   -- Build output with original text
   local output = "%0"

   -- Append difference if enabled and non-zero
   if config:get_option("show_point_calculations").value == "yes" and org_diff ~= 0 then
    output = output .. " " .. string.format("The difference since last check is %.1f Org Points.", org_diff)
   end

   print(output)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Please do not enter so many commands at once\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/spam", "notification")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^(?:[A-Z][a-z\s]+)+ (?:has just)?\s?given? (?:you)?\s?\d+ tradesman certificates?\s?(?:to .+?)?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/certificate")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? turns? .+? pages?[ .].+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/page")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? press(?:es)? a button on the wall to summon the lift\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/liftButton")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^The lift doors slide open with a hiss\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/liftOpen")</send>
  </trigger>
  <trigger
   enabled="y"
   group="misc"
   match="^The lift (?:comes to a )?stops? and the doors slide open with a hiss\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay("misc/liftStop", "environment", 1, nil, nil, 1)
   mplay("misc/liftOpen")
   </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^The doors (?:slide )?closed? and the lift (?:begins to|continues) (?:move|moving) \w+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   liftroom = room
   mplay("misc/liftClose")
   mplay("misc/liftStart", "loop")
   mplay("misc/liftMoving", "environment", 1, nil, 1, 1)
   </send>
  </trigger>



  <trigger
   enabled="y"
   group="misc"
   match="^.+? suddenly loses? \w+ footing and falls? to the ground\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/ftlFall")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\*{3} .+? has arrived to answer your plea for help\. \*{3}$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/hosts/assist")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\w+ the droid punches .+? in the face\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/droidHit")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? jumps? in the \w+ and begins? to swim\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/splash")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? splash(?:es)? around in .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/splash")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? (?:falls?|crash(?:es)?) to the water with a splash!$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/splash")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? push(?:es)? .+? into the water!$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/splash")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? push(?:es)? .+?'s head under the water in an attempt to drown .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/drown")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? (?:emerge|burst)s? from (?:beneath the |under)water(?: and (?:takes? a deep breath(?: after deciding to spare \w+ life)?|gasps? for air))?\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("misc/splash")

   if (not ambianceFile) 
   and environment then
     replicate_line(environment.line)
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You (?:take a deep breath, )?dive underwater, and begin to swim\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("ambiance/underwater", "environment", 1, nil, 1, 1, 0.5)
   ambianceFile = nil
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You go underwater in an attempt to drown yourself\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("ambiance/underwater", "environment", 1, nil, 1, 1, 0.5)
   ambianceFile = nil
  </send>
  </trigger>


  <trigger
   enabled="y"
   group="misc"
   match="^.+? pushes your head under the water and you struggle to breathe\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("ambiance/underwater", "environment", 1, nil, 1, 1, 0.5)
   ambianceFile = nil
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? triumphantly raises? .+? into the air, and with little fanfair, abruptly upends? the contents all over .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/dumpDrink")</send>
  </trigger>
  <trigger
   enabled="y"
   group="misc"
   match="^.+? pulls? a series of straps around .+? and securely buckles? \w+ into \w+? seat\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/buckle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? releases? the buckle of .+? seatbelt, causing it to retract back into the chair\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/unbuckle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? takes? a snapshot of .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/snapshot")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^A .*?message board reader .*?beeps urgently, notifying you that there (?:are|is a) new messages? in .+?\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("device/pendingBoard", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? winds? up and sends? a ball down the lane\.(?:  Good luck\.)?$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/skeballRoll", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^A .+? skeeball machine announces, &quot;(?:.+? has \d+ points? with \d+ balls? remaining|Points: \d+\.  Balls left: \d+)\.&quot;$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/skeballScore", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Game over\. .+? score (?:is|was) \d+(?: points?\.)?$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/skeballEnd", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You suddenly feel more skilled in .+?!$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/skillup", "notification")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^The doors to the pod close and the pod slowly begins .+?\. A hatch closes behind the pod as it .+?\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/pod", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You key a command into your credit unit and donate \d*\.\d+ credits to .+?\. Every fraction of a credit helps!$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/discardCash", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? slides? (open|close) the heavy metal door to .+?\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/transport%1", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? steps? on to a small platform on the floor\. Sensing \w+ presence, a ring of lights along the perimeter of the circle light up as the platform (?:drops downward rapidly, holding your feet firmly in place|shoots upward|shoots (?:downward|upward) out of sight)\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
  >
   <send>mplay("misc/hgLift", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^A bright ring of light emerges from the (?:ceiling|floor) and comes to a halt. .+? steps off\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/hgLift", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Your .+? has been injured!$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/breakBone", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? flicks? .+? open and light it. (?:You|he|she|they|it) watch(?:es)? the flame dance for a moment before flicking it closed\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/flickLighter", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? (?:is dragged|drag .+?) (?:out of|into) the area(?: behind .+?)?\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/dragFollower", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? spins? a .+? coin .*?around on the floor\.$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/coinSpin", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? leans? over and drinks? noisily from .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/slirp")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? climbs? the stairs and leaves? the pool\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/waterSlosh")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? skin begins to mottel and deform as several Borg implants emerge\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/morph")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Bolts of lightning fork from .+?'s fingertips and envelop .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/shock")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? beeps quietly, indicating that there is a new file to import\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/lore/import")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\((?:Another )?([0-9]+) seconds? (stun time|roundtime)\.\)$"
   regexp="y"
   send_to="12"
  >
  <send>
   local time = tonumber("%1")
   local fade = 0.8

   if ("%2" == "stun time") then
    stuntime = stuntime + time

    if (not stunned) then
      stunned = true
      -- Stop current ambiance and environment sounds before playing heartbeat
      stop("ambiance")
      stop("environment")
      ambianceFile = nil
      mplay("ambiance/heartbeat", "environment", 1, nil, 1, 1, fade)
    end -- if

   else
    roundtime = roundtime + time
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^\(([0-9]+) seconds? stun time subtracted\.\)$"
   regexp="y"
   send_to="12"
  >
  <send>
   local num = tonumber("%1")
   if (stuntime) then
    stuntime = stuntime - num
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^In a fit of rage, .+? curls? \w+ face into a menacing snarl and hurls? .+? with all of \w+ might at .+? (?:Of course you're a terrible shot so it comes nowhere close to hitting the target, but rather smashes into the nearest wall and|where it misses by a mile and slams into the nearest wall,) shatter(?:s|ing) into a billion pieces\.(?: Good effort\.)?$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/shatter")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You receive [0-9,.]+ credits?, [0-9,.]+ points?, and [0-9,.]+ combat points? for the defense of .+?\.$"
  regexp="y"
   send_to="12"
  >
  <send>mplay("misc/cash")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? sits? down in the hot tub and relax(?:es)?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/tub")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? gets? out of the hot tub\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/waterSlosh")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^Teleporting you to .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/hosts/arrive")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^.+? turns? the faucets of .+? and water begins to fill the tub\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/fillBath")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^The water quickly drains out of .+?, leaving it empty\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/drainBath")</send>
  </trigger>


  <trigger
   enabled="y"
   group="misc"
   match="^A creepy man sitting in a black leather chair says, &quot;Hello, Fleemco\.&quot;$" 
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/strange")</send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
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
   group="misc"
   script="gagline"
   match="^The hatch refuses to accept your access code\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("misc/deny")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="misc"
   match="^You feel a tingly sensation and notice that you are not what you were!$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("misc/morph")
  </send>
  </trigger>



  <trigger
   enabled="y"
   group="misc"
   match="^.+? (?:yawns suddenly and collapses to the ground, asleep|drifts off to sleep)\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   -- Play yawn social (randomly choose male or female)
   local yawn_gender = (math.random(2) == 1) and "male" or "female"
   mplay("social/"..yawn_gender.."/yawn", "socials")
   -- Play collapse social (neuter has collapse sounds)
   mplay("social/neuter/collapse", "socials")
  </send>
  </trigger>
<trigger
   enabled="y"
   group="misc"
   match="^(.+) gives you (.+) (credit|credits)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
  mplay("misc/cash")
  </send>
  </trigger>

  <trigger
   enabled="y"
   match="^You snatch (.+) from the cold, cruel hands of space\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/artifacting/snatchArtifact")
   increment_counter("spatial_artifacts")
  </send>
  </trigger>
<trigger
   enabled="y"
   match="^You seem to have left .+ behind\!$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/leftPerson")</send>
  </trigger>
<trigger
   enabled="y"
   match="^.+ gives you a mysterious lump of coal\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/leftPerson")</send>
  </trigger>
<trigger
   enabled="y"
   match="^.+ removes? .+ from you\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/leftPerson")</send>
  </trigger>
  <trigger
   enabled="y"
   match="^(Announcement.+\:|Multi-line Announce).+$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("misc/hosts/announcement")</send>
  </trigger>
</triggers>
]=])


