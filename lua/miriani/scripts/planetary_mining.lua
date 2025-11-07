ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^A recorded voice on a large planetary mining drone whispers, &quot;A pocket of (.+) has been detected\.&quot; You set it on the ground and watch as it begins carefully digging\.$"
   regexp="y"
   sequence="100"
   send_to="12"
  >
  <send>stop("loop")
   mplay("activity/PlanetaryMining/MineralsDetected")</send>
  </trigger>

  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^(A|An) (.+) tunnel rat slinks in\.$"
   regexp="y"
   sequence="60"
   send_to="12"
  >
  <send>mplay("activity/PlanetaryMining/TunnelRat", "other")</send>
  </trigger>
  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^A large planetary mining drone beeps quietly, indicating that it has stored one unit of material\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/PlanetaryMining/MineralStored", "other")</send>
  </trigger>

  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^You press a button on a large planetary mining drone\. A recorded voice lightly whispers, &quot;Scanning for minerals of value\. Please wait\.&quot;$"
   regexp="y"
   sequence="60"
   send_to="12"
  >
  <send>
   mplay("activity/PlanetaryMining/ScanningMinerals")
   mplay("activity/PlanetaryMining/ScanLoop", "loop", false, nil, true)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^A recorded voice on a large planetary mining drone whispers, &quot;No minerals of value could be found\. Please scan another area\.&quot;$"
   regexp="y"
   sequence="60"
   send_to="12"
  >
  <send>stop("loop")
   mplay("activity/PlanetaryMining/NoMinerals")</send>
  </trigger>

  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^A recorded voice on a large planetary mining drone says, &quot;The area has been exhausted of minerals\. Please scan for another suitable location\.&quot;$"
   regexp="y"
   sequence="60"
   send_to="12"
  >
  <send>stop("loop")
   mplay("activity/PlanetaryMining/Exhausted", "other")</send>
  </trigger>
  <trigger
   enabled="y"
   group="planetary mining"
   ignore_case="y"
   match="^.+hovering platform.+follows you into the area\.$"
   regexp="y"
   sequence="60"
   send_to="12"
  >
  <send>mplay("activity/PlanetaryMining/PlatformHover", "other")</send>
  </trigger>
<trigger
   enabled="y"
   group="planetary mining"
   
   match="^You receive ([0-9,.]+) credits for the minerals you mined\.$"
   regexp="y"
   sequence="100"
   send_to="12"
  >
  <send>increment_counter("mining_expeditions")</send>
  </trigger>
triggers>
]=])