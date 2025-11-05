local COUNTER_DEFINITIONS = {
  artifacts = "Archaeological Artifacts",
  spatial_artifacts = "Spatial Artifacts",
  asteroids_hauled = "Asteroids Hauled",
  missions = "Missions Completed",
  atmospheric_debris = "Atmospheric Debris",
  water_debris = "Aquatic Debris",
  gas_debris = "Gas Debris",
  regular_debris = "Debris",
  mining_expeditions = "Mining Expeditions"
}

local counters_data = {}
local counter_display_queue = {}
local display_timer_active = false

local function load_counters()
  local stored_data = GetVariable("counters_data")
  if stored_data and stored_data ~= "" then
    local json = require("json")
    local success, data = pcall(json.decode, stored_data)
    if success and data then
      counters_data = data
    else
      counters_data = {}
    end
  else
    counters_data = {}
  end

  for counter_name, _ in pairs(COUNTER_DEFINITIONS) do
    if not counters_data[counter_name] then
      counters_data[counter_name] = 0
    end
  end
end

local function save_counters()
  local json = require("json")
  local stored_data = json.encode(counters_data)
  SetVariable("counters_data", stored_data)
end

function increment_counter(counter_key)
  if not COUNTER_DEFINITIONS[counter_key] then
    return false
  end

  if not counters_data[counter_key] then
    counters_data[counter_key] = 0
  end

  counters_data[counter_key] = counters_data[counter_key] + 1
  save_counters()

  if config:get_option("show_counters").value == "yes" then
    DoAfterSpecial(0.1, COUNTER_DEFINITIONS[counter_key]..": "..counters_data[counter_key], sendto.output)
  end

  return true
end

function get_counter(counter_name)
  return counters_data[counter_name] or 0
end

function display_counters()
  print("Activity Counters:")
  print("")

  for counter_name, display_name in pairs(COUNTER_DEFINITIONS) do
    local value = counters_data[counter_name] or 0
    print(string.format("  %s: %d", display_name, value))
  end
end

function reset_counters(silent)
  for counter_name, _ in pairs(COUNTER_DEFINITIONS) do
    counters_data[counter_name] = 0
  end
  save_counters()
  if not silent then
  print("All activity counters have been reset.")
  end
end

function reset_counter(counter_name)
  if not COUNTER_DEFINITIONS[counter_name] then
    print(string.format("Unknown counter: %s", counter_name))
    return false
  end

  counters_data[counter_name] = 0
  save_counters()
  print(string.format("%s counter has been reset.", COUNTER_DEFINITIONS[counter_name]))
  return true
end

ImportXML([=[
<aliases>
  <alias
    enabled="y"
    
    match="^counters(?:\s+(.+))?$"
    regexp="y"
    send_to="12"
  >
  <send>
    local input = "%1"

    if input == "" or input == nil then
      display_counters()
    else
      local parts = {}
      for word in input:gmatch("%S+") do
        table.insert(parts, word)
      end

      if parts[1] == "reset" then
        if parts[2] then
          reset_counter(parts[2])
        else
          reset_counters(0)
        end
      end
    end
  </send>
  </alias>
</aliases>
]=])

load_counters()