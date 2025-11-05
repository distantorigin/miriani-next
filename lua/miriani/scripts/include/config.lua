-- @module config
-- Defines methods for manipulating global constants.
-- Uses mush variables to serialize across sessions.

-- Author: Erick Rosso
-- Last updated on 2022.01.21

---------------------------------------------

local class = require("pl.class")

local vars = {
  consts = require("miriani.scripts.include.vars.consts"),
} -- vars

class.Config()

function Config:init(options, audio)

  -- Handle new options format (with group_metadata)
  local group_metadata = nil
  local schema = nil

  -- Check if we're being passed the new schema format
  if options and options.version and options.groups and options.options then
    -- New unified schema format
    schema = options
    vars.schema = schema

    -- Convert schema options to Config format
    local converted_options = {}
    for key, opt in pairs(schema.options) do
      converted_options[key] = {
        descr = opt.descr,
        value = opt.default,  -- Use default as initial value
        group = opt.group,
        type = opt.type,
        options = opt.options,  -- For enum types
        action = opt.action,    -- For function types (temporary, will remove in Phase 3)
        read = opt.read,        -- For function types (temporary, will remove in Phase 3)
      }
    end

    options = converted_options
    group_metadata = schema.groups

    -- Convert schema audio to Config format
    if schema.audio and schema.audio.categories then
      audio = schema.audio.categories
    else
      audio = schema.audio
    end
  elseif options and options.options and options.group_metadata then
    -- Old format: {options = {...}, group_metadata = {...}}
    group_metadata = options.group_metadata
    options = options.options
  end

  -- Store defaults in vars for later comparison
  vars.options = options or {}
  vars.audio = audio or {}
  vars.group_metadata = group_metadata
  vars.schema = schema

  -- Initialize master volume and mute (will be loaded from file if present)
  self.master_volume = 50
  self.master_mute = false

  -- Store audio offsets and category map separately if provided
  if schema and schema.audio then
    -- From schema
    if schema.audio.offsets then
      self.audio_offsets = schema.audio.offsets
    end
    if schema.audio.category_map then
      self.category_map = schema.audio.category_map
    end
  elseif audio then
    -- From old format
    if audio.offsets then
      self.audio_offsets = audio.offsets
    end
    if audio.category_map then
      self.category_map = audio.category_map
    end
  end

  -- CRITICAL: Ensure consts is always available (defensive loading)
  if not vars.consts then
    vars.consts = require("miriani.scripts.include.vars.consts")
  end

  -- Initialize consts immediately
  self.consts = vars.consts

  -- Verify initialization worked
  if not self.consts then
    error("Failed to initialize config constants")
  end

  -- If called without parameters (like Config()), we're done with basic initialization
  if not options and not audio then
    self.options = {}
    self.audio = {}
    return self.consts.error.OK
  end

  -- Helper function to deep copy a table
  local function deep_copy(orig)
    local copy
    if type(orig) == 'table' then
      copy = {}
      for k, v in pairs(orig) do
        copy[k] = deep_copy(v)
      end
    else
      copy = orig
    end
    return copy
  end

  -- Start with defaults
  self.options = deep_copy(vars.options)
  self.audio = deep_copy(vars.audio)

  local error = vars.consts.error.OK

  -- Try loading unified config first
  local unified_data = self:load_unified_config()

  if unified_data then
    -- Load from unified miriani.conf with validation
    if unified_data.options then
      for key, value in pairs(unified_data.options) do
        if self.options[key] then
          -- Validate before applying
          local valid, err_msg = self:validate_option(key, value)
          if valid then
            self.options[key].value = value
          else
            Note("Config load warning - invalid value for " .. key .. ": " .. tostring(value))
            Note("  Using default value instead")
            -- Keep default value (already set)
          end
        end
      end
    end

    if unified_data.audio then
      -- Load master volume and mute
      if unified_data.audio.master_volume then
        self.master_volume = unified_data.audio.master_volume
      end
      if unified_data.audio.master_mute ~= nil then
        self.master_mute = unified_data.audio.master_mute
      end

      -- Load category settings
      for group, attrs in pairs(unified_data.audio) do
        if group ~= "master_volume" and group ~= "master_mute" and self.audio[group] and type(attrs) == "table" then
          for attr, value in pairs(attrs) do
            if self.audio[group][attr] ~= nil then
              self.audio[group][attr] = value
            end
          end
        end
      end
    end

    -- Load sound groups
    if unified_data.sound_groups then
      self.sound_groups = unified_data.sound_groups
    end

    -- Load sound variants
    if unified_data.sound_variants then
      self.sound_variants = unified_data.sound_variants
    end

    return error -- Successfully loaded unified config
  end

  -- Otherwise, try to migrate old configs
  local migrated = self:migrate_old_configs()
  if migrated then
    -- Reload after migration
    unified_data = self:load_unified_config()
    if unified_data then
      -- Apply migrated data (same as above)
      if unified_data.options then
        for key, value in pairs(unified_data.options) do
          if self.options[key] then
            self.options[key].value = value
          end
        end
      end

      if unified_data.audio then
        if unified_data.audio.master_volume then
          self.master_volume = unified_data.audio.master_volume
        end
        if unified_data.audio.master_mute ~= nil then
          self.master_mute = unified_data.audio.master_mute
        end

        for group, attrs in pairs(unified_data.audio) do
          if group ~= "master_volume" and group ~= "master_mute" and self.audio[group] and type(attrs) == "table" then
            for attr, value in pairs(attrs) do
              if self.audio[group][attr] ~= nil then
                self.audio[group][attr] = value
              end
            end
          end
        end
      end

      if unified_data.sound_groups then
        self.sound_groups = unified_data.sound_groups
      end

      if unified_data.sound_variants then
        self.sound_variants = unified_data.sound_variants
      end

      return error
    end
  end

  -- Fall back to old loading method if no unified config and no migration
  local file_data = self:load_from_file()

  if file_data then
    -- Check if this is old format (full option structures) or new format (values only)
    local is_old_format = false
    if file_data.options then
      for k, v in pairs(file_data.options) do
        if type(v) == "table" and v.descr and v.value ~= nil then
          is_old_format = true
          break
        end
      end
    end

    if is_old_format then
      -- Old format: merge full structures, keeping user values
      if file_data.options then
        for key, saved_option in pairs(file_data.options) do
          if self.options[key] and saved_option.value ~= nil then
            local value = saved_option.value
            -- Migrate old boolean values to new enum values
            if self.options[key].type == "enum" then
              if key == "scan_interrupt" and (value == "yes" or value == true) then
                value = "starships"
              elseif key == "scan_interrupt" and (value == "no" or value == false) then
                value = "off"
              end
            end
            -- Keep the user's value but update metadata from defaults
            self.options[key].value = value
          end
        end
      end

      if file_data.audio then
        for group, attrs in pairs(file_data.audio) do
          if self.audio[group] and type(attrs) == "table" then
            for attr, value in pairs(attrs) do
              if self.audio[group][attr] ~= nil then
                self.audio[group][attr] = value
              end
            end
          end
        end
      end

      -- Load master volume and mute settings from old format
      if file_data.master_volume then
        self.master_volume = tonumber(file_data.master_volume) or 100
      end
      if file_data.master_mute ~= nil then
        self.master_mute = file_data.master_mute
      end

      -- Load sound variants
      if file_data.sound_variants then
        self.sound_variants = file_data.sound_variants
      end

      -- Convert to new format by saving
      self:save_to_file()
    else
      -- New format: just apply user values to defaults
      if file_data.options then
        for key, value in pairs(file_data.options) do
          if self.options[key] then
            -- Migrate old boolean values to new enum values
            if self.options[key].type == "enum" then
              -- Handle scan_interrupt migration from boolean to enum
              if key == "scan_interrupt" and (value == "yes" or value == true) then
                value = "starships"
              elseif key == "scan_interrupt" and (value == "no" or value == false) then
                value = "off"
              end
            end
            self.options[key].value = value
          end
        end
      end

      if file_data.audio then
        for group, attrs in pairs(file_data.audio) do
          if self.audio[group] and type(attrs) == "table" then
            for attr, value in pairs(attrs) do
              if self.audio[group][attr] ~= nil then
                self.audio[group][attr] = value
              end
            end
          end
        end
      end

      -- Load master volume and mute settings
      if file_data.master_volume then
        self.master_volume = tonumber(file_data.master_volume) or 100
      end
      if file_data.master_mute ~= nil then
        self.master_mute = file_data.master_mute
      end

      -- Load sound variants
      if file_data.sound_variants then
        self.sound_variants = file_data.sound_variants
      end
    end

  end -- if file_data

  -- Also load auto_login settings from separate file
  local auto_login_data = self:load_auto_login_from_file()

  if auto_login_data and auto_login_data.options then
    -- Apply auto_login settings to current config
    for key, value in pairs(auto_login_data.options) do
      if self.options[key] then
        self.options[key].value = value
      end
    end
  end

  return error
end -- _init

function Config:get_option(key)
  if not self.options then
    return {}
  end
  return self.options[key] or {}
end -- get_option

function Config:get_attribute(group, attr)
  if self.audio[group] and self.audio[group][attr] then
    return self.audio[group][attr]
  end -- if

  return self.consts.error.INVALID_ARG
end -- get_attribute

function Config:validate_option(key, val)
  if not self.options[key] then
    return false, "Unknown option: " .. tostring(key)
  end

  local option = self.options[key]
  local opt_type = option.type

  -- Type-specific validation
  if opt_type == "bool" or opt_type == "boolean" then
    -- Accept various boolean representations
    local valid_values = {
      ["yes"] = true, ["no"] = true,
      ["true"] = true, ["false"] = true,
      ["on"] = true, ["off"] = true,
      ["1"] = true, ["0"] = true
    }
    if type(val) == "boolean" then
      return true
    elseif type(val) == "string" and valid_values[val:lower()] then
      return true
    else
      return false, "Boolean value must be yes/no, true/false, on/off, or 1/0"
    end

  elseif opt_type == "enum" then
    -- Check if value is in allowed options
    if option.options then
      for _, allowed in ipairs(option.options) do
        if val == allowed then
          return true
        end
      end
      return false, "Value must be one of: " .. table.concat(option.options, ", ")
    end

  elseif opt_type == "string" or opt_type == "password" then
    -- Strings can be anything, but check for reasonable length
    if type(val) ~= "string" then
      return false, "Value must be a string"
    end
    if #val > 1000 then
      return false, "String value too long (max 1000 characters)"
    end
    return true

  elseif opt_type == "function" or opt_type == "color" then
    -- Color values should be numbers
    if type(val) ~= "number" then
      return false, "Color value must be a number"
    end
    -- RGB color range
    if val < 0 or val > 16777215 then
      return false, "Color value out of range (0-16777215)"
    end
    return true
  end

  -- Default: accept anything for unknown types
  return true
end

function Config:set_option(key, val)
  if not self.options[key] then
    return self.consts.error.INVALID_ARG
  end -- if

  -- Validate the value
  local valid, err_msg = self:validate_option(key, val)
  if not valid then
    Note("Config validation error for " .. key .. ": " .. (err_msg or "Invalid value"))
    return self.consts.error.INVALID_ARG
  end

  -- If empty string is provided, reset to default value
  if val == "" and self.options[key].type == "string" then
    -- Get the default value from schema or vars.options
    if vars.schema and vars.schema.options and vars.schema.options[key] then
      self.options[key].value = vars.schema.options[key].default
    elseif vars.options and vars.options[key] and vars.options[key].value then
      self.options[key].value = vars.options[key].value
    else
      -- Fallback if we can't find the default
      return self.consts.error.INVALID_ARG
    end
  else
    self.options[key].value = val
  end

  return self.consts.error.OK
end -- set_option

function Config:set_attribute(group, attr, val)
  if not self.audio[group] or not self.audio[group][attr] then
    return self.consts.error.INVALID_ARG
  end -- if

  if type(val) ~= type(self.audio[group][attr]) then
    return self.consts.error.INVALID_TYPE
  end -- if

  self.audio[group][attr] = val
  return self.consts.error.OK
end -- set_attribute

function Config:get_master_volume()
  return self.master_volume or 100
end -- get_master_volume

function Config:set_master_volume(val)
  val = tonumber(val)
  if not val or val < 0 or val > 100 then
    return self.consts.error.INVALID_ARG
  end

  self.master_volume = val
  return self.consts.error.OK
end -- set_master_volume

function Config:get_offset(category)
  if self.audio_offsets and self.audio_offsets[category] then
    return self.audio_offsets[category]
  end
  return 0
end -- get_offset

function Config:get_base_category(group)
  -- Check if this group has an explicit category mapping
  if self.category_map and self.category_map[group] then
    return self.category_map[group]
  end
  -- Default to "sounds"
  return "sounds"
end -- get_base_category

function Config:save_to_file()
  -- Don't save old format if we're using unified config
  if vars.schema then
    return self.consts.error.OK  -- Silently succeed, unified save handles it
  end

  local path = require("pl.path")
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local settings_dir = path.join(mushclient_dir, "worlds", "settings")
  local settings_file = path.join(settings_dir, "toastush.conf")

  -- Ensure directory exists
  local dir_ok = utils.readdir(settings_dir)
  if not dir_ok then
    local worlds_dir = path.join(mushclient_dir, "worlds")
    local ok = utils.shellexecute("cmd", "/C mkdir settings", worlds_dir, "open", 0)
    if not ok then
      return self.consts.error.NO_SAVE
    end
  end

  -- Only save values that differ from defaults
  local user_options = {}
  local user_audio = {}

  -- Get default options from vars (the original defaults from options.lua)
  local default_options = vars.options or {}

  -- Compare current options with defaults
  -- Exclude auto_login options as they're saved separately
  for key, option in pairs(self.options) do
    local default = default_options[key]
    -- Skip auto_login options - they go in separate file
    if not key:match("^auto_login") then
      if default and option.value ~= default.value then
        -- Only save the value, not the entire option structure
        user_options[key] = option.value
      end
    end
  end

  -- Get default audio from vars
  local default_audio = vars.audio or {}

  -- Compare current audio settings with defaults
  for group, attrs in pairs(self.audio) do
    local default_group = default_audio[group]
    if default_group and type(attrs) == "table" then
      for attr, value in pairs(attrs) do
        if default_group[attr] ~= nil and value ~= default_group[attr] then
          if not user_audio[group] then
            user_audio[group] = {}
          end
          user_audio[group][attr] = value
        end
      end
    end
  end

  -- Create global variable for serialization with only changed values
  toastush_config = {
    options = user_options,
    audio = user_audio,
    master_volume = self.master_volume ~= 100 and self.master_volume or nil,
    master_mute = self.master_mute or nil,
    sound_variants = self.sound_variants or nil,
    -- Note: we don't save consts anymore as they should come from code
  }

  local serialize = require("serialize")
  local serial_config, error = serialize.save("toastush_config")

  if type(serial_config) ~= 'string' then
    return error or self.consts.error.UNKNOWN
  end

  local file, err = io.open(settings_file, "w")
  if not file then
    return self.consts.error.NO_SAVE
  end

  file:write(serial_config)
  file:close()

  return self.consts.error.OK
end -- save_to_file

function Config:save_auto_login_to_file()
  -- Don't save old format if we're using unified config
  if vars.schema then
    return self.consts.error.OK  -- Silently succeed, unified save handles it
  end

  local path = require("pl.path")
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local settings_dir = path.join(mushclient_dir, "worlds", "settings")
  local settings_file = path.join(settings_dir, "auto_login.conf")

  -- Ensure directory exists
  local dir_ok = utils.readdir(settings_dir)
  if not dir_ok then
    local worlds_dir = path.join(mushclient_dir, "worlds")
    local ok = utils.shellexecute("cmd", "/C mkdir settings", worlds_dir, "open", 0)
    if not ok then
      return self.consts.error.NO_SAVE
    end
  end

  -- Get default options from vars
  local default_options = vars.options or {}

  -- Only save auto_login options that differ from defaults
  local auto_login_options = {}
  for key, option in pairs(self.options) do
    -- Only process auto_login options
    if key:match("^auto_login") then
      local default = default_options[key]
      if default and option.value ~= default.value then
        -- Only save the value, not the entire option structure
        auto_login_options[key] = option.value
      end
    end
  end

  -- Create global variable for serialization
  auto_login_config = {
    options = auto_login_options,
  }

  local serialize = require("serialize")
  local serial_config, error = serialize.save("auto_login_config")

  if type(serial_config) ~= 'string' then
    return error or self.consts.error.UNKNOWN
  end

  local file, err = io.open(settings_file, "w")
  if not file then
    return self.consts.error.NO_SAVE
  end

  file:write(serial_config)
  file:close()

  return self.consts.error.OK
end -- save_auto_login_to_file

function Config:load_from_file()
  local path = require("pl.path")
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local settings_file = path.join(mushclient_dir, "worlds", "settings", "toastush.conf")

  if not path.isfile(settings_file) then
    return nil -- File doesn't exist, not an error
  end

  local file, err = io.open(settings_file, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  if not content or content == "" then
    return nil
  end

  -- Load the serialized data
  local load_func, load_err = loadstring(content)
  if not load_func then
    return nil
  end

  load_func()

  if toastush_config then
    -- New format: only user-modified values
    -- We'll return this and merge with defaults in init
    return toastush_config
  end

  return nil
end -- load_from_file

function Config:load_auto_login_from_file()
  local path = require("pl.path")
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local settings_file = path.join(mushclient_dir, "worlds", "settings", "auto_login.conf")

  if not path.isfile(settings_file) then
    return nil -- File doesn't exist, not an error
  end

  local file, err = io.open(settings_file, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  if not content or content == "" then
    return nil
  end

  -- Load the serialized data
  local load_func, load_err = loadstring(content)
  if not load_func then
    return nil
  end

  load_func()

  if auto_login_config then
    -- Return the auto_login configuration
    return auto_login_config
  end

  return nil
end -- load_auto_login_from_file

-- New unified config methods
function Config:load_unified_config()
  local path = require("pl.path")
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local settings_file = path.join(mushclient_dir, "worlds", "settings", "miriani.conf")

  if not path.isfile(settings_file) then
    return nil -- File doesn't exist, not an error
  end

  local file, err = io.open(settings_file, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  if not content or content == "" then
    return nil
  end

  -- Load the serialized data
  local load_func, load_err = loadstring(content)
  if not load_func then
    return nil
  end

  load_func()

  if miriani_config then
    return miriani_config
  end

  return nil
end -- load_unified_config

function Config:save_unified_config()
  local path = require("pl.path")
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local settings_dir = path.join(mushclient_dir, "worlds", "settings")
  local settings_file = path.join(settings_dir, "miriani.conf")

  -- Ensure directory exists
  local dir_ok = utils.readdir(settings_dir)
  if not dir_ok then
    local worlds_dir = path.join(mushclient_dir, "worlds")
    local ok = utils.shellexecute("cmd", "/C mkdir settings", worlds_dir, "open", 0)
    if not ok then
      return self.consts.error.NO_SAVE
    end
  end

  -- Build unified config structure
  local user_options = {}
  local user_audio = {}

  -- Get defaults from schema or old vars
  local default_options = (vars.schema and vars.schema.options) or vars.options or {}
  local default_audio = (vars.schema and vars.schema.audio) or vars.audio or {}

  -- Compare current options with defaults (including auto_login now)
  for key, option in pairs(self.options) do
    local default = default_options[key]
    if default and option.value ~= default.default then
      -- For schema format, compare with default field
      user_options[key] = option.value
    elseif default and option.value ~= default.value then
      -- For old format, compare with value field
      user_options[key] = option.value
    end
  end

  -- Compare current audio settings with defaults
  if default_audio.categories then
    -- Schema format
    for group, attrs in pairs(self.audio) do
      local default_group = default_audio.categories[group]
      if default_group and type(attrs) == "table" then
        for attr, value in pairs(attrs) do
          if default_group[attr] ~= nil and value ~= default_group[attr] then
            if not user_audio[group] then
              user_audio[group] = {}
            end
            user_audio[group][attr] = value
          end
        end
      end
    end
  else
    -- Old format
    for group, attrs in pairs(self.audio) do
      local default_group = default_audio[group]
      if default_group and type(attrs) == "table" then
        for attr, value in pairs(attrs) do
          if default_group[attr] ~= nil and value ~= default_group[attr] then
            if not user_audio[group] then
              user_audio[group] = {}
            end
            user_audio[group][attr] = value
          end
        end
      end
    end
  end

  -- Create unified config structure
  miriani_config = {
    _version = vars.schema and vars.schema.version or "2.0",
    options = user_options,
    audio = {
      master_volume = self.master_volume ~= 50 and self.master_volume or nil,
      master_mute = self.master_mute or nil,
    }
  }

  -- Add audio category settings if changed
  if next(user_audio) then
    for group, attrs in pairs(user_audio) do
      miriani_config.audio[group] = attrs
    end
  end

  -- Add sound groups if they exist
  if self.sound_groups then
    miriani_config.sound_groups = self.sound_groups
  end

  -- Add sound variants if they exist
  if self.sound_variants then
    miriani_config.sound_variants = self.sound_variants
  end

  local serialize = require("serialize")
  local serial_config, error = serialize.save("miriani_config")

  if type(serial_config) ~= 'string' then
    return error or self.consts.error.UNKNOWN
  end

  local file, err = io.open(settings_file, "w")
  if not file then
    return self.consts.error.NO_SAVE
  end

  file:write(serial_config)
  file:close()

  return self.consts.error.OK
end -- save_unified_config

function Config:migrate_old_configs()
  local path = require("pl.path")
  local mushclient_dir = GetInfo(59)
  local settings_dir = path.join(mushclient_dir, "worlds", "settings")

  local toastush_file = path.join(settings_dir, "toastush.conf")
  local autologin_file = path.join(settings_dir, "auto_login.conf")
  local soundgroups_file = path.join(settings_dir, "sound_groups.conf")
  local miriani_file = path.join(settings_dir, "miriani.conf")

  -- If miriani.conf already exists, no migration needed
  if path.isfile(miriani_file) then
    return true
  end

  -- Check if we have any old files to migrate
  local has_old_files = path.isfile(toastush_file) or path.isfile(autologin_file) or path.isfile(soundgroups_file)

  if not has_old_files then
    -- No old files, nothing to migrate
    return false
  end

  Note("Migrating old configuration files to unified miriani.conf...")

  -- Create backup of old files
  if path.isfile(toastush_file) then
    local backup_file = toastush_file .. ".bak"
    os.execute('copy "' .. toastush_file .. '" "' .. backup_file .. '"')
  end
  if path.isfile(autologin_file) then
    local backup_file = autologin_file .. ".bak"
    os.execute('copy "' .. autologin_file .. '" "' .. backup_file .. '"')
  end
  if path.isfile(soundgroups_file) then
    local backup_file = soundgroups_file .. ".bak"
    os.execute('copy "' .. soundgroups_file .. '" "' .. backup_file .. '"')
  end

  -- Load and merge old configs
  local merged_config = {
    _version = "2.0",
    options = {},
    audio = {},
    sound_groups = {},
    sound_variants = {}
  }

  -- Load toastush.conf
  local toastush_data = self:load_from_file()
  if toastush_data then
    if toastush_data.options then
      for k, v in pairs(toastush_data.options) do
        merged_config.options[k] = v
      end
    end
    if toastush_data.audio then
      merged_config.audio = toastush_data.audio
    end
    if toastush_data.master_volume then
      merged_config.audio.master_volume = toastush_data.master_volume
    end
    if toastush_data.master_mute ~= nil then
      merged_config.audio.master_mute = toastush_data.master_mute
    end
    if toastush_data.sound_variants then
      merged_config.sound_variants = toastush_data.sound_variants
    end
  end

  -- Load auto_login.conf
  local autologin_data = self:load_auto_login_from_file()
  if autologin_data and autologin_data.options then
    for k, v in pairs(autologin_data.options) do
      merged_config.options[k] = v
    end
  end

  -- Load sound_groups.conf (simple key=value format)
  if path.isfile(soundgroups_file) then
    local file = io.open(soundgroups_file, "r")
    if file then
      for line in file:lines() do
        local group, enabled = line:match("^([^=]+)=(.+)$")
        if group and enabled then
          merged_config.sound_groups[group] = enabled == "true"
        end
      end
      file:close()
    end
  end

  -- Save merged config
  miriani_config = merged_config
  local serialize = require("serialize")
  local serial_config = serialize.save("miriani_config")

  if type(serial_config) == 'string' then
    local file = io.open(miriani_file, "w")
    if file then
      file:write(serial_config)
      file:close()

      Note("========================================")
      Note("Configuration Migration Complete!")
      Note("========================================")
      Note("✓ Created unified miriani.conf")
      Note("✓ Old config files backed up with .bak extension:")
      if path.isfile(toastush_file) then
        Note("  - toastush.conf.bak")
      end
      if path.isfile(autologin_file) then
        Note("  - auto_login.conf.bak")
      end
      if path.isfile(soundgroups_file) then
        Note("  - sound_groups.conf.bak")
      end

      -- Delete old config files after successful migration
      local files_deleted = {}
      if path.isfile(toastush_file) then
        os.remove(toastush_file)
        table.insert(files_deleted, "toastush.conf")
      end
      if path.isfile(autologin_file) then
        os.remove(autologin_file)
        table.insert(files_deleted, "auto_login.conf")
      end
      if path.isfile(soundgroups_file) then
        os.remove(soundgroups_file)
        table.insert(files_deleted, "sound_groups.conf")
      end

      if #files_deleted > 0 then
        Note("✓ Removed old config files: " .. table.concat(files_deleted, ", "))
        Note("")
        Note("Your settings have been preserved in miriani.conf")
        Note("Backups are available if needed (.bak files)")
      end
      Note("========================================")

      return true
    end
  end

  Note("Migration failed - old configs still in use.")
  return false
end -- migrate_old_configs

function Config:save()
  -- Use unified save if schema is available
  if vars.schema then
    return self:save_unified_config()
  end

  -- Otherwise fall back to old save methods
  local result1 = self:save_to_file()
  local result2 = self:save_auto_login_to_file()

  -- Return OK if both succeeded, otherwise return first error
  if result1 == self.consts.error.OK and result2 == self.consts.error.OK then
    return self.consts.error.OK
  end

  return result1 ~= self.consts.error.OK and result1 or result2
end -- save

function Config:get(var)

  -- Safety check: ensure consts is initialized
  if not self.consts then
    -- Emergency initialization if somehow consts is missing
    local vars_local = {
      consts = require("miriani.scripts.include.vars.consts"),
    }
    self.consts = vars_local.consts
  end

  if self.consts.pack[var] == nil then
    return self.consts.error.INVALID_ARG
  end -- if

  return self.consts.pack[var]
end -- get

function Config:render_menu_list(option)
  local menu, seen_previously = {}, {}

  for k,v in pairs(self.options) do
    if option and string.find(v.group, option) then

      local value

      if (v.read) then
        local ok, res = pcall(loadstring(v.read)(), v.value)
        if (ok) then value = res end
      elseif v.type == "bool" or v.type == "boolean" then
        -- Display boolean values as [On]/[Off]
        value = (v.value == "yes" or v.value == true) and "[On]" or "[Off]"
      elseif v.type == "enum" then
        -- Display enum values in brackets, capitalize first letter
        local display_value = tostring(v.value):gsub("^%l", string.upper)
        value = "[" .. display_value .. "]"
      elseif v.type == "password" then
        -- Don't show password values in menu
        if v.value and v.value ~= "" then
          value = "[Set]"
        else
          value = "[Not set]"
        end
      else
        value = tostring(v.value)
      end -- if

      -- For boolean, enum, and password types, show status at end; otherwise show "Currently: value"
      if v.type == "bool" or v.type == "boolean" or v.type == "enum" or v.type == "password" then
        menu[k] = v.descr .. " " .. value
      else
        menu[k] = v.descr .. " Currently: " .. value
      end
    elseif (not option) and (not seen_previously[v.group]) then
      -- Use display title instead of raw group key
      menu[#menu + 1] = self:get_group_title(v.group)
      seen_previously[v.group] = true
    end -- if
  end -- for

  if not next(menu) then
    return self.consts.error.INVALID_ARG
  end -- if

  return menu
end -- render_menu_list

function Config:is_option(key)

  if not self.options[key] then
    return false
  end -- if

  return true
end -- is_option

function Config:option_type(key)

  if not self.options[key] then
    return self.consts.error.INVALID_ARG
  end -- if

  return type(self.options[key].value) or self.consts.error.unknown
end -- option_type

function Config:is_mute()
  return self.master_mute
end -- is_mute

function Config:toggle_mute()
  self.master_mute = not self.master_mute
  return not self.master_mute  -- Return true if now unmuted, false if now muted
end -- toggle_mute

function Config:get_version()
  return self.consts.pack.VERSION or self.consts.error.UNKNOWN
end -- get_version

function Config:get_audio_groups()

  local groups = {}
  for k in pairs(self.audio) do

    groups[#(groups)+1] = k
  end -- for

  return not next(groups)
  and self.consts.error.UNKNOWN
  or groups
end -- get_audio_groups

function Config:get_group_title(group_key)
  -- Get display title for a group, falling back to the key if no metadata exists
  if vars.group_metadata then
    for _, meta in ipairs(vars.group_metadata) do
      if meta.key == group_key then
        return meta.title
      end
    end
  end
  -- Fallback: capitalize first letter of group_key
  return group_key:gsub("^%l", string.upper)
end -- get_group_title

function Config:get_group_order(group_key)
  -- Get sort order for a group, returning 999 if not defined (will sort to end)
  if vars.group_metadata then
    for _, meta in ipairs(vars.group_metadata) do
      if meta.key == group_key then
        return meta.order
      end
    end
  end
  return 999
end -- get_group_order

function Config:get_group_key_from_title(title)
  -- Get group key from display title
  if vars.group_metadata then
    for _, meta in ipairs(vars.group_metadata) do
      if meta.title == title then
        return meta.key
      end
    end
  end
  -- Fallback: if no metadata match, check if the title matches any actual group keys
  for _, v in pairs(self.options) do
    if self:get_group_title(v.group) == title then
      return v.group
    end
  end
  -- Last resort: return title as-is (might be a group key already)
  return title:lower()
end -- get_group_key_from_title

-- Sound group management methods (for unified config)
function Config:get_sound_group(group)
  if self.sound_groups and self.sound_groups[group] ~= nil then
    return self.sound_groups[group]
  end
  -- Check schema defaults
  if vars.schema and vars.schema.sound_groups and vars.schema.sound_groups[group] ~= nil then
    return vars.schema.sound_groups[group]
  end
  return true -- Default to enabled for unknown groups
end -- get_sound_group

function Config:set_sound_group(group, enabled)
  if not self.sound_groups then
    self.sound_groups = {}
  end
  self.sound_groups[group] = enabled
  return self.consts.error.OK
end -- set_sound_group

function Config:get_all_sound_groups()
  local groups = {}

  -- Start with schema-defined groups
  if vars.schema and vars.schema.sound_groups then
    for group, _ in pairs(vars.schema.sound_groups) do
      groups[group] = self:get_sound_group(group)
    end
  end

  -- Add any dynamically discovered groups
  if self.sound_groups then
    for group, enabled in pairs(self.sound_groups) do
      groups[group] = enabled
    end
  end

  return groups
end -- get_all_sound_groups

-- Sound variant management methods
function Config:get_sound_variant(path)
  if self.sound_variants and self.sound_variants[path] then
    return self.sound_variants[path]
  end
  -- Check schema defaults
  if vars.schema and vars.schema.sound_variants and vars.schema.sound_variants[path] then
    return vars.schema.sound_variants[path].default
  end
  return 1 -- Default variant
end -- get_sound_variant

function Config:set_sound_variant(path, variant)
  if not self.sound_variants then
    self.sound_variants = {}
  end
  self.sound_variants[path] = variant
  return self.consts.error.OK
end -- set_sound_variant

return Config