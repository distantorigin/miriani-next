
ImportXML([=[

<triggers>
  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack[_ ](.+?)$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   keep_evaluating="y"
   send_to="14"
   sequence="50"
  >
  <send>channel("hooks", "%1", {"hooks"})</send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#px (.+?)$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   keep_evaluating="y"
   send_to="14"
   sequence="50"
  >
  <send>channel("hooks", "%1", {"hooks"})</send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack_pong$"
   omit_from_log="y"
   regexp="y"
   sequence="100"   
  >
  <send>#$#SOUNDPACK_PING_REPLY ms</send>
  </trigger>

  <trigger
   enabled="y"
   name="starship"
   group="hooks"
   script="set_environment"
   match="^#\$#soundpack environment starship (space|landed) \| (powered|unpowered) \| (hostile|safe) \| (light|dark) \| (indoors|outdoors) \| (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   </trigger>

  <trigger
   enabled="y"
   name="planet"
   group="hooks"
   script="set_environment"
   match="^#\$#soundpack environment planet (.+?) \| (hostile|safe) \| (light|dark) \| (indoors|outdoors) \| (.+?)$$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   </trigger>

  <trigger
   enabled="y"
   name="space"
   group="hooks"
   script="set_environment"
   match="^#\$#soundpack environment space \| (hostile) \| (light|dark) \| (outdoors)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   </trigger>

  <trigger
   enabled="y"
   name="station"
   group="hooks"
   script="set_environment"
   match="^#\$#soundpack environment station \| (hostile|safe) \| (light|dark) \| (indoors|outdoors) \| (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   </trigger>


  <trigger
   enabled="y"
   name="vehicle"
   group="hooks"
   script="set_environment"
   match="^#\$#soundpack environment vehicle (powered|unpowered) \| (landed|atmosphere)(?: \| (.+?))?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   </trigger>

  <trigger
   enabled="y"
   group="hooks"
   script="latency"
   match="^#\$#soundpack_lag (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   name="room"
   group="hooks"
   script="set_environment"
   match="^#\$#soundpack environment room \| (hostile|safe) \| (light|dark) \| (indoors|outdoors) \| (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   </trigger>

  <trigger
   enabled="y"
   group="hooks"
   script="playsocial"
   match="^#\$#soundpack social \| (\w+) \| (male|female|nonbinary)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   script="handle_emote_hook"
   match="^#\$#soundpack emote \| (male|female|nonbinary) \| (.+)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   script="check_emote_line_start"
   match="^(.+)$"
   regexp="y"
   send_to="12"
   sequence="1"
   keep_evaluating="y"
  >
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   script="check_emote_line_end"
   match="^(.+)$"
   regexp="y"
   send_to="12"
   sequence="9999"
   keep_evaluating="y"
  >
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack lore \| (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   lore = string.lower("%1")
   mplay("device/lore/access")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack video_feed$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/camera")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack status outdated$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>

   if config:get_option("update_sound").value == "yes" then
     mplay("misc/update", "notification", 1)
   end -- if

   if IsPluginInstalled(UPDATE_ID) then
    notify("info", "** Updater detected: You may type update to apply pending updates. **")
 
     if config:get_option("automatic_updates").value == "yes" then
        Execute("update quietly")
     end -- if
   else
     notify("important", "Missing updater.xml plugin. Unable to fetch updates.")
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack weapon \| (.+?) \| (.+?) \| (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local weapon = "%1"
   local action = "%2"
   local outcome = "%3"
   if string.find (weapon, "blaster") then
    weapon = "blaster"
   elseif string.find (weapon, "hollow") then
    weapon = "hollow"
   elseif string.find (weapon, "rifle") then
    weapon = "rifle"
   elseif string.find (weapon, "pistol") then
    weapon = "pistol"
   elseif string.find (weapon, "revolver") then
    weapon = "revolver"
   elseif string.find (weapon, "shotgun") then
    weapon = "shotgun"
   elseif string.find (weapon, "stun turret") then
    weapon = "turret"
   elseif string.find (weapon, "stun baton") then
    weapon = "stunBaton"
   elseif string.find (weapon, "correction club") then
    weapon = "stunBaton"
   else
    weapon = "defaultGun"
   end -- weapon type 


   if (outcome == "miss")
   or (outcome == "unloaded") then
     mplay("combat/"..outcome, "melee")
   else
     -- Handle melee weapons vs guns differently
     if (weapon == "stunBaton") then
       mplay("combat/"..weapon, "melee")
     else
       mplay("combat/guns/"..weapon, "melee")
     end

     -- Play action/outcome sound if it exists
     if action ~= "unknown" then
       mplay("combat/"..action.."/"..outcome, "melee")
     end
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#px say (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>notify("info", "%1", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#px starmap nearest (\d+).*$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local distance = tonumber("%1")
   if (distance == 1) then
     mplay("ship/computer/oneUnit", "notification")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#px version .+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   SetVariable("proxiani_enabled", 1)
   --register()
   EnableGroup("starmap", 0)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack fc \| (.+?)$"
   regexp="y"
   send_to="12"
   keep_evaluating="y"
   sequence="10"
  >
  <send>
   -- Store flight control scanner name for the upcoming message
   SetVariable("fc_scanner_name", "%1")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   script="handle_coordinates"
   match="^#\$#soundpack coordinates \| (\d+) \| (\d+) \| (\d+)$"
   regexp="y"
   send_to="12"
   omit_from_output="y"
   omit_from_log="y"
   keep_evaluating="y"
   sequence="100"
  >
  </trigger>

</triggers>
]=])

function playsocial(name, line, wildcards)
  local action = wildcards[1]
  local gender = wildcards[2]

  notify("important", "Hook received: " .. action .. " | " .. gender)

  pending_targeted_message = {
    action = action,
    actor = "You",
    timestamp = os.time()
  }
end

pending_emote_text = nil
suppress_emote_sounds = false

function handle_emote_hook(name, line, wildcards)
  local gender = wildcards[1]
  local emote_text = wildcards[2]
  pending_emote_text = emote_text
  channel("rp", emote_text, {"rp"})
end

function check_emote_line_start(name, line, wildcards)
  local current_line = wildcards[1]
  if pending_emote_text and current_line == pending_emote_text then
    suppress_emote_sounds = true
    pending_emote_text = nil
  end
end

function check_emote_line_end(name, line, wildcards)
  suppress_emote_sounds = false
end

function handle_coordinates(name, line, wildcards)
  local x = tonumber(wildcards[1])
  local y = tonumber(wildcards[2])
  local z = tonumber(wildcards[3])

  -- Store coordinates globally for other scripts to access
  current_coordinates = {
    x = x,
    y = y,
    z = z
  }

  -- Check if we've arrived at artifact coordinates
  if artifact_coordinates and artifact_coordinates.x == x and artifact_coordinates.y == y then
    mplay("activity/archaeology/artifactHere")
    -- Clear the artifact coordinates so we don't keep playing the sound
    artifact_coordinates = nil
  end

  -- Channel to hooks buffer if enabled
  channel("hooks", string.format("Coordinates: %d, %d, %d", x, y, z), {"hooks"})
end

