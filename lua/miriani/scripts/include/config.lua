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
  if options and options.options and options.group_metadata then
    -- New format: {options = {...}, group_metadata = {...}}
    group_metadata = options.group_metadata
    options = options.options
  end

  -- Store defaults in vars for later comparison
  vars.options = options or {}
  vars.audio = audio or {}
  vars.group_metadata = group_metadata

  -- Initialize master volume and mute (will be loaded from file if present)
  self.master_volume = 50
  self.master_mute = false

  -- Store audio offsets and category map separately if provided
  if audio then
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

  -- Dynamically inject social options from socials database
  if get_all_socials and get_social_info then
    for _, social_name in ipairs(get_all_socials()) do
      local info = get_social_info(social_name)
      if info then
        local category = info.category or "uncategorized"
        local option_key = "social_" .. social_name
        local display_name = social_name:gsub("^%l", string.upper)
        self.options[option_key] = {
          descr = display_name,
          value = "yes",
          group = "socials_" .. category,
          type = "bool"
        }
      end
    end
  end

  local error = vars.consts.error.OK

  -- Try loading from file
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

function Config:set_option(key, val)
  if not self.options[key] then
    return self.consts.error.INVALID_ARG
  end -- if

  -- If empty string is provided, reset to default value
  if val == "" and self.options[key].type == "string" then
    -- Get the default value from vars.options (the original defaults)
    if vars.options and vars.options[key] and vars.options[key].value then
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

function Config:save()
  -- Save both main config and auto_login config
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

function Config:is_dnd()
  return self:get_option("dnd_mode").value == "yes"
end -- is_dnd

function Config:toggle_dnd()
  local current = self:get_option("dnd_mode").value
  local new_value = (current == "yes") and "no" or "yes"
  self:set_option("dnd_mode", new_value)
  self:save()
  return new_value == "yes"  -- Return true if DND is now enabled
end -- toggle_dnd

function Config:set_dnd(enabled)
  local value = enabled and "yes" or "no"
  self:set_option("dnd_mode", value)
  self:save()
end -- set_dnd

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

return Config