-- NPC AI Voiceovers

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   group="npc_voices"
   match="^A harried looking woman says, &quot;Thank goodness you're here! I need help!&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("npc/harried_woman_intro", "npc", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="npc_voices"
   match="^A harried looking woman says, &quot;Is there any way, any way at all, that you could help me out\?&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("npc/harried_woman_prompt1", "npc", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="npc_voices"
   match="^A harried looking woman says, &quot;Thank you so much!&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("npc/harried_woman_prompt2", "npc", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="npc_voices"
   match="^A harried looking woman says, &quot;That's strange\. My friend isn't responding to my comm\. I think I'll hold on to these artifacts until I get a response\.&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("npc/harried_woman_prompt3", "npc", 1)</send>
  </trigger>

  <trigger
   enabled="y"
   group="npc_voices"
   match="^A harried looking woman says, &quot;Thanks for checking in! My friends and I are all safe and sound for now\. Thank you for your concern\.&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("npc/harried_woman_prompt4", "npc", 1)</send>
  </trigger>

  </triggers>
]=])