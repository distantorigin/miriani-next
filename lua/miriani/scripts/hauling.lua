ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="hauling"
   match="^You feel a mild vibration as the starship's asteroid anchor buries itself into the asteroid's surface\.$"
   regexp="y"
   send_to="12"
   omit_from_output="y"
 >
  <send>mplay("activity/asteroid/shipAnchorStart")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^Upon finding a suitable location, you press a small button on the side of an asteroid anchor, which forcefully buries itself into the ground\.$"
   regexp="y"
   send_to="12"
   omit_from_output="y"
 >
  <send>mplay("activity/asteroid/anchorEnd")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^You begin to painstakingly tie a coil of sturdy line to an asteroid anchor\.$"
   regexp="y"
   send_to="12"
   omit_from_output="y"
 >
  <send>mplay("activity/asteroid/lineStart")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^The whine of strained components echos throughout the area as the starship struggles to haul the asteroid\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
 >
  <send>mplay("SHIP/MOVE/HAUL")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^A light envelops the room and quickly sucks your asteroid hauling supplies into an asteroid hauling kit\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
 >
  <send>mplay("activity/asteroid/kitRetrieve")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^You spend a moment searching for a suitable location to deploy an asteroid anchor\.$"
   regexp="y"
   send_to="12"
   omit_from_output="y"
 >
  <send>mplay("activity/asteroid/anchorStart")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^You step back and admire your handiwork\.$"
   regexp="y"
   send_to="12"
 >  
  <send>mplay("activity/asteroid/lineEnd")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^You press a button on the side of an asteroid anchor, which works its way out of the ground\. You pick it up\.$"
   regexp="y"
   send_to="12"
 >
  <send>mplay("activity/asteroid/anchorRemove")</send>
  </trigger>

  <trigger
   enabled="y"
   group="hauling"
   match="^.+announces,.+Lifting anchor and establishing standard dock.+$"
   regexp="y"
   send_to="12"
   >
   <send>mplay("activity/asteroid/shipAnchorEnd")</send>
  </trigger>
  </triggers>
]=])