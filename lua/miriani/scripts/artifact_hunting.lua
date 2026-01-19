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

-- Track last activity timestamp (in seconds)
local last_activity_time = 0

-- Activity timeout in seconds
local ACTIVITY_TIMEOUT = 60

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
