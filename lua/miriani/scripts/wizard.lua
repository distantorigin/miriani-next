-- @module wizard
-- Getting Started Wizard for new Miriani-Next users
-- Mixes native Windows dialogs with terminal menus to introduce the interface

local wizard = {}
local steps = {}
local current_step = 0

local function msgbox(message, title, buttons, icon)
  return utils.msgbox(message, title, buttons or "ok", icon or "i", 1)
end

local function yesno(message, title)
  return msgbox(message, title, "yesno", "?") == "yes"
end

local deferred_fn = nil

function wizard_deferred()
  if deferred_fn then
    local fn = deferred_fn
    deferred_fn = nil
    fn()
  end
end

local function defer(fn)
  deferred_fn = fn
  DoAfterSpecial(2, "wizard_deferred()", sendto.script)
end

local social_categories = {
  {key = "social_cat_laughter", label = "Laughter (laugh, giggle, chuckle)"},
  {key = "social_cat_distress", label = "Distress (cry, sob, moan)"},
  {key = "social_cat_reflex", label = "Reflex (cough, sneeze, yawn)"},
  {key = "social_cat_bodily", label = "Bodily (fart, burp, belch)"},
  {key = "social_cat_physical", label = "Physical (punch, kick, clap)"},
  {key = "social_cat_novelty", label = "Novelty (animals, musical, memes)"},
  {key = "social_cat_songs", label = "Songs"},
  {key = "social_cat_uncategorized", label = "Uncategorized"},
}

function wizard.should_run()
  return GetVariable("wizard_completed") == nil
end

function wizard.advance()
  current_step = current_step + 1
  if steps[current_step] then
    steps[current_step]()
  end
end

function wizard.run()
  current_step = 0
  steps = {
    wizard.step_welcome,
    wizard.step_auto_login,
    wizard.step_social_sounds,
    wizard.step_themes,
    wizard.step_volume,
    wizard.step_ambiance,
    wizard.step_screen_reader,
    wizard.step_keybindings,
    wizard.step_updates,
    wizard.step_finish,
  }
  wizard.advance()
end

function wizard.step_welcome()
  local result = msgbox(
    "Welcome to Miriani-Next, a fully-featured client package for Miriani!\n\n" ..
    "This wizard will walk you through some initial settings to help you " ..
    "get the most out of the scripts. It should only take a minute or two.\n\n" ..
    "You'll see a mix of popup dialogs and textual menus during setup. " ..
    "The textual menus work the same way as the rest of the configuration, as well as " ..
    "menus inside the game itself, so this is a good preview of how things work.\n\n" ..
    "You can always change these settings later using the 'conf' command or by pressing F1.\n\n" ..
    "Click OK to begin, or Cancel to skip.",
    "Miriani-Next Setup Wizard",
    "okcancel", "i"
  )

  if result == "cancel" then
    SetVariable("wizard_completed", "1")
    notify("info", "Setup wizard skipped. Type 'setup' to run it again anytime.")
    return
  end

  wizard.advance()
end

function wizard.step_auto_login()
  if not yesno(
    "Would you like to set up automatic login?\n\n" ..
    "When enabled, Miriani-Next will automatically enter your " ..
    "username and password when you connect to the game.\n\n" ..
    "You can skip this and set it up later in 'conf auto'.",
    "Auto-Login Setup"
  ) then
    wizard.advance()
    return
  end

  local username = utils.inputbox(
    "Enter your Miriani character name:\n\n" ..
    "(If your name contains spaces, use underscores instead.)",
    "Auto-Login - Username",
    ""
  )

  if not username or username == "" then
    wizard.advance()
    return
  end

  local password = utils.inputbox(
    "Enter your Miriani password:\n\n" ..
    "(Note: the password will be visible as you type.)",
    "Auto-Login - Password",
    ""
  )

  if not password or password == "" then
    wizard.advance()
    return
  end

  config:set_option("auto_login_username", username)
  config:set_option("auto_login_password", password)
  config:set_option("auto_login", "yes")
  config:save()

  msgbox(
    "Auto-login has been configured for " .. username .. ".\n\n" ..
    "You can update your credentials anytime in 'conf auto'.",
    "Auto-Login Setup"
  )

  wizard.advance()
end

function wizard.step_social_sounds()
  if not yesno(
    "Miriani-Next includes sound effects for in-game social commands " ..
    "like laugh, cry, sneeze, clap, and many more.\n\n" ..
    "Would you like to enable social sounds?",
    "Social Sounds"
  ) then
    config:set_option("social_sounds", "no")
    config:save()
    wizard.advance()
    return
  end

  config:set_option("social_sounds", "yes")
  config:save()

  msgbox(
    "Now let's choose which social sound categories to enable.\n\n" ..
    "Warning: The Songs category is disabled by default since the clips can " ..
    "be up to 20 seconds long. It covers socials like cake, horses, " ..
    "and pirate.\n\n" ..
    "You're about to see an in-game menu in the MUSHclient window. " ..
    "This is how most configuration works in Miriani-Next.\n\n" ..
    "To use it:\n" ..
    "  - Type a number to select an option.\n" ..
    "  - Or type part of an option's name.\n" ..
    "  - Select a category to toggle it on or off.\n" ..
    "  - Choose 'Done' when you're finished.",
    "Social Sound Categories"
  )

  defer(wizard.show_social_category_menu)
end

function wizard.show_social_category_menu()
  local choices = {}
  for i, cat in ipairs(social_categories) do
    local status = config:get_option(cat.key).value == "yes" and "[On]" or "[Off]"
    choices[tostring(i)] = cat.label .. " " .. status
  end
  choices["0"] = "Done - continue to next step"

  dialog.menu({
    title = "\nSocial Sound Categories\n" ..
            "Select a category to toggle it, or choose Done to continue.",
    choices = choices,
    prompt = "Type a number or part of a name to select.",
    callback = function(result, reason)
      if not result or result.key == "0" then
        wizard.advance()
        return
      end

      local index = tonumber(result.key)
      if index and social_categories[index] then
        local cat = social_categories[index]
        local current = config:get_option(cat.key).value
        local new_value = current == "yes" and "no" or "yes"
        config:set_option(cat.key, new_value)
        config:save()
        local status = new_value == "yes" and "enabled" or "disabled"
        notify("info", cat.label .. " " .. status)
      end

      wizard.show_social_category_menu()
    end
  })
end

function wizard.step_themes()
  if not get_all_themes then
    wizard.advance()
    return
  end

  local themes = get_all_themes()
  if #themes == 0 then
    wizard.advance()
    return
  end

  msgbox(
    "Miriani-Next supports sound themes that can customize your audio experience.\n\n" ..
    "Themes can be 'additive' (new sounds are mixed in with defaults for variety) " ..
    "or 'replace' (theme sounds override the defaults entirely).\n\n" ..
    "Let's review the available themes.",
    "Sound Themes"
  )

  for _, theme in ipairs(themes) do
    local desc = theme.description or "No description available."
    local mode_label = theme.mode == "additive"
      and "Additive (adds variety to existing sounds)"
      or "Replace (overrides default sounds)"
    local author_line = theme.author
      and ("Author: " .. theme.author .. "\n")
      or ""

    if yesno(
      theme.name .. "\n" ..
      author_line ..
      "Mode: " .. mode_label .. "\n\n" ..
      desc .. "\n\n" ..
      "Would you like to enable this theme?",
      "Sound Themes - " .. theme.name
    ) then
      set_theme_enabled(theme.id, true)
    end
  end

  wizard.advance()
end

function wizard.step_volume()
  local current = tostring(config:get_master_volume())

  local volume = utils.inputbox(
    "Set your master volume level (0 to 100).\n\n" ..
    "This controls the overall volume of all sound audio. " ..
    "You can adjust it anytime with the F11 and F12 keys.\n\n" ..
    "There are also separate volume controls for sound effects, " ..
    "ambient sounds, and social sounds that you can tweak later " ..
    "using F10 to cycle between groups.",
    "Master Volume",
    current
  )

  if volume then
    local vol_num = tonumber(volume)
    if vol_num and vol_num >= 0 and vol_num <= 100 then
      config:set_master_volume(vol_num)
      config:save()
    else
      msgbox(
        "Invalid volume value. Keeping the current setting (" .. current .. "%).",
        "Master Volume",
        "ok", "!"
      )
    end
  end

  wizard.advance()
end

function wizard.step_ambiance()
  msgbox(
    "Miriani-Next can play ambient background sounds based on your " ..
    "in-game location.\n\n" ..
    "For example, you might hear ocean waves on a beach, machinery " ..
    "in a station, or wind on a planet surface.\n\n" ..
    "Next you'll choose your preferred mode using an in-game menu.",
    "Background Ambiance"
  )

  defer(wizard.show_ambiance_menu)
end

function wizard.show_ambiance_menu()
  local current = config:get_option("background_ambiance").value or "focused"
  local function label(mode, desc)
    local marker = mode == current and " (current)" or ""
    return desc .. marker
  end

  dialog.menu({
    title = "\nBackground Ambiance\n" ..
            "Choose your preferred ambiance mode.",
    choices = {
      ["1"] = label("off", "Off - No background ambiance"),
      ["2"] = label("focused", "Focused - Plays only when MUSHclient has focus"),
      ["3"] = label("always", "Always - Plays continuously"),
    },
    prompt = "Type a number to select.",
    callback = function(result, reason)
      if result then
        local modes = {["1"] = "off", ["2"] = "focused", ["3"] = "always"}
        local mode = modes[result.key]
        if mode then
          config:set_option("background_ambiance", mode)
          config:save()
          notify("info", "Background ambiance set to: " .. mode)
        end
      end
      wizard.advance()
    end
  })
end

function wizard.step_screen_reader()
  if not yesno(
    "Miriani-Next includes screen reader integration features.\n\n" ..
    "If you use a screen reader, the scripts can interrupt speech " ..
    "for important events so you don't miss critical information.\n\n" ..
    "Do you use a screen reader?",
    "Screen Reader Integration"
  ) then
    wizard.advance()
    return
  end

  if yesno(
    "Would you like your screen reader to be interrupted when " ..
    "Praelor (enemy) activity is detected nearby?\n\n" ..
    "This helps ensure you don't miss urgent combat alerts.",
    "Screen Reader - Praelor Alerts"
  ) then
    config:set_option("praelor_interrupt", "yes")
    config:save()
  end

  msgbox(
    "When scanning from a starship, the scripts can interrupt " ..
    "your screen reader to announce coordinates.\n\n" ..
    "You can choose to have this happen for starships only, " ..
    "for everything that shows up on scan, or not at all.\n\n" ..
    "Choose your preference in the next menu.",
    "Screen Reader - Scan Interrupts"
  )

  defer(wizard.show_scan_interrupt_menu)
end

function wizard.show_scan_interrupt_menu()
  local current = config:get_option("scan_interrupt").value or "starships"
  local function label(mode, desc)
    local marker = mode == current and " (current)" or ""
    return desc .. marker
  end

  dialog.menu({
    title = "\nScan Interrupt Mode\n" ..
            "Choose when scan coordinates should interrupt speech.",
    choices = {
      ["1"] = label("starships", "Starships only"),
      ["2"] = label("everything", "Everything"),
      ["3"] = label("off", "Off"),
    },
    prompt = "Type a number to select.",
    callback = function(result, reason)
      if result then
        local modes = {["1"] = "starships", ["2"] = "everything", ["3"] = "off"}
        local mode = modes[result.key]
        if mode then
          config:set_option("scan_interrupt", mode)
          config:save()
          notify("info", "Scan interrupts set to: " .. mode)
        end
      end
      wizard.show_follow_interrupt_confirm()
    end
  })
end

function wizard.show_follow_interrupt_confirm()
  dialog.confirm({
    title = "\nFollow Interrupt\n" ..
            "Would you like speech to be interrupted when you follow someone " ..
            "or are dragged to a new room?",
    callback = function(result, reason)
      if result and result.confirmed then
        config:set_option("follow_interrupt", "yes")
        config:save()
        notify("info", "Follow interrupt enabled.")
      end
      wizard.advance()
    end
  })
end

function wizard.step_keybindings()
  msgbox(
    "Here are the most important keyboard shortcuts:\n\n" ..
    "Configuration:\n" ..
    "  F1 - Open configuration menu.\n" ..
    "  F2 - View changelog.\n\n" ..
    "Audio Controls:\n" ..
    "  F9 - Toggle global mute.\n" ..
    "  Ctrl+F9 - Toggle foreground-only sounds.\n" ..
    "  F10 / Shift+F10 - Cycle audio groups.\n" ..
    "  F11 / F12 - Decrease / increase group volume.\n\n" ..
    "Output Buffers:\n" ..
    "  Alt+1 through Alt+0 - Read recent messages.\n" ..
    "  Alt+Up / Alt+Down - Navigate message history.\n" ..
    "  Alt+Left / Alt+Right - Switch between buffers.\n" ..
    "  Alt+Q / Alt+Shift+Q - Cycle through quick buffers.\n\n" ..
    "Other:\n" ..
    "  Escape - Send @abort command.\n" ..
    "  Shift+Escape - Reset sounds and triggers.",
    "Key Bindings Reference"
  )

  wizard.advance()
end

function wizard.step_updates()
  msgbox(
    "Miriani-Next includes a built-in updater to keep your scripts current.\n\n" ..
    "To check for updates, type 'update' or press Ctrl+U. " ..
    "If an update is available, you'll be walked through installing it.\n\n" ..
    "If you just want to see what's available without installing anything, " ..
    "you can type 'update check' instead.",
    "Updates"
  )

  msgbox(
    "There are two update channels available: stable and dev.\n\n" ..
    "Stable is the default and recommended for most users. " ..
    "Dev gets new features and fixes sooner, but may occasionally " ..
    "have rough edges.\n\n" ..
    "You can switch channels anytime by typing 'update switch'.",
    "Updates - Channels"
  )

  if yesno(
    "Would you like to enable automatic updates?\n\n" ..
    "When enabled, the scripts will quietly check for and apply " ..
    "updates when you log in, so you're always running the latest version.\n\n" ..
    "The changelog will also be shown automatically after each update " ..
    "so you can see what changed.",
    "Updates - Automatic Updates"
  ) then
    config:set_option("automatic_updates", "yes")
    config:set_option("automatic_changelog", "yes")
    config:save()
  end

  wizard.advance()
end

function wizard.step_finish()
  config:save()
  SetVariable("wizard_completed", "1")

  msgbox(
    "Setup complete! Your settings have been saved.\n\n" ..
    "If you ever need help, type 'next:help' for a full overview " ..
    "of the package's features, commands, and key bindings.\n\n" ..
    "Here are some other useful commands:\n\n" ..
    "  conf - Open the full configuration menu (also F1).\n" ..
    "  whatsnew - View the changelog (also F2).\n" ..
    "  update - Check for and install updates (also Ctrl+U).\n" ..
    "  setup - Run this wizard again.\n\n" ..
    "Enjoy Miriani-Next!",
    "Setup Complete"
  )
end

function start_wizard()
  wizard.run()
end

function start_wizard_if_first_run()
  if wizard.should_run() then
    wizard.run()
  end
end

return wizard
