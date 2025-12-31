ImportXML([=[
<triggers>
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
  <send>mplay("vehicle/decelerate", "vehicle")</send>
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
  <send>mplay("vehicle/decelerate", "vehicle")</send>
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
   match="^You hear a sharp whine as the vehicle accelerates through the.+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("activity/atmo/salvagerDescend", "vehicle")</send>
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
  <send>mplay("activity/atmo/stop", "vehicle")</send>
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
   match="^The craft makes a tremendous splash as it lands in the planet's watery atmosphere\. It turns a few times and then the stabilizers kick in, righting the craft.+$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("vehicle/landingSplash", "vehicle")
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
  <send>mplay("activity/atmo/salvageLands", "vehicle")</send>
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

<trigger
   enabled="y"
   group="vehicle"
   match="^You hear scrapes and scratching coming from the storage compartment as debris is transferred\.|A slight breeze enters the cockpit as the storage compartment is opened and closed\.|A series of drones lift canisters of atmospheric debris and cart them off\.$"
   regexp="y"
script = "gagline"
   send_to="12"
   omit_from_output="y"
   sequence="100"
   >
  </trigger>
</triggers>
]=])
