-- @module themes
-- Sound theme discovery, loading, and management

require("json")
local path = require("pl.path")

local enabled_themes = {}
local theme_cache = {}

local function get_themes_dir()
  return config:get("SOUND_DIRECTORY") .. THEMES_PATH
end

local function load_theme_json(theme_dir)
  local json_path = theme_dir .. "/theme.json"
  if not path.isfile(json_path) then
    return nil
  end

  local f = io.open(json_path, "r")
  if not f then
    return nil
  end

  local content = f:read("*all")
  f:close()

  local ok, data = pcall(json.decode, content)
  if not ok or type(data) ~= "table" then
    return nil
  end

  return data
end

function discover_themes()
  theme_cache = {}
  local themes_dir = get_themes_dir()

  if not path.isdir(themes_dir:gsub("/$", "")) then
    return theme_cache
  end

  local entries = utils.readdir(themes_dir .. "*")
  if not entries then
    return theme_cache
  end

  for name, metadata in pairs(entries) do
    if metadata.directory and name ~= "." and name ~= ".." then
      local theme_dir = themes_dir .. name
      local json_data = load_theme_json(theme_dir) or {}

      theme_cache[name] = {
        id = name,
        name = json_data.name or name,
        author = json_data.author,
        description = json_data.description,
        mode = json_data.mode or "additive",
        hidden = json_data.hidden == true,
        path = theme_dir,
      }
    end
  end

  return theme_cache
end

function invalidate_theme_cache()
  theme_cache = {}
end

function get_theme_info(theme_id)
  local cached = theme_cache[theme_id]
  if cached and path.isdir(cached.path) then
    return cached
  end
  -- Cache miss, or cached entry points at a directory that no longer exists.
  discover_themes()
  return theme_cache[theme_id]
end

function get_all_themes()
  discover_themes()

  local themes = {}
  for _, theme in pairs(theme_cache) do
    if not theme.hidden then
      table.insert(themes, theme)
    end
  end
  table.sort(themes, function(a, b) return a.name < b.name end)
  return themes
end

function count_theme_files(theme_id)
  local info = get_theme_info(theme_id)
  if not info then return 0, 0 end

  local count = 0
  local total_size = 0
  local function scan_dir(dir)
    local entries = utils.readdir(dir .. "/*")
    if not entries then return end
    for name, metadata in pairs(entries) do
      if name ~= "." and name ~= ".." then
        if metadata.directory then
          scan_dir(dir .. "/" .. name)
        elseif name:match("%.ogg$") then
          count = count + 1
          total_size = total_size + (metadata.size or 0)
        end
      end
    end
  end

  scan_dir(info.path)
  return count, total_size
end

-- List the sound files a theme provides (replaces or adds), as paths relative
-- to the theme root (e.g. "comm/Channels/guild.ogg"). Root-level files such as
-- the theme's own enable/disable feedback sounds, theme.json, changelog.md and
-- README.txt are excluded — only files inside category subdirectories count as
-- sounds the theme will change or add.
function list_theme_sounds(theme_id)
  local info = get_theme_info(theme_id)
  if not info then return {} end

  local results = {}
  local function scan_dir(dir, rel)
    local entries = utils.readdir(dir .. "/*")
    if not entries then return end
    for name, metadata in pairs(entries) do
      if name ~= "." and name ~= ".." then
        local sub_rel = rel == "" and name or rel .. "/" .. name
        if metadata.directory then
          scan_dir(dir .. "/" .. name, sub_rel)
        elseif rel ~= "" and name:match("%.ogg$") then
          table.insert(results, sub_rel)
        end
      end
    end
  end

  scan_dir(info.path, "")
  table.sort(results, function(a, b) return a:lower() < b:lower() end)
  return results
end

function get_theme_last_updated(theme_id)
  local info = get_theme_info(theme_id)
  if not info then return nil end

  local latest = 0
  local function scan_dir(dir)
    local entries = utils.readdir(dir .. "/*")
    if not entries then return end
    for name, metadata in pairs(entries) do
      if name ~= "." and name ~= ".." then
        if metadata.directory then
          scan_dir(dir .. "/" .. name)
        else
          local mtime = path.getmtime(dir .. "/" .. name)
          if mtime and mtime > latest then
            latest = mtime
          end
        end
      end
    end
  end

  scan_dir(info.path)
  if latest > 0 then
    return latest
  end
  return nil
end

function is_theme_enabled(theme_id)
  return enabled_themes[theme_id] == true
end

function set_theme_enabled(theme_id, enabled)
  enabled_themes[theme_id] = enabled or nil
  save_enabled_themes()

  local sound_name = enabled and "enable" or "disable"
  play(THEMES_PATH .. theme_id .. "/" .. sound_name .. EXTENSION, "notification")
end

function get_enabled_themes_by_mode(mode)
  local result = {}
  for theme_id, _ in pairs(enabled_themes) do
    local info = get_theme_info(theme_id)
    if info and info.mode == mode then
      table.insert(result, info)
    end
  end
  table.sort(result, function(a, b) return a.name < b.name end)
  return result
end

function get_all_enabled_themes()
  local result = {}
  for theme_id, _ in pairs(enabled_themes) do
    local info = get_theme_info(theme_id)
    if info then
      table.insert(result, info)
    end
  end
  table.sort(result, function(a, b) return a.name < b.name end)
  return result
end

function load_enabled_themes()
  if not config then
    return
  end

  local saved_data = config:load()
  if saved_data and saved_data.enabled_themes then
    enabled_themes = {}
    local pruned = false
    for _, theme_id in ipairs(saved_data.enabled_themes) do
      local theme_dir = get_themes_dir() .. theme_id
      if path.isdir(theme_dir) then
        enabled_themes[theme_id] = true
      else
        pruned = true
      end
    end
    if pruned then
      save_enabled_themes()
    end
  end
end

function save_enabled_themes()
  if not config then
    return
  end

  local theme_list = {}
  for theme_id, _ in pairs(enabled_themes) do
    table.insert(theme_list, theme_id)
  end
  table.sort(theme_list)

  config.enabled_themes = theme_list
  config:save()
end

-- Strip the miriani/ prefix from a sound path so it matches theme folder structure
-- e.g., "miriani/combat/hit.ogg" -> "combat/hit.ogg"
local function strip_soundpath(sound_file)
  if sound_file:sub(1, #SOUNDPATH) == SOUNDPATH then
    return sound_file:sub(#SOUNDPATH + 1)
  end
  return sound_file
end

-- Check replace-mode themes for a matching sound.
-- sound_file: path relative to SOUND_DIRECTORY (e.g., "miriani/combat/hit.ogg")
-- Returns: theme-relative path (e.g., "themes/spooky/combat/hit.ogg") or nil.
--
-- Contract: the returned path is a *stem* that find_sound_file() will resolve.
-- If the theme provides numbered variants (e.g. hit1.ogg, hit2.ogg) but no
-- bare hit.ogg, the bare path is still returned — find_sound_file globs out
-- the variants and randomises. Callers must always route the returned path
-- through play()/find_sound_file(), never path.isfile() it directly.
function resolve_theme_sound(sound_file)
  local sound_dir = config:get("SOUND_DIRECTORY")
  local stripped = strip_soundpath(sound_file)
  local replace_themes = get_enabled_themes_by_mode("replace")

  for i = #replace_themes, 1, -1 do
    local theme = replace_themes[i]
    local theme_file = THEMES_PATH .. theme.id .. "/" .. stripped
    local full_path = sound_dir .. theme_file
    if path.isfile(full_path) then
      return theme_file
    end
    local base, ext = path.splitext(theme_file)
    local search = utils.readdir(sound_dir .. base .. "*" .. ext)
    if search and next(search) then
      return theme_file
    end
  end

  return nil
end

-- Collect sound files from additive-mode themes to merge into the random pool.
-- file: path relative to SOUND_DIRECTORY (e.g., "miriani/combat/hit.ogg")
-- Returns: list of full filesystem paths ready to play
function collect_additive_theme_files(file)
  local sound_dir = config:get("SOUND_DIRECTORY")
  local stripped = strip_soundpath(file)
  local additive_themes = get_enabled_themes_by_mode("additive")
  local extra_files = {}

  for _, theme in ipairs(additive_themes) do
    local file_base, ext = path.splitext(stripped)
    local theme_prefix = THEMES_PATH .. theme.id .. "/"
    local theme_file = sound_dir .. theme_prefix .. stripped

    if path.isfile(theme_file) then
      table.insert(extra_files, theme_file)
    end

    local search_pattern = sound_dir .. theme_prefix .. file_base .. "*" .. ext
    local search = utils.readdir(search_pattern)
    if search and type(search) == "table" then
      local basename = path.basename(file_base)
      local escaped_ext = ext:gsub("%.", "%%.")
      local variant_pattern = "^" .. string.lower(basename) .. "%d+" .. escaped_ext .. "$"
      for filename, metadata in pairs(search) do
        if not metadata.directory and string.match(string.lower(filename), variant_pattern) then
          local dir_part = path.dirname(theme_prefix .. stripped)
          local full_path = sound_dir .. dir_part
          if dir_part ~= "." then
            full_path = full_path .. "/"
          end
          table.insert(extra_files, full_path .. filename)
        end
      end
    end
  end

  return extra_files
end

-- Check if any enabled theme provides a sound, without falling back to main sounds.
-- sound_key: path relative to SOUNDPATH without extension (e.g., "misc/Connections/disconnected")
-- Returns: path relative to SOUND_DIRECTORY suitable for play(), or nil
function find_theme_override(sound_key)
  local sound_file = SOUNDPATH .. sound_key .. EXTENSION
  local sound_dir = config:get("SOUND_DIRECTORY")

  local replace_path = resolve_theme_sound(sound_file)
  if replace_path then
    return replace_path
  end

  local theme_files = collect_additive_theme_files(sound_file)
  if #theme_files > 0 then
    local chosen = theme_files[math.random(#theme_files)]
    if chosen:sub(1, #sound_dir) == sound_dir then
      return chosen:sub(#sound_dir + 1)
    end
    return chosen
  end

  return nil
end

load_enabled_themes()
