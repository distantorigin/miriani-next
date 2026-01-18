function check_alert_autowake(alert_color)
  if config and config:is_dnd() and config:get_option("dnd_wake_on_red").value == "yes" then
    config:set_dnd(false)
    Execute("tts_enable_silent")
    notify("important", "Do Not Disturb auto-disabled: " .. alert_color:gsub("^%l", string.upper) .. " alert!")
  end
end

ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="gags"
   match="^You feel the sudden pull of acceleration as the starship's relativity drive kicks in, hurling you through the gate's event horizon\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>
  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You notice a faint hum begin to emanate from nowhere in particular as the starship's systems begin to power up\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("ship/move/enablePower", "ship")
   if config:get_option("background_ambiance").value == "yes"
   and environment then
     replicate_line(string.gsub(environment.line, "unpowered", "powered"))
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You suddenly become aware of a decrease in noise as the ship's systems shut down, leaving you in complete silence\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("ship/move/disablePower", "ship")
   if config:get_option("background_ambiance").value == "yes"
   and environment then
     replicate_line(string.gsub(environment.line, "powered", "unpowered"))
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A chime (?:sounds|is piped through a nearby speaker), indicating that somebody has entered the airlock\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("ship/misc/chime", "ship")
   print("Airlock Chime")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The hatch acknowledges your key and unlocks, allowing you to .+? through\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/misc/enter", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^[A-Z][a-z]+?[A-Za-z\s]*? through the (broken|unlocked)?\s?hatch of.+?(?:&quot;.+?&quot;)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/enter", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
match="^(You|[A-Z][a-z]+(?: [A-Z][a-z]+)*) [a-z].{0,19}?(?: \w+ feet)? out of the (?:&quot;.+?&quot;|ship|hatch|airlock|docking bay|(?:\w+-person .+?)|Highguard)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/exit", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^[A-Z][a-z]+?[A-Za-z\s]*? begin[ing]{0,3} the \w+ sequence\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/move/sequence", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^[A-Z][a-z]+?[A-Za-z\s]*? input.+? (?:a |some )?\w+ (?:of commands )?into .+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/keyboard")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The sound of the relativity drive echoes through the room as it propels the ship towards space\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/move/launch", "ship")</send>
  </trigger>


  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You feel mild acceleration as the ship (?:descends|moves) toward .+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/move/land", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear a (?:gentle pulsing sound as the starship begins an|low rumbling sound as the wormhole drive opens a|deep hum as the starship begins an|sharp whine as the starship begins an)\s?(?:intrasector)? (wavewarp|wormhole|subwarp|slip)\.$"
  regexp="y"
  omit_from_output="y"
  send_to="14"
  sequence="100"
  >
  <send>if not originating_from_camera("%0") then
  mplay ("ship/move/%1", "ship")
  else
    print("%0")
  end</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear a high pitched whine as the starship's bias drive spools up\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
  mplay ("ship/move/BiasStart", "ship")
  else
    print("%0")
  end</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^A wave of nausea comes over you as gravity around the ship is twisted and bent\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/move/BiasContinues", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The feeling of nausea passes as the starship moves rapidly\. .+?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/move/BiasEnds", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The sounds of the relativity drive calm as the starship completes its final maneuver into space\.$"
   regexp="y"
      script="gagline"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
  mplay("misc/beep/beep", "ship")
  mplay ("ship/misc/background", "ship")
  if config:get_option("spam").value ~= "yes" then
    print ("%0")
  end -- if
else
  print("%0")
end -- camera</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The deck beneath you vibrates slightly as the relativity drive begins accelerating the starship through space\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
  local frequency = tonumber(config:get_option("relativity_drive_freq").value) or 44100
  mplay ("ship/move/accelerate", "ship", false, nil, false, false, nil, frequency)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The sounds of the relativity drive slowly cease as the starship comes to a halt\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
  local frequency = tonumber(config:get_option("relativity_drive_freq").value) or 44100
  mplay ("ship/move/decelerate", "ship", false, nil, false, false, nil, frequency)
  </send>
</trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The experience abruptly ends as the starship exits from the companion jumpgate and the relativity drive takes over to slow the ship to a stop\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("misc/beep/beep", "ship")
  mplay ("ship/misc/background", "ship")
  if not originating_from_camera("%0") then
   -- Clear destination and focus infobar when ship finishes jumping
   infobar("dest", "")
   infobar("focus", "")
   infobar("scan", "")
  end</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You feel a mild vibration as the ship nears the active jumpgate\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/move/jumpgate", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^[A-Z][A-Za-z\s]+? instructs? the computer to begin scanning for debris\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/keyPress", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear the sounds of the atmospheric scoop activating\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>mplay("activity/salvaging/scoop", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear a thunk as a salvaging line is deployed into space\. You watch as the line slowly winds its way to a piece of debris, projects an energy net around it and begins to slowly make its way back to the ship\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/misc/salvageLine", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^(A|An|The) .+ has (launched|landed|docked|undocked) (from|on|with) .+$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("comm/other", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^A mechanical groan permeates the room as a heavy blast door (?:suddenly |)begins to (slide|move) .+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
  if string.find ("%1", "slide") then
    mplay ("ship/misc/blastClosing", "ship")
    print("Door Closing")
  else
    mplay ("ship/misc/blastOpen", "ship")
    print("Door Opening")
  end
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^A mechanical groan gradually subsides as the blast door(?:'s)? (locking|disappears) (?:mechanisms|from) (?:click|view,) .+? exit (\w+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
     mplay ("ship/misc/blastSettle", "ship")
   if "%1" == "disappears" then
    print("%2 unlocked")
   else
    print("%2 locked")
   end -- if
  else
    DeleteVariable("last_camera_line")
    print("%0")
  end -- camera
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^Starship (?:Damage|Status|Security Status):$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/display")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You notify flight control of your desire to (undock|dock|launch|land)\.$"
   regexp="y"
   send_to="12"
   script="gagline"
   omit_from_output="y"
   sequence="100"
  >
  <send>mplay ("ship/misc/radio", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You notice a bright flash of light (?:above|in the distance); a starship must be coming in (?:for a landing|to dock)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/move/otherLanding", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The [a-z-\s]+person .+? (touches down smoothly on the|sets down on the) (?:ground|docking bay floor|hangar floor)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/move/otherTouchDown", "ship")</send>
  </trigger>

   <trigger
   enabled="y"
   group="ship"
   match="^[A-Za-z0-9\s-'&quot;]+? rises smoothly off the ground and hovers for a brief moment before rapidly accelerating towards space\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/move/otherLaunching", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The starship (?:begins)?\s?(?:vibrating|shudders) (?:violently|beneath) (?:as|your) (?:the|feet).? (?:hum|It|as) (?:picks|feels|it) (?:up|like|continues) (?:in|the|propelling) (?:intensity|hull is breaking apart around you|itself forward)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/misc/creak")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^With a sharp lurch, the starship completes its intrasector (?:slip|wavewarp)\.?\s?(?:The pulsing sound stops as the wavewarp drive powers down)?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/misc/creak")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The vibration diminishes as the starship completes its subwarp\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
      mplay ("ship/move/orbit", "ship")
  else
    print("%0")
  end</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear (?:several clinking|a deafening booming|a buzzing|a shrill screeching|an electrical zapping) sound.+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
  mplay ("ship/misc/repair", "ship")
  else
    print("%0")
  end</send>
  </trigger>
  <trigger
   enabled="y"
   group="ship"
   match="^HULL: ([0-9]{1,2})%$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if tonumber("%1") > 79 then
    mplay ("ship/alarm/criticalHull", "notification")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
match="^(?:The|A|An|Praelor) .+? has (left|entered|exited from|jumped into|jumped out of) (?:the|to)? sector\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if probeHistory then
    return 0
   end -- if video probe

   if "%1" == "left"
   or string.find  ("%0", "entered Jumpgate")
   or string.find ("%0", "Mission")
   or "%1" == "jumped out" then
     mplay ("ship/move/sectorExit", "ship")
   else
     mplay ("ship/move/sectorEnter", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You detect a faint rumbling as the starship begins to orient toward another ship\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/dockBegin", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^(The starship rocks gently as the docking ring comes into contact with another starship|You hear a soft clang as another ship's docking ring comes into contact with the hull)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/dockComplete", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^Video probe history:$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("ship/misc/probeHistory", "ship")
   probeHistory = true
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^End of history\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>probeHistory = false</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You hear a satisfying click as the (?:docked)?\s?ship's docking ring is (?:retracted|released)\s?(?:from the docked ship's hull)?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/undockBegin", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^(Scanning is made much more difficult by the lack of sensors|That object was not found|There is nothing here to scan|There are no ships here|Nothing was detected at those coordinates)\.$"
   script="endScan"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/computer/noScan", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^That space is occupied\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/move/sameSpace", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The .+ drive is still recharging\. Time remaining: .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/computer/driveCharging", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^[A-Za-z0-9\s-'&quot;]+? has initiated an intrasector (?:subwarp|slip|wavewarp)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if (not probeHistory) then
    mplay ("ship/move/drive", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You hear a deep rumbling as the docking bay door (open|close)s\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/dock%1", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You feel a mild vibration as the ship begins to enter another ship's docking bay\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/dockOpen", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The faint vibration eases off as the starship sets down inside the other ship's docking bay\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("ship/misc/dockClose", "ship")
   -- Clear infobar when ship lands in docking bay
   infobar("dest", "")
   infobar("focus", "")
   infobar("scan", "")
  </send>
  </trigger>


  <trigger
   enabled="y"
   group="ship"
   match="^You hear a?\s?(?:several)?\s?(?:thunk|thud)s? as a?n?\s?(blockade|blockades|interdictor|proximity weapon) (?:is|are) launched\s?(into space)?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == "blockade" then
    mplay ("ship/combat/prox/singleBlockade", "ship")
     elseif "%1" == "interdictor" then
    mplay ("ship/combat/prox/interdict", "ship")
  elseif "%1" == "blockades" then
    mplay ("ship/combat/prox/multiBlockade", "ship")
   else
    mplay ("ship/combat/prox/proxLaunch", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The [a-z-]+person .+? has launched a?n?\s?\w+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if (not probeHistory) then
    mplay ("ship/combat/prox/otherProx")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A security drone (?:suddenly)?\s?appears (?:and|to) (?:drags|escort) you off the ship\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/exit", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The \w+-person .+? &quot;.+?&quot; is hauled out of the \w+-person .+? &quot;.+?&quot; by a number of drones\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/expeled", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear several loud thuds as cargo is transferred from the ship\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  sequence="100"
  >
  <send>mplay("ship/misc/startTransfer", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^(The noises coming from the storage room gradually cease until they can be heard no more\.|The commotion from the storage bay stops as the cargo transfer is completed\.)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  sequence="100"
  >
  <send>mplay("ship/misc/endTransfer", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^(You hear the bustle of activity from the ship's cargo hold|A haunting screech drifts in from the storage room as something heavy is dragged across the floor|A loud whirring sound comes from the ship's storage room as motorized lifts haul cargo away|A loud bang emanates from the storage room as workers haul cargo out|A series of drones lift canisters of atmospheric debris and cart them off|You hear scrapes and scratching coming from the storage compartment as debris is transferred)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/transfer", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The ship cannot leave this sector\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/interdiction", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^An interdiction field prevents the ship from communicating with the navigational beacons\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/interdiction", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You (?:hear somebody)?\s?((?:impatiently)?\s?knock[ing]{0,3}|kick[ing]{0,3} furiously) on the .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == "knocking" or "%1" == "knock" then
    mplay ("ship/misc/knock", "ship")
   elseif "%1" == "impatiently knocking" or "%1" == "impatiently knock" then
    mplay ("ship/misc/impatientKnock", "ship")
   else
    mplay ("ship/misc/kickKnock", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear a loud clang as robotic arms seize the ship and transport it to the .+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/misc/clang", "ship")</send>
  </trigger>

 <trigger
   enabled="y"
   group="ship"
   match="^[A-Z][a-z]+? [A-Za-z]*?\s?(?:is|are) turned away by the locked hatch of .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/misc/lockedHatch", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A loud klaxon sounds as (red|blue|purple|orange) lights (continue to )?flash overhead\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>

   -- Wake on alert for all alert colors (red, blue, purple, orange)
   if "%2" == "" then
    check_alert_autowake("%1")
   end

   if "%1" == "red" and "%2" == "" then
    mplay ("ship/alarm/redStart", "notification", 1)
   elseif "%1" == "red" and "%2" == "continue to " then
    mplay ("ship/alarm/redContinue", "notification", 1)
   elseif "%1" == "blue" then
    mplay ("ship/alarm/blue", "notification", 1)
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The lights overhead suddenly flicker as they change from \w+ to (\w+)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("ship/alarm/%1", "notification", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A destination appears on the ship's navigation controls: (.+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay("ship/move/course", "ship")
   if config:get_option("spam").value == "yes" then
    print ("Destination: %1")
   else
    print("%0")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You instruct the computer to calculate the distance between your current galactic coordinates and the last known location of the standard navigational beacons\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/beacon", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You lift a small panel and crawl through\.?\s?(the resulting opening, emerging in the starship's network of ducts. Being the \w+ that you are, you replace the panel behind you\.)?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   if "%1" ~= "" then
    return mplay("ship/misc/ductEnter", "ship")
   else
    return mplay("ship/misc/ductExit", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^[A-Z][a-z]+?\s?\w* (lifts a small panel and)?\s?crawls \w*\s?through (?:it|a small panel)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
  if "%1" ~= "" then
    return mplay("ship/misc/ductEnter", "ship")
   else
    return mplay("ship/misc/ductExit", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^A small light on the airlock control panel turns from red to yellow\. The faint hiss of air can be heard (exiting|entering) the airlock\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/airlock/airStart", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A small light on the airlock control panel turns from red to yellow\. Water begins rushing in, swirling chaotically and forming frothy waves\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("ship/misc/airlock/waterStart")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A small light on the airlock control panel turns from red to yellow\. The water filling the airlock begins to rapidly drain through open vents in the floor, where it is carried away by the ship's network of pipes\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("ship/misc/airlock/waterEnd")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The hiss of air slowly fades away into nothingness, and the yellow light becomes green\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/airlock/airStop", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The computer flashes a message next to the airlock cycle button saying, &quot;(Beginning cycling|Cycling complete)\.&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == "Beginning cycling" then
    return mplay("ship/misc/airlock/close", "ship")
   else
    return mplay("ship/misc/airlock/open", "ship")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You hear the airlock (begin|finish) cycling\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/airlock/hear%1", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^Some lovely elevator music begins playing as the airlock cycles\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("music/theme", "elevator_music", true, nil, true)</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^Some lovely elevator music abruptly stops playing as the airlock ceases cycling\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>stop("elevator_music")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^(Name\s+#\s+Units|Weapon Status:|Charge Readout:|Starship Weapon Information)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/display", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You input some commands into a console and access the starship's service record\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/display", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^Laser Turrets\s+\d+/\d+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/display", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^Starship\s+Mass\s+Docking Bay\s+Status$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/display", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear \w+ thunks? as salvage lines? are simultaneously deployed into space\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/bulkSalvage", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The overhead lights dim for a moment before returning to normal\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/fuzzyDamage", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You hear the sounds of somebody attempting to enter the airlock, but they're turned away by the locked hatch\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/lockedHatch", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^You feel a mighty shaking as something seemingly large impacts the hull\.$"
   regexp="y"
   send_to="14"
   
   sequence="100"
  >
  <send>
   mplay("ship/COMBAT/hit/youHit6")
     </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^.+ (?:press(?:es)?|slides) (?:a button|out of) (?:and quickly retrieves?|a nearby printer) .+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/print", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear a mechanical whine as (the ship's solar panels orient themselves toward a star|the ship's solar panels return to their previous positions along the hull)\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>mplay("ship/misc/solarPanels"..("%1" == "the ship's solar panels return to their previous positions along the hull" and "Off" or "On"), "other")</send>
  </trigger>
  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^A bright flash of blue light floods the room as the starship travels through the wormhole\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>--mplay("ship/move/flash")</send>
  </trigger>
  
<trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^There is a brilliant flash of blue light as the ship emerges on the other side of the wormhole\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
   mplay("ship/misc/background")
   -- Clear infobar when ship emerges from the natural wormhole
   infobar("focus", "")
   infobar("scan", "")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The starship vibrates violently as it nears the natural wormhole's event horizon\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>mplay("ship/move/natural")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^.+? flips? a switch on a control board and (?:de)?activates? the alien signal broadcaster\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("ship/misc/summon")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The bright light vanishes as the starship emerges at the other side of the wormhole\.$"
      regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>mplay("ship/misc/background")
   -- Clear destination infobar when ship finishes jumping
   infobar("dest", "")
   infobar("focus", "")
   infobar("scan", "")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^A blinding flash of light suddenly permeates the entire area\. You hear a pounding sound on the hull, as if the starship were a drum being relentlessly pounded on\. The next thing you know the room begins shaking violently(, sending you flying .+?)?\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("ship/misc/anomalyHit")
   if "%1" ~= nil then mplay("misc/bodyImpact") end
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The ship rocks and shakes intensely as it is thrown violently by an unknown force\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("ship/misc/anomalyMove")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^An? .+? scan suddenly emerges from a console\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("ship/misc/print")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The ship wrenches violently as the wavewarp drive interacts with stellar material\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("ship/misc/starWavewarp")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   match="^The focused ship is no longer in the sector\.$"
   regexp="y"
   send_to="14"
   sequence="1"
   keep_evaluating="y"
  >
  <send>
   -- Clear focus and scan infobar when ship leaves sector
   focusTarget = nil
   focusCoordinates = nil
   infobar("focus", "")
   infobar("scan", "")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
      match="^You hear the distinct hiss of water being pumped through the ship's piping\. Moments later, a flurry of frozen water crystals begins to drift down from vents in the ceiling, lazily swirling through currents of air being pumped out until it settles on the deck plating, where it immediately melts into a hazardous water puddle\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/waterCrystals", "ship")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^You hear the occasional ping of objects impacting the hull as the starship moves through space\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/backgroundHigh", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="ship"
   script="gagline"
   match="^The gentle hum of the ship's engines momentarily amplifies as the starship moves through space\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/misc/backgroundHigh", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="gags"
   match="^You detect a faint thrumming as the ship reorients itself\.$"
   regexp="y"
   omit_from_output="y"
   sequence="100"
  >
  </trigger>

</triggers>
]=])
