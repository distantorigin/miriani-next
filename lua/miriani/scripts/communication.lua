
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="comm"
   match="^(\[Frequency ([0-9]{1,3}\.[0-9]{1,2}) ?\|? ?([^\]]+)?\]) (.+? transmits,?)? ?(.+?)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   -- Determine custom sound file based on label or frequency number
   local sound_file = "metaf"
   local label = "%3"
   local frequency = "%2"
   local speaker_part = "%4"
   local message = "%5"

   if label ~= "" then
     -- Check if custom sound exists for the label
     local custom_label = string.lower(label)
     if require("pl.path").isfile(config:get("SOUND_DIRECTORY")..SOUNDPATH.."comm/"..custom_label..EXTENSION) then
       sound_file = custom_label
     end
   else

     local custom_freq = frequency:gsub("%.", "")
     if require("pl.path").isfile(config:get("SOUND_DIRECTORY")..SOUNDPATH.."comm/"..custom_freq..EXTENSION) then
       sound_file = custom_freq
     end
   end

   mplay ("comm/"..sound_file, "communication")

   -- Format output based on shorten_communication setting
   local display_output
   if config:get_option("shorten_communication").value == "yes" then
     if speaker_part ~= "" then
       -- Speaker transmits pattern matched - strip "transmits," to get "Speaker:"
       local speaker_short = string.gsub(speaker_part, "%s*transmits,?%s*$", ":")
       local unquoted = string.gsub(string.gsub(message, '^%s*"?', ''), '"?%s*$', '')
       display_output = speaker_short .. " " .. unquoted
     else
       -- No transmits - parse message for verb pattern
       local speaker, verb, rest = string.match(message, '^(.-)%s+(%a+),%s*(.+)$')
       if speaker and verb and rest then
         local unquoted = string.gsub(string.gsub(rest, '^%s*"?', ''), '"?%s*$', '')
         local v = string.lower(verb)
         if v == "says" or v == "say" or v == "asks" or v == "ask" or
            v == "exclaims" or v == "exclaim" or v == "transmits" or v == "transmit" then
           display_output = speaker .. ": " .. unquoted
         else
           display_output = speaker .. " " .. verb .. ": " .. unquoted
         end
       else
         display_output = message
       end
     end
   else
     display_output = speaker_part .. " " .. message
   end

   if "%3" ~= "" then
    print_color({"[%3] " .. display_output, "priv_comm"})
    channel(name, "[%3] %4 %5", {"metaf %3", "metaf", "communication"})
   else
    print_color({"[%2] " .. display_output, "priv_comm"})
    channel(name, "%0", {"metaf %2", "metaf", "communication"})
   end -- if
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^\[Admin Message\]: (.+)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   local message = "%1"

   -- Play admin message sound
   mplay("comm/adminPrivateMessage", "communication")

   -- Display the message
   print_color({"[Admin Message] ", "default"}, {message, "priv_comm"})

   -- Add to main communications buffer
   channel(name, "[Admin Message] " .. message, {"admin", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^\[Private \| Auction Service\] Auction Service transmits, &quot;(.+?) has bid ([0-9,.]+) credits on auction ([a-z0-9]+): (.+?)!&quot;$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   local bidder = "%1"
   local amount = "%2"
   local auction_num = "%3"
   local item = "%4"

   -- Play auction bid sound
   mplay("misc/bid", "notification")

   -- Format display text
   local display_text = bidder .. " has bid " .. amount .. " credits on auction " .. auction_num .. ": " .. item .. "!"
   print_color({"[Auction] ", "default"}, {display_text, "priv_comm"})

   -- Add to Auction buffer
   channel("auction", "[Auction] " .. display_text, {"auction", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(\[Private \| (.+?)\]) (.+?)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>
   local sender_name = string.lower("%2")
   local message = "%3"
   local sound_file = "private"
   local bypass_foreground = true

   if sender_name:find("service") or sender_name:find("recipient") then
     sound_file = "services"
     -- Service comms default to NOT bypassing foreground sounds unless option is enabled
     bypass_foreground = config:get_option("service_comm_interrupt").value == "yes"
   end

   -- Apply shortening to remove verbs like "transmits"
   local display_message = message
   if config:get_option("shorten_communication").value == "yes" then
     -- Match: Speaker transmits, rest -> Speaker: message
     local speaker, rest = string.match(message, '^(.-)%s+transmits?,?%s*(.+)$')
     if speaker and rest then
       -- Strip surrounding quotes if present
       local unquoted = string.match(rest, '^"(.+)"$') or rest
       display_message = speaker .. ": " .. unquoted
     end
   end

   mplay ("comm/"..sound_file, "communication", nil, nil, nil, nil, nil, bypass_foreground)
   channel("private", "[%2] %3", {"private %2", "private", "communication"})
   print_color({"[%2] ", "default"}, {display_message, "priv_comm"})
  </send>
  </trigger>


  <trigger
   enabled="y"
   group="comm"
   match="^\[(Newbie|Chatter|Design|OOC|General Communication|Short-range Communication)\]:? (.+)$"
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
     sound_name = "short_range"
   elseif channel_name == "General Communication" then
     -- Shorten General Communication to just General
     display_name = "General"
     sound_name = "general"
   end

   -- Apply shortening: remove comma and quotes, keep non-communication verbs
   local display_message = message
   if config:get_option("shorten_communication").value == "yes" then
     -- Match: Speaker verb, "message"
     local speaker, verb, rest = string.match(message, '^(.-)%s+(%a+),%s*(.+)$')
     if speaker and verb and rest then
       -- Strip surrounding quotes if present
       local unquoted = string.match(rest, '^"(.+)"$') or rest
       local v = string.lower(verb)
       if v == "says" or v == "say" or v == "asks" or v == "ask" or
          v == "exclaims" or v == "exclaim" or v == "transmits" or v == "transmit" then
         -- Communication verbs: remove verb entirely
         display_message = speaker .. ": " .. unquoted
       else
         -- Other verbs: keep verb, just remove comma and quotes
         display_message = speaker .. " " .. verb .. ": " .. unquoted
       end
     end
   end

   local display_text = "[" .. display_name .. "] " .. display_message

   mplay("comm/"..sound_name, "communication")
   channel(display_name, "[" .. display_name .. "] " .. message, {"communication", sound_name})
   print(display_text)
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^([A-Z][A-Za-z]+(?: [A-Z][A-Za-z]+)*) (.+ )?(says?|asks?|exclaims?)(?: (?:to )?([A-Za-z]+(?: [A-Z][A-Za-z]+)*))?, &quot;(.+?)&quot;$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
   keep_evaluating="y"
  >
  <send>
   local speaker = "%1"
   local emotes = "%2"  -- Everything before the verb (includes emotes like "grins and ", "hesitates briefly before ", etc.)
   local verb = "%3"
   local target = "%4"
   local message = "%5"

   -- Check if this is directed at you (exact match, case-insensitive)
   local is_direct_to_you = target and string.lower(target) == "you"

   if is_direct_to_you then
     -- Direct say TO YOU - use directsay sound and bypass foreground sounds
     mplay("comm/directsay", "sounds", nil, nil, nil, nil, nil, true)
   elseif target and target ~= "" then
     -- Direct say to someone else - use normal say sound
     mplay("comm/say", "communication")
   else
     -- General say - use normal say sound
     mplay("comm/say", "communication")
   end

   -- Format output based on shorten_communication setting
   local output
   if config:get_option("shorten_communication").value == "yes" then
     -- Shortened format: Speaker: message (or Speaker [to Target]: message)
     if target and target ~= "" then
       output = speaker .. " [to " .. target .. "]: " .. message
     else
       output = speaker .. ": " .. message
     end
   else
     -- Original format
     output = "%0"
   end

   -- Print with appropriate color based on target
   if is_direct_to_you then
     print_color({output, "priv_comm"})
   else
     print_color({output, "pub_comm"})
   end

   -- Add to say buffer (always use original format for buffer)
   channel("say", "%0", {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+?) \[to (.+?)\]:?\s*(.+)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="98"
  >
  <send>
   local speaker = "%1"
   local target = "%2"
   local message = "%3"

   -- Check if this is directed at you
   local is_direct_to_you = string.find(string.lower(target), "you")

   if is_direct_to_you then
     -- Direct say TO YOU - use directsay sound and bypass foreground sounds
     mplay("comm/directsay", "communication", nil, nil, nil, nil, nil, true)
     print_color({speaker .. " [to " .. target .. "]: ", "default"}, {message, "priv_comm"})
   else
     -- Direct say to someone else - use normal say sound
     mplay("comm/say", "communication")
     print_color({speaker .. " [to " .. target .. "]: ", "default"}, {message, "pub_comm"})
   end

   -- Add to say buffer
   channel("say", speaker .. " [to " .. target .. "]: " .. message, {"say", "communication"})
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
   local speaker = "%1"
   local msg = "%3"

   -- Apply shortening if enabled
   local display_msg = msg
   local sep = " "
   if config:get_option("shorten_communication").value == "yes" then
     local verb, rest = string.match(msg, '^(%a+),%s*(.+)$')
     if verb and rest then
       local unquoted = string.match(rest, '^"(.+)"$') or rest
       local v = string.lower(verb)
       if v == "says" or v == "say" or v == "asks" or v == "ask" or
          v == "exclaims" or v == "exclaim" then
         display_msg = unquoted
         sep = ": "
       else
         display_msg = verb .. ": " .. unquoted
       end
     end
   end

   if "%2" == "ship-wide" or "%2" == "structure-wide" then
    print_color({"[SOOC] " .. speaker .. sep, "default"}, {display_msg, "pub_comm"})
    channel("sooc", "[SOOC] " .. speaker .. " " .. msg, {"ooc", "communication"})
    mplay ("comm/sooc", "communication")
   else
    print_color({"[ROOC] " .. speaker .. sep, "default"}, {display_msg, "pub_comm"})
   channel(name, "[ROOC] " .. speaker .. " " .. msg, {"ooc", "communication"})
   mplay ("comm/rooc", "communication")
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
   match="^([a-zA-Z].+)'s voice comes over the intercom, (.+?), (&quot;.+?&quot;)$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
   mplay("comm/paOther", "communication")
   if environment and config:get_option("pa_interrupt").value == "yes" and environment["parent"] == "starship" then
    Execute("tts_stop")
   end -- if
   local verb = string.gsub("%2", "ing", "s")
   local prefix = "[PA] %1 "..verb..", "
   local msg = prefix.."%3"
   channel(name, msg, {"pa", "communication"})
   print_color({prefix, "default"}, {"%3", "pub_comm"})
  else
  print("%0")
  end</send>
  </trigger>
  <trigger
   enabled="y"
   group="comm"
   match="^([a-zA-Z].+) (\w+) over the intercom\.$"
   regexp="y"
   send_to="14"
   omit_from_output="y"
   sequence="100"
  >
  <send>if not originating_from_camera("%0") then
   mplay("comm/paOther", "communication")
   local prefix = "[PA] %1 "
   local msg = prefix.."%2."
   channel(name, msg, {"pa", "communication"})
   print_color({prefix, "default"}, {"%2", "pub_comm"})
   else
    print("%0")
   end</send>
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
   match="^([A-Z][A-Za-z]+(?: [A-Z][A-Za-z]+)*|You) (?:hear )?(shout|yell|holler)s?, &quot;(.+?)&quot;$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("comm/shout", "communication")
   local speaker = "%1"
   local verb = "%2"
   local message = "%3"
   -- Properly conjugate the verb: third person gets 's', first person doesn't
   local verb_form = speaker == "You" and verb or verb .. "s"

   -- Format output based on shorten_communication setting
   local output
   local q = '"'
   if config:get_option("shorten_communication").value == "yes" then
     -- Shortened format: Speaker: message (remove the shout/yell verb and quotes)
     output = speaker .. ": " .. message
   else
     -- Original format with quotes
     output = speaker .. " " .. verb_form .. ", " .. q .. message .. q
   end

   print_color({output, "pub_comm"})
   channel(name, speaker .. " " .. verb_form .. ", " .. q .. message .. q, {"say", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^You whisper &quot;(.+)&quot; to (.+)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   mplay ("comm/whisperSent", "communication")
   local message = "%1"
   local target = "%2"
   channel("whisper", "%0", {"whisper", "communication"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^(.+) leans in close and whispers, &quot;(.+)&quot;$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   local speaker = "%1"
   local message = "%2"

   -- Whispered to you - use whisperTo sound and priv_comm color, bypass foreground sounds
   mplay("comm/whisperTo", "communication", nil, nil, nil, nil, nil, true)
   channel("whisper", "%0", {"whisper", "communication"})
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
   send_to="14"
   sequence="100"
  >
  <send>
   local sound = "%1" == "broadcasts" and "comm/ship" or "comm/sector"
   mplay (sound, "communication")
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

   -- Apply shortening: remove comma and quotes, keep non-communication verbs
   local display_message = message
   if config:get_option("shorten_communication").value == "yes" then
     -- Match: Speaker verb, "message"
     local speaker, verb, rest = string.match(message, '^(.-)%s+(%a+),%s*(.+)$')
     if speaker and verb and rest then
       -- Strip surrounding quotes if present
       local unquoted = string.match(rest, '^"(.+)"$') or rest
       local v = string.lower(verb)
       if v == "says" or v == "say" or v == "asks" or v == "ask" or
          v == "exclaims" or v == "exclaim" or v == "transmits" or v == "transmit" then
         -- Communication verbs: remove verb entirely
         display_message = speaker .. ": " .. unquoted
       else
         -- Other verbs: keep verb, just remove comma and quotes
         display_message = speaker .. " " .. verb .. ": " .. unquoted
       end
     end
   end

   -- Always show as [shipname] format
   print_color({"[" .. ship_name .. "] ", "default"}, {display_message, "priv_comm"})
   channel("ship", "[" .. ship_name .. "] " .. message, {"ship", "communication"})
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
   match="^(?!This (?:ship|planet|station|moon) )([\w\s]+) transmits?(?: in an? \w+ voice)?, &quot;(.+?)&quot;$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   local speaker = "%1"
   local message = "%2"

   mplay ("comm/transmit", "communication")

   -- Format output based on shorten_communication setting
   local output
   if config:get_option("shorten_communication").value == "yes" then
     -- Shortened format: Speaker: message
     output = speaker .. ": " .. message
   else
     -- Original format
     output = "%0"
   end

   print_color({output, "pub_comm"})
   channel ("transmit", "%0", {"communication", "say"})
  </send>
  </trigger>
  
  <trigger
   enabled="y"
   group="comm"
   match="^You have access to the following channels:|You are averaging \d+ points and \d+ combat points per day\.$"
   regexp="y"
   send_to="14"
   sequence="50"
  >
  <send>
   -- Start looking for our organization name in either score or tr channels
   EnableTrigger("detect_org", 1)
   -- Also look for courier
   EnableTrigger("detect_courier", 1)</send>
  </trigger>

  <trigger
   enabled="n"
   name="detect_org"
   match="^Private Organization: .+ \((.+)\)|\[Organization\] (.+)$"
   regexp="y"
   send_to="14"
   sequence="50"
  >
  <send>local current_org = GetVariable("org_name")
     if current_org ~= "%1" and "%1" ~= "" then
       SetVariable("org_name", "%1")
       print_color({"Organization set: ", "default"}, {"%1", "priv_comm"})
     end
            EnableTrigger("detect_org", 0)</send>
  </trigger>

  <trigger
   enabled="n"
   name="detect_courier"
   match="^Courier Company: (.+)$"
   regexp="y"
   send_to="14"
   sequence="50"
  >
  <send>local current_courier = GetVariable("courier_company")
     if current_courier ~= "%1" and "%1" ~= "" then
       SetVariable("courier_company", "%1")
            end
     EnableTrigger("detect_courier", 0)</send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^\[([\w ]+)\] (.+)$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="110"
  >
  <send>
   local detected_org = GetVariable("org_name")
   local detected_courier = GetVariable("courier_company")
   local channel_name = "%1"
   local message = "%2"

   if detected_org and channel_name == detected_org then
     -- This is our organization
     local file = require("pl.path").isfile(
     config:get("SOUND_DIRECTORY")..SOUNDPATH.."comm/"..channel_name..EXTENSION) and channel_name or "organization"
     mplay("comm/"..file, "communication")
     channel(name, "%0", {"organization", "communication"})

     -- Apply shortening
     local display_message = message
     if config:get_option("shorten_communication").value == "yes" then
       local speaker, verb, rest = string.match(message, '^(.-)%s+(%a+),%s*(.+)$')
       if speaker and verb and rest then
         local unquoted = string.gsub(string.gsub(rest, '^%s*"?', ''), '"?%s*$', '')
         local v = string.lower(verb)
         if v == "says" or v == "say" or v == "asks" or v == "ask" or
            v == "exclaims" or v == "exclaim" or v == "transmits" or v == "transmit" then
           display_message = speaker .. ": " .. unquoted
         else
           display_message = speaker .. " " .. verb .. ": " .. unquoted
         end
       end
     end
     print_color({"[" .. channel_name .. "] ", "default"}, {display_message, "priv_comm"})

   elseif detected_courier and channel_name == detected_courier then
     -- This is our courier company
     mplay("comm/courier", "communication")
     channel(name, "%0", {"courier", "communication"})

     -- Apply shortening
     local display_message = message
     if config:get_option("shorten_communication").value == "yes" then
       local speaker, verb, rest = string.match(message, '^(.-)%s+(%a+),%s*(.+)$')
       if speaker and verb and rest then
         local unquoted = string.gsub(string.gsub(rest, '^%s*"?', ''), '"?%s*$', '')
         local v = string.lower(verb)
         if v == "says" or v == "say" or v == "asks" or v == "ask" or
            v == "exclaims" or v == "exclaim" or v == "transmits" or v == "transmit" then
           display_message = speaker .. ": " .. unquoted
         else
           display_message = speaker .. " " .. verb .. ": " .. unquoted
         end
       end
     end
     print_color({"[" .. channel_name .. "] ", "default"}, {display_message, "priv_comm"})
   else
     -- Not our org or courier, just print original
     print("%0")
   end
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^\[.+?\] .+ transmits an exciting burst of static"
   regexp="y"
   send_to="12"
   sequence="50"
   keep_evaluating="y"
  >
  <send>mplay("comm/static", "communication")</send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^.+ yawns suddenly and collapses to the ground, asleep\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
    -- Pick random yawn from social directories
    local yawn_sounds = {"social/male/yawn", "social/female/yawn1", "social/female/yawn2", "social/female/YAWN3"}
    mplay(yawn_sounds[math.random(#yawn_sounds)], "communication")
    mplay("social/neuter/collapse" .. math.random(1,3), "communication")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^.+ suddenly awakens\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
    mplay("misc/wake_up", "communication")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^A.+ sanitation drone arrives\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
    mplay("misc/sanin", "communication")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="comm"
   match="^A.+ sanitation drone goes .+\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
    mplay("misc/sanout", "communication")
  </send>
  </trigger>

</triggers>

]=])