
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="computer"
   match="^(?:The computer|.+? flickers into existence and) (announces|reports).?(?:that)? &quot;?(?:Arrr! )?(.+?)&quot;?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>

   -- build output string depending on config option
local str
   if config:get_option ("spam").value == "yes" then
    str = "%2"
   else
    str = "%0"
   end -- if

   -- add to history
   channel("computer", str, {"computer"})

   -- mplay sound for default computer

   if string.find ("%2", "Control room reports") then
    mplay ("ship/computer/control", "computer")
  elseif string.find ("%2", "Warning")
  or string.find ("%2", "Alert") then
    mplay ("ship/computer/warning", "computer")
   else
    mplay ("ship/computer/announce", "computer")
   end -- if

   print_color({str, "computer"})

   -- replicate the string for toastush:
   replicate_line("#$# computer | %2")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^Invalid coordinates\. Range: \(1, 1, 1\) to \(20, 20, 20\)\.(?: You may also specify a destination name\.)?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>   if config:get_option("computer_voice").value == "yes" then
mplay("ship/computer/voice/unclear", "computer")
   else
   print_color({"%0", "computer"})
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   script="gagline"
   match="^Objects\s+Direction\s+Lightyears\s+Coordinates\s+$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("ship/computer/lrscan", "computer")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| .+?$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   keep_evaluating="y"
   sequence="50"
  >
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Autopilot engaged\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if config:get_option("computer_voice").value == "yes" then
     mplay("ship/computer/voice/auto", "computer")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Autopilot disengaged\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if config:get_option("computer_voice").value == "yes" then
     mplay("ship/computer/voice/manual", "computer")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Self-destruct sequence initiated. Destruction in sixty seconds\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if config:get_option("computer_voice").value == "yes" then
     mplay("ship/computer/voice/selfdestruct", "computer")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Self-destruct sequence has been aborted\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if config:get_option("computer_voice").value == "yes" then
     mplay("ship/computer/voice/terminate", "computer")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| $"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if config:get_option("computer_voice").value == "yes" then
     mplay("ship/computer/voice/terminate", "computer")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| (.+?) been detect(?:ed|'d) in the sector\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>

   if string.find("%1", "artifact") then mplay ("ship/computer/artifact", "notification") end
   if string.find("%1", "planet") then mplay ("ship/computer/planet", "notification") end
   if string.find("%1", "starship") or string.find("%1", "furner") then mplay ("ship/computer/starship", "notification") end
   if string.find("%1", "space station") then mplay ("ship/computer/station", "notification") end
   if string.find("%1", "anomaly") then mplay ("ship/computer/anomaly", "notification") end
   if string.find("%1", "wormhole") then mplay ("ship/computer/wormhole", "notification") end
   if string.find("%1", "long%-range communication beacon") then mplay ("ship/computer/beacon", "notification") end


  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| NAVI was unable to continue due to sensor interference\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/anomaly", "notification")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| no nearby debris\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/noDebris", "notification")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| I (?:am|be) (?:beginning|beginnin') the repair of .+?\. Estimat(?:ed|'d) time (?:to |t')completion: .+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/repStart", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| I have complet(?:ed|'d) the repair of .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/repStop", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| This starship has triggered a push pulse device. Brace for impact\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/pushPulse", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| .+? has been destroyed\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/otherDestroy", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Target destroyed\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/destroy/targetDestroyed", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| .+? (?:locking|be lockin') (?:onto |ont')empty space\.$"
   regexp="y"
   send_to="12"
   sequence="90"
  >
  <send>mplay ("ship/combat/noLock", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| There is no target at those coordinates\. Aborting\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>play("audio/cancel.ogg")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| (Turret|Bardenium Cannon|Long-Range)s? .+? (locked|lockin') (on|ont')(to )?.+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>

   -- count shots if cannonCount is active
   if string.find("%1", "Bardenium Cannon")
   and config:get_option("count_cannon").value == "yes"
   and cannonShots then
     cannonShots = cannonShots - 1

     -- play a sound for 0 shots left.
     if cannonShots == 0 then
      mplay("ship/combat/noBarde", "ship")
     end -- no shots

    notify("info", "Shots Remaining: "..cannonShots, 1)
   end -- if cannonCount

   mplay ("ship/combat/weaponFire", "ship")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| There is insufficient weapons-grade bardenium available for firing\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/noBarde", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Firing on empty space complete\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/noTarget", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Hit on .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/hit/otherHit", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Partial hit on .+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/hit/partialHit", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| .+? is one unit away from this ship\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/inRange", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Scans reveal the debris to be (.+?)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>

   mplay("ship/misc/debrisSalvage", "computer")   
   if string.find("%1", "lifeform") then
     mplay("ship/computer/lifeform", "notification")
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Docking has failed\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/computer/dockingFailed", "notification")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| That destination is beyond the range of the wormhole drive\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/computer/failFtl", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Mission objective has been complet(?:ed|'d) in approximately .+?\. Return to base\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("music/mission", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Weapon launch sequence initiated\. Bomb's away!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/acv/bombRelease", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Weapon launch sequence initiated\. Detonator deployed!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/acv/detonatorRelease", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Successfully detonated .+? detonator\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/acv/detonate", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| Bomb has detonated .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/acv/detonate", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| The target is no longer IN range\. Firing aborted\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>ordinatesFiring = nil</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^#\$# computer \| The starship has entered an H II region\. Caution is advised\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/computer/nebula", "notification")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^Several short bleeps emit from .+ Lore computer, followed by a hardcopy print of .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("device/lore/Print", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
   match="^There are no damaged components\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/computer/NoDamage", "computer")</send>
  </trigger>

  <trigger
   enabled="y"
   group="computer"
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

</triggers>
]=])