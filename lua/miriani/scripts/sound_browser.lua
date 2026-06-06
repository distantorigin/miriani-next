-- @module sound_browser
-- Reusable directory browser for selecting sound files

local sound_browser = {}

local function get_parent(dir)
  if dir == "" then return nil end
  local trimmed = dir:match("^(.-)/?$")
  return trimmed:match("^(.*/)") or ""
end

function sound_browser.browse(options)
  options = options or {}
  local callback = options.callback
  local title = options.title or "Browse Sounds"
  local sound_dir = config:get("SOUND_DIRECTORY")
  local start_dir = options.start_dir or ""

  local function show_directory(rel_dir)
    local search_path = sound_dir .. rel_dir .. "*"
    local entries = utils.readdir(search_path)

    if not entries or not next(entries) then
      notify("info", "This directory is empty.")
      local parent = get_parent(rel_dir)
      if parent then
        show_directory(parent)
      else
        if callback then callback(nil) end
      end
      return
    end

    local dirs = {}
    local files = {}

    for name, meta in pairs(entries) do
      if name ~= "." and name ~= ".." then
        if meta.directory then
          table.insert(dirs, name)
        elseif name:match("%.ogg$") or name:match("%.wav$") then
          table.insert(files, name)
        end
      end
    end

    table.sort(dirs, function(a, b) return a:lower() < b:lower() end)
    table.sort(files, function(a, b) return a:lower() < b:lower() end)

    if #dirs == 0 and #files == 0 then
      notify("info", "No sound files found in this directory.")
      local parent = get_parent(rel_dir)
      if parent then
        show_directory(parent)
      else
        if callback then callback(nil) end
      end
      return
    end

    local choices = {}
    local entry_map = {}
    local n = 0

    for _, name in ipairs(dirs) do
      n = n + 1
      local key = tostring(n)
      choices[key] = name .. "/"
      entry_map[key] = {type = "dir", name = name}
    end

    for _, name in ipairs(files) do
      n = n + 1
      local key = tostring(n)
      choices[key] = name
      entry_map[key] = {type = "file", name = name}
    end

    choices["0"] = "Go back"

    local display_path = rel_dir == "" and "sounds/" or "sounds/" .. rel_dir

    dialog.menu({
      title = title .. "\n" .. display_path,
      choices = choices,
      callback = function(result, reason)
        if not result then
          if callback then callback(nil) end
          return
        end

        if result.key == "0" then
          local parent = get_parent(rel_dir)
          if parent then
            show_directory(parent)
          else
            if callback then callback(nil) end
          end
          return
        end

        local entry = entry_map[result.key]
        if not entry then return end

        if entry.type == "dir" then
          show_directory(rel_dir .. entry.name .. "/")
        else
          if callback then callback(rel_dir .. entry.name) end
        end
      end
    })
  end

  show_directory(start_dir)
end

return sound_browser
