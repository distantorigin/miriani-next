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
  ["Debris destroyed."] = {
    sound = "ship/combat/destroy/debrisDestroyed",
    group = "ship"
  },
  ["Blockade destroyed."] = {
    sound = "ship/combat/destroy/blockadeDestroyed",
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
      local found = false
      if string.find(string.lower(match1), "artifact") then mplay("ship/computer/artifact", "computer") found = true end
      if string.find(match1, "planet") then mplay("ship/computer/planet", "computer") found = true end
      if string.find(match1, "starship") or string.find(match1, "furner") or string.find(match1, "sleigh") then mplay("ship/computer/starship", "computer") found = true end
      if string.find(match1, "space station") then mplay("ship/computer/station", "computer") found = true end
      if string.find(match1, "anomaly") then
        if not anomaly_found then
          mplay("ship/computer/anomaly", "computer")
          anomaly_found = true
          DoAfterSpecial(10, "anomaly_found = false", sendto.script)
        end
        found = true
      end
      if string.find(match1, "wormhole") then mplay("ship/computer/wormhole", "computer") found = true end
      if string.find(match1, "long%-range communication beacon") then mplay("ship/computer/beacon", "computer") found = true end
      if string.find(match1, " star ") then mplay("ship/computer/star", "computer") found = true end
      if not found then mplay("ship/computer/announce", "computer") end
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

-- Text transforms for "shorten_computer" option (ordered array for deterministic matching)
-- Each entry: {pattern = "...", transform = function(...) return "shortened" end}
computer_transforms = {
  {
    pattern = "Scans reveal the debris to be (.+)%.",
    transform = function(debris_type)
      return "Salvaged " .. debris_type .. "."
    end
  },
  {
    pattern = "I am beginning the repair of (.+)%. Estimated time to completion: (.+)%.",
    transform = function(component, time_estimate)
      return time_estimate .. " for " .. component .. " to be repaired."
    end
  },
  {
    pattern = "(.+) will be completely repaired in approximately (.+)%.",
    transform = function(component, time_estimate)
      return time_estimate .. " for " .. component .. " to be repaired."
    end
  },
  {
    pattern = "I am currently repairing: (.+), which is (.+)%% damaged%. Estimated time to completion is (.+)%.",
    transform = function(component, damage_pct, time_estimate)
      return damage_pct .. "% damage to " .. component .. " will take " .. time_estimate .. " to repair."
    end
  },
  {
    pattern = "I have completed the repair of (.+)%.",
    transform = function(component)
      return component .. " repaired."
    end
  },
  {
    pattern = "I have aborted the repair of (.+)%.",
    transform = function(component)
      return "Aborted repair of " .. component .. "."
    end
  },
  {
    pattern = "Turret.+ locking onto empty space%.",
    transform = function()
      return "Nothing targeted."
    end
  },
  {
    pattern = "Long%-Range Laser .+ is locking onto empty space%.",
    transform = function()
      return "Nothing targeted."
    end
  },
  {
    pattern = ".+ is locking onto empty space%.",
    transform = function()
      return "Nothing targeted."
    end
  },
  {
    pattern = "Direct hit%. (.+) destroyed%.",
    transform = function(target)
      return target .. " destroyed."
    end
  },
  {
    pattern = "Bardenium Cannon(.+) locked on (.+)%. Firing%.",
    transform = function(cannon_suffix, target)
      return "Cannon" .. cannon_suffix .. " locked on " .. target .. "."
    end
  },
  {
    pattern = "This vessel is of the (.+) design%. It was manufactured on (.+) at the (.+) and commissioned by the (.+)%. The vessel came under licensed control on (.+) and is presently licensed to (.+)%.",
    transform = function(design, mfg_date, mfg_location, commissioner, license_date, owner)
      return "This " .. design .. " is licensed to " .. owner .. "."
    end
  },
  {
    pattern = "Via synchronized text message broadcasts, (.+)",
    transform = function(message)
      return "[STMB] " .. message
    end
  },
  {
    pattern = "The target has moved from the locked coordinates%.",
    transform = function()
      return "Target moved."
    end
  },
  {
    pattern = "There is insufficient weapons%-grade bardenium available for firing%.",
    transform = function()
      return "Insufficient bardenium."
    end
  },
  {
    pattern = "The target is no longer available%. Probable cause for lost sensor contact is destruction%.",
    transform = function()
      return "Target destroyed."
    end
  },
}

-- Apply computer transform if shorten_computer is enabled
-- Returns transformed string or nil if no transform applies
function apply_computer_transform(message)
  if config:get_option("shorten_computer").value ~= "yes" then
    return nil
  end

  for _, entry in ipairs(computer_transforms) do
    local matches = {string.match(message, entry.pattern)}
    if #matches > 0 then
      local ok, result = pcall(entry.transform, unpack(matches))
      if ok and result and result ~= "" then
        return result
      end
    end
  end

  return nil
end

-- Damage reader: check for critical damage (80-99%) and play alert sound
-- Called by damage_reader trigger, enabled by dam/damage alias
function checkDamageLine(line)
  for component, damage_str in string.gmatch(line, "([A-Za-z0-9 ]+):%s*(%d+)") do
    local damage = tonumber(damage_str)
    if damage and damage >= 80 and damage < 100 then
      local name = component:match("^%s*(.-)%s*$"):upper()
      if name == "HULL" then
        mplay("ship/combat/hullCritical", "ship", nil, nil, nil, nil, nil, nil, -20)
      else
        mplay("ship/combat/componentCritical", "ship", nil, nil, nil, nil, nil, nil, -15)
      end
      EnableTrigger("damage_reader", false)
      return
    end
  end
end

ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="computer"
   match="^(?:The computer|([^\[].+?) flickers into existence and) (announces|reports).?(?:that)? &quot;?(?:Arrr! )?(.+?)&quot;?$"
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

   -- Apply computer transforms if shorten_computer option is enabled
   local transformed = apply_computer_transform(message)
   if transformed then
     str = transformed
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

   -- Check for "Control room reports:" prefix and extract content for action matching
   local control_room_message = string.match(message, "^Control room reports:%s*(.+)")
   local action_message = control_room_message or message

   -- Check exact match actions first
   local action = computer_actions[action_message]
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
       local matches = {string.match(string.lower(action_message), string.lower(pattern))}
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

   -- Always play control room sound for control room messages
   if control_room_message then
     mplay("ship/computer/control", "computer")
     -- Play interdiction sound for GATE interruption relayed outside CR
     if string.find(action_message, "has been interrupted") then
       mplay("ship/computer/error", "computer")
     end
     -- Also check for Warning/Alert in the control room content
     if PlayComputerSound and (string.find(action_message, "Warning") or string.find(action_message, "Alert")) then
       mplay("ship/computer/warning", "computer")
     end
   elseif PlayComputerSound then
     if string.find(message, "Warning") or string.find(message, "Alert") then
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
  <send>
   mplay("ship/computer/NoDamage", "computer")
   EnableTrigger("damage_reader", false)
  </send>
  </trigger>

  <!-- Damage reader: plays critical sounds for components at 80-99% damage -->
  <trigger
   enabled="n"
   name="damage_reader"
   group="computer"
   match="^(?!.*\[)[A-Za-z0-9 ]+: \d+%"
   regexp="y"
   send_to="12"
   sequence="100"
   keep_evaluating="y"
  >
  <send>checkDamageLine("%0")</send>
  </trigger>

</triggers>

<aliases>
  <!-- Damage command aliases - activate damage reader mode for critical sounds -->
  <alias
   enabled="y"
   group="computer"
   match="^dam(?:a(?:g(?:e)?)?)?(.*)$"
   regexp="y"
   send_to="14"
   sequence="100"
  >
  <send>
   EnableTrigger("damage_reader", true)
   Send("%0")
  </send>
  </alias>

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