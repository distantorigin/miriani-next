ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="vehicle"
   match="^You input a command into the navigational controls to return to the ship\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/acv/return", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^You orient the automatic weapons and begin firing\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/acv/aim", "combat")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The room shudders violently from the recoil as the automatic weapons (?:begin|continue) firing\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>mplay("activity/acv/ordinatesFire", "combat")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^You access the vehicle's targeting controls and instruct it to launch a bomb\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/acv/bombActivate", "combat")</send>
  </trigger>

</triggers>
]=])
