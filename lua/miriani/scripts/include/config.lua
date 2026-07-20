-- @module config
-- Defines methods for manipulating global constants.
-- Uses MUSHclient world variables to serialize across sessions.

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

  -- Initialize master volume and mute (will be loaded from variable if present)
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
    self.sound_groups = {}
    self.ignored_sounds = {}
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
        local option_def = {
          descr = display_name,
          value = "yes",
          group = "socials_" .. category,
          type = "bool"
        }
        -- Add to vars.options for save comparison (defaults reference)
        vars.options[option_key] = option_def
        -- Add to self.options (working copy that gets loaded values applied)
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

  -- Try loading saved config
  local saved_data = self:load()

  if saved_data then
    -- Check if this is old format (full option structures) or new format (values only)
    local is_old_format = false
    if saved_data.options then
      for k, v in pairs(saved_data.options) do
        if type(v) == "table" and v.descr and v.value ~= nil then
          is_old_format = true
          break
        end
      end
    end

    if is_old_format then
      -- Old format: merge full structures, keeping user values
      if saved_data.options then
        for key, saved_option in pairs(saved_data.options) do
          if self.options[key] and saved_option.value ~= nil then
            local value = saved_option.value
            if self.options[key].type == "enum" then
              if key == "scan_interrupt" and (value == "yes" or value == true) then
                value = "starships"
              elseif key == "scan_interrupt" and (value == "no" or value == false) then
                value = "off"
              elseif key == "background_ambiance" and (value == "yes" or value == true) then
                value = "focused"
              elseif key == "background_ambiance" and (value == "no" or value == false) then
                value = "off"
              end
            end
            self.options[key].value = value
          end
        end
      end

      self:apply_audio_data(saved_data)
      self:apply_extra_data(saved_data)

      -- Convert to new format by saving
      self:save()
    else
      -- New format: just apply user values to defaults
      if saved_data.options then
        for key, value in pairs(saved_data.options) do
          if self.options[key] then
            if self.options[key].type == "enum" then
              if key == "scan_interrupt" and (value == "yes" or value == true) then
                value = "starships"
              elseif key == "scan_interrupt" and (value == "no" or value == false) then
                value = "off"
              elseif key == "background_ambiance" and (value == "yes" or value == true) then
                value = "focused"
              elseif key == "background_ambiance" and (value == "no" or value == false) then
                value = "off"
              end
            end
            self.options[key].value = value
          end
        end
      end

      self:apply_audio_data(saved_data)
      self:apply_extra_data(saved_data)
    end

  end -- if saved_data

  -- Initialize sound_groups and ignored_sounds tables if not loaded
  self.sound_groups = self.sound_groups or {}
  self.ignored_sounds = self.ignored_sounds or {}

  -- Migrate legacy .conf files into world variables
  self:migrate_legacy_files()

  return error
end -- _init

function Config:apply_audio_data(data)
  if data.audio then
    for group, attrs in pairs(data.audio) do
      if self.audio[group] and type(attrs) == "table" then
        for attr, value in pairs(attrs) do
          if self.audio[group][attr] ~= nil then
            self.audio[group][attr] = value
          end
        end
      end
    end
  end
end

function Config:apply_extra_data(data)
  if data.master_volume then
    self.master_volume = tonumber(data.master_volume) or 50
  end
  if data.master_mute ~= nil then
    self.master_mute = data.master_mute
  end
  if data.sound_variants then
    self.sound_variants = data.sound_variants
  end
  if data.enabled_themes then
    self.enabled_themes = data.enabled_themes
  end
  if data.all_themes_mode ~= nil then
    self.all_themes_mode = data.all_themes_mode
  end
  if data.sound_groups then
    self.sound_groups = data.sound_groups
  end
  if data.ignored_sounds then
    self.ignored_sounds = data.ignored_sounds
  end
end

function Config:load()
  local content = GetVariable("toastush_config")
  if not content or content == "" then
    return nil
  end

  local load_func, load_err = loadstring(content)
  if not load_func then
    return nil
  end

  load_func()

  local result = toastush_config
  toastush_config = nil
  return result
end

function Config:save()
  -- Only save values that differ from defaults
  local user_options = {}
  local default_options = vars.options or {}

  for key, option in pairs(self.options) do
    local default = default_options[key]
    if default and option.value ~= default.value then
      user_options[key] = option.value
    end
  end

  local user_audio = {}
  local default_audio = vars.audio or {}

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

  toastush_config = {
    options = user_options,
    audio = user_audio,
    master_volume = self.master_volume ~= 100 and self.master_volume or nil,
    master_mute = self.master_mute or nil,
    sound_variants = self.sound_variants or nil,
    enabled_themes = self.enabled_themes or nil,
    all_themes_mode = self.all_themes_mode or nil,
    sound_groups = next(self.sound_groups) and self.sound_groups or nil,
    ignored_sounds = next(self.ignored_sounds) and self.ignored_sounds or nil,
  }

  local serialize = require("serialize")
  local serial_config, err = serialize.save("toastush_config")
  toastush_config = nil

  if type(serial_config) ~= 'string' then
    return err or self.consts.error.UNKNOWN
  end

  SetVariable("toastush_config", serial_config)

  -- Recreate Proxiani bypass aliases after a short delay to avoid interfering with current command
  if create_proxiani_bypass_aliases then
    DoAfterSpecial(0.1, "create_proxiani_bypass_aliases()", sendto.script)
  end

  return self.consts.error.OK
end -- save

function Config:migrate_legacy_files()
  local path = require("pl.path")
  local mushclient_dir = GetInfo(59)
  local settings_dir = path.join(mushclient_dir, "worlds", "settings")

  if not utils.readdir(settings_dir) then
    return
  end

  local legacy_files = {
    "toastush.conf",
    "auto_login.conf",
    "sound_groups.conf",
    "ignored_sounds.conf",
  }

  -- Also check for per-world-id .conf files from the intermediate migration
  local world_id = (GetInfo(3) or "default"):gsub("[^%w_%-]", ""):lower()
  local world_id_files = {
    world_id .. ".conf",
    world_id .. "_auto_login.conf",
    world_id .. "_sound_groups.conf",
    world_id .. "_ignored_sounds.conf",
  }

  local has_legacy = false
  local all_files = {}
  for _, f in ipairs(legacy_files) do table.insert(all_files, f) end
  for _, f in ipairs(world_id_files) do table.insert(all_files, f) end

  for _, filename in ipairs(all_files) do
    if path.isfile(path.join(settings_dir, filename)) then
      has_legacy = true
      break
    end
  end

  if not has_legacy then
    return
  end

  -- Try loading config data from legacy files (prefer world-id variants)
  local already_loaded = GetVariable("toastush_config") ~= nil

  if not already_loaded then
    -- Load main config from file
    local main_files = { world_id .. ".conf", "toastush.conf" }
    for _, filename in ipairs(main_files) do
      local filepath = path.join(settings_dir, filename)
      if path.isfile(filepath) then
        local f = io.open(filepath, "r")
        if f then
          local content = f:read("*all")
          f:close()
          if content and content ~= "" then
            local load_func = loadstring(content)
            if load_func then
              load_func()
              local data = toastush_config
              toastush_config = nil
              if data then
                if data.options then
                  for key, value in pairs(data.options) do
                    if self.options[key] then
                      if type(value) == "table" and value.value ~= nil then
                        self.options[key].value = value.value
                      else
                        self.options[key].value = value
                      end
                    end
                  end
                end
                self:apply_audio_data(data)
                self:apply_extra_data(data)
              end
            end
          end
        end
        break
      end
    end

    -- Load auto_login from file
    local auto_files = { world_id .. "_auto_login.conf", "auto_login.conf" }
    for _, filename in ipairs(auto_files) do
      local filepath = path.join(settings_dir, filename)
      if path.isfile(filepath) then
        local f = io.open(filepath, "r")
        if f then
          local content = f:read("*all")
          f:close()
          if content and content ~= "" then
            local load_func = loadstring(content)
            if load_func then
              load_func()
              local data = auto_login_config
              auto_login_config = nil
              if data and data.options then
                for key, value in pairs(data.options) do
                  if self.options[key] then
                    self.options[key].value = value
                  end
                end
              end
            end
          end
        end
        break
      end
    end

    -- Load sound_groups from file
    if not next(self.sound_groups) then
      local sg_files = { world_id .. "_sound_groups.conf", "sound_groups.conf" }
      for _, filename in ipairs(sg_files) do
        local filepath = path.join(settings_dir, filename)
        if path.isfile(filepath) then
          local f = io.open(filepath, "r")
          if f then
            local content = f:read("*all")
            f:close()
            for line in content:gmatch("[^\r\n]+") do
              local group, enabled = line:match("^([^=]+)=([^=]+)$")
              if group and enabled then
                self.sound_groups[group] = (enabled == "true")
              end
            end
          end
          break
        end
      end
    end

    -- Load ignored_sounds from file
    if not next(self.ignored_sounds) then
      local is_files = { world_id .. "_ignored_sounds.conf", "ignored_sounds.conf" }
      for _, filename in ipairs(is_files) do
        local filepath = path.join(settings_dir, filename)
        if path.isfile(filepath) then
          local f = io.open(filepath, "r")
          if f then
            local content = f:read("*all")
            f:close()
            for line in content:gmatch("[^\r\n]+") do
              local trimmed = line:match("^%s*(.-)%s*$")
              if trimmed and trimmed ~= "" then
                self.ignored_sounds[trimmed] = true
              end
            end
          end
          break
        end
      end
    end

    -- Save migrated data to world variable
    self:save()
  end

  -- Delete all legacy files
  for _, filename in ipairs(all_files) do
    local filepath = path.join(settings_dir, filename)
    if path.isfile(filepath) then
      os.remove(filepath)
    end
  end
end

function Config:reset()
  DeleteVariable("toastush_config")
end

function Config:get(var)
  if not self.consts then
    self.consts = require("miriani.scripts.include.vars.consts")
  end

  if self.consts.pack[var] == nil then
    return self.consts.error.INVALID_ARG
  end

  return self.consts.pack[var]
end -- get

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
  return self.master_volume or 50
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

function Config:render_menu_list(option)
  local menu, seen_previously = {}, {}

  for k,v in pairs(self.options) do
    if v.hidden then
      -- skip
    elseif option and string.find(v.group, option) then

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
