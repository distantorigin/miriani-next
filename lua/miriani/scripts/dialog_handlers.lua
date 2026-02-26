-- @module dialog_handlers
-- Dialog system input handlers
-- Handles the global input interceptor for the dialog system

ImportXML([=[
<aliases>
  <!-- Dialog input interceptor - only enabled when dialog is active -->
  <!-- keep_evaluating="y" lets bypass commands (vol, history_, tts, etc.) flow naturally to their aliases -->
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
    -- Enable the consumer alias to stop this input from reaching the MUD
    EnableAlias("dialog_input_consumer", true)
    dialog.handle_input(input)
  end
  -- Bypass commands: do nothing here; keep_evaluating passes them to their actual aliases.
end
  </send>
  </alias>

  <!-- Consumes dialog input so it doesn't leak to the MUD via keep_evaluating -->
  <!-- Enabled on-demand by dialog_input_handler for non-bypass commands only -->
  <alias
   name="dialog_input_consumer"
   enabled="n"
   match="^(.*)$"
   regexp="y"
   send_to="12"
   sequence="11"
  >
  <send>
EnableAlias("dialog_input_consumer", false)
  </send>
  </alias>

</aliases>
]=])
