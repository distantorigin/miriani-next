ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="vehicle"
   match="^You open the hatch of an? .+? (?:called &quot;.+?&quot;)?\s?and climb inside\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("vehicle/enter", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^([A-Z][a-z\s]+)+ climbs? out of .+?(?:vehicle|asteroid rover).*\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("vehicle/exit", "vehicle")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^You carefully pilot the vehicle into a small chamber above the docking bay\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("vehicle/drive", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^You are suddenly pressed against your seat as the vehicle is catapulted out of the docking bay( and into space. With a rapid jerk, the vehicle begins accelerating into the planet's atmosphere)?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("vehicle/launch", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^The ship comes to a halt in the planet's atmosphere\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("vehicle/halt", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^You feel a floating sensation as the craft moves through the water\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/move", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The craft comes to a halt, a plume of bubbles surrounding it before dissipating\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/decelerate", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^The craft spins around and around as it's sucked downward\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/atmo/whirlpool", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The pull of acceleration eases off as the ship ceases its .+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/salvagestop", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The vehicle shudders violently as it makes contact with the topmost gas clouds\. .+$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/contact", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^A whirlpool forms nearby, sucking the craft downward into its swirling vortex.+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/atmo/whirlpool", "vehicle")
mplay("activity/atmo/wave", "vehicle")
gagline()</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The craft manages to stabilize itself and break free from the whirlpool\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/decelerate", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^A bubble in the vicinity bursts and you hear the engines strain to keep the craft on course.+?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/bubble", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^.+?A disruption in the water near the craft has caused a massive wave which has resulted in the current trajectory being rerouted\. Please stand by.+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/atmo/wave", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The craft makes a tremendous splash as it lands in the planet's watery atmosphere\. It turns a few times and then the stabilizers kick in, righting the craft.+$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/landingsplash", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^.+?The craft has slammed into a massive life form\. A breach in the outer hull has been detected.+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/atmo/fishcrash", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^You feel the pull of acceleration as the (?:craft|ship|vehicle) (?:navigates|begins) ((?:[dea]{1,2}scending)? ?through the (?:planet's)? ?atmosphere|moving)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("vehicle/accelerate", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The (?:pull|tug) of acceleration [c]{0,1}eases (?:off)? ?as the (?:craft|ship|vehicle) (?:completes|ceases) its (?:maneuvering|[dea]{1,2}scent|thrust and resumes stationary mode)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("vehicle/decelerate", "vehicle")</send>
  </trigger>

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

  <trigger
   enabled="y"
   group="vehicle"
   match="^A gust of atmospheric wind suddenly buffets the ship.+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/wind", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^The vehicle suddenly hits a pocket of fierce wind.+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/wind", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^A sudden instability in the layer of gasses around the ship causes it to rapidly sink deeper into the atmosphere\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/wind", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The vehicle shudders violently as it makes contact with the topmost gas clouds\. .+?\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
  >
  <send>mplay("vehicle/contact", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   script="gagline"
   match="^The heavy vibration of the running engine ceases as the vehicle glides out of the top levels of the atmosphere and into space\. The sound of the thrusters can be heard as the craft orients itself toward the .+?\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
  >
  <send>mplay("vehicle/decelerate", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^Without any warning sign, the ship tilts over and the engine section is quickly detached through a short series of explosions just behind the cockpit, giving what remains a great upwards speed\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/explode", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^The clouds of gas get thinner and the haze of violent purple and yellow is replaced by the view of space\. Having drained the last of their emergency power, the thrusters burn out and are released through two more short explosions, sending your capsule forward and leaving it in a sickening spin while slowly falling back towards the planet\. Moments later the entire cockpit shakes violently as it is caught by a set of salvage lines that abruptly stop the tumbling and rapidly hauled back to .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/salvageExplode", "vehicle")</send>
  </trigger>


  <trigger
   enabled="y"
   group="vehicle"
   match="^A bubble in the vicinity bursts and you hear the engines strain to keep the craft on course.+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/bubble", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^The craft makes a tremendous splash as it lands in the planet's watery atmosphere\. It turns a few times and then the stabilizers kick in, righting the craft.+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("vehicle/landingSplash", "vehicle")
   -- Clear destination infobar when vehicle lands
   infobar("dest", "")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^The vehicle manages to break free from the pocket of wind and stabilize its course\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/decelerate", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You flip a conveniently placed switch, powering (down|up) the vehicle's (?:active|dormant) systems\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("vehicle/togglePower", "vehicle")
   if config:get_option("background_ambiance").value == "yes"
   and environment then
     replicate_line(
     "%1" == "up" and string.gsub(environment.line, "unpowered", "powered") or string.gsub(environment.line, "powered", "unpowered"))
   end -- if
  </send>
  </trigger>
<trigger
   enabled="y"
   group="vehicle"
   match="^The computer announces, &quot;Warning, avian lifeform in processing chamber. Expelling\.\.\.&quot;"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/atmo/salvageLifeform", "vehicle")
   mplay("activity/atmo/avianExpulsion", "vehicle")</send>
  </trigger>

  <trigger
   enabled="y"
   group="vehicle"
   match="^You hear a gentle thud as the salvager sets down in the docking bay\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("vehicle/salvageLands", "vehicle")</send>
  </trigger>
  
  <trigger
   enabled="y"
   group="vehicle"
   match="^The vehicle carefully maneuvers into the docking bay\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/atmo/salvageReturn", "vehicle")</send>
</trigger>
</triggers>
]=])