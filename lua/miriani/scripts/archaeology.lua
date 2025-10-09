-- Global variables for tracking player coordinates
player_x = nil
player_y = nil
player_z = nil

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
   match="^A level \w+ archaeological dig site scanner (?:indicates|reports) that (?:you should move to|there is an object) (.+)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
   mplay("activity/archaeology/detect")

   local output_message = "%1"

   -- Check if we should calculate direction
   if config:get_option("archaeology_calculate_direction").value == "yes"
      and player_x and player_y then

     -- Try to extract coordinates from message like "(X, Y, Z)" or "(X, Y)"
     local coords_pattern = "%(([%-%d]+),%s*([%-%d]+)%s*,?%s*([%-%d]*)%)"
     local target_x, target_y, target_z = output_message:match(coords_pattern)

     if target_x and target_y then
       target_x = tonumber(target_x)
       target_y = tonumber(target_y)
       target_z = target_z ~= "" and tonumber(target_z) or player_z

       -- Calculate direction
       local directions = {}
       local x_diff = target_x - player_x
       local y_diff = target_y - player_y

       if x_diff ~= 0 then
         if x_diff > 0 then
           table.insert(directions, string.format("%dE", x_diff))
         else
           table.insert(directions, string.format("%dW", math.abs(x_diff)))
         end
       end

       if y_diff ~= 0 then
         if y_diff > 0 then
           table.insert(directions, string.format("%dS", y_diff))
         else
           table.insert(directions, string.format("%dN", math.abs(y_diff)))
         end
       end

       -- Only calculate Z if both coordinates exist
       if target_z and player_z then
         local z_diff = target_z - player_z
         if z_diff ~= 0 then
           if z_diff > 0 then
             table.insert(directions, string.format("%dD", z_diff))
           else
             table.insert(directions, string.format("%dU", math.abs(z_diff)))
           end
         end
       end

       if #directions > 0 then
         output_message = table.concat(directions, ", ")
       end
     end
   end

   -- Always print the result (we're gagging the original line)
   if config:get_option("spam").value == "yes" then
     print("Artifact detected " .. output_message)
   else
     print("Scanner indicates: " .. output_message)
   end  -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^A level \w+ archaeological dig site scanner reports (nothing nearby)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
  >
  <send>
mplay("activity/archaeology/nothing")

   if gagline("archaeology_text", "%0") then
     print("%1")
   end -- if
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
   mplay("activity/archaeology/artifact")

   if config:get_option("spam").value == "yes" then
     print("%1 feet")
   end  -- if

   if config:get_option("archaeology_helper_dig").value == "yes" then
     buried_artifact = tonumber("%1")
     artifact_room = room
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
   and room == artifact_room then
     buried_artifact = buried_artifact - 0.5
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
   and room == artifact_room then
     buried_artifact = buried_artifact - 0.1
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
   and room == artifact_room then
     buried_artifact = buried_artifact - 0.3
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
  <send>
   mplay("activity/archaeology/find")

   if buried_artifact or artifact_room then
     buried_artifact, artifact_room = nil
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^You notice some debris littering the area and realize that you shattered the artifact\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("activity/archaeology/shatter")</send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^You firmly wedge a sleek metallic digging apparatus into the ground and press a trigger on the handle\. The attached shovel immediately goes to work, sending debris| (?:flying into the air around it|floating away into the surrounding water)\.$"
   regexp="y"
   send_to="12"
  >
  <send>
   mplay("activity/archaeology/apparatus")

   if buried_artifact
   and room == artifact_room then
     buried_artifact = buried_artifact - 2.0
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
     print(string.format("%%.2f feet.", buried_artifact))
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="archaeology"
   match="^(.+) \((.+)\)$"
   regexp="y"
   send_to="12"
   sequence="99"
  >
  <send>
   -- Try to extract coordinates from room description
   -- Pattern: "Room Name (X, Y, Z)" or "Room Name (X, Y)"
   local room_info = "%2"

   -- Look for coordinate pattern
   local x, y, z = room_info:match("^([%-%d]+),%s*([%-%d]+)%s*,?%s*([%-%d]*)$")

   if x and y then
     player_x = tonumber(x)
     player_y = tonumber(y)
     player_z = z ~= "" and tonumber(z) or nil
   end
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
   if player_x and player_y then
     if player_z then
       print(string.format("Current coordinates: (%d, %d, %d)", player_x, player_y, player_z))
     else
       print(string.format("Current coordinates: (%d, %d)", player_x, player_y))
     end
   else
     print("No coordinates detected yet. Visit a room with coordinates in the title.")
   end
  </send>
  </alias>
</aliases>
]=])
