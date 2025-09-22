
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
        Execute("update --quiet")
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
   else
    weapon = "defaultGun"
   end -- weapon type 


   if (outcome == "miss")
   or (outcome == "unloaded") then
   mplay("combat/"..outcome, "melee")
   else
   mplay("combat/guns/"..weapon, "melee")

   mplay("combat/"..action.."/"..outcome, "melee")
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
   EnableGroup("starmap", 0)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="hooks"
   match="^#\$#soundpack fc \| (.+?)$"
   regexp="y"
   send_to="12"
   omit_from_output="y"
   omit_from_log="y"
   keep_evaluating="y"
   sequence="10"
  >
  <send>
   -- Store flight control scanner name for the upcoming message
   SetVariable("fc_scanner_name", "%1")
  </send>
  </trigger>

</triggers>
]=])


