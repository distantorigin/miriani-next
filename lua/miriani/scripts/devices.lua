-- @module devices
-- Device sounds and notifications

-- Sector name to number mapping table (from VIP Mud soundpack)
sector_numbers = {
  ["Central Jumpgate Hub"] = 0,
  ["Satus"] = 1,
  ["Ono"] = 2,
  ["Harboria"] = 3,
  ["Savius"] = 4,
  ["Stallax"] = 5,
  ["Ascension"] = 6,
  ["Narth Polus"] = 7,
  ["Intrepid"] = 8,
  ["Autumn"] = 9,
  ["Shivaldi"] = 10,
  ["Universal End"] = 11,
  ["Bellerophon"] = 12,
  ["Triskaideka"] = 13,
  ["Interlition"] = 14,
  ["Miriani"] = 15,
  ["Expedocious"] = 16,
  ["Groombridge"] = 17,
  ["Omnivincere"] = 18,
  ["Venitia"] = 19,
  ["Tartarus"] = 20,
  ["Solaris"] = 21,
  ["Barnard's Star"] = 22,
  ["Apophyllite"] = 23,
  ["Alliance High Guard Command"] = 24,
  ["Pegasus"] = 25,
  ["Polaris"] = 26,
  ["Ophiuchus"] = 27,
  ["Kerensky"] = 28,
  ["Malta"] = 29,
  ["Outreach"] = 30,
  ["Porta"] = 31,
  ["Infinitus Astrum"] = 32,
  ["Adaukerisicka"] = 33,
  ["Strages"] = 34,
  ["Casus"] = 35,
  ["Dombrowski"] = 36,
  ["Perspicuus Astrum"] = 37,
  ["Lacuna"] = 38,
  ["Lucksburg"] = 39,
  ["Vetus Fragminis"] = 40,
  ["Omega Sector"] = 115,
}

ImportXML([=[
<triggers>

  <trigger
   enabled="y"
   name="MessageBoardNewMessage"
   group="devices"
   match="^A.+message board reader beeps quietly, indicating to you that there is a new message.+\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/newPost")</send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardToggle"
   group="devices"
   match="^A.+message board reader will (now|no longer) notify you of new messages\.$"
   regexp="y"
   send_to="12"
  >
  <send>if "%1" == "now" then
    mplay("miriani/device/activate")
  else
    mplay("miriani/device/deactivate")
  end
  </send>
  </trigger>

  <trigger
   enabled="y"
   name="MessageBoardUnreadPosts"
   group="devices"
   match="^(There are new messages in.+\.|A.+message board reader beeps urgently, notifying you that there are new messages in .+\.)$"
   regexp="y"
   send_to="12"
  >
  <send>play("miriani/device/UnreadPosts.ogg")</send>
  </trigger>

  <trigger
   enabled="y"
   name="FlightControlScanner"
   group="devices"
   match="^(?:A|From).* flight control scanner \w+, &quot;(.+?)&quot;$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   local scanner_name = GetVariable("fc_scanner_name") or "flight control"
   local message = "%1"
 
   local clean_message = message:gsub("^A .+flight control scanner.+announces, ", ""):gsub("^From .* flight control scanner .*, ", "")

   -- If fc_sector_numbers option is enabled, substitute sector names with numbers
   if config:get_option("fc_sector_numbers").value == "yes" then
     -- Try to find and replace sector names with numbers
     for sector_name, sector_num in pairs(sector_numbers) do
       -- Pattern 1: "Flight control in [sector name]"
       clean_message = clean_message:gsub("Flight control in " .. sector_name, "Flight control in Sector " .. sector_num)
       -- Pattern 2: "[ship] to [sector name] flight control"
       clean_message = clean_message:gsub("to " .. sector_name .. " flight control", "to sector " .. sector_num .. " flight control")
     end
   end

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
   match="^.+ beeps quietly, indicating that there (is|are) (new files|a new file) to import\.$"
   regexp="y"
   send_to="12"
  >
  <send>mplay("device/lore/import")</send>
  </trigger>
</triggers>
]=])
