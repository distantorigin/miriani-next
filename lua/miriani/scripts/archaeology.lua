ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="archaeology"
   script="gagline"
   match="^You press a small button on the side of (a level \w+ archaeological dig site scanner) and begin directing it toward several likely locations\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
   mplay("activity/archaeology/search")

   if config:get_option("spam").value == "yes" then
     print("You activate %1.")
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   script="gagline"
match="^A level \w+ archaeological dig site scanner (?:indicates|reports) that ([A-Za-z0-9 \(\),'-]{10,120})\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
   mplay("activity/archaeology/detect")

   local output_message = "%1"

   -- Check if we should calculate direction
   if config:get_option("archaeology_calculate_direction").value == "yes" and current_coordinates and current_coordinates['x'] and current_coordinates['y'] then
     local coords_pattern = "%(([%-%d]+),%s*([%-%d]+)%s*,?%s*([%-%d]*)%)"
     local target_x, target_y, target_z = output_message:match(coords_pattern)

     if target_x and target_y then
       target_x = tonumber(target_x)
       target_y = tonumber(target_y)
       target_z = target_z ~= "" and tonumber(target_z) or current_coordinates['z']

       artifact_coordinates = {
         x = target_x,
         y = target_y,
         z = target_z
       }

       output_message = calculate_direction(current_coordinates, artifact_coordinates, ", ")
     end
   end

   -- Always print the result (we're gagging the original line)
   if config:get_option("spam").value == "yes" then
     print("" .. output_message)
   else
     print("" .. output_message)
   end  -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
match="^A level \w+ archaeological dig site scanner (indicates|reports) (nothing nearby|that nothing is buried nearby|that nothing is nearby)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
print("%2")
mplay("activity/archaeology/nothing")
   </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   script="gagline"
   match="^A level \w+ archaeological dig site scanner indicates that there is an artifact buried approximately (\d+\.\d+) feet beneath the surface\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
   mplay("activity/archaeology/artifactHere")

   if config:get_option("spam").value == "yes" then
     print("%1 feet")
   end  -- if

   if config:get_option("archaeology_helper_dig").value == "yes" then
     buried_artifact = tonumber("%1")
     artifact_room = room
     artifact_depth_unknown = nil
     infobar("arch", string.format("Artifact: %.2f feet %s", buried_artifact, artifact_depth_unknown and "dug" or "remaining"))
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^[A-Z].+ thrusts? a small shovel into the ground and begins? methodically removing large chunks of dirt\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/archaeology/shovel")

   if buried_artifact
   and (artifact_depth_unknown or room == artifact_room) then
     if artifact_depth_unknown then
       buried_artifact = buried_artifact + 0.5
     else
       buried_artifact = math.max(0, buried_artifact - 0.5)
     end
     infobar("arch", string.format("Artifact: %.2f feet %s", buried_artifact, artifact_depth_unknown and "dug" or "remaining"))
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^You begin gently brushing dirt aside with a small brush\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/archaeology/brush")

   if buried_artifact
   and (artifact_depth_unknown or room == artifact_room) then
     if artifact_depth_unknown then
       buried_artifact = buried_artifact + 0.1
     else
       buried_artifact = math.max(0, buried_artifact - 0.1)
     end
     infobar("arch", string.format("Artifact: %.2f feet %s", buried_artifact, artifact_depth_unknown and "dug" or "remaining"))
   end -- if

  </send>
  </trigger>

<trigger
   enabled="y"
   group="archaeology"
   match="^[A-Z].+ thrusts? a small pickaxe into the ground and begins? methodically removing large chunks of dirt\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/archaeology/shovel")

   if buried_artifact
   and (artifact_depth_unknown or room == artifact_room) then
     if artifact_depth_unknown then
       buried_artifact = buried_artifact + 0.3
     else
       buried_artifact = math.max(0, buried_artifact - 0.3)
     end
     infobar("arch", string.format("Artifact: %.2f feet %s", buried_artifact, artifact_depth_unknown and "dug" or "remaining"))
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^Your digging reveals (.+).+\.$"
   regexp="y"
   send_to="12"
  >
  <send>  mplay("activity/archaeology/find")

   if buried_artifact or artifact_room then
     buried_artifact, artifact_room, artifact_depth_unknown = nil
     infobar_t["arch"] = nil
   end -- if

   increment_counter("artifacts")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^You notice some debris littering the area and realize that you shattered the artifact\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/archaeology/shatter")
   if buried_artifact or artifact_room then
     buried_artifact, artifact_room, artifact_depth_unknown = nil
     infobar_t["arch"] = nil
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^You firmly wedge a sleek metallic digging apparatus into the ground and press a trigger on the handle\. The attached shovel immediately goes to work, sending debris.+$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/archaeology/apparatus")

   if buried_artifact
   and (artifact_depth_unknown or room == artifact_room) then
     if artifact_depth_unknown then
       buried_artifact = buried_artifact + 2.0
     else
       buried_artifact = math.max(0, buried_artifact - 2.0)
     end
     infobar("arch", string.format("Artifact: %.2f feet %s", buried_artifact, artifact_depth_unknown and "dug" or "remaining"))
   end -- if

  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^An eighteen-legged insect that greatly resembles an orange stone sidles along the walls of the hole before eventually falling back to the bottom\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/archaeology/insect")</send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^You (?:wipe your brow and )?cease digging\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/archaeology/cease")
   if config:get_option("archaeology_helper_dig").value == "yes"
   and buried_artifact then
     print(string.format("%.2f feet %s.", buried_artifact, artifact_depth_unknown and "dug" or "remaining"))
     end -- if
   </send>
  </trigger>
</triggers>
]=])

-- Debug alias to show current coordinates
ImportXML([=[
<aliases>
  <alias
   enabled="y"
   group="archaeology"
   match="^archcoords$"
   regexp="y"
   send_to="12"
  >
  <send>
   if current_coordinates then
       print(string.format("Current coordinates: (%d, %d, %d)", current_coordinates['x'], current_coordinates['y'], current_coordinates['z']))
        else
     print("No coordinates detected yet. Visit a room with coordinates, such as a digsite.")
   end -- if current_coordinates
  </send>
  </alias>
</aliases>
]=])
