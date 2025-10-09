ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="asteroid"
   match="^The ground shudders underfoot as materials are moved by .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/drill", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^A cloud of particulate matter floats up from the drilling area of .+? as it extracts .+? from a nearby source\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/drill", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^A small light on .+? suddenly (.+?)\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   if string.find("%1", "begins to glow as power pours into the unit") then
     mplay("activity/asteroid/powerOn", "other")
   elseif string.find("%1", "fades as power to the unit is severed") then
   mplay("activity/asteroid/powerOff", "other")
   end -- if
   </send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^You orient the business end of .+? away from your face and activate it\. A brilliant blue energy beam, carefully controlled to lose energy after about an inch of exposure, begins to issue forth from the barrel\. You lean toward .+? and apply the beam to the nearest tear and begin sealing it\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/microSealerStart", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^You manage to seal the breach you were working on and deactivate .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/microSealerEnd", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^The drill bit of .+? suddenly catches, seizing up for a moment before drilling resumes\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/shakyDrill", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^The rover shudders violently as the arm .+? and begins rotating\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/rotating", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^You watch as a small ramp is extended from outside the hull to the asteroid surface\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/rampDown", "other", nil, nil, nil, nil, nil, nil, -25)</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^Several loud banging sounds emanate from the cargo area behind you\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/cargoBang", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^A large panel on the bottom of .+? slowly opens, causing a cascade of .+? to come tumbling out\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/dump", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^A small amount of .+? trickles out of a tear in .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/trickle", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^You input a command into a docking console and watch as a ramp begins to extend from .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/rampDown", "other", nil, nil, nil, nil, nil, nil, -25)</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^You instruct the rover to begin .+?\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/roverCommand", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^You begin accelerating the vehicle .+? the ramp\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/rampStart", "other", nil, nil, nil, nil, nil, nil, -25)</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   script="gagline"
   match="^You pull a cord out of a bulky diagnostic device and plug it into an available port on .+?\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
  >
  <send>mplay("activity/asteroid/diag", "other")</send>
  </trigger>


</triggers>
]=])