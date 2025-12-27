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
  <send>mplay("misc/baby/babycry", "babies")</send>
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
  <send>mplay("misc/baby/babybabble", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ bubbles\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babybubble", "babies")</send>
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
  <send>mplay("misc/baby/babyfuss", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ groans\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygroan", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ giggles softly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygiggle", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ giggles loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygiggle", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ laughs loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babylaugh", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ grunts loudly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babygrunt", "babies")</send>
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
  <send>mplay("misc/baby/babysqueak", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ squeals\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babysqueal", "babies")</send>
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
  <send>mplay("misc/baby/babywail", "babies")</send>
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
  <send>mplay("misc/baby/babywhimper", "babies")</send>
  </trigger>

  <trigger
   enabled="y"
   group="babies"
   match="^[a-zA-Z][a-zA-Z0-9 '-]+ whines\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/baby/babywhine", "babies")</send>
  </trigger>

</triggers>
]=])
