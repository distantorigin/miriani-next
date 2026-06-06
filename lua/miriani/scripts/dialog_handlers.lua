-- @module dialog_handlers
-- Dialog system input handlers
-- Handles the global input interceptor for the dialog system

ImportXML([=[
<aliases>
  <!-- Dialog input interceptor - only enabled when dialog is active -->
  <!-- Negative lookahead excludes bypass commands (vol, history_, tts, etc.) so they flow to their own aliases -->
  <alias
   name="dialog_input_handler"
   enabled="n"
   match="^(?!vol|history_|tts|#\$#|Line_Get|clearoutput|prevline|toggleoutput|toggleinterrupt|curline|select|nextline|whichline|topline|snap_shot|endline)(.*)$"
   regexp="y"
   send_to="12"
   sequence="10"
  >
  <send>
if dialog and dialog.is_active() then
  dialog.handle_input("%1")
end
  </send>
  </alias>

</aliases>
]=])
