-- @module sound_conflict_detector
-- Detects and handles conflicts between numbered and non-numbered sound files

local path = require("pl.path")
local utils = require("pl.utils")

-- Function to analyze and clean up sound file conflicts
function check_and_cleanup_sound_conflicts()
  local sound_dir = config:get("SOUND_DIRECTORY") .. "miriani/"

  if not path.isdir(sound_dir) then
    if config:get_option("debug_mode").value == "yes" then
      notify("important", "Sound directory not found: " .. sound_dir)
    end
    return
  end

  local conflicts = find_sound_conflicts(sound_dir)

  if #conflicts > 0 then
    notify("important", string.format("Warning: Found %d sound file conflicts - removing non-numbered versions", #conflicts))

    local cleaned = 0
    for _, conflict in ipairs(conflicts) do
      if cleanup_conflict(conflict) then
        cleaned = cleaned + 1
        -- Warn about specific conflicts being cleaned
        local dir_display = conflict.directory == "" and "root" or conflict.directory
        notify("info", string.format("Removed %s.ogg (conflicts with numbered variants in %s)",
          conflict.base_name, dir_display))
      end
    end

    if cleaned > 0 then
      notify("info", string.format("Cleaned up %d conflicting sound files", cleaned))
    end
  end
end

-- Find conflicts between numbered and non-numbered sound files
function find_sound_conflicts(sound_dir)
  local conflicts = {}
  local file_groups = {}

  -- Recursively scan all .ogg files
  local function scan_directory(dir, relative_path)
    relative_path = relative_path or ""

    local search_pattern = dir .. "*"
    local search = utils.readdir(search_pattern)

    if not search then
      return
    end

    for filename, metadata in pairs(search) do
      local full_path = path.join(dir, filename)

      if metadata.directory then
        -- Recursively scan subdirectories
        local new_relative = relative_path == "" and filename or path.join(relative_path, filename)
        scan_directory(full_path .. "/", new_relative)
      elseif string.match(filename, "%.ogg$") then
        -- Extract base name and number
        local base_name, number = string.match(filename, "^(.-)(%d*)%.ogg$")
        if base_name then
          base_name = string.lower(base_name)
          local is_numbered = number ~= ""

          -- Group by directory and base name
          local group_key = relative_path .. "|" .. base_name
          if not file_groups[group_key] then
            file_groups[group_key] = {
              directory = relative_path,
              base_name = base_name,
              numbered_files = {},
              non_numbered_files = {}
            }
          end

          local file_info = {
            full_path = full_path,
            relative_path = path.join(relative_path, filename),
            filename = filename,
            number = is_numbered and tonumber(number) or nil
          }

          if is_numbered then
            table.insert(file_groups[group_key].numbered_files, file_info)
          else
            table.insert(file_groups[group_key].non_numbered_files, file_info)
          end
        end
      end
    end
  end

  scan_directory(sound_dir)

  -- Find conflicts (groups with both numbered and non-numbered files)
  for group_key, group in pairs(file_groups) do
    if #group.numbered_files > 0 and #group.non_numbered_files > 0 then
      table.insert(conflicts, group)
    end
  end

  return conflicts
end

-- Clean up a single conflict by removing non-numbered files
function cleanup_conflict(conflict)
  local success = true

  for _, file_info in ipairs(conflict.non_numbered_files) do
    if path.isfile(file_info.full_path) then
      local result = os.remove(file_info.full_path)
      if result then
        if config:get_option("debug_mode").value == "yes" then
          notify("info", "Removed conflicting file: " .. file_info.relative_path)
        end
      else
        notify("important", "Failed to remove conflicting file: " .. file_info.relative_path)
        success = false
      end
    end
  end

  return success
end

