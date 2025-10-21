-- @module config_menu
-- Terminal-based configuration menu using dialog system

local config_menu = {}

-- Helper function to strip trailing punctuation from option descriptions
local function strip_trailing_punctuation(text)
  return text:gsub("[%.,:;!?]+%s*$", "")
end

-- Main configuration menu
function config_menu.show_main()
  local main_menu = config:render_menu_list()

  if type(main_menu) ~= 'table' then
    mplay("misc/cancel")
    notify("critical", "Unable to load configuration menu.")
    return
  end

  -- Add "audio groups" and "sound variants" to the menu even though they have no regular options
  local special_groups = {"audio groups", "sound variants"}
  for _, group_key in ipairs(special_groups) do
    local found = false
    for _, title in ipairs(main_menu) do
      if config:get_group_key_from_title(title) == group_key then
        found = true
        break
      end
    end
    if not found then
      table.insert(main_menu, config:get_group_title(group_key))
    end
  end

  -- Custom sort based on group order metadata
  table.sort(main_menu, function(a, b)
    -- Get group keys from titles
    local key_a = config:get_group_key_from_title(a)
    local key_b = config:get_group_key_from_title(b)

    -- Get sort orders
    local order_a = config:get_group_order(key_a)
    local order_b = config:get_group_order(key_b)

    -- If orders are different, sort by order
    if order_a ~= order_b then
      return order_a < order_b
    end

    -- If orders are the same (both undefined), sort alphabetically
    return a < b
  end)

  -- Convert to choices format for dialog
  local choices = {}
  for i, group_title in ipairs(main_menu) do
    choices[tostring(i)] = group_title
  end

  dialog.menu({
    title = string.format("%s Configuration Options", GetPluginName()),
    choices = choices,
    callback = function(result, reason)
      if result then
        -- Convert title back to group key
        local group_key = config:get_group_key_from_title(result.value)
        config_menu.show_group(group_key)
      end
    end
  })
end

-- Show options for a specific group
function config_menu.show_group(group_name)
  -- Special handling for audio groups submenu - it has no regular options
  local secondary_menu = {}

  -- If group_name is partial, try to find the actual group key
  local actual_group_key = group_name
  local special_groups = {"audio groups", "sound variants"}

  -- First check if it's a partial match for special groups
  local matched_special = false
  for _, special_group in ipairs(special_groups) do
    if string.find(string.lower(special_group), string.lower(group_name)) then
      actual_group_key = special_group
      matched_special = true
      break
    end
  end

  -- If not a special group, try to find a matching regular group
  if not matched_special then
    for key, option in pairs(config.options or {}) do
      if string.find(string.lower(option.group), string.lower(group_name)) then
        actual_group_key = option.group
        break
      end
    end
  end

  local group_title = config:get_group_title(actual_group_key)

  if actual_group_key == "sound variants" then
    -- Predefined list of sounds that support variants with their defaults
    local variant_sounds = {
      {path = "miriani/ship/move/accelerate.ogg", name = "Ship Accelerate", default = 3},
      {path = "miriani/ship/move/decelerate.ogg", name = "Ship Decelerate", default = 3},
      {path = "miriani/vehicle/accelerate.ogg", name = "Vehicle Accelerate (Salvagers and ACVs)", default = 1},
   {path = "miriani/vehicle/decelerate.ogg", name = "Vehicle Decelerate (Salvagers and ACVs)", default = 1},
   {path = "miriani/activity/archaeology/artifactHere.ogg", name = "Archaeology Artifact Detected", default = 1}
    }

    for _, sound in ipairs(variant_sounds) do
      local sound_key = "_sound_variant_" .. sound.path:gsub("/", "_"):gsub("%.", "_")
      local preference = get_variant_preference(sound.path)

      -- If no preference is set, use the default
      if preference == 0 or not preference then
        preference = sound.default
      end

      local status = "Variant " .. preference

      secondary_menu[sound_key] = string.format("%s [%s]", sound.name, status)
    end
  elseif actual_group_key == "audio groups" then
    -- Get all discovered sound groups
    local groups = get_all_sound_groups()

    if #groups == 0 then
      notify("info", "No sound groups discovered yet. Play the game to discover sound groups, then they will appear here for toggling.")
      config_menu.show_main()
      return
    end

    -- Add each group as a toggleable option
    for _, group in ipairs(groups) do
      local group_key = "_sound_group_" .. group
      local enabled = is_group_enabled(group)
      local status = enabled and "[On]" or "[Off]"
      -- Capitalize first letter
      local display_name = group:gsub("^%l", string.upper)
      secondary_menu[group_key] = string.format("%s %s", display_name, status)
    end
  else
    -- Normal menu rendering for other groups
    secondary_menu = config:render_menu_list(actual_group_key)

    if type(secondary_menu) ~= 'table' then
      notify("info", string.format("Unable to locate menu group '%s'.", group_name))
      config_menu.show_main()
      return
    end
  end

  -- Convert to numbered choices and create a key mapping
  local choices = {}
  local key_map = {}  -- Maps numbers to option keys
  local sorted_keys = {}

  -- Get all keys and sort by their display text
  for key in pairs(secondary_menu) do
    table.insert(sorted_keys, key)
  end
  table.sort(sorted_keys, function(a, b)
    return secondary_menu[a] < secondary_menu[b]
  end)

  -- Create numbered menu
  choices["0"] = "Go back"
  for i, key in ipairs(sorted_keys) do
    local num = tostring(i)
    choices[num] = secondary_menu[key]  -- Just the description, no key name
    key_map[num] = key  -- Remember which option this number refers to
  end

  dialog.menu({
    title = string.format("%s", group_title),
    choices = choices,
    callback = function(result, reason)
      if result then
        if result.key == "0" then
          config_menu.show_main()
        else
          -- Look up the actual option key from our mapping
          local option_key = key_map[result.key]
          if option_key then
            config_menu.edit_option(option_key, actual_group_key)
          end
        end
      else
        -- Aborted or cancelled - save config
        config:save()
              end
    end
  })
end

-- Edit a specific option
function config_menu.edit_option(option_key, group_name)
  -- Special handling for sound variants
  if option_key:match("^_sound_variant_") then
    local sound_path = option_key:match("^_sound_variant_(.+)$"):gsub("_", "/"):gsub("/ogg$", ".ogg")
    if sound_path then
      -- Get available variants
      local variants = scan_sound_variants(sound_path)

      -- Check if we found any variants
      if #variants == 0 then
        notify("critical", string.format("No variants found for %s", sound_path))
        config_menu.show_group(group_name)
        return
      end

      -- Build menu choices with numbered options
      local choices = {}
      local current_preference = get_variant_preference(sound_path)

      -- Get display name
      local display_name = sound_path:match("([^/]+)$"):gsub("^%l", string.upper)

      -- Add each variant as a numbered menu option
      for i, variant_num in ipairs(variants) do
        local choice_key = tostring(i)
        if current_preference == variant_num then
          choices[choice_key] = string.format("Variant %d (Currently selected)", variant_num)
        else
          choices[choice_key] = string.format("Variant %d", variant_num)
        end
      end

      dialog.menu({
        title = string.format("Select variant for %s", display_name),
        message = string.format("%d variants available. Select one:", #variants),
        choices = choices,
        callback = function(result, reason)
          if result then
            local menu_index = tonumber(result.key)
            local selected_variant = variants[menu_index]
            set_variant_preference(sound_path, selected_variant)

            -- Play preview of the selected sound
            -- Remove .ogg extension, add variant number, then add .ogg back
            local path_without_ext = sound_path:gsub("%.ogg$", "")
            local preview_file = path_without_ext .. tostring(selected_variant) .. ".ogg"
            play(preview_file)

            notify("info", string.format("%s set to Variant %d", display_name, selected_variant))
          end
          -- Return to sound variants menu
          config_menu.show_group(group_name)
        end
      })
      return
    end
  end

  -- Special handling for dynamic sound groups
  if option_key:match("^_sound_group_") then
    local sound_group = option_key:match("^_sound_group_(.+)$")
    if sound_group then
      -- Toggle the group
      local current_state = is_group_enabled(sound_group)
      local new_state = not current_state
      set_group_enabled(sound_group, new_state)

      local status = new_state and "on" or "off"
      notify("info", string.format("%s sounds set to %s", sound_group, status))

      -- Return to group menu
      config_menu.show_group(group_name)
      return
    end
  end

  if not config:is_option(option_key) then
    mplay("misc/cancel")
    notify("critical", string.format("Invalid option: %s.", option_key))
    config_menu.show_group(group_name)
    return
  end

  local option = config:get_option(option_key)
  local opt_type = option.type or config:option_type(option_key)

  if opt_type == "boolean" or opt_type == "bool" then
    -- Boolean option - toggle directly
    local current_is_on = (option.value == "yes" or option.value == true)
    local new_value = current_is_on and "no" or "yes"
    local display_value = current_is_on and "off" or "on"

    config:set_option(option_key, new_value)
    notify("info", string.format("%s set to %s", strip_trailing_punctuation(option.descr), display_value))
    config:save()

    -- Special handling for tab_activates_notepad option
    if option_key == "tab_activates_notepad" then
      -- Update tab accelerators immediately
      if update_tab_accelerators then
        update_tab_accelerators()
      end

      -- Show friendly info dialog only the first time they enable it
      if new_value == "yes" then
        local first_time = GetVariable("tab_output_first_time")
        if first_time == nil or first_time == "1" then
          SetVariable("tab_output_first_time", "0")

          -- Show a message box for first-time users
          utils.msgbox(
            "Hi! Since this is your first time enabling this feature, here's what's changed:\n\n" ..
            "Pressing Tab or Shift+Tab will now switch focus to the accessible output window, " ..
            "making it easier to review game text with your screen reader.\n\n" ..
            "Don't worry about tab completion though - we've moved that to Ctrl+Space so you can still use it whenever you need it.\n\n" ..
            "You can toggle this mode on or off anytime from the config menu. Enjoy!",
            "Welcome to Accessible Output Mode!",
            "ok",
            "i",
            1
          )
        end
      end
    end

    -- Return to group menu
    config_menu.show_group(group_name)

  elseif opt_type == "enum" then
    -- Enum option - show menu of choices
    if not option.options or #option.options == 0 then
      mplay("misc/cancel")
      notify("critical", "No options defined for this enum.")
      config_menu.show_group(group_name)
      return
    end

    local choices = {}
    for i, opt_value in ipairs(option.options) do
      local display_value = opt_value:gsub("^%l", string.upper)
      -- Mark current selection
      if opt_value == option.value then
        choices[tostring(i)] = display_value .. " (Currently selected)"
      else
        choices[tostring(i)] = display_value
      end
    end

    dialog.menu({
      title = string.format("Make a selection for %s", strip_trailing_punctuation(option.descr)),
      choices = choices,
      callback = function(result, reason)
        if result then
          local selected_value = option.options[tonumber(result.key)]
          if selected_value then
            config:set_option(option_key, selected_value)
            local display_value = selected_value:gsub("^%l", string.upper)
            notify("info", string.format("%s set to %s", strip_trailing_punctuation(option.descr), display_value))
            config:save()
          end
        end
        -- Return to group menu
        config_menu.show_group(group_name)
      end
    })

  elseif opt_type == "function" then
    -- Function-based option
    local newval = loadstring(option.action)()

    if newval and newval ~= -1 then
      config:set_option(option_key, newval)
      notify("info", string.format("%s updated", strip_trailing_punctuation(option.descr)))
      config:save()
    end

    config_menu.show_group(group_name)

  else
    -- String or other type - use prompt
    dialog.prompt({
      title = string.format("Set %s", option.descr),
      message = string.format("Current value: %s\n\nEnter a blank line to reset to default.", tostring(option.value)),
      allow_blank = true,
      callback = function(result, reason)
        if reason == "aborted" then
          -- User aborted, just return to menu
        elseif reason == "blank" or (result and result.value == "") then
          -- Blank line - reset to default
          config:set_option(option_key, "")
          -- Get the default value to show in notification
          local default_value = config:get_option(option_key).value
          notify("info", string.format("%s reset to default: %s", strip_trailing_punctuation(option.descr), default_value))
          config:save()
        elseif result and result.value then
          -- Normal value
          config:set_option(option_key, result.value)
          notify("info", string.format("%s set to %s", strip_trailing_punctuation(option.descr), result.value))
          config:save()
        end
        -- Return to group menu
        config_menu.show_group(group_name)
      end
    })
  end
end

-- Convenience function for command alias
function config_menu.start(group)
  if group then
    config_menu.show_group(group)
  else
    config_menu.show_main()
  end
end

-- Find and edit option by partial name or numeric index
function config_menu.find_and_edit(group_name, search_term)
  -- If group_name is partial, try to find the actual group key
  local actual_group_key = group_name
  local special_groups = {"audio groups", "sound variants"}

  -- First check if it's a partial match for special groups
  local matched_special = false
  for _, special_group in ipairs(special_groups) do
    if string.find(string.lower(special_group), string.lower(group_name)) then
      actual_group_key = special_group
      matched_special = true
      break
    end
  end

  -- If not a special group, try to find a matching regular group
  if not matched_special then
    for key, option in pairs(config.options or {}) do
      if string.find(string.lower(option.group), string.lower(group_name)) then
        actual_group_key = option.group
        break
      end
    end
  end

  -- Special handling for audio groups
  if actual_group_key == "audio groups" then
    local groups = get_all_sound_groups()

    -- Try numeric index first
    local index = tonumber(search_term)
    if index and index >= 1 and index <= #groups then
      local group = groups[index]
      local enabled = is_group_enabled(group)
      set_group_enabled(group, not enabled)
      local status = (not enabled) and "on" or "off"
      notify("info", string.format("%s sounds set to %s", group, status))
      return
    end

    -- Try partial name match
    for _, group in ipairs(groups) do
      if string.find(string.lower(group), string.lower(search_term)) then
        local enabled = is_group_enabled(group)
        set_group_enabled(group, not enabled)
        local status = (not enabled) and "on" or "off"
        notify("info", string.format("%s sounds set to %s", group, status))
        return
      end
    end

    mplay("misc/cancel")
    notify("critical", string.format("Could not find sound group matching '%s'.", search_term))
    return
  end

  -- Special handling for sound variants
  if actual_group_key == "sound variants" then
    -- Predefined list of sounds that support variants
    local variant_sounds = {
      {path = "miriani/ship/move/accelerate.ogg", name = "Ship Accelerate", default = 3},
      {path = "miriani/ship/move/decelerate.ogg", name = "Ship Decelerate", default = 3},
      {path = "miriani/activity/archaeology/artifactHere.ogg", name = "Archaeology Artifact Detected", default = 1},
    }

    -- Try numeric index first
    local index = tonumber(search_term)
    if index and index >= 1 and index <= #variant_sounds then
      local sound = variant_sounds[index]
      local sound_key = "_sound_variant_" .. sound.path:gsub("/", "_"):gsub("%.", "_")
      config_menu.edit_option(sound_key, actual_group_key)
      return
    end

    -- Try partial name match
    for _, sound in ipairs(variant_sounds) do
      if string.find(string.lower(sound.name), string.lower(search_term)) or
         string.find(string.lower(sound.path), string.lower(search_term)) then
        local sound_key = "_sound_variant_" .. sound.path:gsub("/", "_"):gsub("%.", "_")
        config_menu.edit_option(sound_key, actual_group_key)
        return
      end
    end

    mplay("misc/cancel")
    notify("critical", string.format("Could not find sound variant matching '%s'.", search_term))
    return
  end

  -- Get options for this group
  local group_options = config:render_menu_list(actual_group_key)

  if type(group_options) ~= 'table' then
    mplay("misc/cancel")
    notify("critical", string.format("Could not find group '%s'.", group_name))
    return
  end

  -- Build a sorted list of option keys
  local sorted_keys = {}
  for key in pairs(group_options) do
    table.insert(sorted_keys, key)
  end
  table.sort(sorted_keys, function(a, b)
    return group_options[a] < group_options[b]
  end)

  -- Try numeric index first
  local index = tonumber(search_term)
  if index and index >= 1 and index <= #sorted_keys then
    local option_key = sorted_keys[index]
    config_menu.edit_option(option_key, actual_group_key)
    return
  end

  -- Try partial name matching (case-insensitive)
  local matches = {}
  local search_lower = string.lower(search_term)

  for _, key in ipairs(sorted_keys) do
    local option = config:get_option(key)
    local descr_lower = string.lower(option.descr or "")
    local key_lower = string.lower(key)

    if string.find(descr_lower, search_lower) or string.find(key_lower, search_lower) then
      table.insert(matches, key)
    end
  end

  if #matches == 0 then
    mplay("misc/cancel")
    notify("critical", string.format("Could not find option matching '%s' in group '%s'.", search_term, group_name))
  elseif #matches == 1 then
    -- Single match - edit it
    config_menu.edit_option(matches[1], actual_group_key)
  else
    -- Multiple matches - show them
    local match_names = {}
    for i, key in ipairs(matches) do
      local option = config:get_option(key)
      match_names[i] = string.format("%d. %s", i, strip_trailing_punctuation(option.descr))
    end
    notify("info", string.format("Multiple matches found for '%s':\n%s", search_term, table.concat(match_names, "\n")))
  end
end

return config_menu
