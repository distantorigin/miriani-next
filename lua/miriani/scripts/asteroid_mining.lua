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
  <send>mplay("activity/asteroid/diag")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^(.+?) carefully (secure|secures|disconnect|disconnects) the end of.+(cable|tubing).+\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   local action = "%2"
   local item = "%3"

   if string.find(action, "secure") then
     if item == "cable" then
       mplay("activity/asteroid/cableAttach")
     else
       mplay("activity/asteroid/tubingAttach")
     end
   else
     mplay("activity/asteroid/cableDetach")
   end
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^[a-zA-Z].+ input.+ (an activation|a deactivation).+command into .+\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   local action = "%1"
   if string.find(action, "deactivation") then
     mplay("activity/asteroid/reactorDisable", "other")
   else
     mplay("activity/asteroid/reactorEnable", "other")
   end
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^WARNING: (Coolant leak detected\!|Drill bit is not properly secure in the unit\.|Contaminants have been detected in the storage unit\.|Drill bit has become dull\.)$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/dump")</send>
  </trigger>

  <trigger
   enabled="y"
   group="asteroid"
   match="^FAILURE: The motor powering this unit has been destroyed beyond repair\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/dump")</send>
  </trigger>
<trigger
   enabled="y"
   group="asteroid"
   match="^A computerized voice coming from (.+) reports, &quot;Completed construction of (.+)\.&quot;$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/asteroid/manufacturingComplete")</send>
  </trigger>


</triggers>
]=])