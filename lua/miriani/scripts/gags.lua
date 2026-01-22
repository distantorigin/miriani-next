
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="gags"
   match="^[-]{3,}$"
   regexp="y"
   omit_from_output="y"
   send_to="12"
   sequence="100"
  >
  <send>
   EnableTrigger("damage_reader", false)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^You make a selection on a .+? Lore computer\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^Salvage line energy emitters linked. Beginning salvage sweep[.]{3}$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^You watch as the salvage lines slowly wind their way to what might be several pieces of debris, projecting an energy net around them before carefully making their way back to the ship\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^You peer \w+ and see[.]{3}$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Set peering flag to prevent ambiance changes from peered room
   peering = true
  </send>
  </trigger>

  <trigger
enabled="y"
   group="gags"
   match="^The starship vibrates violently as it nears the wormhole's event horizon\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
enabled="y"
   group="gags"
   match="^LoreTech Personal Lore Computer - \[.+?\]$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^The windows automatically dim as gate after gate becomes visible, each causing a brilliant flash of light as it redirects the wormhole\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^You are suddenly jarred as the ship begins rapid deceleration\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^The mild vibration of acceleration eases off (?:and|as) (?:is|the) (?:replaced|ship) (?:by|sets) (?:the|down) (?:firm|on) (?:pull|the) .+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Clear destination infobar when ship lands
   infobar("dest", "")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^You hear the sounds of strained metal as the starship travels through the wormhole\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^The starship shakes violently as it continues through the wormhole\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^#\$#(?:keep_alive|hjelp)$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Optionally play beep sound on keep-alive
   if config:get_option("beep_on_keepalive").value == "yes" then
     mplay("misc/beep/beep", "notification")
   end
  </send>
  </trigger>


</triggers>
]=])