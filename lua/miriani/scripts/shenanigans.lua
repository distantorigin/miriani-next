-- Shenanigan triggers for blade combat, slime machines, and other RP shenanigans
-- Credit: Miriani Soundpack for VIP Mud

ImportXML([=[
<triggers>

  <!-- Blade Combat Sounds -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ (remove|unsheathe).+(from a .+sheath|with lightning speed)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/unsheathe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You stab at .+'s .+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Stab")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You swipe at .+'s .+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/swipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ stabs at your .+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/stab")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ swipes at your .+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/swipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ slashes you.+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/swipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You clean the blood off of .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/wipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^A loud clang fills the air and sparks fly from both weapons as you successfully block .+'s attack with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/block")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You carefully sheathe .+ in a .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/sheathe")</send>
  </trigger>

  <!-- Slime Machine Sounds -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^A.+ of .+ slams into .+, drenching .+!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("social/slimeMachineHit")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You smash your foot into a.+ of .+ and it forms a large puddle\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("social/slimePuddleSplat")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You smash a.+ of .+ into your face, where it bursts and covers you in .+!$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("social/slimePuddleSplat")</send>
  </trigger>

  <!-- Paint Canister Explosions -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You gleefully puncture a canister of .+ paint, which explodes in your face\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/atmo/gasExplodes")</send>
  </trigger>

  <!-- Toilet Flush Sounds -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^[A-Za-z]+ press(?:es)? the flushing mechanism on .*\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/toiletFlush")</send>
  </trigger>

  <!-- Poo Accident -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ strains? so hard to .+ that .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/oops")</send>
  </trigger>

  <!-- Jingle Bells (Holiday) -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^A loud rendition of Jingle Bells sounds as .+ lights twinkle overhead\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/jingleBell")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ .+ a finger over the touch pad of an impact target array unit and .+ an inert sphere of inoperative bardenium at .+ chosen target\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/combat/cannon")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="An inert sphere of inoperative bardenium misses its target and shatters into sparkling dust that is efficiently suctioned away\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/archaeology/shatter1")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="An inert sphere of inoperative bardenium crashes into .+ and sends it sliding down the pneumatic transport tube\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("activity/archaeology/practice")</send>
  </trigger>

<trigger
   enabled="y"
   group="shenanigans"
   match="After a few seconds, the sound of ravens cawing plays from a hidden speaker on a spiderweb-covered pyramidal machine as if in mockery\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/cawingRavens")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="After a few seconds, a faint thud can be heard, and .+ falls into the retrieval slot at the bottom of a spiderweb-covered pyramidal machine\.(?: [A-Z][^.]{1,80}\.)?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/slotPayout")</send>
  </trigger>

  <!-- Air Freshener Sounds -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^A.+ air freshener freshens the room with the scent of .+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/scent")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You carefully spray a fine mist from .+ at .+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("ship/misc/scent")</send>
  </trigger>

  <!-- Shower Sounds -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You slide open the shower door and enter"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/showerdoor")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="enters through the sliding glass door\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/showerdoor")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^The .+ water continues to spray down on you"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/shower")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="turn.+ the water off"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/ShowerEnd")</send>
  </trigger>

  </triggers>
]=])
