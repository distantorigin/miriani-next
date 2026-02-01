
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="market"
match="^\[Tradesman Market\] ([A-Z][a-z]+) ([A-Z][a-zA-Z]*?) has commenced a sale\. (?:She|He) is selling (one|\d+) tradesman item (certificate|certificates) for ((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d{2})?) credits\s?(a piece)?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
<send>
 mplay ("misc/tradesmanSale", "notification")
 print_color ({"[Tradesman Market] ", "default"}, {"New Sale by %1 %2: %3 %4 for %5 credits.", "market"})
 channel ("market", "[Tradesman Market] New Sale by %1 %2: %3 %4 for %5 credits.", {"market"})
</send>
  </trigger>

  <trigger
   enabled="y"
   group="market"
match="^\[Tradesman Market\]\s+([A-Z][a-z]+(?:\s+(?:Mc)?[A-Z][a-z]+))\s+has\s+(lowered|raised)\s+the\s+price\s+of\s+(his|her)\s+sale\s+from\s+((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d{2})?)\s+credits\s+to\s+((?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d{2})?)\s+credits\s+per\s+certificate\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("misc/tradesmanPrice", "notification")
local v1 = tonumber((string.gsub("%4", ",", "")))
local v2 = tonumber((string.gsub("%5", ",", "")))
local diff = 0

  if v1 and v2 then
if "%2" == "lowered" then
  diff = v1 - v2
else
  diff = v2 - v1
end
    end


   local line = "%1 %2 %3 sale by "..diff.." credits. Price: %5"
print_color ({"[Tradesman Market] ", "default"}, {line, "market"})
   --channel ("market", line, {"market"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="market"
match="^\[Tradesman Market\]\s+[A-Z][a-z]+\s+(?:Mc)?[A-Z][a-z]+'s\s+(?:has\s+canceled\s+(?:his|her)\s+sale|sale\s+has\s+completed)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   channel("market", "%0", {"market"})
   mplay ("misc/tradesmanComplete", "notification")
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="market"
match="^\[Tradesman Market\]\s+(?:[A-Z][a-z]+\s+(?:Mc)?[A-Z][a-z]+)\s+has\s+bought\s+.+?\s+tradesman\s+certificates?\s+from\s+(?:[A-Z][a-z]+\s+(?:Mc)?[A-Z][a-z]+)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>
   channel("market", "%0", {"market"})
   mplay ("misc/tradesmanBid", "notification")
  </send>
  </trigger>

</triggers>
]=])