-- @module artifact_hunting
-- Artifact hunting mode: gags engine sounds when not actively piloting or gunning
--
-- When enabled, acceleration/deceleration sounds are suppressed unless
-- the player has recently:
--   - Typed movement commands (m, mo, mov, move)
--   - Typed numeric commands (1-9, -, +, +1, -1, =, =1, etc.)
--   - Typed weapon commands (laser, cannon, aim, lock)
--   - Typed directional/cone commands (w, a, s, d, q, e, x, z, c, f, r, rw, fw, etc.)
--   - Typed travel commands (subwarp, slip, wavewarp)
--   - Moved rooms
--
-- "Quiet" engine sounds (pings) still play regardless.
--
-- Also suppresses repeated piloting action messages like:
--   "Person inputs a series of commands into a navigation console."
--   "Person flicks a switch."
-- with a 30-second cooldown (resets on each occurrence).

-- Track last activity timestamp (in seconds)
local last_activity_time = 0

-- Activity timeout in seconds
local ACTIVITY_TIMEOUT = 150

-- Update the last activity timestamp
function update_artifact_hunting_activity()
  last_activity_time = os.time()
end

-- Check if engine sounds should be gagged
-- Returns true if sounds should be gagged (artifact hunting mode active and no recent activity)
function should_gag_engine_sounds()
  -- Check if artifact hunting mode is enabled
  if not config or config:get_option("artifact_hunting_mode").value ~= "yes" then
    return false
  end

  -- Check if there was recent activity
  local current_time = os.time()
  local time_since_activity = current_time - last_activity_time

  -- If activity within timeout, don't gag
  if time_since_activity < ACTIVITY_TIMEOUT then
    return false
  end

  -- No recent activity, gag the sounds
  return true
end

-- Cooldown for repeated messages (in seconds)
local MESSAGE_COOLDOWN = 30

-- Track last time each message was seen
-- Format: { ["full message text"] = timestamp, ... }
local message_times = {}

-- Check if a message should be suppressed
-- Returns true if the message should be gagged (seen within cooldown)
function should_suppress_message(line)
  -- Check if artifact hunting mode is enabled
  if not config or config:get_option("artifact_hunting_mode").value ~= "yes" then
    return false
  end

  local current_time = os.time()
  local last_time = message_times[line] or 0
  local time_since_last = current_time - last_time

  -- Always update timestamp (resets cooldown on every occurrence)
  message_times[line] = current_time

  -- If within cooldown, suppress the message
  if time_since_last < MESSAGE_COOLDOWN then
    return true
  end

  return false
end

-- Aliases to track piloting/gunning commands
-- These use sequence="200" with keep_evaluating to update activity then forward the command
ImportXML([=[
<aliases>
  <!-- Movement commands: m, mo, mov, move (with optional destination) -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^m(?:o(?:v(?:e)?)?)?(?:\s+.*)?$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Numeric movement/targeting: 1-9 -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^[1-9]$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Plus/minus movement: -, +, -1, +1, -2, +2, etc. -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^[-+]\d*$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Equals movement: =, =1, =2, =3, etc. -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^=\d*$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Directional/cone commands: w,a,s,d,q,e,x,z,c,f,r and prefixed rw,ra,fw,fa,rc,fc,etc. -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^[wasdqexzcfr]$|^[rf][wasdqezxvc]$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Laser commands: la, las, lase, laser -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^la(?:s(?:e(?:r)?)?)?(?:\s+.*)?$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Cannon commands: can, cann, canno, cannon -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^can(?:n(?:o(?:n)?)?)?(?:\s+.*)?$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Aim command -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^aim(?:\s+.*)?$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- Lock command -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^lock(?:\s+.*)?$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>

  <!-- subwarp/slip/wavewarp commands -->
  <alias
   enabled="y"
   group="artifact_hunting"
   match="^(?:subwarp|slip|wavewarp)(?:\s+.*)?$"
   regexp="y"
   sequence="200"
   keep_evaluating="y"
   script="update_artifact_hunting_activity"
  >
  <send>%0</send>
  </alias>
</aliases>
]=])

-- Triggers to suppress repeated piloting action messages
ImportXML([=[
<triggers>
  <!-- Suppress repeated "inputs commands into navigation console" messages -->
  <trigger
   enabled="y"
   group="artifact_hunting"
   match="^[A-Z][A-Za-z]+(?:\s[A-Z][A-Za-z]+)* inputs a series of commands into a navigation console\.$"
   regexp="y"
   sequence="50"
   omit_from_output="y"
   send_to="14"
  >
  <send>
if not should_suppress_message("%0") then
  print("%0")
  mplay("device/keyboard")
end
  </send>
  </trigger>

  <!-- Suppress repeated "flicks a switch" messages -->
  <trigger
   enabled="y"
   group="artifact_hunting"
   match="^[A-Z][A-Za-z]+(?:\s[A-Z][A-Za-z]+)* flicks a switch\.$"
   regexp="y"
   sequence="50"
   omit_from_output="y"
   send_to="14"
  >
  <send>
if not should_suppress_message("%0") then
  print("%0")
end
  </send>
  </trigger>
</triggers>
]=])
