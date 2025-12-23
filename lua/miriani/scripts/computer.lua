
-- Computer action lookup tables
computer_actions = {
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
  },
  ["Warning! Aquatic life form has entered scooper chamber. Expulsion in progress..."] = {
    sound = "ship/computer/warning",
    group = "computer"
  },
  ["We have arrived at the target destination. Lifting anchor and establishing standard dock."] = {
    func = function()
      increment_counter("asteroids_hauled")
	  mplay("activity/asteroid/shipAnchorEnd")
    end
  },
  [""] = {
    func = function(credits)
      increment_counter("mining_expeditions")
    end
  }
}

computer_actions_wildcard = {
  ["Mission objective has been completed in approximately (.+)%. Return to base%."] = {
    sound = "music/theme",
  group = "computer",
    func = function(time_taken)
      increment_counter("missions")
    end
  },
  ["Processing complete%. One unit of (.+) has been secured%."] = {
    func = function(material_type)
      -- Define material categories
      local atmospheric_materials = {
        nitrogen = true, oxygen = true, ["water vapor"] = true, ozone = true,
        argon = true, neon = true, helium = true, krypton = true,
        xenon = true, hydrogen = true
      }

      local gas_materials = {
        methane = true, ammonia = true, ["sulphur dioxide"] = true,
        germanium = true, ["carbon dioxide"] = true, phosphorus = true
      }

      local aquatic_materials = {
        ["octopus ink"] = true, ["fish scales"] = true, seaweed = true,
        kelp = true, sponge = true, algae = true, plankton = true,
        ["seashells"] = true, ["fish eggs"] = true,
        ["raw sewage"] = true, ["shark teeth"] = true, mercury = true,
        coral = true, barnacles = true, ["starfish arms"] = true
      }

      local material_lower = string.lower(material_type)

      -- Check which category the material falls into
      if atmospheric_materials[material_lower] then
        increment_counter("atmospheric_debris")
      elseif gas_materials[material_lower] then
        increment_counter("gas_debris")
      elseif aquatic_materials[material_lower] then
        increment_counter("water_debris")
      else
        -- Default to atmospheric for anything else
        increment_counter("atmospheric_debris")
      end
    end
  },
  ["(.+) been detected in the sector%."] = {
    func = function(match1)
      if string.find(string.lower(match1), "artifact") then mplay("ship/computer/artifact", "notification") end
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
  -- Unified turret and long-range weapon triggers (using Lua patterns, not PCRE)
  -- Matches anything ending with "locking onto [target]."
  [".+ locking ont?o (.+)%."] = {
    func = function(target)
      if target == "empty space" then
        mplay("ship/combat/noLock", "ship")
      else
        mplay("ship/combat/weaponFire", "ship")
      end
    end
  },
  ["I am beginning the repair of (.+)%. Estimated time to completion: (.+)"] = {
    sound = "ship/computer/repStart",
    group = "computer"
  },
  ["I have completed the repair of (.+)%."] = {
    sound = "ship/computer/repStop",
    group = "computer"
  },
  ["(.+) has been destroyed%."] = {
    sound = "ship/computer/otherDestroy",
    group = "computer"
  },
  ["Hit on (.+)%."] = {
    sound = "ship/combat/hit/otherHit",
    group = "ship"
  },
  ["Partial hit on (.+)"] = {
    sound = "ship/combat/hit/partialHit",
    group = "ship"
  },
  ["Scans reveal the debris to be (.+)%."] = {
    func = function(debris_type)
      mplay("ship/misc/debrisSalvage", "computer")
      if string.find(debris_type, "lifeform") then
        mplay("ship/computer/lifeform", "notification")
      end
    end
  },
  ["(.+) is one unit away from this ship%."] = {
    sound = "ship/computer/inRange",
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
  ["Successfully detonated (.+) detonator%."] = {
    sound = "activity/acv/detonate",
    group = "ship"
  },
  ["Bomb has detonated (.+)%."] = {
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
       local matches = {string.match(string.lower(message), string.lower(pattern))}
       if #matches > 0 then
         if action.sound then
           mplay(action.sound, action.group or "computer")
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
  <send>print_color({"%0", "computer"})</send>
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
   match="^Several short bleeps emit from .+ Lore computer.+followed by .+\.$"
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