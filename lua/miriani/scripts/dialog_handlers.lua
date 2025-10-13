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
   keep_evaluating="y"
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

  if not should_bypass then
    -- Handle as dialog input
    dialog.handle_input(input)
  end
  -- With keep_evaluating=y, bypassed commands will be processed by their actual aliases, so reading history doesn't cancel out a menu.
end
  </send>
  </alias>

</aliases>
]=])
