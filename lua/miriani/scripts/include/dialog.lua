-- @module dialog
-- Terminal-based menu and prompt system for Toastush
-- Inspired by mudmixer, proxiani, and VIP MUD implementations

local class = require("pl.class")

-- Dialog state management
local dialog_state = {
  active = false,
  type = nil, -- 'menu', 'prompt', 'confirm'
  callback = nil,
  data = {}
}

class.Menu()

function Menu:_init(options)
  self.title = options.title
  self.choices = options.choices or {}
  self.callback = options.callback
  self.allow_blank = options.allow_blank or false
  self.prompt_text = options.prompt or "Enter your selection.\n\n[Type a line of input or '@abort' to abort the command.]"
  self.matches = nil -- For progressive narrowing

  -- Convert array to map if needed
  if #self.choices > 0 and not self.choices[1].key then
    local numbered = {}
    for i, choice in ipairs(self.choices) do
      numbered[tostring(i)] = choice
    end
    self.choices = numbered
  end
end

function Menu:display()
  if self.title then
    Note(self.title)
  end

  -- Display matched choices or all choices
  local items = self.matches or self.choices
  local keys = {}
  for k in pairs(items) do
    table.insert(keys, k)
  end

  -- Sort numerically if all keys are numbers, otherwise alphabetically
  -- Special case: "0" always goes to the end
  table.sort(keys, function(a, b)
    if a == "0" then return false end
    if b == "0" then return true end

    local a_num = tonumber(a)
    local b_num = tonumber(b)
    if a_num and b_num then
      return a_num < b_num
    else
      return tostring(a) < tostring(b)
    end
  end)

  for _, key in ipairs(keys) do
    local choice = items[key]
    if type(choice) == "table" then
      Note(string.format("[%s] %s", key, choice.label or choice[1] or ""))
    else
      Note(string.format("[%s] %s", key, choice))
    end
  end

  Note(self.prompt_text)
end

function Menu:handle_input(input)
  local trimmed = input:match("^%s*(.-)%s*$"):lower()

  -- Handle abort
  if trimmed == "@abort" then
    mplay("misc/cancel")
    Note(">> Command Aborted <<")
    -- Store callback and result, don't call yet
    self.result = {callback = self.callback, data = nil, reason = "aborted"}
    return true -- done
  end

  -- Handle blank input
  if trimmed == "" then
    if self.matches then
      -- Reset to show all options
      self.matches = nil
      self:display()
      return false
    elseif self.allow_blank then
      self.result = {callback = self.callback, data = nil, reason = "blank"}
      return true
    else
      mplay("misc/cancel")
      Note("Invalid selection.")
      return true
    end
  end

  -- Check for exact match (by key)
  local items = self.matches or self.choices
  if items[trimmed] then
    self.result = {callback = self.callback, data = {key = trimmed, value = items[trimmed], input = input}, reason = nil}
    return true
  end

  -- Progressive matching
  local matches = {}
  local match_count = 0
  for key, choice in pairs(items) do
    local text = type(choice) == "table" and (choice.label or choice[1] or "") or tostring(choice)
    local lower_text = text:lower()
    local lower_key = key:lower()

    -- Match at start or after space
    if lower_text:match("^" .. trimmed) or
       lower_text:match("%s" .. trimmed) or
       lower_key == trimmed then
      matches[key] = choice
      match_count = match_count + 1
    end
  end

  if match_count == 0 then
    mplay("misc/cancel")
    Note("Invalid selection.")
    self.result = {callback = self.callback, data = nil, reason = "invalid"}
    return true
  elseif match_count == 1 then
    local key = next(matches)
    self.result = {callback = self.callback, data = {key = key, value = matches[key], input = input}, reason = nil}
    return true
  else
    -- Multiple matches - narrow down
    if self.matches and match_count == #self.matches then
      Note("All options still match. Please be more specific.")
    else
      Note(string.format("%d options match:", match_count))
    end
    self.matches = matches
    self:display()
    return false
  end
end

class.Prompt()

function Prompt:_init(options)
  self.title = options.title
  self.message = options.message
  self.callback = options.callback
  self.multiline = options.multiline or false
  self.allow_blank = options.allow_blank or false
  self.validation = options.validation -- regex or function
  self.hint = options.hint
  self.lines = {}
end

function Prompt:display()
  if self.title then
    Note(self.title)
  end
  if self.message then
    Note(self.message)
  end
  if self.hint then
    Note(self.hint)
  end

  if self.multiline then
    Note("Enter text (type '.' on a line by itself to finish, or @abort to cancel):")
  else
    Note("Enter text (or @abort to cancel):")
  end
end

function Prompt:handle_input(input)
  local trimmed = input:match("^%s*(.-)%s*$")

  -- Handle abort
  if trimmed:lower() == "@abort" then
    mplay("misc/cancel")
    Note(">> Command Aborted <<")
    self.result = {callback = self.callback, data = nil, reason = "aborted"}
    return true
  end

  -- Handle multiline
  if self.multiline then
    if input == "." then
      if #self.lines > 0 or self.allow_blank then
        self.result = {callback = self.callback, data = {lines = self.lines, value = table.concat(self.lines, "\n")}, reason = nil}
        return true
      else
        self.result = {callback = self.callback, data = nil, reason = "blank"}
        return true
      end
    else
      table.insert(self.lines, input)
      return false
    end
  else
    -- Single line
    if trimmed == "" and not self.allow_blank then
      self.result = {callback = self.callback, data = nil, reason = "blank"}
      return true
    end

    -- Validate if needed
    if self.validation then
      local valid = false
      if type(self.validation) == "function" then
        valid = self.validation(trimmed)
      elseif type(self.validation) == "string" then
        valid = trimmed:match(self.validation) ~= nil
      end

      if not valid then
        Note(self.hint or "Invalid input. Please try again.")
        self:display()
        return false
      end
    end

    self.result = {callback = self.callback, data = {value = trimmed, input = input}, reason = nil}
    return true
  end
end

class.Confirm()

function Confirm:_init(options)
  self.title = options.title
  self.message = options.message
  self.callback = options.callback
end

function Confirm:display()
  if self.title then
    Note(self.title)
  end
  if self.message then
    Note(self.message)
  end
  Note("[Enter 'yes' or 'no', or @abort to cancel]")
end

function Confirm:handle_input(input)
  local trimmed = input:match("^%s*(.-)%s*$"):lower()

  if trimmed == "@abort" then
    mplay("misc/cancel")
    Note(">> Command Aborted <<")
    self.result = {callback = self.callback, data = nil, reason = "aborted"}
    return true
  end

  if trimmed:match("^y") or trimmed == "yes" then
    self.result = {callback = self.callback, data = {confirmed = true, value = true}, reason = nil}
    return true
  elseif trimmed:match("^n") or trimmed == "no" then
    self.result = {callback = self.callback, data = {confirmed = false, value = false}, reason = nil}
    return true
  else
    Note("Please enter 'yes' or 'no'.")
    self:display()
    return false
  end
end

-- Public API
local dialog = {}

function dialog.menu(options)
  if dialog_state.active then
    Note("A dialog is already active. Please complete it first.")
    return false
  end

  local menu = Menu(options)
  dialog_state.active = true
  dialog_state.type = "menu"
  dialog_state.handler = menu
  dialog_state.callback = options.callback

  -- Enable the dialog input interceptor alias
  EnableAlias("dialog_input_handler", true)

  mplay("misc/prompt")
  menu:display()
  return true
end

function dialog.prompt(options)
  if dialog_state.active then
    Note("A dialog is already active. Please complete it first.")
    return false
  end

  local prompt = Prompt(options)
  dialog_state.active = true
  dialog_state.type = "prompt"
  dialog_state.handler = prompt
  dialog_state.callback = options.callback

  -- Enable the dialog input interceptor alias
  EnableAlias("dialog_input_handler", true)

  mplay("misc/prompt")
  prompt:display()
  return true
end

function dialog.confirm(options)
  if dialog_state.active then
    Note("A dialog is already active. Please complete it first.")
    return false
  end

  local confirm = Confirm(options)
  dialog_state.active = true
  dialog_state.type = "confirm"
  dialog_state.handler = confirm
  dialog_state.callback = options.callback

  -- Enable the dialog input interceptor alias
  EnableAlias("dialog_input_handler", true)

  confirm:display()
  return true
end

function dialog.handle_input(input)
  if not dialog_state.active then
    return false
  end

  local done = dialog_state.handler:handle_input(input)

  if done then
    -- Get the callback result from handler
    local result = dialog_state.handler.result

    -- Clean up state BEFORE calling callback
    -- This allows callbacks to open new dialogs
    dialog_state.active = false
    dialog_state.type = nil
    dialog_state.handler = nil
    dialog_state.callback = nil

    -- Disable the dialog input interceptor alias
    EnableAlias("dialog_input_handler", false)

    -- Now safe to invoke callback which might create new dialog
    -- (which will re-enable the alias if needed)
    if result and result.callback then
      result.callback(result.data, result.reason)
    end
  end

  return true
end

function dialog.is_active()
  return dialog_state.active
end

function dialog.cancel(silent)
  if dialog_state.active then
    if dialog_state.callback then
      dialog_state.callback(nil, "cancelled")
    end
    dialog_state.active = false
    dialog_state.type = nil
    dialog_state.handler = nil
    dialog_state.callback = nil

    -- Disable the dialog input interceptor alias
    EnableAlias("dialog_input_handler", false)

    if not silent then
      Note("Dialog cancelled.")
    end
  end
end

return dialog
