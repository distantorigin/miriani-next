-- @module config_menu
-- Terminal-based configuration menu using dialog system

local config_menu = {}

-- Sounds that support variants (used in show_group and find_and_edit)
local variant_sounds = {
  {path = "miriani/ship/move/accelerate.ogg", name = "Ship Accelerate", default = 3},
  {path = "miriani/ship/move/decelerate.ogg", name = "Ship Decelerate", default = 3},
  {path = "miriani/ship/combat/weaponsLocked.ogg", name = "Weapons Locked", default = 2},
  {path = "miriani/vehicle/accelerate.ogg", name = "Vehicle Accelerate (Salvagers and ACVs)", default = 1},
  {path = "miriani/vehicle/decelerate.ogg", name = "Vehicle Decelerate (Salvagers and ACVs)", default = 1},
  {path = "miriani/activity/archaeology/artifactHere.ogg", name = "Archaeology Artifact Detected", default = 1},
  {path = "miriani/misc/Santa Box Sounds/jingleBell.ogg", name = "Jingle Bells", default = 1},
  {path = "miriani/ship/misc/chime.ogg", name = "Airlock Chime", default = 2},
  {path = "miriani/device/radio/detect.ogg", name = "Radio Receiver Transmission Detected", default = 1}
}

-- Special groups that have no regular options
local special_groups = {"audio groups", "sound variants", "themes", "mutes"}

-- Get social categories dynamically from socials module
local function get_social_categories()
  local categories = {}
  if get_all_social_categories then
    for _, cat in ipairs(get_all_social_categories()) do
      table.insert(categories, "socials_" .. cat)
    end
  else
    -- Fallback to defaults
    categories = {"socials_laughter", "socials_distress", "socials_reflex", "socials_bodily", "socials_physical", "socials_reaction", "socials_novelty"}
  end
  return categories
end

-- Known option groups for exact matching
local known_groups = {
  "general", "auto_login", "ship", "room", "helpers", "screen reader",
  "gags", "socials", "socials_laughter", "socials_distress", "socials_reflex",
  "socials_bodily", "socials_physical", "socials_reaction", "socials_novelty",
  "socials_songs", "socials_dances", "socials_uncategorized", "scan_formats", "buffers", "colors", "developer",
  "themes", "mutes"
}

-- Helper function to strip trailing punctuation from option descriptions
local function strip_trailing_punctuation(text)
  return text:gsub("[%.,:;!?]+%s*$", "")
end

-- Validate and normalize a value for a given option type.
-- Returns normalized_value, error_message
local function validate_option_value(option, value)
  local opt_type = option.type or "string"
  if opt_type == "bool" or opt_type == "boolean" then
    local v = string.lower(value)
    if v == "yes" or v == "on" or v == "true" or v == "1" then
      return "yes", nil
    elseif v == "no" or v == "off" or v == "false" or v == "0" then
      return "no", nil
    end
    return nil, string.format("Invalid value '%s' for toggle option. Use yes/no, on/off, or true/false.", value)
  elseif opt_type == "enum" then
    if option.options then
      for _, valid in ipairs(option.options) do
        if string.lower(valid) == string.lower(value) then
          return valid, nil
        end
      end
      return nil, string.format("Invalid value '%s'. Options: %s", value, table.concat(option.options, ", "))
    end
  elseif opt_type == "password" then
    return nil, "Passwords cannot be set inline."
  end
  return value, nil
end

-- Main configuration menu
function config_menu.show_main()
  local main_menu = config:render_menu_list()

  if type(main_menu) ~= 'table' then
    mplay("misc/Uncategorized/cancel")
    notify("critical", "Unable to load configuration menu.")
    return
  end

  -- Add "audio groups" and "sound variants" to the menu even though they have no regular options
  for _, group_key in ipairs(special_groups) do
    local found = false
    for _, title in ipairs(main_menu) do
      if config:get_group_key_from_title(title) == group_key then
        found = true
        break
      end
    end
    if not found then
      table.insert(main_menu, (config:get_group_title(group_key)))
    end
  end

  -- Filter out socials subcategory groups (they appear under "Social Sounds" menu instead)
  local filtered_menu = {}
  for _, title in ipairs(main_menu) do
    local group_key = config:get_group_key_from_title(title)
    -- Only include if it's not a socials subcategory (socials_laughter, socials_distress, etc.)
    if not (group_key and group_key:match("^socials_")) then
      table.insert(filtered_menu, title)
    end
  end
  main_menu = filtered_menu

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
  if string.lower(group_name) == "reset" then
    local result = utils.msgbox(
      "This will reset all settings to their defaults.\n\nAre you sure?",
      "Reset Configuration",
      "yesno",
      "!",
      2
    )
    if result == "yes" then
      config:reset()
      notify("info", "Configuration has been reset to defaults. Please restart the world for changes to take effect.")
    end
    return
  end

  -- Special handling for audio groups submenu - it has no regular options
  local secondary_menu = {}
  -- Optional secondary_menu key. When set, a divider row is drawn just
  -- before this entry in the rendered choice list.
  local menu_separator_before = nil

  -- If group_name is partial, try to find the actual group key
  local actual_group_key = group_name

  -- First check if it's an exact or partial match for a known group (prefer shorter matches)
  local matched_exact = false
  local partial_match = nil
  for _, known in ipairs(known_groups) do
    if string.lower(known) == string.lower(group_name) then
      actual_group_key = known
      matched_exact = true
      break
    elseif string.find(string.lower(known), string.lower(group_name)) then
      -- Prefer shorter matches (e.g., "socials" over "socials_distress")
      if not partial_match or #known < #partial_match then
        partial_match = known
      end
    end
  end

  -- If not an exact match, check special groups
  if not matched_exact then
    for _, special_group in ipairs(special_groups) do
      if string.find(string.lower(special_group), string.lower(group_name)) then
        if not partial_match or #special_group < #partial_match then
          partial_match = special_group
        end
      end
    end
  end

  -- Use partial match if found
  if not matched_exact and partial_match then
    actual_group_key = partial_match
    matched_exact = true
  end

  -- If still not matched, try to find a matching group from options
  if not matched_exact then
    partial_match = nil
    for key, option in pairs(config.options or {}) do
      local group_lower = string.lower(option.group)
      local name_lower = string.lower(group_name)
      if group_lower == name_lower then
        actual_group_key = option.group
        matched_exact = true
        break
      elseif string.find(group_lower, name_lower) then
        if not partial_match or #option.group < #partial_match then
          partial_match = option.group
        end
      end
    end
    if not matched_exact and partial_match then
      actual_group_key = partial_match
    end
  end

  local group_title = config:get_group_title(actual_group_key)
  -- Override title for virtual socials_all group
  if actual_group_key == "socials_all" then
    group_title = "All Sounds"
  end

  if actual_group_key == "socials" then
    -- Special handling for socials menu - show master toggle AND subcategory links
    -- Only include the master toggle, not category toggles (those go in their submenus)
    if config:is_option("social_sounds") then
      local master = config:get_option("social_sounds")
      local status = master.value == "yes" and "[On]" or "[Off]"
      -- Prefix with "00" to sort first
      secondary_menu["00_social_sounds"] = string.format("All Socials (Master Mute/Unmute) %s", status)
    end

    -- Add links to subcategory menus dynamically
    local subcategories = {}
    for _, cat_key in ipairs(get_social_categories()) do
      local cat_name = cat_key:match("^socials_(.+)$")
      if cat_name then
        -- Get description from category toggle option
        local toggle_key = "social_cat_" .. cat_name
        local toggle_opt = config:get_option(toggle_key)
        local title = toggle_opt.descr or cat_name:gsub("^%l", string.upper)
        table.insert(subcategories, {key = cat_key, title = title})
      end
    end
    -- Add "Show All Social Sounds" at the end
    table.insert(subcategories, {key = "socials_all", title = "Show All Social Sounds"})

    for i, subcat in ipairs(subcategories) do
      -- Use numeric prefix in key to preserve order
      secondary_menu[string.format("%02d", i) .. "_submenu_" .. subcat.key] = subcat.title
    end

  elseif actual_group_key == "sound variants" then
    for _, sound in ipairs(variant_sounds) do
      local sound_key = "_sound_variant_" .. sound.path:gsub("/", "_"):gsub("%.", "_")
      local preference = get_variant_preference(sound.path)

      -- If no preference is set, use the default
      if preference == 0 or not preference then
        preference = sound.default
      end

      local status = "Variant " .. preference
      local overriding_theme = find_overriding_replace_theme and find_overriding_replace_theme(sound.path)
      if overriding_theme then
        status = status .. ", replaced by " .. overriding_theme.name .. " theme"
      end

      secondary_menu[sound_key] = string.format("%s [%s]", sound.name, status)
    end
  elseif actual_group_key == "socials_all" then
    -- Special handling for "All sounds" - show all individual social toggles from all categories
    for _, group_key in ipairs(get_social_categories()) do
      local category_options = config:render_menu_list(group_key)
      if type(category_options) == 'table' then
        for key, value in pairs(category_options) do
          secondary_menu[key] = value
        end
      end
    end

  elseif actual_group_key:match("^socials_") then
    -- Special handling for socials subcategory menus - include category toggle at the top
    local category_name = actual_group_key:match("^socials_(.+)$")
    local category_toggle_key = "social_cat_" .. category_name

    -- Add the category toggle first (prefix with "00" to sort first)
    if config:is_option(category_toggle_key) then
      local cat_option = config:get_option(category_toggle_key)
      local status = cat_option.value == "yes" and "[On]" or "[Off]"
      secondary_menu["00_" .. category_toggle_key] = string.format("Toggle Category %s", status)
    end

    -- Then add all individual socials for this category
    local category_options = config:render_menu_list(actual_group_key)
    if type(category_options) == 'table' then
      for key, value in pairs(category_options) do
        secondary_menu[key] = value
      end
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

  elseif actual_group_key == "themes" then
    discover_themes()
    local themes = get_all_themes()

    if #themes == 0 then
      notify("info", "No themes found. Place theme folders in sounds/themes/ to get started.")
      config_menu.show_main()
      return
    end

    local all_mode = is_all_themes_mode()

    for i, theme in ipairs(themes) do
      local theme_key = string.format("%02d_theme_", i) .. theme.id
      local status
      if all_mode then
        status = "[On, via all themes mode]"
      else
        status = is_theme_enabled(theme.id) and "[On]" or "[Off]"
      end
      secondary_menu[theme_key] = string.format("%s %s", theme.name, status)
    end

    -- Advanced-options link sits at the bottom of the list; the "zz_" prefix
    -- sorts it after the "NN_theme_" entries. A separator is inserted just
    -- above it via the numbered-choices step below.
    secondary_menu["zz_submenu_themes_advanced"] = "Advanced options..."
    menu_separator_before = "zz_submenu_themes_advanced"

  elseif actual_group_key == "themes_advanced" then
    local all_mode = is_all_themes_mode()
    local force_additive = is_force_additive_mode()
    secondary_menu["01_all_themes_mode"] = string.format(
      "All themes mode: keep every theme enabled, including any you add later [%s]",
      all_mode and "On" or "Off")
    secondary_menu["02_force_additive_mode"] = string.format(
      "Force additive: mix replace-mode theme sounds into the shuffle instead of letting them override the default sounds [%s]",
      force_additive and "On" or "Off")

  elseif actual_group_key == "mutes" then
    secondary_menu["00_ignore_new"] = "Mute a sound..."

    local ignored = get_ignored_sounds()
    for i, sound_path in ipairs(ignored) do
      local display = sound_path:gsub("^miriani/", ""):gsub("%.ogg$", ""):gsub("%.wav$", "")
      secondary_menu["_ignored_" .. tostring(i)] = display
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

  -- Get all keys and sort
  for key in pairs(secondary_menu) do
    table.insert(sorted_keys, key)
  end
  if actual_group_key == "socials" or actual_group_key:match("^socials_") or actual_group_key == "mutes" or actual_group_key == "themes" or actual_group_key == "themes_advanced" then
    -- Sort by key to preserve intended order (00_ prefix sorts action first)
    table.sort(sorted_keys)
  else
    table.sort(sorted_keys, function(a, b)
      local opt_a = config.options and config.options[a]
      local opt_b = config.options and config.options[b]
      local order_a = opt_a and opt_a.order
      local order_b = opt_b and opt_b.order
      if order_a or order_b then
        return (order_a or 9999) < (order_b or 9999)
      end
      return secondary_menu[a] < secondary_menu[b]
    end)
  end

  -- Create numbered menu
  choices["0"] = "Go back"
  local separator_target_num = nil
  for i, key in ipairs(sorted_keys) do
    local num = tostring(i)
    choices[num] = secondary_menu[key]  -- Just the description, no key name
    key_map[num] = key  -- Remember which option this number refers to
    if key == menu_separator_before and i > 1 then
      separator_target_num = tostring(i - 1)
    end
  end

  local separators = nil
  if separator_target_num then
    separators = {
      {after = separator_target_num, label = string.rep("-", 40)},
    }
  end

  if actual_group_key == "themes_advanced" then
    group_title = "Advanced Theme Options"
  end

  dialog.menu({
    title = group_title,
    choices = choices,
    separators = separators,
    callback = function(result, reason)
      if result then
        if result.key == "0" then
          -- If we're in a socials subcategory, go back to socials menu
          if actual_group_key:match("^socials_") then
            config_menu.show_group("socials")
          elseif actual_group_key == "themes_advanced" then
            config_menu.show_group("themes")
          else
            config_menu.show_main()
          end
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
-- If skip_menu is true, don't show the group menu after editing (for direct command access)
function config_menu.edit_option(option_key, group_name, skip_menu)
  -- Special handling for socials submenu navigation
  if option_key:match("_submenu_socials_") then
    local subgroup = option_key:match("_submenu_(socials_.+)$")
    if subgroup then
      config_menu.show_group(subgroup)
      return
    end
  end

  -- Special handling for the themes advanced-options submenu link
  if option_key:match("_submenu_themes_advanced$") then
    config_menu.show_group("themes_advanced")
    return
  end

  -- Special handling for socials toggles (have "00_" prefix)
  if option_key == "00_social_sounds" then
    option_key = "social_sounds"
  elseif option_key:match("^00_social_cat_") then
    option_key = option_key:gsub("^00_", "")
  end

  -- Special handling for sound variants
  if option_key:match("^_sound_variant_") then
    local sound_path = option_key:match("^_sound_variant_(.+)$"):gsub("_", "/"):gsub("/ogg$", ".ogg")
    if sound_path then
      -- Get available variants
      local variants = scan_sound_variants(sound_path)

      -- Check if we found any variants
      if #variants == 0 then
        notify("critical", string.format("No variants found for %s", sound_path))
        if not skip_menu then config_menu.show_group(group_name) end
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

      local message = string.format("%d variants available. Select one:", #variants)
      local overriding_theme = find_overriding_replace_theme and find_overriding_replace_theme(sound_path)
      if overriding_theme then
        message = message .. string.format(
          "\n\nThe %s theme is replacing this sound. Disable it to hear your variant selection.",
          overriding_theme.name
        )
      end

      dialog.menu({
        title = string.format("Select variant for %s", display_name),
        message = message,
        choices = choices,
        callback = function(result, reason)
          if result then
            local menu_index = tonumber(result.key)
            local selected_variant = menu_index and variants[menu_index]
            if not selected_variant then
              notify("critical", "Invalid variant selection; preference unchanged.")
            else
              set_variant_preference(sound_path, selected_variant)

              -- Play preview of the selected sound
              -- Remove .ogg extension, add variant number, then add .ogg back
              local path_without_ext = sound_path:gsub("%.ogg$", "")
              local preview_file = path_without_ext .. tostring(selected_variant) .. ".ogg"
              play(preview_file)

              notify("info", string.format("%s set to Variant %d", display_name, selected_variant))
            end
          end
          -- Return to sound variants menu
          if not skip_menu then config_menu.show_group(group_name) end
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
      if not skip_menu then config_menu.show_group(group_name) end
      return
    end
  end

  -- Special handling for the advanced themes toggles. Menu keys are
  -- `NN_all_themes_mode` / `NN_force_additive_mode` from the submenu, or
  -- `_all_themes_mode` / `_force_additive_mode` from find_and_edit.
  if option_key:match("^%d*_all_themes_mode$") then
    local current = is_all_themes_mode()
    set_all_themes_mode(not current)
    local status = (not current) and "on" or "off"
    notify("info", string.format("All themes mode set to %s", status))
    if not skip_menu then config_menu.show_group(group_name) end
    return
  end

  if option_key:match("^%d*_force_additive_mode$") then
    local current = is_force_additive_mode()
    set_force_additive_mode(not current)
    local status = (not current) and "on" or "off"
    notify("info", string.format("Force additive theme mode set to %s", status))
    if not skip_menu then config_menu.show_group(group_name) end
    return
  end

  -- Special handling for themes (menu keys are `_theme_<id>` from find_and_edit
  -- or `NN_theme_<id>` from the numbered submenu).
  if option_key:match("^%d*_theme_") then
    local theme_id = option_key:match("^%d*_theme_(.+)$")
    if theme_id then
      local theme_info = get_theme_info(theme_id)
      if not theme_info then
        notify("critical", string.format("Theme '%s' not found.", theme_id))
        if not skip_menu then config_menu.show_group(group_name) end
        return
      end

      local all_mode = is_all_themes_mode and is_all_themes_mode()
      local force_additive = is_force_additive_mode and is_force_additive_mode()
      -- Under all-themes mode the effective state is always on, but the
      -- individual toggle still edits the underlying preference so it takes
      -- effect once all-themes mode is turned back off.
      local current_state = all_mode and is_theme_preference_enabled(theme_id) or is_theme_enabled(theme_id)
      local file_count, total_size = count_theme_files(theme_id)
      local mode_label
      if theme_info.mode == "replace" then
        mode_label = force_additive
          and "Replace (pooled with default sounds while force additive mode is on)"
          or  "Replace (overrides default sounds)"
      else
        mode_label = "Additive (pools with default sounds)"
      end

      local function format_size(bytes)
        if bytes >= 1024 * 1024 then
          return string.format("%.2fMB", bytes / (1024 * 1024))
        elseif bytes >= 1024 then
          return string.format("%.1fKB", bytes / 1024)
        else
          return string.format("%dB", bytes)
        end
      end

      local detail_lines = {}
      table.insert(detail_lines, theme_info.name)
      table.insert(detail_lines, string.rep("-", #theme_info.name))
      if theme_info.author then
        table.insert(detail_lines, "Author: " .. theme_info.author)
      end
      if theme_info.description then
        table.insert(detail_lines, "")
        table.insert(detail_lines, theme_info.description)
        table.insert(detail_lines, "")
      end
      table.insert(detail_lines, "Mode: " .. mode_label)
      table.insert(detail_lines, string.format("Files: %d (%s)", file_count, format_size(total_size)))
      local last_updated = get_theme_last_updated(theme_id)
      if last_updated then
        table.insert(detail_lines, "Last updated: " .. os.date("%b %d, %Y at %I:%M %p", last_updated))
      end
      if all_mode then
        table.insert(detail_lines, "")
        table.insert(detail_lines, "All themes mode is on: this theme is active regardless of the toggle below. The toggle sets what will apply once all-themes mode is turned off.")
      end
      table.insert(detail_lines, "")

      local pl_path = require("pl.path")
      local toggle_label
      if all_mode then
        toggle_label = current_state and "Set preference to off" or "Set preference to on"
      else
        toggle_label = current_state and "Disable theme" or "Enable theme"
      end
      local changelog_path = theme_info.path .. "/changelog.md"
      local has_changelog = pl_path.isfile(changelog_path)

      local choices = {
        ["1"] = toggle_label,
        ["2"] = "View sounds",
        ["3"] = "Open folder",
      }
      if has_changelog then
        choices["4"] = "View changelog"
      end
      if not skip_menu then
        choices["0"] = "Go back"
      end

      dialog.menu({
        title = table.concat(detail_lines, "\n"),
        choices = choices,
        callback = function(result, reason)
          if result and result.key == "1" then
            local new_state = not current_state
            set_theme_enabled(theme_id, new_state)
            local status = new_state and "on" or "off"
            notify("info", string.format("Theme \"%s\" set to %s", theme_info.name, status))
          elseif result and result.key == "2" then
            local sounds = list_theme_sounds(theme_id)
            local mode_verb = theme_info.mode == "replace" and "replace" or "add"
            local lines = {
              string.format("%s - sounds this theme will %s (%d files)",
                theme_info.name, mode_verb, #sounds),
              "",
            }
            if #sounds == 0 then
              table.insert(lines, "This theme has no sound files in its category folders yet.")
            else
              for _, rel in ipairs(sounds) do
                table.insert(lines, rel)
              end
            end
            local notepad_title = theme_info.name .. " Sounds"
            SendToNotepad(notepad_title, table.concat(lines, "\r\n"))
            NotepadReadOnly(notepad_title, true)
            NotepadSaveMethod(notepad_title, 2)
            ActivateNotepad(notepad_title)
            return
          elseif result and result.key == "3" then
            local abs = pl_path.abspath(theme_info.path):gsub("/", "\\")
            os.execute('start "" "' .. abs .. '"')
            return
          elseif result and result.key == "4" and has_changelog then
            local f = io.open(changelog_path, "r")
            if f then
              local text = f:read("*all")
              f:close()
              local notepad_title = theme_info.name .. " Changelog"
              SendToNotepad(notepad_title, (string.gsub(text, "\n", "\r\n")))
              NotepadReadOnly(notepad_title, true)
              NotepadSaveMethod(notepad_title, 2)
              ActivateNotepad(notepad_title)
            end
            -- Changelog opens in an external notepad; re-displaying the menu here
            -- would intercept the user's next input when they return from the notepad.
            return
          end
          if not skip_menu then config_menu.show_group(group_name) end
        end
      })
      return
    end
  end

  -- Special handling for muted sounds
  if option_key == "00_ignore_new" then
    local sound_browser = require("lua/miriani/scripts/sound_browser")
    sound_browser.browse({
      title = "Select a sound to mute",
      start_dir = "miriani/",
      callback = function(selected_path)
        if selected_path then
          local normalized = selected_path:gsub("(%d+)(%.%w+)$", "%2")
          ignore_sound(normalized)
          local display = normalized:gsub("^miriani/", ""):gsub("%.ogg$", ""):gsub("%.wav$", "")
          notify("info", string.format("Muted: %s", display))
        end
        if not skip_menu then config_menu.show_group(group_name) end
      end
    })
    return
  end

  if option_key:match("^_ignored_") then
    local index = tonumber(option_key:match("^_ignored_(%d+)$"))
    local ignored = get_ignored_sounds()
    if index and ignored[index] then
      local sound_path = ignored[index]
      local display = sound_path:gsub("^miriani/", ""):gsub("%.ogg$", ""):gsub("%.wav$", "")
      dialog.confirm({
        title = string.format("Unmute %s?", display),
        callback = function(result, reason)
          if result and result.confirmed then
            unignore_sound(sound_path)
            notify("info", string.format("Unmuted: %s", display))
          end
          if not skip_menu then config_menu.show_group(group_name) end
        end
      })
    else
      if not skip_menu then config_menu.show_group(group_name) end
    end
    return
  end

  if not config:is_option(option_key) then
    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Invalid option: %s.", option_key))
    if not skip_menu then config_menu.show_group(group_name) end
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

    -- Special handling for channel_history_persist option
    if option_key == "channel_history_persist" then
      if new_value == "no" then
        -- Disable persistence - enable memory-only mode and clear the database
        Execute("history_memory_only")
      else
        -- Enable persistence - initialize database and start saving
        Execute("history_persist")
      end
    end

    -- Special handling for buffer options - delete the buffer when disabled
    if option_key:match("_buffer$") and new_value == "no" then
      -- Exceptions where the category name differs from the option prefix
      local buffer_exceptions = {
        url_buffer = "URLs",
        flight_buffer = "flight control",
        board_buffer = "boards",
        scan_buffer = "scans",
        rp_buffer = "roleplay",
      }
      -- Special case: metaf_buffer deletes all buffers starting with "metaf"
      if option_key == "metaf_buffer" then
        Execute("history_delete_prefix metaf")
      else
        local category = buffer_exceptions[option_key] or option_key:gsub("_buffer$", "")
        Execute("history_delete " .. category)
      end
    end

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
    if not skip_menu then config_menu.show_group(group_name) end

  elseif opt_type == "enum" then
    -- Enum option - show menu of choices
    if not option.options or #option.options == 0 then
      mplay("misc/Uncategorized/cancel")
      notify("critical", "No options defined for this enum.")
      if not skip_menu then config_menu.show_group(group_name) end
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
      title = strip_trailing_punctuation(option.descr),
      choices = choices,
      callback = function(result, reason)
        if result then
          local selected_value = option.options[tonumber(result.key)]
          if selected_value then
            config:set_option(option_key, selected_value)
            local display_value = selected_value:gsub("^%l", string.upper)
            notify("info", string.format("%s set to %s", strip_trailing_punctuation(option.descr), display_value))
            config:save()

            -- Update ambiance immediately when the setting changes
            if option_key == "background_ambiance" then
              updateAmbiance()
            end
          end
        end
        -- Return to group menu
        if not skip_menu then config_menu.show_group(group_name) end
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

    if not skip_menu then config_menu.show_group(group_name) end

  else
    -- String or other type - use prompt
    local prompt_message
    if option_key == "relativity_drive_freq" then
      prompt_message = "Presets: 22050=half, 44100=normal, 88200=double\n\nEnter a blank line to reset to default."
    else
      prompt_message = string.format("Current value: %s\n\nEnter a blank line to reset to default.", tostring(option.value))
    end

    dialog.prompt({
      title = string.format("Set %s", option.descr),
      message = prompt_message,
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
        if not skip_menu then config_menu.show_group(group_name) end
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

  -- First check if it's an exact or partial match for a known group (prefer shorter matches)
  local matched_exact = false
  local partial_match = nil
  for _, known in ipairs(known_groups) do
    if string.lower(known) == string.lower(group_name) then
      actual_group_key = known
      matched_exact = true
      break
    elseif string.find(string.lower(known), string.lower(group_name)) then
      if not partial_match or #known < #partial_match then
        partial_match = known
      end
    end
  end

  -- If not an exact match, check special groups
  if not matched_exact then
    for _, special_group in ipairs(special_groups) do
      if string.find(string.lower(special_group), string.lower(group_name)) then
        if not partial_match or #special_group < #partial_match then
          partial_match = special_group
        end
      end
    end
  end

  -- Use partial match if found
  if not matched_exact and partial_match then
    actual_group_key = partial_match
    matched_exact = true
  end

  -- If still not matched, try to find a matching group from options
  if not matched_exact then
    partial_match = nil
    for key, option in pairs(config.options or {}) do
      local group_lower = string.lower(option.group)
      local name_lower = string.lower(group_name)
      if group_lower == name_lower then
        actual_group_key = option.group
        matched_exact = true
        break
      elseif string.find(group_lower, name_lower) then
        if not partial_match or #option.group < #partial_match then
          partial_match = option.group
        end
      end
    end
    if not matched_exact and partial_match then
      actual_group_key = partial_match
    end
  end

  -- Special handling for socials - navigate to subcategory menus or toggle individual socials
  if actual_group_key == "socials" then
    -- First try matching a category name
    local subcategory_names = {"laughter", "distress", "reflex", "bodily", "physical", "reaction", "novelty", "songs", "dances", "all"}
    for _, cat in ipairs(subcategory_names) do
      if string.find(string.lower(cat), string.lower(search_term)) then
        config_menu.show_group("socials_" .. cat)
        return
      end
    end

    -- Try matching an individual social name
    if get_all_socials then
      local search_lower = string.lower(search_term)
      for _, social_name in ipairs(get_all_socials()) do
        if string.find(string.lower(social_name), search_lower) then
          local option_key = "social_" .. social_name
          local option = config:get_option(option_key)
          if option then
            local new_value = option.value == "yes" and "no" or "yes"
            config:set_option(option_key, new_value)
            config:save()
            local status = new_value == "yes" and "enabled" or "disabled"
            notify("info", string.format("%s sound %s", social_name, status))
            return
          end
        end
      end
    end

    -- If nothing matched, show error
    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Could not find social or category matching '%s'.", search_term))
    return
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

    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Could not find sound group matching '%s'.", search_term))
    return
  end

  -- Special handling for sound variants
  if actual_group_key == "sound variants" then
    -- Try numeric index first
    local index = tonumber(search_term)
    if index and index >= 1 and index <= #variant_sounds then
      local sound = variant_sounds[index]
      local sound_key = "_sound_variant_" .. sound.path:gsub("/", "_"):gsub("%.", "_")
      config_menu.edit_option(sound_key, actual_group_key, true)
      return
    end

    -- Try partial name match
    for _, sound in ipairs(variant_sounds) do
      if string.find(string.lower(sound.name), string.lower(search_term)) or
         string.find(string.lower(sound.path), string.lower(search_term)) then
        local sound_key = "_sound_variant_" .. sound.path:gsub("/", "_"):gsub("%.", "_")
        config_menu.edit_option(sound_key, actual_group_key, true)
        return
      end
    end

    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Could not find sound variant matching '%s'.", search_term))
    return
  end

  -- Special handling for themes
  if actual_group_key == "themes" then
    discover_themes()
    local themes = get_all_themes()

    -- Shortcuts for the advanced toggles.
    local search_lower = string.lower(search_term)
    if search_lower == "all" or search_lower == "all themes" then
      config_menu.edit_option("_all_themes_mode", "themes", true)
      return
    end
    if search_lower == "additive" or search_lower == "force additive" then
      config_menu.edit_option("_force_additive_mode", "themes", true)
      return
    end
    if search_lower == "advanced" then
      config_menu.show_group("themes_advanced")
      return
    end

    -- Try numeric index first
    local index = tonumber(search_term)
    if index and index >= 1 and index <= #themes then
      local theme = themes[index]
      config_menu.edit_option("_theme_" .. theme.id, "themes", true)
      return
    end

    -- Try partial name match
    for _, theme in ipairs(themes) do
      if string.find(string.lower(theme.name), string.lower(search_term)) or
         string.find(string.lower(theme.id), string.lower(search_term)) then
        config_menu.edit_option("_theme_" .. theme.id, "themes", true)
        return
      end
    end

    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Could not find theme matching '%s'.", search_term))
    return
  end

  -- Special handling for muted sounds
  if actual_group_key == "mutes" then
    local ignored = get_ignored_sounds()

    -- Try numeric index first
    local index = tonumber(search_term)
    if index and index >= 1 and index <= #ignored then
      config_menu.edit_option("_ignored_" .. tostring(index), "mutes", true)
      return
    end

    -- Try partial name match to unignore
    for i, sound_path in ipairs(ignored) do
      if string.find(string.lower(sound_path), string.lower(search_term)) then
        config_menu.edit_option("_ignored_" .. tostring(i), "mutes", true)
        return
      end
    end

    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Could not find muted sound matching '%s'.", search_term))
    return
  end

  -- Get options for this group
  local group_options = config:render_menu_list(actual_group_key)

  if type(group_options) ~= 'table' then
    mplay("misc/Uncategorized/cancel")
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

  -- Try numeric index first (with optional inline value: "2 yes")
  local index_str, index_value = search_term:match("^(%d+)%s+(%S+)$")
  local index = tonumber(index_str) or tonumber(search_term)
  if index and index >= 1 and index <= #sorted_keys then
    local option_key = sorted_keys[index]
    if index_value then
      local option = config:get_option(option_key)
      local validated, err = validate_option_value(option, index_value)
      if err then
        mplay("misc/Uncategorized/cancel")
        notify("critical", err)
        return
      end
      config:set_option(option_key, validated)
      config:save()
      notify("info", string.format("%s set to %s", strip_trailing_punctuation(option.descr), validated))
    else
      config_menu.edit_option(option_key, actual_group_key, true)
    end
    return
  end

  -- Try partial name matching (case-insensitive)
  local matches = {}
  local search_lower = string.lower(search_term)
  local search_underscored = search_lower:gsub("%s+", "_")

  for _, key in ipairs(sorted_keys) do
    local option = config:get_option(key)
    local descr_lower = string.lower(option.descr or "")
    local key_lower = string.lower(key)

    if string.find(descr_lower, search_lower) or string.find(key_lower, search_lower) or string.find(key_lower, search_underscored) then
      table.insert(matches, key)
    end
  end

  -- Fallback: search hidden options directly
  if #matches == 0 then
    for key, option in pairs(config.options or {}) do
      if option.hidden and string.find(option.group, actual_group_key) then
        local descr_lower = string.lower(option.descr or "")
        local key_lower = string.lower(key)
        if string.find(descr_lower, search_lower) or string.find(key_lower, search_lower) or string.find(key_lower, search_underscored) then
          table.insert(matches, key)
        end
      end
    end
  end

  -- If no matches and search term has multiple words, try splitting into option name + value
  -- Try each possible split point from right to left (last word as value, then last two, etc.)
  if #matches == 0 then
    local option_name, inline_value = search_term:match("^(.+)%s+(%S+)$")
    if option_name then
      local name_lower = string.lower(option_name)
      local name_underscored = name_lower:gsub("%s+", "_")
      -- Search visible options
      for _, key in ipairs(sorted_keys) do
        local option = config:get_option(key)
        local descr_lower = string.lower(option.descr or "")
        local key_lower = string.lower(key)
        if string.find(descr_lower, name_lower) or string.find(key_lower, name_lower) or string.find(key_lower, name_underscored) then
          table.insert(matches, key)
        end
      end
      -- Search hidden options
      if #matches == 0 then
        for key, option in pairs(config.options or {}) do
          if option.hidden and string.find(option.group, actual_group_key) then
            local descr_lower = string.lower(option.descr or "")
            local key_lower = string.lower(key)
            if string.find(descr_lower, name_lower) or string.find(key_lower, name_lower) or string.find(key_lower, name_underscored) then
              table.insert(matches, key)
            end
          end
        end
      end
      if #matches == 1 then
        local option = config:get_option(matches[1])
        local validated, err = validate_option_value(option, inline_value)
        if err then
          mplay("misc/Uncategorized/cancel")
          notify("critical", err)
          return
        end
        config:set_option(matches[1], validated)
        config:save()
        notify("info", string.format("%s set to %s", strip_trailing_punctuation(option.descr), validated))
        return
      end
      matches = {}
    end
  end

  if #matches == 0 then
    mplay("misc/Uncategorized/cancel")
    notify("critical", string.format("Could not find option matching '%s' in group '%s'.", search_term, group_name))
  elseif #matches == 1 then
    -- Single match - edit it
    config_menu.edit_option(matches[1], actual_group_key, true)
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
