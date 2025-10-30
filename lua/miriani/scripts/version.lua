-- Version management functions for Miriani Next
-- Reads version information from version.json and .update_channel

require("json")
version = {}

-- Cache the version data
local version_data = nil
local update_channel = nil

-- Read and parse version.json
local function load_version_data()
  if version_data then
    return version_data
  end

  local file = io.open(GetInfo(66).."version.json", "r")
  if not file then
    error("Could not open version.json")
  end

  local content = file:read("*all")
  file:close()

  version_data = json.decode(content)
  return version_data
end


function load_update_channel()
  if update_channel then
    return update_channel
  end

  local file = io.open(GetInfo(66)..".update_channel", "r")
  if not file then
    update_channel = "unknown"
    return update_channel
  end

  update_channel = file:read("*l") or "unknown"
  file:close()

  update_channel = update_channel:match("^%s*(.-)%s*$")
  return update_channel
end

-- Get the basic version string: major.minor.patch (with padded patch)
-- Example: "4.0.02"
function version.version_string()
  local data = load_version_data()
  local patch = string.format("%02d", data.patch)
  return string.format("%d.%d.%s", data.major, data.minor, patch)
end

-- Get the full version string with all components including channel and commit
-- Example: "4.0.02-dev (914b5e6c)"
function version.full_version_string()
  local data = load_version_data()
  local channel = load_update_channel()
  local base = version.version_string()

  local result = base .. "-" .. channel

  if data.commit then
    result = result .. " (" .. data.commit .. ")"
  end

  return result
end

-- Get the update channel
-- Returns: "dev", "stable", or a specific tag/branch name
function version.update_channel()
  return load_update_channel()
end

-- Get the commit hash if available
function version.commit()
  local data = load_version_data()
  return data.commit
end

-- Get individual version components
function version.major()
  local data = load_version_data()
  return data.major
end

function version.minor()
  local data = load_version_data()
  return data.minor
end

function version.patch()
  local data = load_version_data()
  return data.patch
end

function version.patch_padded()
  -- So I can have my beautiful padded  version numbers.
  local data = load_version_data()
  return string.format("%02d", data.patch)
end

return version
