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
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ cries softly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysoftcry", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ starts crying loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babycry"..math.random(1,6), "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ coos\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babycoo", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ babbles\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babybabble"..math.random(1,2))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ bubbles\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babybubble"..math.random(1,6))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ begins? to feed [a-zA-Z][a-zA-Z0-9 '-]+, making a sucking sound as"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyeats", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^You pat [a-zA-Z][a-zA-Z0-9 '-]+ on the back and (he|she|they) lets out a small burp\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyburps", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^You offer [a-zA-Z][a-zA-Z0-9 '-]+ a [a-z]+ to (eat|drink)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyeats", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ starts fussing\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyfuss"..math.random(1,14))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ groans\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygroan"..math.random(1,3))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ giggles softly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygiggle"..math.random(1,9))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ giggles loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygiggle"..math.random(1,9))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ laughs loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babylaugh"..math.random(1,3))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ grunts loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygrunt"..math.random(1,2))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ flails (his|her|their) limbs\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>--mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ hiccups\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyhiccups", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ kicks (his|her|their) feet and waves (his|her|their) arms\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>--mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ kicks one foot\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>--mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ nibbles on (his|her|their) (finger|fingers|hand|hands)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysucking", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ rolls over\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyrolls", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ screams loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyscreams", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ shrieks loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyscreams", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ sneezes\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysneeze", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ sucks (his|her|their) thumb\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysucking", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ spits\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyspit", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ spits up\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babyspitup", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ sputters\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysputter", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ squeaks\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysqueak"..math.random(1,6))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ squeals\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysqueal"..math.random(1,7))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ starts sucking on (his|her|their) toes\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysucking", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ toddles (in|out|north|south|east|west|up|down|northeast|northwest|southeast|southwest)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babytoddles", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ wails loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywail"..math.random(1,3))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ waves (his|her|their) fist around\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>--mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ waves (his|her|their) hand through the air\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywave", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ whimpers\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywhimper"..math.random(1,2))</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ whines\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywhine"..math.random(1,5))</send>
  </trigger>

</triggers>
]=])
