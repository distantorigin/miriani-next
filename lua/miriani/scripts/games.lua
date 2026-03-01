-- Collection of arcade and other miscellaneous games.

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="games"
   match="^You pick up the silver laser gun attached to the game console and begin a game of Chicken Chase!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_start", "games", 1)</send>
  </trigger>


  <trigger
   enabled="y"
   group="games"
   match="^A[n]? .+? chicken .+? screen\. You take careful aim with the laser gun and fire\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_shoot", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^A Chicken Chase game announces, &quot;Points\: \d+\.  Shots left: \d+\.&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_announce", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^Your red laser shot goes wide, missing the target entirely\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_miss", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^Your laser barely hits the chicken's tail feathers\. That's worth \d+ points?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_hit", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^Your laser shot clips one foot as the chicken flaps across the screen\. \d+ points?\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_hit", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^The red laser shot hits the center of one wing!  \d+ points?!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_hit", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^You nail a solid body shot for \d+ points\. The chicken lets out a loud squawk\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_squawk", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^Nice shot!  You nailed it right in the head!  The chicken explodes in a burst of feathers\. \d+ points?!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_explode", "games", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="games"
   match="^The screen flashes &quot;Game Over\.&quot;  Your final score is \d+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/chicken_chase_game_over", "games", 1)</send>
  </trigger>


  </triggers>
]=])