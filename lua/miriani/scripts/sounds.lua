-- @module sounds
-- Audio management tables
local streamtable = {}
local active_group = 1

-- foreground sounds system
local window_has_focus = true

-- Group audio IDs for management
local group_sounds = {}

-- Group registry for sound filtering
-- Tracks discovered sound groups (notification, computer, babies, etc.) and their enabled state
local group_registry = {}
local registry_file = "worlds/settings/sound_groups.conf"

-- Groups that should not be filterable (they have their own volume controls)
local excluded_groups = {
  ambiance = true,
  environment = true,
}



-- Device health monitoring variables
local last_device_check = 0
local device_check_interval = 5000 -- Check every 5 seconds
local last_position_check = {}

-- Helper function to cleanup finished sounds from a group
local function cleanup_group(group)
  if not streamtable[group] then
    return
  end

  for i = #streamtable[group], 1, -1 do
    local sound_data = streamtable[group][i]
    if sound_data.stream then
      local status = sound_data.stream:IsActive()
      -- Remove streams that are stopped (0) - keep playing (1), stalled (2), paused (3)
      if status == 0 then
        -- Properly free the BASS stream resource
        sound_data.stream:Free()
        table.remove(streamtable[group], i)
      elseif status == 1 then
        -- For playing streams, check position to detect stuck playback
        local current_pos = sound_data.stream:GetPosition()
        local stream_id = tostring(sound_data.stream.id)

        if last_position_check[stream_id] then
          -- If position hasn't changed in multiple checks, stream might be stuck
          if current_pos == last_position_check[stream_id].position then
            last_position_check[stream_id].stuck_count = (last_position_check[stream_id].stuck_count or 0) + 1
            -- If stuck for more than 3 checks, consider it a device issue
            if last_position_check[stream_id].stuck_count > 3 then
              check_and_recover_device()
              last_position_check[stream_id] = nil
            end
          else
            last_position_check[stream_id] = { position = current_pos, stuck_count = 0 }
          end
        else
          last_position_check[stream_id] = { position = current_pos, stuck_count = 0 }
        end
      end
    else
      -- Remove entries with invalid streams
      table.remove(streamtable[group], i)
    end
  end

  -- Remove empty groups
  if #streamtable[group] == 0 then
    streamtable[group] = nil
  end
end

-- Function to check device health and attempt recovery
function check_and_recover_device()
  if not BASS then
    return false
  end

  local health = BASS:CheckDeviceHealth()
  if health ~= Audio.CONST.error.ok then
    if config:get_option("debug_mode").value == "yes" then
      notify("important", string.format("Audio device issue detected (error %d), attempting recovery...", health))
    end

    -- Store info about currently playing streams for recovery
    local streams_to_recover = {}
    for group, sounds in pairs(streamtable) do
      for _, sound_data in ipairs(sounds) do
        if sound_data.stream and sound_data.stream:IsActive() == 1 then
          table.insert(streams_to_recover, {
            file = sound_data.file,
            group = group,
            position = sound_data.stream:get_position()
          })
        end
      end
    end

    -- Stop all current streams before recovery
    cleanup_all_streams()

    local success, message = BASS:RecoverFromDeviceFailure()
    if success then
      if config:get_option("debug_mode").value == "yes" then
        notify("info", "Audio device recovery successful: " .. message)
      end

      -- Attempt to restore streams that were playing
      for _, stream_info in ipairs(streams_to_recover) do
        if stream_info.group ~= "ambiance" then -- Don't restore ambiance as it may be inappropriate
          -- Try to restart the sound from where it left off
          play(stream_info.file, stream_info.group, false, nil, false, nil, nil, true)
        end
      end

      return true
    else
      if config:get_option("debug_mode").value == "yes" then
        notify("important", "Audio device recovery failed: " .. message)
      end
      return false
    end
  end
  return true
end

-- Periodic device health check
local function periodic_device_check()
  local current_time = GetInfo(304) -- GetInfo(304) returns current time in milliseconds
  if current_time - last_device_check > device_check_interval then
    check_and_recover_device()
    last_device_check = current_time
  end
end

-- Group registry functions

-- Load group registry from file
local function load_group_registry()
  local path = require("pl.path")
  local file_path = registry_file

  if path.isfile(file_path) then
    local f = io.open(file_path, "r")
    if f then
      local content = f:read("*all")
      f:close()

      -- Parse the registry file (format: group=enabled)
      for line in content:gmatch("[^\r\n]+") do
        local group, enabled = line:match("^([^=]+)=([^=]+)$")
        if group and enabled then
          group_registry[group] = (enabled == "true")
        end
      end
    end
  end
end

-- Save group registry to file
local function save_group_registry()
  local path = require("pl.path")
  local dir = path.dirname(registry_file)

  -- Ensure directory exists
  if not path.isdir(dir) then
    path.mkdir(dir)
  end

  local f = io.open(registry_file, "w")
  if f then
    for group, enabled in pairs(group_registry) do
      f:write(string.format("%s=%s\n", group, tostring(enabled)))
    end
    f:close()
  end
end

-- Register a group if not already registered
-- New groups default to enabled (true)
-- Excluded groups (ambiance, environment) are not registered
local function register_group(group)
  if not group or group == "" then
    return
  end

  -- Skip excluded groups
  if excluded_groups[group] then
    return
  end

  -- If group is not in registry, add it as enabled
  if group_registry[group] == nil then
    group_registry[group] = true
    save_group_registry()
  end
end

-- Check if a group is enabled
-- Returns true if enabled or not yet registered (default enabled)
-- Excluded groups always return true
function is_group_enabled(group)
  if not group or group == "" then
    return true -- Unknown groups are enabled by default
  end

  -- Excluded groups are always enabled (they have their own controls)
  if excluded_groups[group] then
    return true
  end

  -- If not in registry, it's enabled by default
  if group_registry[group] == nil then
    return true
  end

  return group_registry[group]
end

-- Get all registered groups
function get_all_sound_groups()
  local groups = {}
  for group, _ in pairs(group_registry) do
    table.insert(groups, group)
  end
  table.sort(groups)
  return groups
end

-- Set group enabled state
function set_group_enabled(group, enabled)
  if not group or group == "" then
    return
  end

  -- Don't allow changing excluded groups
  if excluded_groups[group] then
    return
  end

  group_registry[group] = enabled
  save_group_registry()
end

-- Initialize group registry on module load
load_group_registry()

-- Default variants for sounds (defines which variant is used by default)
local variant_defaults = {
  ["miriani/ship/move/accelerate.ogg"] = 3,
  ["miriani/ship/move/decelerate.ogg"] = 3,
  ["miriani/activity/archaeology/artifactHere.ogg"] = 1,
["miriani/vehicle/accelerate.ogg"] = 1,
["miriani/vehicle/decelerate.ogg"] = 1,
}

-- Sound variant preferences: maps sound base name to selected variant number
-- e.g., { ["miriani/ship/accelerate"] = 2 } means always use accelerate2.ogg
-- nil means use the default variant, 0 means random selection
local variant_preferences = {}

-- Load sound variant preferences from config
local function load_variant_preferences()
  if not config then
    return
  end

  local loaded = config:load_from_file()
  if loaded and loaded.sound_variants then
    variant_preferences = loaded.sound_variants
  end
end

-- Save variant preferences to config
local function save_variant_preferences()
  if not config then
    return
  end

  -- Update the config's internal state
  config.sound_variants = variant_preferences

  -- Save to toastush.conf
  config:save()
end

-- Get the variant preference for a sound
-- Returns: variant number (1, 2, 3, etc.) or 0 for random
-- If no preference is set, returns the default variant for that sound
function get_variant_preference(sound_path)
  -- Normalize path: convert alternate audio paths to standard paths for preference lookup
  -- This ensures alternate and standard audio share the same variant preferences
  local normalized_path = sound_path
  if sound_path:match("^alternate/") then
    normalized_path = sound_path:gsub("^alternate/", "miriani/")
  end

  local pref = variant_preferences[normalized_path]

  -- If a preference is explicitly set, use it (even if it's 0 for random)
  if pref ~= nil then
    return pref
  end

  -- Otherwise, use the default for this sound (or 0 if no default is defined)
  return variant_defaults[normalized_path] or 0
end

-- Set the variant preference for a sound
-- variant: variant number (1, 2, 3, etc.) or 0 for random
function set_variant_preference(sound_path, variant)
  -- Normalize path: convert alternate audio paths to standard paths
  -- This ensures alternate and standard audio share the same variant preferences
  local normalized_path = sound_path
  if sound_path:match("^alternate/") then
    normalized_path = sound_path:gsub("^alternate/", "miriani/")
  end

  variant = tonumber(variant) or 0

  if variant == 0 then
    -- Remove preference to use default random behavior
    variant_preferences[normalized_path] = nil
  else
    variant_preferences[normalized_path] = variant
  end

  save_variant_preferences()
end

-- Scan for available variants of a sound file
-- Returns: table of available variant numbers, or empty table if none found
function scan_sound_variants(file)
  local path = require("pl.path")
  local sound_dir = config:get("SOUND_DIRECTORY")
  local file_base, ext = path.splitext(file)

  -- Check if the base filename already ends with a number
  local has_number = string.match(file_base, "%d+$")
  if has_number then
    -- This is already a numbered variant, don't scan
    return {}
  end

  -- Extract just the filename without directory
  local file_dir = path.dirname(file)
  local just_filename = path.basename(file_base)

  -- Build search pattern: sound_dir + file_dir + "/" + just_filename + "*" + ext
  local search_pattern
  if file_dir == "." then
    search_pattern = sound_dir .. just_filename .. "*" .. ext
  else
    search_pattern = sound_dir .. file_dir .. "/" .. just_filename .. "*" .. ext
  end

  local search = utils.readdir(search_pattern)

  if not search or type(search) ~= "table" or not next(search) then
    return {}
  end

  local variants = {}
  for filename, metadata in pairs(search) do
    if not metadata.directory then
      -- Extract variant number from filename
      -- e.g., "accelerate2.ogg" -> 2
      -- Strip extension manually since path.basename isn't doing it
      local base_name = filename:gsub("%.ogg$", ""):gsub("%.wav$", "")
      local variant_num = base_name:match("^" .. just_filename .. "(%d+)$")

      if variant_num then
        table.insert(variants, tonumber(variant_num))
      end
    end
  end

  table.sort(variants)
  return variants
end

-- Initialize variant preferences on module load
load_variant_preferences()


function find_sound_file(file)
  local path = require("pl.path")
  local sound_dir = config:get("SOUND_DIRECTORY")
  local file_base, ext = path.splitext(file)

  -- Check if the file already exists as-is
  if path.isfile(sound_dir .. file) then
    return sound_dir .. file
  end

  -- Check if the base filename already ends with a number
  local has_number = string.match(file_base, "%d+$")
  if has_number then
    return nil -- Don't randomize numbered files that don't exist
  end

  -- Check for user variant preference
  local preference = get_variant_preference(file)
  if preference and preference > 0 then
    -- User has selected a specific variant
    local variant_file = file_base .. tostring(preference) .. ext
    local variant_path = sound_dir .. variant_file

    if path.isfile(variant_path) then
      return variant_path
    else
      -- Variant preference is set but file doesn't exist, fall through to random
      if config:get_option("debug_mode").value == "yes" then
        notify("important", string.format("Preferred variant %d not found for: %s", preference, file))
      end
    end
  end

  -- Use utils.readdir to find files with wildcards
  local search_pattern = sound_dir .. file_base .. "*" .. ext
  local search = utils.readdir(search_pattern)

  if search and type(search) == "table" and next(search) then
    local files = {}
    for filename, metadata in pairs(search) do
      if not metadata.directory then
        -- Store the full path to the file
        local full_path = sound_dir .. path.dirname(file)
        if path.dirname(file) ~= "." then
          full_path = full_path .. "/"
        end
        table.insert(files, full_path .. filename)
      end
    end

    if #files > 0 then
      -- Pick a random file from the list and return its full path
      return files[math.random(#files)]
    end
  end

  return nil
end

function play(file, group, interrupt, pan, loop, slide, sec, ignore_focus, custom_offset)
  local path = require("pl.path")
  group = group or "other"
  sec = tonumber(sec) or 1 -- 1 second fadeout by default

  -- Periodic device health check
  periodic_device_check()

  if config:is_mute() then
    return -- Audio is muted.
  end -- if

  -- Group filtering: register the group and check if it's enabled
  register_group(group)

  if not is_group_enabled(group) then
    return -- This group is disabled
  end

  -- foreground sounds: check foreground sounds mode
  if not window_has_focus and not ignore_focus then
    local fsounds_option = config:get_option("foreground_sounds")
    local fsounds_enabled = fsounds_option.value or "yes"
    if fsounds_enabled == "yes" then
      -- When foreground sounds is enabled, don't play any new sounds when not in focus (except ignore_focus bypass)
      return
    elseif group == "ambiance" then
      -- When foreground sounds is disabled, still don't start new ambience when not in focus
      return
    end -- if
  end -- if

  local sfile
  local original_file = file

  -- Find the sound file
  sfile = find_sound_file(original_file)

  if not sfile then
    if config:get_option("debug_mode").value == "yes" then
      notify("important", string.format("Unable to find audio file: %s", original_file))
    end
    return
  end

  -- Handle interrupt - stop all sounds in group if needed
  if interrupt and is_group_playing(group) then
    -- For ambiance, only interrupt if it's a different sound
    if group == "ambiance" then
      local should_interrupt = false
      if streamtable[group] then
        for _, sound_data in ipairs(streamtable[group]) do
          if sound_data.file ~= sfile then
            should_interrupt = true
            break
          end
        end
      end
      if should_interrupt then
        stop(group) -- Stop all sounds in the group
      end
    else
      -- For non-ambiance groups, always interrupt
      stop(group) -- Stop all sounds in the group
    end
  end

  -- Clean up finished sounds before adding new one
  cleanup_group(group)

  -- New volume system: master * (category_volume + offset)
  -- Get the base category for this group (sounds or environment)
  local master_vol = config:get_master_volume() or 100
  local base_category = config:get_base_category(group)
  local category_vol = config:get_attribute(base_category, "volume") or 100
  local group_pan = config:get_attribute(base_category, "pan") or 0

  -- Use custom offset if provided, otherwise use group offset
  local offset = tonumber(custom_offset) or config:get_offset(group)

  -- Use provided pan or group pan
  local final_pan = pan or group_pan

  -- Convert loop parameter
  local loop_mode = loop and 1 or 0

  -- Calculate final volume: master * (category + offset) / 10000
  -- Clamp offset application to 0-100 range
  local adjusted_vol = math.max(0, math.min(100, category_vol + offset))
  local final_volume = (master_vol / 100.0) * (adjusted_vol / 100.0)

  -- Convert volume to decimal
  local volume = final_volume

  -- Verify file exists before attempting to play
  if not path.isfile(sfile) then
    notify("important", string.format("Audio file not found: %s", sfile))
    return
  end

  -- Add loop flag if needed
  local flags = Audio.CONST.stream.auto_free
  if loop then
    -- Check if loop constant exists, otherwise use a common BASS loop flag
    local loop_flag = Audio.CONST.stream.loop or 4 -- BASS_SAMPLE_LOOP = 4
    flags = flags + loop_flag
  end

  local stream = BASS:StreamCreateFile(false, sfile, 0, 0, flags)

  -- Validate stream creation
  if type(stream) == "number" then
    -- Error codes that indicate device issues:
    -- 4 = buffer_lost (device disconnected/changed)
    -- 23 = device (illegal device number)
    -- 3 = driver (can't find free/valid driver)
    -- 9 = start (BASS_Start has not been successfully called)
    if stream == 4 or stream == 23 or stream == 3 or stream == 9 then
      if config:get_option("debug_mode").value == "yes" then
        notify("important", string.format("Audio device error (code %d), attempting recovery...", stream))
      end

      -- Use the improved recovery mechanism
      local recovery_success, recovery_message = BASS:RecoverFromDeviceFailure()
      if recovery_success then
        if config:get_option("debug_mode").value == "yes" then
          notify("info", "Device recovery successful: " .. recovery_message)
        end

        -- Retry playing the sound
        stream = BASS:StreamCreateFile(false, sfile, 0, 0, flags)
        if type(stream) == "number" then
          -- Still failing after recovery, give up
          if config:get_option("debug_mode").value == "yes" then
            notify("important", string.format("BASS audio failed after recovery: %s (error code %d)", sfile, stream))
          end
          return
        end
        -- Successfully recovered, continue below to play sound
      else
        -- Recovery failed - no available device, fail silently
        if config:get_option("debug_mode").value == "yes" then
          notify("important", "Device recovery failed: " .. recovery_message)
        end
        return
      end
    else
      if config:get_option("debug_mode").value == "yes" then
        notify("important", string.format("BASS audio failed to play: %s (error code %d)", sfile, stream))
      end
      return
    end
  end

  -- Set volume for this group
  stream:SetAttribute(Audio.CONST.attribute.volume, volume)

  -- Only set pan if it's not zero (avoid unnecessary panning)
  if final_pan ~= 0 then
    stream:SetAttribute(Audio.CONST.attribute.pan, final_pan / 100.0) -- Convert to -1 to 1 range
  end

  -- Play the stream
  stream:Play()

  -- Track the stream for group management
  add_stream(group, stream, original_file)

  -- Log to sounds buffer if enabled
  if config:get_option("sounds_buffer").value == "yes" then
    Execute("history_add sounds=" .. original_file)
  end

end -- play

function stop(group, option, slide, sec)
  sec = tonumber(sec) or 1 -- 1 second fade out

  if not streamtable then
    return 0
  end

  local streams = {}
  if not group then
    -- Stop all groups
    for g, files in pairs(streamtable) do
      for _, sound_data in ipairs(files) do
        streams[#streams + 1] = sound_data
      end
      streamtable[g] = nil
    end
  else
    -- Stop specific group
    if streamtable[group] then
      for _, sound_data in ipairs(streamtable[group]) do
        streams[#streams + 1] = sound_data
      end
      if option == 1 then
        -- Remove only the last sound
        table.remove(streamtable[group])
      else
        -- Remove all sounds from group
        streamtable[group] = nil
      end
    end
  end

  -- Stop the BASS streams
  for _, sound_data in ipairs(streams) do
    if sound_data.stream then
      if slide then
        -- Fade out (BASS doesn't have built-in fadeout, so just stop)
        sound_data.stream:Stop()
      else
        -- Stop immediately
        sound_data.stream:Stop()
      end
      -- Properly free the BASS stream resource
      sound_data.stream:Free()
    end
  end

  return 1
end -- stop

function add_stream(group, stream, file, volume)
  if not streamtable[group] then
    streamtable[group] = {}
  end

  streamtable[group][#streamtable[group] + 1] = {
    stream = stream,
    file = file
  }

  -- Cap at 10 sounds per group
  if #streamtable[group] > 10 then
    local old_sound = table.remove(streamtable[group], 1)
    if old_sound.stream then
      old_sound.stream:Stop()
      -- Properly free the BASS stream resource
      old_sound.stream:Free()
    end
  end
end -- add_stream

function is_group_playing(group)
  if not streamtable[group] then
    return 0
  end

  -- Clean up finished sounds
  cleanup_group(group)

  -- Check again after cleanup since cleanup_group might set streamtable[group] to nil
  if not streamtable[group] then
    return 0
  end

  return #streamtable[group] > 0 and 1 or 0
end -- is_group_playing

function slide_group(group, attr, value, time_ms)
  if not streamtable[group] then
    return
  end

  time_ms = time_ms or 1000

  -- Apply changes to all currently playing streams in this group
  for _, sound_data in ipairs(streamtable[group]) do
    if sound_data.stream then
      if attr == "volume" then
        -- Apply master volume multiplication with offset support
        local master_vol = config:get_master_volume() or 100
        local offset = config:get_offset(group)
        local adjusted_vol = math.max(0, math.min(100, value + offset))
        local final_volume = (master_vol / 100.0) * (adjusted_vol / 100.0)
        sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, final_volume)
      elseif attr == "pan" then
        sound_data.stream:SetAttribute(Audio.CONST.attribute.pan, value / 100.0)
      end
    end
  end
end -- slide_group

-- Focus handling functions

function pause_all_sounds()
  window_has_focus = false
  local fsounds_option = config:get_option("foreground_sounds")
  local fsounds_enabled = fsounds_option.value or "yes"

  -- Clean up finished streams first
  for group, _ in pairs(streamtable) do
    cleanup_group(group)
  end

  -- Always pause ambience when losing focus (regardless of foreground sounds setting)
  if streamtable["ambiance"] then
    for _, sound_data in ipairs(streamtable["ambiance"]) do
      if sound_data.stream then
        sound_data.stream:Pause()
      end
    end
  end

  if fsounds_enabled == "yes" then
    -- When foreground sounds is enabled, also stop all other sounds permanently
    for group, sounds in pairs(streamtable) do
      if group ~= "ambiance" then
        -- Stop all non-ambience sounds permanently
        for _, sound_data in ipairs(sounds) do
          if sound_data.stream then
            sound_data.stream:Stop()
            -- Properly free the BASS stream resource
            sound_data.stream:Free()
          end
        end
        streamtable[group] = nil -- Clear the group since sounds are stopped
      end
    end
  end
  -- When foreground sounds is disabled, only ambience is paused, other sounds continue playing
end

function resume_all_sounds()
  window_has_focus = true
  
  -- Always resume paused ambience when window regains focus (regardless of foreground sounds setting)
  if streamtable["ambiance"] then
    for _, sound_data in ipairs(streamtable["ambiance"]) do
      if sound_data.stream then
        sound_data.stream:Play()
      end
    end
  end
  -- Other sounds: when foreground sounds is off, they were never stopped so nothing to resume
  -- When foreground sounds is on, they were stopped permanently so nothing to resume
end

-- Global cleanup function for proper resource management
function cleanup_all_streams()
  for group, sounds in pairs(streamtable) do
    for _, sound_data in ipairs(sounds) do
      if sound_data.stream then
        sound_data.stream:Stop()
        sound_data.stream:Free()
      end
    end
  end
  streamtable = {}
end

-- Audio group management for volume controls
-- Simplified: only cycle between master, sounds, environment
local volume_groups = {"master", "sounds", "environment"}

function forward_cycle_audio_groups()
  active_group = active_group + 1
  if active_group > #volume_groups then
    active_group = 1
  end

  mplay("misc/mouseClick")
  local group_name = volume_groups[active_group]
  local volume

  if group_name == "master" then
    volume = config:get_master_volume()
  else
    volume = config:get_attribute(group_name, "volume") or 0
  end

  Execute(string.format("tts_interrupt %s %d%%", group_name, volume))
end

function previous_cycle_audio_groups()
  active_group = active_group - 1
  if active_group < 1 then
    active_group = #volume_groups
  end

  mplay("misc/mouseClick")
  local group_name = volume_groups[active_group]
  local volume

  if group_name == "master" then
    volume = config:get_master_volume()
  else
    volume = config:get_attribute(group_name, "volume") or 0
  end

  Execute(string.format("tts_interrupt %s %d%%", group_name, volume))
end

function increase_attribute(attribute)
  if active_group > 0 and active_group <= #volume_groups then
    local group_name = volume_groups[active_group]

    if group_name == "master" then
      -- Adjusting master volume
      if attribute == "volume" then
        local current_val = config:get_master_volume()
        local new_val = math.min(current_val + 5, 100)
        config:set_master_volume(new_val)

        -- Apply to all currently playing sounds
        for group, sounds in pairs(streamtable) do
          local base_category = config:get_base_category(group)
          local category_vol = config:get_attribute(base_category, "volume") or 100
          local offset = config:get_offset(group)
          local adjusted_vol = math.max(0, math.min(100, category_vol + offset))
          local final_volume = (new_val / 100.0) * (adjusted_vol / 100.0)
          for _, sound_data in ipairs(sounds) do
            if sound_data.stream then
              sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, final_volume)
            end
          end
        end

        Execute(string.format("tts_interrupt master %d%%", new_val))
        mplay("misc/volume")
        BroadcastPlugin(999, "audio_volume_changed|master," .. new_val)
      end
    else
      -- Adjusting sounds or environment volume
      if attribute == "volume" then
        local current_val = config:get_attribute(group_name, "volume") or 0
        local new_val = math.min(current_val + 5, 100)
        config:set_attribute(group_name, "volume", new_val)
        config:save()

        -- Apply volume change to all currently playing sounds that use this category
        local master_vol = config:get_master_volume() or 100
        for group, sounds in pairs(streamtable) do
          -- Check if this group uses the category we're adjusting
          local base_category = config:get_base_category(group)

          if base_category == group_name then
            local category_vol = new_val
            local offset = config:get_offset(group)
            local adjusted_vol = math.max(0, math.min(100, category_vol + offset))
            local final_volume = (master_vol / 100.0) * (adjusted_vol / 100.0)

            for _, sound_data in ipairs(sounds) do
              if sound_data.stream then
                sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, final_volume)
              end
            end
          end
        end

        Execute(string.format("tts_interrupt %s %d%%", group_name, new_val))
        mplay("misc/volume")
        BroadcastPlugin(999, "audio_volume_changed|" .. group_name .. "," .. new_val)
      elseif attribute == "pan" then
        local current_val = config:get_attribute(group_name, "pan") or 0
        local new_val = math.min(current_val + 5, 100)
        config:set_attribute(group_name, "pan", new_val)
        config:save()
        slide_group(group_name, "pan", new_val)
        notify("info", string.format("%s %s: %d", group_name, attribute, new_val))
      end
    end
  end
end

function decrease_attribute(attribute)
  if active_group > 0 and active_group <= #volume_groups then
    local group_name = volume_groups[active_group]

    if group_name == "master" then
      -- Adjusting master volume
      if attribute == "volume" then
        local current_val = config:get_master_volume()
        local new_val = math.max(current_val - 5, 0)
        config:set_master_volume(new_val)

        -- Apply to all currently playing sounds
        for group, sounds in pairs(streamtable) do
          local base_category = config:get_base_category(group)
          local category_vol = config:get_attribute(base_category, "volume") or 100
          local offset = config:get_offset(group)
          local adjusted_vol = math.max(0, math.min(100, category_vol + offset))
          local final_volume = (new_val / 100.0) * (adjusted_vol / 100.0)
          for _, sound_data in ipairs(sounds) do
            if sound_data.stream then
              sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, final_volume)
            end
          end
        end

        Execute(string.format("tts_interrupt master %d%%", new_val))
        mplay("misc/volume")
        BroadcastPlugin(999, "audio_volume_changed|master," .. new_val)
      end
    else
      -- Adjusting sounds or environment volume
      if attribute == "volume" then
        local current_val = config:get_attribute(group_name, "volume") or 0
        local new_val = math.max(current_val - 5, 0)
        config:set_attribute(group_name, "volume", new_val)
        config:save()

        -- Apply volume change to all currently playing sounds that use this category
        local master_vol = config:get_master_volume() or 100
        for group, sounds in pairs(streamtable) do
          -- Check if this group uses the category we're adjusting
          local base_category = config:get_base_category(group)

          if base_category == group_name then
            local category_vol = new_val
            local offset = config:get_offset(group)
            local adjusted_vol = math.max(0, math.min(100, category_vol + offset))
            local final_volume = (master_vol / 100.0) * (adjusted_vol / 100.0)

            for _, sound_data in ipairs(sounds) do
              if sound_data.stream then
                sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, final_volume)
              end
            end
          end
        end

        Execute(string.format("tts_interrupt %s %d%%", group_name, new_val))
        mplay("misc/volume")
        BroadcastPlugin(999, "audio_volume_changed|" .. group_name .. "," .. new_val)
      elseif attribute == "pan" then
        local current_val = config:get_attribute(group_name, "pan") or 0
        local new_val = math.max(current_val - 5, 0)
        config:set_attribute(group_name, "pan", new_val)
        config:save()
        slide_group(group_name, "pan", new_val)
        notify("info", string.format("%s %s: %d", group_name, attribute, new_val))
      end
    end
  end
end

function toggle_mute()
  -- Check current mute state first
  local was_muted = config:is_mute()

  if was_muted then
    -- If currently muted, unmute first then play click
    local result = config:toggle_mute()
    mplay("misc/mouseClick", "notification")
    -- Restore current group volumes when unmuting (in case they changed while muted)
    for group, sounds in pairs(streamtable) do
      local master_vol = config:get_master_volume() or 100
      local base_category = config:get_base_category(group)
      local category_vol = config:get_attribute(base_category, "volume") or 100
      local offset = config:get_offset(group)
      local adjusted_vol = math.max(0, math.min(100, category_vol + offset))
      local final_volume = (master_vol / 100.0) * (adjusted_vol / 100.0)
      for _, sound_data in ipairs(sounds) do
        if sound_data.stream then
          sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, final_volume)
        end
      end
    end
  else
    -- If currently unmuted, play click then mute by setting volume to 0
    mplay("misc/mouseClick", "notification")
    local result = config:toggle_mute()
    -- Set volume to 0 for all currently playing sounds when muting (they continue playing silently)
    for group, sounds in pairs(streamtable) do
      for _, sound_data in ipairs(sounds) do
        if sound_data.stream then
          sound_data.stream:SetAttribute(Audio.CONST.attribute.volume, 0.0)
        end
      end
    end
  end

  local status = config:is_mute() and "muted" or "unmuted"
  notify("info", "Audio " .. status)
end

function pause_group(group)
  if not streamtable[group] then
    return
  end

  for _, sound_data in ipairs(streamtable[group]) do
    if sound_data.stream then
      sound_data.stream:Pause()
    end
  end
end

function resume_group(group)
  if not streamtable[group] then
    return
  end

  for _, sound_data in ipairs(streamtable[group]) do
    if sound_data.stream then
      sound_data.stream:Play()
    end
  end
end

