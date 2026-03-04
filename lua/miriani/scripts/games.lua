-- Collection of arcade and other miscellaneous games.

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="games"
   match="^.+? picks? up the silver laser gun attached to the game console and begins? a game of Chicken Chase!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_start", "games")</send>
  </trigger>


  <trigger
   enabled="y"
   group="games"
   match="^A[n]? .+? chicken .+? screen\. .+? (?:aims the gun controller at it and|take careful aim with the laser gun and) fires?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_shoot", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A Chicken Chase game announces, &quot;.+?&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_announce", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^.+? laser shot missed entirely!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_miss", "games")</send>
  </trigger>


  <trigger
   enabled="y"
   group="games"
   match="^Your red laser shot goes wide, missing the target entirely\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_miss", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^.+? barely hits the chicken's tail feathers\. That's worth \d+ points?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_hit", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^.+? laser shot clips one foot as the chicken flaps across the screen\. \d+ points?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_hit", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^.+? red laser shot hits the center of one wing.  ?\d+ points?!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_hit", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^.+? nails? a solid body shot.*?\. The chicken lets out a loud squawk\..*?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_squawk", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^Nice shot!  You nailed it right in the head!  The chicken explodes in a burst of feathers\. \d+ points?!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_explode", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^The chicken explodes in a burst of feathers as .+? laser shot nails it in the head!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_explode", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^The screen flashes &quot;Game Over\.&quot;  Your final score is \d+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/chicken chase/chicken_chase_game_over", "games")</send>
  </trigger>

 <trigger
   enabled="y"
   group="games"
   match="^.+? winds? up and sends? a ball down the lane\.(?:  Good luck\.)?$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/games/skeeball/skeballRoll", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A .+? skeeball machine announces, &quot;(?:.+? has \d+ points? with \d+ balls? remaining|Points: \d+\.  Balls left: \d+)\.&quot;$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/games/skeeball/skeballScore", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^Game over\. .+? score (?:is|was) \d+(?: points?\.)?$"
   regexp="y"
   send_to="12"
  >
   <send>mplay("misc/games/skeeball/skeballEnd", "games")</send>
  </trigger>

<trigger
   enabled="y"
   group="games"
   match="^After a few seconds, the sound of ravens cawing plays from a hidden speaker on a spiderweb-covered pyramidal machine as if in mockery\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/prize machines/cawingRavens", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^After a few seconds, a faint thud can be heard, and .+ falls into the retrieval slot at the bottom of a spiderweb-covered pyramidal machine\.(?: [A-Z][^.]{1,80}\.)?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/prize machines/slotPayout", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A holographic representation of .+? flickers into existence on the dunking platform\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/dunk tank/dunk_tank_hologram_appear", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A holographic depiction of .+? vanishes\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/dunk tank/dunk_tank_hologram_vanish", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^.+? throws? a scuffed dunk tank ball toward the bullseye on a gigantic dunk tank \(holo-.+? sitting on the dunking platform\)!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/dunk tank/throw_ball", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A scuffed dunk tank ball hits the bullseye and a holographic representation of .+? plummets into the dunking tank, splashing quite real water all over the area!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/dunk tank/dunk_tank_bullseye", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A scuffed dunk tank ball misses the bullseye just barely!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/dunk tank/dunk_tank_hit", "games")</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A scuffed dunk tank ball misses the bullseye by a mile!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/games/dunk tank/dunk_tank_miss", "games")</send>
  </trigger>

  </triggers>
]=])