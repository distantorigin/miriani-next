-- Shenanigan triggers for blade combat, slime machines, and other RP shenanigans
-- Credit: Miriani Soundpack for VIP Mud

ImportXML([=[
<triggers>

  <!-- Blade Combat Sounds -->

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ (remove|unsheathe).+ (from a .+sheath|with lightning speed).$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Unsheathe")</send>
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
  <send>mplay("misc/blades/Swipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ stabs at your .+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Stab")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ swipes at your .+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Swipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^.+ slashes you.+ with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Swipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You clean the blood off of .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Wipe")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^A loud clang fills the air and sparks fly from both weapons as you successfully block .+'s attack with .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Block")</send>
  </trigger>

  <trigger
   enabled="y"
   group="shenanigans"
   match="^You carefully sheathe .+ in a .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/blades/Sheathe")</send>
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

</triggers>
]=])
