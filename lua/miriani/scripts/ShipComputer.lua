anomaly_found = false

-- Repair timer tracking
repair_timer_id = nil
repair_start_room = nil
repair_component = nil
repair_end_time = nil

-- Parse time string like "2 minutes" or "1 hour and 30 minutes" to seconds
function parseTimeToSeconds(timeStr)
  local seconds = 0

  -- Match hours
  local hours = string.match(timeStr, "(%d+)%s*hours?")
  if hours then seconds = seconds + tonumber(hours) * 3600 end

  -- Match minutes
  local minutes = string.match(timeStr, "(%d+)%s*minutes?")
  if minutes then seconds = seconds + tonumber(minutes) * 60 end

  -- Match seconds
  local secs = string.match(timeStr, "(%d+)%s*seconds?")
  if secs then seconds = seconds + tonumber(secs) end

  return seconds
end

-- Called when repair timer fires
function onRepairTimerComplete()
  if repair_start_room and roomName ~= repair_start_room then
    -- We're not in engineering, notify the user
    mplay("ship/computer/repStop", "notification")
    print("Repair complete!")
  end
  -- Clear repair state
  repair_timer_id = nil
  repair_start_room = nil
  repair_component = nil
  repair_end_time = nil
end


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
    func = function()
      if not anomaly_found then
        mplay("ship/computer/anomaly", "notification")
        anomaly_found = true
        DoAfterSpecial(10, "anomaly_found = false", sendto.script)
      end
    end
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
  ["An interdiction field is preventing the validation of cached navigational beacon data. Safety overrides are now in effect."] = {
    sound = "ship/computer/error",
    group = "computer"
  },
  ["An interdiction field prevents the ship from communicating with the navigational beacons."] = {
    sound = "ship/computer/error",
    group = "computer"
  },
  ["This starship has triggered a push pulse device. Brace for impact."] = {
    sound = "ship/computer/pushPulse",
    group = "computer"
  },
  -- Self-destruct countdown sequence
  ["Self-destruct sequence initiated. Destruction in sixty seconds."] = {
    sound = "ship/computer/selfDestructStart",
    group = "computer"
  },
  ["Self-destruct in thirty seconds."] = {
    sound = "ship/computer/selfDestructThirty",
    group = "computer"
  },
  ["Self-destruct in ten seconds."] = {
    sound = "ship/computer/selfDestructTen",
    group = "computer"
  },
  ["Five."] = {
    sound = "ship/computer/selfDestructFive",
    group = "computer"
  },
  ["Four."] = {
    sound = "ship/computer/selfDestructFour",
    group = "computer"
  },
  ["Three."] = {
    sound = "ship/computer/selfDestructThree",
    group = "computer"
  },
  ["Two."] = {
    sound = "ship/computer/selfDestructTwo",
    group = "computer"
  },
  ["One."] = {
    sound = "ship/computer/selfDestructOne",
    group = "computer"
  },
  ["Goodbye."] = {
    sound = "ship/computer/selfDestructEnd",
    group = "computer"
  },
  ["The starship has entered an H II region. Caution is advised."] = {
    sound = "ship/computer/nebula",
    group = "notification",
    PlayComputerSound = true
  },
  ["Warning! Aquatic life form has entered scooper chamber. Expulsion in progress..."] = {
    sound = "ship/computer/warning",
    group = "computer",
    PlayComputerSound = true
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
      if string.find(match1, "starship") or string.find(match1, "furner") or string.find(match1, "sleigh") then mplay("ship/computer/starship", "notification") end
      if string.find(match1, "space station") then mplay("ship/computer/station", "notification") end
      if string.find(match1, "anomaly") then
        if not anomaly_found then
          mplay("ship/computer/anomaly", "notification")
          anomaly_found = true
          DoAfterSpecial(10, "anomaly_found = false", sendto.script)
        end
      end
      if string.find(match1, "wormhole") then mplay("ship/computer/wormhole", "notification") end
      if string.find(match1, "long%-range communication beacon") then mplay("ship/computer/beacon", "notification") end
	  if string.find(match1, " star ") then mplay("ship/computer/star", "notification") end
    end
  },
  ["Bardenium Cannons? (.+) locked on (.+)%. Firing%."] = {
    func = function(cannon_list, target)
      mplay("device/keyboard", "ship")
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

      mplay("ship/combat/weaponsLocked", "ship")
    end
  },
  -- Unified turret and long-range weapon triggers (using Lua patterns, not PCRE)
  -- Matches anything ending with "locking onto [target]."
  [".+ locking ont?o (.+)%."] = {
    func = function(target)
      mplay("device/keyboard", "ship")
      if target == "empty space" then
        mplay("ship/combat/noLock", "ship")
      else
        mplay("ship/combat/weaponsLocked", "ship")
      end
    end
  },
  ["I am beginning the repair of (.+)%. Estimated time to completion: (.+)"] = {
    sound = "ship/computer/repStart",
    group = "computer",
    PlayComputerSound = true,
    func = function(component, time_estimate)
      -- Store repair info
      repair_start_room = roomName
      repair_component = component
      local seconds = parseTimeToSeconds(time_estimate)
      repair_end_time = os.time() + seconds
      -- Only set timer if repair notifications are enabled
      if config:get_option("repair_notifs").value == "yes" and seconds > 0 then
        -- Add 5 second buffer to account for timing variations
        DoAfterSpecial(seconds + 5, "onRepairTimerComplete()", sendto.script)
        repair_timer_id = true
      end
    end
  },
  ["I have completed the repair of (.+)%."] = {
    sound = "ship/computer/repStop",
    group = "computer",
    PlayComputerSound = true,
    func = function()
      -- Clear repair timer state since we got the completion message
      repair_timer_id = nil
      repair_start_room = nil
      repair_component = nil
      repair_end_time = nil
    end
  },
  ["I have aborted the repair of (.+)%."] = {
    group = "computer",
    PlayComputerSound = true,
    func = function()
      -- Clear repair timer state on abort
      repair_timer_id = nil
      repair_start_room = nil
      repair_component = nil
      repair_end_time = nil
    end
  },
  ["(.+) has been destroyed%."] = {
    func = function()
      mplay("ship/computer/otherDestroy", "computer")
      mplay("ship/combat/destroy/targetDestroyed", "ship")
    end
  },
  ["^Hit on (.+)%."] = {
    sound = "ship/combat/hit/otherHit",
    group = "ship"
  },
  ["Partial hit on (.+)"] = {
    func = function()
      mplay("ship/combat/hit/partialHit", "computer", nil, nil, nil, nil, nil, nil, 10)
	  mplay("ship/combat/hit/otherHit", "computer")
    end
	},
  ["Scans reveal the debris to be (.+)%."] = {
    PlayComputerSound = true,
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
  },
  ["Warning, power level has dropped to (%d+)%%."] = {
    func = function(power_level)
      local level = tonumber(power_level)
      if level and level > 5 then
        mplay("activity/atmo/salvageLow", "notification")
      else
        mplay("activity/atmo/salvageCritical", "notification")
      end
    end
  }
}

ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="computer"
   match="^(?:The computer|(.+?) flickers into existence and) (announces|reports).?(?:that)? &quot;?(?:Arrr! )?(.+?)&quot;?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   local avatar_name = "%1"  -- holographic avatar name (empty if standard computer)
   local action_type = "%2"  -- announces or reports
   local message = "%3"

   -- Build output string depending on config option
   local str
   if config:get_option("spam").value == "yes" then
     str = message
   else
     str = "%0"
   end

   -- Check if we should show the holographic avatar name
   -- Standard computer names are always gagged (they're just the default computer)
   local standard_names = {
     ["A holographic representation of the ship's computer"] = true,
     ["Computer"] = true,
     ["The computer"] = true,
     ["The ship's computer"] = true,
   }

   if avatar_name ~= "" and not standard_names[avatar_name] and config:get_option("gag_holographic_avatar").value == "no" then
     str = avatar_name .. ": " .. str
   end

   -- Add to history
   channel("computer", str, {"computer"})

   -- Check exact match actions first
   local action = computer_actions[message]
   local PlayComputerSound = false

   if action then
     if action.condition then
       if loadstring("return " .. action.condition)() then
         if action.sound then
           mplay(action.sound, action.group or "computer")
         end
       end
     elseif action.sound then
       mplay(action.sound, action.group or "computer")
     end
     if action.func then
       action.func()
     end
     if action.PlayComputerSound then
       PlayComputerSound = true
     end
   else
     -- Check wildcard patterns
     local matched = false
     for pattern, action in pairs(computer_actions_wildcard) do
       local matches = {string.match(string.lower(message), string.lower(pattern))}
       if #matches > 0 then
         matched = true
         if action.sound then
           mplay(action.sound, action.group or "computer")
         end
         if action.func then
           action.func(unpack(matches))
         end
         if action.PlayComputerSound then
           PlayComputerSound = true
         end
         break
       end
     end
     -- No action matched, play generic sound
     if not matched then
       PlayComputerSound = true
     end
   end

   -- Play generic computer sound if requested
   if PlayComputerSound then
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
   match="^There are no damaged components\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/computer/NoDamage", "computer")</send>
  </trigger>
</triggers>

<aliases>
  <alias
   enabled="y"
   group="computer"
   match="^checkrepairtimer$"
   regexp="y"
   send_to="14"
   sequence="100"
  >
  <send>
   if repair_end_time then
     local remaining = repair_end_time - os.time()
     if remaining > 0 then
       local mins = math.floor(remaining / 60)
       local secs = remaining % 60
       if mins > 0 then
         print(string.format("Repairing %s: %d minutes %d seconds remaining", repair_component or "component", mins, secs))
       else
         print(string.format("Repairing %s: %d seconds remaining", repair_component or "component", secs))
       end
     else
       print("Repair should be complete any moment now.")
     end
   else
     print("No repair in progress.")
   end
  </send>
  </alias>
  </aliases>
]=])