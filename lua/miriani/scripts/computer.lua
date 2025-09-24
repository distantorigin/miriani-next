
-- Computer action lookup tables
computer_actions = {
  ["Autopilot engaged."] = {
    sound = "ship/computer/voice/auto",
    condition = 'config:get_option("computer_voice").value == "yes"'
  },
  ["Autopilot disengaged."] = {
    sound = "ship/computer/voice/manual",
    condition = 'config:get_option("computer_voice").value == "yes"'
  },
  ["Self-destruct sequence initiated. Destruction in sixty seconds."] = {
    sound = "ship/computer/voice/selfdestruct",
    condition = 'config:get_option("computer_voice").value == "yes"'
  },
  ["Self-destruct sequence has been aborted."] = {
    sound = "ship/computer/voice/terminate",
    condition = 'config:get_option("computer_voice").value == "yes"'
  },
  [""] = {
    sound = "ship/computer/voice/terminate",
    condition = 'config:get_option("computer_voice").value == "yes"'
  },
  ["There is insufficient weapons-grade bardenium available for firing."] = {
    sound = "ship/combat/noBarde",
    group = "ship"
  },
  ["no nearby debris."] = {
    sound = "ship/misc/noDebris",
    group = "notification"
  },
  ["NAVI was unable to continue due to sensor interference."] = {
    sound = "ship/computer/anomaly",
    group = "notification"
  },
  ["Target destroyed."] = {
    sound = "ship/combat/destroy/targetDestroyed",
    group = "ship"
  },
  ["Firing on empty space complete."] = {
    sound = "ship/combat/noTarget",
    group = "ship"
  },
  ["There is no target at those coordinates. Aborting."] = {
    sound = "misc/cancel",
    group = "ship"
  },
  ["Docking has failed."] = {
    sound = "ship/computer/dockingFailed",
    group = "notification"
  },
  ["That destination is beyond the range of the wormhole drive."] = {
    sound = "ship/computer/failFtl",
    group = "computer"
  },
  ["This starship has triggered a push pulse device. Brace for impact."] = {
    sound = "ship/computer/pushPulse",
    group = "computer"
  },
  ["The starship has entered an H II region. Caution is advised."] = {
    sound = "ship/computer/nebula",
    group = "notification"
  }
}

computer_actions_wildcard = {
  ["(.+?) been detect(?:ed|'d) in the sector%."] = {
    func = function(match1)
      if string.find(match1, "artifact") then mplay("ship/computer/artifact", "notification") end
      if string.find(match1, "planet") then mplay("ship/computer/planet", "notification") end
      if string.find(match1, "starship") or string.find(match1, "furner") then mplay("ship/computer/starship", "notification") end
      if string.find(match1, "space station") then mplay("ship/computer/station", "notification") end
      if string.find(match1, "anomaly") then mplay("ship/computer/anomaly", "notification") end
      if string.find(match1, "wormhole") then mplay("ship/computer/wormhole", "notification") end
      if string.find(match1, "long%-range communication beacon") then mplay("ship/computer/beacon", "notification") end
    end
  },
  ["Bardenium Cannons? (.+) locked on (.+)%. Firing%."] = {
    func = function(cannon_list, target)
      -- Extract cannon count
      local count = 0
      for num in string.gmatch(cannon_list, "%d+") do
        count = count + 1
      end

      -- Update cannon count and recalculate if changed
      if numberOfCannons ~= count then
        local oldCannons = numberOfCannons
        numberOfCannons = count
        if config:get_option("count_cannon").value == "yes" and numberOfCannons > 0 and cannonShots and oldCannons then
          local estimatedBardenium = cannonShots * oldCannons
          cannonShots = math.ceil(estimatedBardenium / numberOfCannons)
        end
      end

      -- Handle shot counting
      if config:get_option("count_cannon").value == "yes" then
        local wasFirstShot = not cannonShots
        if not cannonShots then
          if numberOfCannons and numberOfCannons > 0 then
            cannonShots = math.max(8, math.ceil(20 / numberOfCannons))
          else
            cannonShots = 8
          end
        end

        cannonShots = cannonShots - 1

        if cannonShots == 0 then
          mplay("ship/combat/noBarde", "ship")
        end

        print("Shots: "..cannonShots)
      end

      mplay("ship/combat/weaponFire", "ship")
    end
  },
  ["(Turret|Long%-Range)s? (.+?) (?:(?:is|are) locking|(?:locked|lockin')|locked on) (?:on|ont'|)(?:to )?(.+?)%.? ?(?:Firing%.)?"] = {
    func = function(weapon_type, weapon_num, target)
      mplay("ship/combat/weaponFire", "ship")
    end
  },
  ["I (?:am|be) (?:beginning|beginnin') the repair of (.+?)%. Estimat(?:ed|'d) time (?:to |t')completion: (.+?)"] = {
    sound = "ship/computer/repStart",
    group = "computer"
  },
  ["I have complet(?:ed|'d) the repair of (.+?)%."] = {
    sound = "ship/computer/repStop",
    group = "computer"
  },
  ["(.+?) has been destroyed%."] = {
    sound = "ship/computer/otherDestroy",
    group = "computer"
  },
  ["Hit on (.+?)%."] = {
    sound = "ship/combat/hit/otherHit",
    group = "ship"
  },
  ["Partial hit on (.+?)"] = {
    sound = "ship/combat/hit/partialHit",
    group = "ship"
  },
  ["Scans reveal the debris to be (.+?)%."] = {
    func = function(debris_type)
      mplay("ship/misc/debrisSalvage", "computer")
      if string.find(debris_type, "lifeform") then
        mplay("ship/computer/lifeform", "notification")
      end
    end
  },
  ["(.+?) (?:locking|be lockin') (?:onto |ont')empty space%."] = {
    sound = "ship/combat/noLock",
    group = "ship"
  },
  ["(.+?) is one unit away from this ship%."] = {
    sound = "ship/computer/inRange",
    group = "computer"
  },
  ["Mission objective has been complet(?:ed|'d) in approximately (.+?)%. Return to base%."] = {
    sound = "music/mission",
    group = "computer"
  },
  ["Weapon launch sequence initiated%. Bomb's away!"] = {
    sound = "activity/acv/bombRelease",
    group = "ship"
  },
  ["Weapon launch sequence initiated%. Detonator deployed!"] = {
    sound = "activity/acv/detonatorRelease",
    group = "ship"
  },
  ["Successfully detonated (.+?) detonator%."] = {
    sound = "activity/acv/detonate",
    group = "ship"
  },
  ["Bomb has detonated (.+?)%."] = {
    sound = "activity/acv/detonate",
    group = "ship"
  },
  ["The target is no longer IN range%. Firing aborted%."] = {
    func = function()
      ordinatesFiring = nil
    end
  }
}

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
   local action_type = "%1"  -- announces or reports
   local message = "%2"

   -- Build output string depending on config option
   local str
   if config:get_option("spam").value == "yes" then
     str = message
   else
     str = "%0"
   end

   -- Add to history
   channel("computer", str, {"computer"})

   -- Check exact match actions first
   local action = computer_actions[message]
   local sound_played = false

   if action then
     if action.condition then
       if loadstring("return " .. action.condition)() then
         if action.sound then
           mplay(action.sound, action.group or "computer")
           sound_played = true
         end
       end
     elseif action.sound then
       mplay(action.sound, action.group or "computer")
       sound_played = true
     end
     if action.func then
       action.func()
     end
   else
     -- Check wildcard patterns
     for pattern, action in pairs(computer_actions_wildcard) do
       local matches = {string.match(message, pattern)}
       if #matches > 0 then
         if action.sound then
           mplay(action.sound, action.group or "computer")
           sound_played = true
         end
         if action.func then
           action.func(unpack(matches))
         end
         break
       end
     end
   end

   -- Default computer sounds if no specific action matched
   if not sound_played then
     if string.find(message, "Control room reports") then
       mplay("ship/computer/control", "computer")
     elseif string.find(message, "Warning") or string.find(message, "Alert") then
       mplay("ship/computer/warning", "computer")
     elseif action_type == "reports" then
       mplay("ship/computer/report", "computer")
     else
       mplay("ship/computer/announce", "computer")
     end
   end

   -- Display the message
   print_color({str, "computer"})
  </send>
  </trigger>


  <!-- Non-computer triggers that we want to keep -->
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