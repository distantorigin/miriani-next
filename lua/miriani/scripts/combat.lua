
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^You hear (?:a|the) gentle hum (?:begin to fade)?\s?as the weapons power (up|down)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("ship/combat/weaponPower%1", "ship")</send>
</trigger>
  <trigger
   enabled="y"
   group="combat"
   match="^This starship has been hit by (.+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("ship/combat/hit/youHit", "ship")
   print_color({"Hit by %1", "combat"})
   channel("combat", "Hit by %1", {"combat"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^The (?:star)?ship (?:rocks|shakes|shudders) (?:violently|slightly) as (?:it'?s?|a)?\s?(hit by an automated laser turret|comes into contact with a space mine|projectile strikes the hull|solar material impacts the hull)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/hit/youHit", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^([A-Za-z0-9\s-'&quot;]+?) has fired at (.+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   if  probeHistory then
    return
   end -- if
   channel("combat", "%0", {"combat"})
   if config:get_option("friendly_combat").value == "no" then
    print("%0")
    mplay ("ship/combat/hit/sectorHit", "ship")
   else -- display only if its Praelor on alliance.
    if string.find ("%1", "Praelor") or (not string.find ("%2", "Praelor")) then
     print("%0")
     mplay ("ship/combat/hit/sectorHit", "ship")
    end -- if praelor hits other
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^You hear a mechanical whine as the laser reflectors reorient themselves\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/combat/reflector", "ship")</send>
  </trigger>


  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^(?:The room is (?:filled with a .+? light as the laser turrets? (?:are|is) fired|bathed in brilliant .+? light as the ship's (?:laser turrets? )?fires? alternating patterns of festive color)|The ship jerks slightly as its turrets are fired)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/combat/laser", "sounds", nil, math.random(-100, 100))</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^The ship jerks slightly as its turrets are fired\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/combat/laser", "sounds", nil, math.random(-100, 100))</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^You hear a thunk as a chunk of charged weapons-grade bardenium is fired from the ship's cannons\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay ("ship/combat/cannon", "sounds", nil, math.random(-100, 100))</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^([A-Za-z0-9\s'-]+?) has a lock on this starship\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   if config:get_option("secondary_lock").value == "yes" and focusTarget and focusTarget ~= "%1" then
    return mplay("ship/combat/secondaryLock", "ship")
   else -- main or unset target.
    mplay ("ship/combat/enemyLock", "ship")
   print_color({"Locked by %1", "combat"})

   end -- if

   channel("combat", "Locked by %1", {"combat"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^[A-Z][a-z]+?[A-Za-z\s]*? deftly (draw|insert)s? an? .+? (?:from|into) a .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("combat/%1", "melee")</send>
  </trigger>
  <trigger
  enabled="y"
   group="combat"
   match="^[A-Z][a-z]+?\s?\w* slides? an oddly\-shaped EM pulse emitter (out|into) (?:of)?\s?a pulse emitter clip,?\s?(?:where it settles into place with a small click)?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if "%1" == "out" then
    return mplay("combat/pDraw", "melee")
   else
    return mplay("combat/pHolster", "melee")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^[A-Z][a-z]+?\s?\w* aims? an oddly\-shaped EM pulse emitter at .+? and activates? it\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
   <send>mplay("combat/pFire", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(?:You|[A-Z][a-z]+?\s?\w*) carefully discharges? a.+?energy pack into a.+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/LoadEMPulse", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^A.+?appears to have run out of energy\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/EmptyEmitter", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(?:You press and hold a small red button on .+? pulse emitter, discharging the remaining energy and rendering the device inert|[A-Z][a-z]+?\s?\w* presses and holds a small red button on .+? pulse emitter)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/EmptyEmitter", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^A distant whirring noise can be heard as the \w+'s laser aligns itself, followed by a faint pulse as it fires\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/combat/planetaryLaser", "sounds", nil, math.random(-100, 100))</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^([A-Z][a-z]+?[A-Za-z\s]*?) points? (.+?) at .+? and fires?!$|^[A-Z][\w\s]* carefully takes? aim .+?\.{3}$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>

  if string.match ("%0", "(carefully %w+ aim at)") then
     mplay("combat/aim", "melee")
   end -- if
  </send>
  </trigger>


  <trigger
   enabled="y"
   group="combat"
   match="^The shot blows a hole in an? .+? insectoid creature's exoskeleton, sending a spray of acid outward\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("combat/praelor/hit", "melee")
</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^The shot impacts the edge of the orifice, sending a thick stream of acid outward\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("combat/praelor/wallHit", "melee")
</send>
  </trigger>
  <trigger
   enabled="y"
   group="combat"
   match="^The shot grazes the wall, which begins to bleed a strange green fluid\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("combat/praelor/wallLeak", "melee")
</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^A piercing, sourceless cry echos throughout the room as the shot makes contact\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("combat/praelor/wallCry", "melee")
</send>
  </trigger>
  <trigger
   enabled="y"
   group="combat"
   match="^The orifice, unable to withstand further fire, begins expanding outward, creating an entry point large enough for a human to fit through\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("combat/praelor/wallOpen", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^The shot (?:seems to have little|impacts luminescent orifice with no noticeable|hits squarely in the center of the orifice with no noticeable) effect( on the outside)?\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("combat/absorb", "melee")
</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^Wait \d+ seconds?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/stunTime", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^A loud clicking is followed by the clatter of an empty cartridge to the floor\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("combat/eject", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^[A-Z][a-z]+?\s?[A-Za-z\s]*? hastily slams? .+? into the open ammo slot of .+?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("combat/loadGun", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(A high-pitched, wobbling alarm sounds as the hull begins breaking up around you|You hear several rumbling sounds as the starship explodes around you)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("ship/combat/destroy/youDestroy", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^You depress the cartridge release lever on .+?, causing the loaded cartridge to slide out of the weapon and into your hand\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("combat/unloadGun", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^[A-Z][a-z]+?\s?[A-Za-z\s]*? (load|unload)s? .+? (?:from|into) .+? ammunition container\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("combat/ammunition", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^You take a quick glance at .+?, noting that the effective stun power is (\d+)\.? (It appears to be unloaded|and that it is loaded with (.+?) and has (\d+) (\w+) left)\.$"
   omit_from_output="y"
   regexp="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("combat/checkGun", "melee")
   if "%2" == "It appears to be unloaded" then
    print("Unloaded")
   else
     print("Power %1%%: %3 %4 %5 left.")
   end -- check
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^(?:The room is (?:filled with a .+? light as the laser turrets? (?:are|is) fired|bathed in brilliant .+? light as the ship's (?:laser turrets? )?fires? alternating patterns of festive color)|The ship jerks slightly as its turrets are fired)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
      sequence="100"
  >
  <send>mplay ("ship/combat/laser", "sounds", nil, math.random(-100, 100))</send>
  </trigger>


  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^You hear several scraping sounds as bardenium is transferred from the ship's storage to the cannons\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("ship/combat/reload", "ship")
   if config:get_option("count_cannon").value == "yes" and numberOfCannons then
    lastKnownBardenium = 20  -- Track bardenium amount
    cannonShots = math.max(7, math.ceil(20 / numberOfCannons))
   end -- if cannonCount
</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(.+?): (\d{1,2}, \d{1,2}, \d{1,2})$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
   keep_evaluating="y"
  >
  <send>
   if "%1" == "Locked onto coordinates" then
    print("%0")
    mplay("ship/combat/aim", "ship")
   elseif "%1" == "Current coordinates" then
    return print("%2")
   elseif "%1" == "Coordinates" then
    return print("%0")
   else -- do if focus
 if focusCoordinates and focusCoordinates == "%2" then
      local unchanged = (config:get_option("unchange_coords").value == "yes") and "Unchanged: " or ""
      return print(unchanged.."%2 (%1)")
    end -- if
    focusCoordinates = "%2"
    focusTarget = "%1"
    local coords = string.gsub(focusCoordinates, "[()]", "")  -- Strip parentheses
    infobar("focus", "Focus: " .. coords .. " (" .. focusTarget .. ")")
    print("%2 (%1)")
    mplay("ship/combat/focus", "ship")
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^Target: (.+?)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/combat/targetLocked", "ship")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(Those coordinates are too far away to establish a lock|The locked coordinates are out of range of the available weapons)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/combat/notRanged", "ship")</send>
  </trigger>

  <trigger
   name="cannonCountSetup"
   enabled="y"
   group="combat"
   match="^Available Cannons: (\d+)\s?(\(Salvo of (\d+)\))?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   -- Get number of cannons
   local totalCannons = tonumber("%1") or 0

   -- Check if salvo mode (capture group %3 contains salvo size)
   if "%3" ~= "" and "%3" ~= nil then
    numberOfCannons = tonumber("%3") or totalCannons
   else
    numberOfCannons = totalCannons
   end
  </send>
  </trigger>

  <trigger
   name="cannonCountBardenium"
   enabled="y"
   group="combat"
   match="^\s*([A-Za-z\s-]+) Bardenium: (\d+)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   -- Only process if we have cannon count from previous trigger and counting is enabled
   if numberOfCannons and numberOfCannons > 0 and config:get_option("count_cannon").value == "yes" then
    local bardeniumAmount = tonumber("%2") or 0
    lastKnownBardenium = bardeniumAmount  -- Store for recalculation when cannon count changes
    if bardeniumAmount > 0 then
     cannonShots = math.ceil(bardeniumAmount / numberOfCannons)
    else
     cannonShots = 0
    end

    mplay("ship/combat/secondaryLock", "ship")
    print("Bardenium counter reset: " .. cannonShots .. " shots")
   end
  </send>
  </trigger>


  <trigger
   enabled="y"
   group="combat"
   match="^An? .+? insectoid creature suddenly explodes violently, showering the area with pieces of exoskeleton, guts and a strange bubbling substance\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/praelor/explodeHere", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(An? .+? insectoid creature) crouches low to the ground and hisses, expelling a large quantity of an acidic compound at (.+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
   >
  <send>
   if config:get_option("praelor_interrupt").value == "yes" then
    Execute("tts_stop")
   end -- if praelor interrupt
   mplay("combat/praelor/attack", "melee")
   if "%2" ~= "you" then
    channel(name, "%2 is attacked by %1", {"combat"})
    praelorVictim = "%2"
    if config:get_option("spam").value == "yes" then
     return print_color({"%2 is attacked by %1", "combat"})
    end -- if spam
   else -- if target is you.
    if config:get_option("spam").value == "yes" then
     return print_color({"You are attacked by %1", "combat"})
    end -- if spam
   end -- if
   print_color({"%0", "combat"})

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^The force of the attack sends \w+ sprawling to the ground!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   if praelorVictim then channel("thrown", praelorVictim.." is thrown to the ground.", {"combat"}) end
   mplay("combat/praelor/throw", "melee")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^You are suddenly struck by a .+?!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/praelor/limb", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^(An? .+? insectoid creature) starts shrieking loudly, the pitch ramping up as it succumbs to the effects of the alkalines\. Sections of its exoskeleton begin to swell, tiny bumps forming on the swelling sections\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   channel("combat", "%1 is dying.", {"combat"})
   mplay("combat/praelor/shriekHere", "melee")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^You hear a strange shrieking sound from the .+?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("combat/praelor/shriekNearby", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   script="gagline"
   match="^You hear a worryingly wet sounding explosion from (?:the \w+|somewhere nearby)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>mplay("combat/praelor/explodeNearby", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^An? .+? insectoid creature collapses on the ground, a bubbling substance leaking out from around its eyes and from its mandibles. It begins thrashing violently, its wings flapping uselessly\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/praelor/death", "melee")</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^An? .+? insectoid creature scurries in\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
  if config:get_option("praelor_interrupt").value == "yes" then
    Execute("tts_stop")
   end -- if

   channel("combat", "%0", {"combat"})
   mplay("combat/praelor/enter", "melee")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^You see (.+)$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local count, creature, output = 0, "", "%1"

   if string.find(output, "[A-Za-z] .+ insectoid creatures?") then
    mplay("combat/praelor/detected", "melee")

   if config:get_option("count_praelor").value == "yes" then

    -- Add all praelor.
     for words in string.gmatch(output, "insectoid creature") do
      count = count + 1
     end -- for loop

    -- Figure out if its plural
    if count &gt; 1 then
    creature = "creatures"
   else
    creature = "creature"
   end -- if plural

    -- Interrupt if true.
    if config:get_option("praelor_interrupt").value == "yes" then

     Execute("tts_stop")
    end -- if interrupt speech

     channel("combat", count.." insectoid "..creature, {"combat"})

    print_color({string.format("%d insectoid %s.", count, creature), "combat"})
    end -- if praelor count

   end -- if praelor detected
</send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^A number of biological pods slam into the hull\. You hear a loud grinding noise\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("combat/praelor/board", "melee")</send>
  </trigger>


  <trigger
   enabled="y"
   group="combat"
   match="^You hear an oscillating discordant sound of electrical energy reverberating off the bulkheads as an electromagnetically coupled energy packet is fired from the starship's CDP launcher\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("ship/combat/pulse/cdp", "ship")
   if gagline(nil, "%0") == 1 then
     print_color({"CDP pulse discharged.", "combat"})
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^You hear a crackling burst of sound as an immobilization pulse builds up, before it is ejected from its emitter with a loud whine\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("ship/combat/pulse/immobilize", "ship")
   if gagline(nil, "%0") == 1 then
     print_color({"Immobilization pulse discharged.", "combat"})
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="combat"
   match="^You hear a loud popping sound as a disarmament pulse is fired\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("ship/combat/pulse/disarm", "ship")
   if gagline(nil, "%0") == 1 then
     print_color({"Disarmament pulse discharged.", "combat"})
   end -- if
  </send>
  </trigger>

</triggers>
]=])
