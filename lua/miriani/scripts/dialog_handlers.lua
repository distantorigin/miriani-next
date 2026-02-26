-- @module dialog_handlers
-- Dialog system input handlers
-- Handles the global input interceptor for the dialog system

ImportXML([=[
<aliases>
  <!-- Dialog input interceptor - only enabled when dialog is active -->
  <alias
   name="dialog_input_handler"
   enabled="n"
   match="^(.*)$"
   regexp="y"
   send_to="12"
   sequence="10"
  >
  <send>
-- Check if dialog is active
if dialog and dialog.is_active() then
  local input = "%1"

  -- Allow volume, history, use, clear, and output function commands through
  local bypass_patterns = {
    "^vol",           -- Volume commands
    "^history_",      -- Channel history commands
"^tts",
"^\#\$\#",
    "^Line_Get",      -- Output functions
    "^clearoutput",   -- Output functions
    "^prevline",      -- Output functions
    "^toggleoutput",  -- Output functions
    "^toggleinterrupt", -- Output functions
    "^curline",       -- Output functions
    "^select",        -- Output functions
    "^nextline",      -- Output functions
    "^whichline",     -- Output functions
    "^topline",       -- Output functions
    "^snap_shot",     -- Output functions
    "^endline",       -- Output functions
  }

  local should_bypass = false
  for _, pattern in ipairs(bypass_patterns) do
    if input:match(pattern) then
      should_bypass = true
      break
    end
  end

  if should_bypass then
    -- Temporarily disable this alias to avoid recursion, then re-inject the command
    EnableAlias("dialog_input_handler", false)
    Execute(input)
    EnableAlias("dialog_input_handler", true)
  else
    -- Handle as dialog input (alias consumes the command, nothing sent to MUD)
    dialog.handle_input(input)
  end
end
  </send>
  </alias>

</aliases>
]=])
