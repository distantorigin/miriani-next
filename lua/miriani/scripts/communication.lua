
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="comm"
   match="^(\[Frequency ([0-9]{1,3}\.[0-9]{1,2}) ?\|? ?(\w+)?\]) (.+? transmits,?)? ?(.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="75"
  >
  <send>
   mplay ("comm/metaf", "communication")

   if "%3" ~= "" then
    print_color({"[%3] %4 ", "default"}, {"%5", "priv_comm"})
    channel(name, "[%3] %4 %5", {"metaf %3", "metaf", "communication"})
   else
    print_color({"[%2] %4 ", "default"}, {"%5", "priv_comm"})
    channel(name, "%0", {"metaf %2", "metaf", "communication"})
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(?:A|From).* flight control scanner \w+, &quot;(.+?)&quot;$"
   regexp="y"
  omit_from_output="y"
   send_to="14"
   sequence="100"
    >
  <send>
   local scanner_name = GetVariable("fc_scanner_name") or "flight control"
   local message = "%1"

   -- Always truncate "A flight monitor announces, " or similar
   local clean_message = message:gsub("^[Aa] flight .* announces, ", ""):gsub("^From .* flight control scanner .*, ", "")

   print_color({clean_message, "flight"})
   channel("flight", clean_message, {"flight"})

   if string.find (clean_message, "we detect.+Ontanka") then
     mplay ("comm/praelorInbound", "communication")
   end -- if praelor activity
   mplay ("comm/flight", "communication")

   -- Clear the stored scanner name
   DeleteVariable("fc_scanner_name")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"	
   match="^(\[Private \| .+?\]) (.+?)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay ("comm/private", "communication", nil, nil, nil, nil, nil, true)
   channel("private", "%0", {"private", "communication"})
   print_color({"%1 ", "default"}, {"%2", "priv_comm"})
  </send>
  </trigger>


  <trigger
   enabled="y"
   group="comm"
   match="^\[(Newbie|Chatter|OOC|General Communication|Short-range Communication)\]:? (.+)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   local channel_name = "%1"
   local message = "%2"

   -- Map channel names for display and sound
   local display_name = channel_name
   local sound_name = string.lower(channel_name)

   if channel_name == "Short-range Communication" then
     -- Keep full name for short-range
     sound_name = "short"
   elseif channel_name == "General Communication" then
     -- Shorten General Communication to just General
     display_name = "General"
     sound_name = "general"
   end

   local display_text = "[" .. display_name .. "] " .. message

   mplay("comm/"..sound_name, "communication")
   channel(display_name, display_text, {"communication", sound_name})
   print(display_text)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^((?:[A-Za-z0-9]+)(?:[\w !]+) (say|ask|exclaim)s?,? ?(?:.+? )?)(&quot;.+?&quot;)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("comm/say", "communication")
   print_color({"%1", "default"}, {"%3", "pub_comm"})
   channel(name, "%0", {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^([\w\s'!]+) \[to ([\w\s'!]+)\] ?: (.+)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="99"
  >
  <send>
   if string.find(string.lower("%2"), "you") then
     -- Direct say TO YOU - use directsay sound and bypass foreground sounds
     mplay("comm/directsay", "communication", nil, nil, nil, nil, nil, true)
     print_color({"%1 [to %2]: ", "default"}, {"%3", "priv_comm"})
   else
     -- Direct say to someone else - use normal say sound
     mplay("comm/say", "communication")
     print_color({"%1 [to %2]: ", "default"}, {"%3", "pub_comm"})
   end
   -- All direct says go to the say buffer
   channel("say", "%1 [to %2]: %3", {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+?) says to ([\w\s'!]+), &quot;(.+?)&quot;$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="99"
  >
  <send>
   if string.find(string.lower("%2"), "you") then
     -- Direct say TO YOU - use directsay sound and bypass foreground sounds
     mplay("comm/directsay", "communication", nil, nil, nil, nil, nil, true)
     print_color({"%1 says to %2, \"", "default"}, {"%3", "priv_comm"}, {"\"", "default"})
   else
     -- Direct say to someone else - use normal say sound
     mplay("comm/say", "communication")
     print_color({"%1 says to %2, \"", "default"}, {"%3", "pub_comm"}, {"\"", "default"})
   end
   -- All direct says go to the say buffer (use normalized format for buffer)
   channel("say", "%1 [to %2]: %3", {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+?) (asks|exclaims) (?:to )?you, &quot;(.+?)&quot;$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="99"
  >
  <send>
   mplay("comm/directsay", "communication", nil, nil, nil, nil, nil, true)
   print_color({"%1 %2 you, \\"%3\\"", "priv_comm"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+?) .+ to you, &quot;(.+?)&quot;$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="98"
  >
  <send>
   -- Catch-all for complex direct says TO YOU (like hesitates briefly before saying)
   mplay("comm/directsay", "communication", nil, nil, nil, nil, nil, true)
   print_color({"%0", "priv_comm"})
   -- Add to say buffer (use normalized format for buffer)
   channel("say", "%1 [to you]: %2", {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^\[ ([\w\s']+) shatters? immersion (\w+-wide)?\s?and &quot;?(.+)&quot;? \]$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/rooc", "communication")
   if "%2" == "ship-wide" or "%2" == "structure-wide" then
    print_color({"[SOOC] %1 ", "default"}, {"%3", "pub_comm"})
    channel("sooc", "[SOOC] %1 %3", {"ooc", "communication"})
   else
    print_color({"[ROOC] %1 ", "default"}, {"%3", "pub_comm"})
   channel(name, "[ROOC] %1 %3", {"ooc", "communication"})
   end -- if ship wide
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^You (?:press a small button mounted on the wall|patch your suit radio through the public address system) and (.+)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="75"
  >
  <send>
   mplay("comm/paYou", "communication")
   channel(name, "[PA] You %1", {"pa", "communication"})
       print_color({"[PA] You ", "default"}, {"%1", "pub_comm"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+?)'s voice comes over the intercom, (.+?), (&quot;.+?&quot;)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("comm/paOther", "communication")
   if environment and config:get_option("pa_interrupt").value == "yes" and environment["parent"] == "starship" then
    Execute("tts_stop")
   end -- if
   local verb = string.gsub("%2", "ing", "s")
   local prefix = "[PA] %1 "..verb..", "
   local msg = prefix.."%3"
   channel(name, msg, {"pa", "communication"})
   print_color({prefix, "default"}, {"%3", "pub_comm"})
  </send>
  </trigger>
  <trigger
   enabled="y"
   group="comm"
   match="^(.+) (\w+) over the intercom\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("comm/paOther", "communication")
   local prefix = "[PA] %1 "
   local msg = prefix.."%2."
   channel(name, msg, {"pa", "communication"})
   print_color({prefix, "default"}, {"%2", "pub_comm"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+) into a small microphone mounted on the wall\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay("comm/paOther", "communication")
   channel(name, "[PA] %1", {"pa", "communication"})
   print_color({"[PA] ", "default"}, {"%1", "pub_comm"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^([\w\s]+) (?:hear)?\s?(shout|yell)s?, (&quot;.+?&quot;)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/shout", "communication")
   print_color({"%1 %2, ", "default"}, {"%3", "pub_comm"})
   channel(name, "%1 %2, %3", {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^You (.+?) into a small microphone and listen as (?:it is|it's) played through the ship's external PA\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/paYou", "communication")
   print_color({"[External PA] You ", "default"}, {"%1", "pub_comm"})
   channel(name, "[External PA] You %1", {"pa", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^A (.+?) from (.+?) is piped through the ship's intercom from the external PA\.( You hear (?:\w+?) ((\w+?)? ?(?:and )?(say|ask|exclaim)),? (.+?))?$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/paOther", "communication")
   if "%3" == "" then
    print_color({"[External PA] %2 %1s.", "pub_comm"})
    channel(name, "[External PA] %2 %1s.", {"pa", "communication"})
   else
     local social = "%5" == "" and "" or "%5s and "
    print_color({"[External PA] %2 "..social.."%6s, ", "default"}, {"%7", "pub_comm"})
    channel(name, "[External PA] %2 "..social.."%6s, %7", {"pa", "communication"})
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^From a large speaker on ([\w\s]+), (you hear .+)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/paOther", "communication")
   print_color({"[From %1] ", "default"}, {"%2", "pub_comm"})
   channel(name, "[From %1] %2", {"pa", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^This (?:ship|planet|station|moon) (transmits|demands|broadcasts),? &quot;?.+&quot;?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("comm/ship", "communication")
   channel("ship", "%0", {"ship", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^[\w\s]+ the droid says in an? \w+ voice, &quot;.+?&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("comm/droid", "communication")</send>
  </trigger>


  <trigger
   enabled="y"
   group="comm"
   match="^Via general sector communication, (.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/sector", "communication")
   print_color({"[Gen] ", "default"}, {"%1", "pub_comm"})
   channel(name, "[Gen] %1", {"ship", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^Via long-range communication, (.+?) broadcasts: (&quot;.+?&quot;)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/broadcast", "communication")
   print_color({"%1 broadcasts: ", "default"}, {"%2", "pub_comm"})
   channel(name, "%1 broadcasts: %2", {"ship", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^\[(?:AIE|Commonwealth|Hale) \| .+?\] .+$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("comm/alliance", "communication")
   channel("alliance", "%0", {"alliance", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(\[Starship \| (.+?)\]) (.+?)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   mplay ("comm/relay", "communication")
   local ship_name = "%2"
   local message = "%3"

   -- Always show as [shipname] format
   print_color({"[" .. ship_name .. "] ", "default"}, {message, "priv_comm"})
   channel("ship", "[" .. ship_name .. "] " .. message, {"ship", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^A message board reader beeps quietly, indicating to you that there is a new message in (.+?)\. It was posted by (.+?) with the subject (.+?)\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("device/newPost")
   print_color({"New board post in %1. Posted by %2: Subject: ", "default"}, {"%3", "board"})
   channel(name, "New board post in %1. Posted by %2: Subject: %3", {"board"})
  </send>
  </trigger>
  <trigger
   enabled="y"
   group="comm"
   match="^You turn a .+? (on|off)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("comm/%1", "communication")</send>
  </trigger>

<trigger
   enabled="y"
   group="comm"
   match="^You add frequency [0-9]{1,3}\.[0-9]{1,2}\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("comm/tune", "communication")</send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^You (?:re)?(activate|deactivate) .+?$"
regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay ("device/%1", "communication")</send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^[\w\s]+ transmits?(?: in an? \w+ voice)?, &quot;.+?&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("comm/transmit", "communication")
   channel ("transmit", "%0", {"communication", "say"})
  </send>
  </trigger>
  
  <trigger
   enabled="y"
   group="comm"
   match="^\[(\w+)\] .+? (?:transmits|says), .+?$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local file = require("pl.path").isfile(
   config:get("SOUND_DIRECTORY")..SOUNDPATH.."comm/%1"..config:get("EXTENSION")) and "%1" or "organization"
   mplay("comm/"..file, "communication")
   channel(name, "%0", {"communication", file})
  </send>
  </trigger>

</triggers>
]=])