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

</triggers>
]=])