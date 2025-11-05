-- @module sound_preferences
-- Sound group and variant preference management
-- Extracted from sounds.lua to separate concerns
-- Part of the unified configuration system

local sound_preferences = {}

-- Get config instance (will be initialized by sounds.lua)
local config = nil

-- Initialize with config instance
function sound_preferences.init(config_instance)
  config = config_instance
end

---------------------------------------------
-- SOUND GROUPS MANAGEMENT
---------------------------------------------

-- Check if a group is enabled
-- Now delegates to config system
function sound_preferences.is_group_enabled(group)
  if not config then
    return true -- Default to enabled if config not initialized
  end

  if not group or group == "" then
    return true
  end

  -- Check if this is an excluded group (uses volume controls instead)
  if config.schema and config.schema.excluded_sound_groups and config.schema.excluded_sound_groups[group] then
    return true -- Excluded groups are always "enabled" (controlled by volume)
  end

  return config:get_sound_group(group)
end

-- Get all sound groups (including dynamically discovered)
function sound_preferences.get_all_sound_groups()
  if not config then
    return {}
  end

  local groups = config:get_all_sound_groups()
  local sorted = {}

  for group, _ in pairs(groups) do
    -- Skip excluded groups from the list
    if not (config.schema and config.schema.excluded_sound_groups and config.schema.excluded_sound_groups[group]) then
      table.insert(sorted, group)
    end
  end

  table.sort(sorted)
  return sorted
end

-- Set group enabled state
function sound_preferences.set_group_enabled(group, enabled)
  if not config then
    return
  end

  if not group or group == "" then
    return
  end

  -- Don't allow changing excluded groups
  if config.schema and config.schema.excluded_sound_groups and config.schema.excluded_sound_groups[group] then
    return
  end

  config:set_sound_group(group, enabled)
  config:save()
end

-- Register a new sound group (called when sounds are played)
function sound_preferences.register_group(group)
  if not config then
    return
  end

  if not group or group == "" then
    return
  end

  -- Skip excluded groups
  if config.schema and config.schema.excluded_sound_groups and config.schema.excluded_sound_groups[group] then
    return
  end

  -- Check if group is already known
  local current = config:get_sound_group(group)

  -- If it's a new group (nil result means unknown), add it as enabled
  if current == nil then
    config:set_sound_group(group, true)
    -- Note: We don't save immediately here to avoid excessive disk writes
    -- The config will be saved periodically or when the user changes settings
  end
end

---------------------------------------------
-- SOUND VARIANTS MANAGEMENT
---------------------------------------------

-- Get the variant preference for a sound
-- Returns: variant number (1, 2, 3, etc.) or 0 for random
function sound_preferences.get_variant_preference(sound_path)
  if not config then
    return 1 -- Default variant
  end

  return config:get_sound_variant(sound_path)
end

-- Set the variant preference for a sound
-- variant: variant number (1, 2, 3, etc.) or 0 for random
function sound_preferences.set_variant_preference(sound_path, variant)
  if not config then
    return
  end

  variant = tonumber(variant) or 1

  config:set_sound_variant(sound_path, variant)
  config:save()
end

-- Scan for available variants of a sound file
-- Returns: table of available variant numbers, or empty table if none found
function sound_preferences.scan_sound_variants(file)
  local path = require("pl.path")
  local sound_dir = config and config:get("SOUND_DIRECTORY") or "sounds/"
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

  -- Build search pattern
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

-- Get list of sounds that have variants available
function sound_preferences.get_variant_capable_sounds()
  if not config or not config.schema or not config.schema.sound_variants then
    return {}
  end

  local sounds = {}
  for path, info in pairs(config.schema.sound_variants) do
    table.insert(sounds, {
      path = path,
      name = info.name,
      default = info.default,
      current = config:get_sound_variant(path)
    })
  end

  -- Sort by name for display
  table.sort(sounds, function(a, b)
    return a.name < b.name
  end)

  return sounds
end

-- Check if a specific sound has variants
function sound_preferences.has_variants(sound_path)
  local variants = sound_preferences.scan_sound_variants(sound_path)
  return #variants > 0
end

-- Get default variant for a sound
function sound_preferences.get_default_variant(sound_path)
  if not config or not config.schema or not config.schema.sound_variants then
    return 1
  end

  local variant_info = config.schema.sound_variants[sound_path]
  if variant_info then
    return variant_info.default
  end

  return 1
end

---------------------------------------------
-- MIGRATION SUPPORT
---------------------------------------------

-- Migrate old sound_groups.conf if needed (called during config migration)
-- This is now handled by Config:migrate_old_configs() in config.lua
-- Keeping this function for reference but it's not used
function sound_preferences.migrate_old_registry()
  -- Migration is handled by the unified config system
  -- Old sound_groups.conf is merged into miriani.conf
  return true
end

return sound_preferences