-- @module babies
-- Baby sound triggers migrated from VIP Mud soundpack
-- These triggers provide audio feedback for baby actions and emotes
-- Credit to David Kieran for original VIP Mud implementation

-- Author: Toastush Migration (Claude Code)
-- Last updated: 2025-10-09

---------------------------------------------

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? cries softly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysoftcry", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? starts crying loudly"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babycry"..math.random(1,6), "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? coos"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babycoo", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? babbles"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babybabble"..math.random(1,2))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? bubbles\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babybubble"..math.random(1,6))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? begin.* to feed .* a sucking sound as"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyeats", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^You pat .* on the back and .* lets out a small burp\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyburps", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^You offer .* a .* to .*$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyeats", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? starts fussing\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyfuss"..math.random(1,14))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^(.+?) groans"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local name = "%1"
   -- Only play if it's not a channel message (contains [) or number (#)
   if not name:find("[%[#]") then
     mplay("misc/baby/babygroan"..math.random(1,3))
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? giggles softly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygiggle"..math.random(1,9))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? giggles loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygiggle"..math.random(1,9))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? laughs loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babylaugh"..math.random(1,3))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? grunts loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygrunt"..math.random(1,2))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? flails.+?limbs\.\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? hiccups\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyhiccups", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? kicks.+?feet and waves.+?arms\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? kicks one foot\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? nibbles on"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysucking", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? rolls over\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyrolls", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? screams loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyscreams", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? shrieks loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyscreams", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? sneezes\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysneeze", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? sucks.+?thumb\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysucking", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? spits\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyspit", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? spits up\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyspitup", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? sputters\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysputter", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? squeaks\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysqueak"..math.random(1,6))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? squeals\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysqueal"..math.random(1,7))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? starts sucking on.+?toes\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysucking", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^(.+?) toddles"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local name = "%1"
   -- Only play if it's not a channel message (contains [) or number (#)
   if not name:find("[%[#]") then
     mplay("misc/baby/babytoddles", "babies")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? wails loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywail"..math.random(1,3))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? waves.+?fist around\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? waves.+?hand through the air\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? whimpers\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywhimper"..math.random(1,2))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^.+? whines\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywhine"..math.random(1,5))</send>
  </trigger>

</triggers>
]=])
