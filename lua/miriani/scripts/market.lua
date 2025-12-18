
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   group="market"
   match="^\[Tradesman Market\] ([A-Z][a-z]+? [A-Z][a-z]+?) has commenced a sale\. [SsHhe]{2,3} is selling (\w+?) tradesman item (certificates?) for ([0-9,]+[.0-9]{3}) credits\s?(a piece)?\.$"
   regexp="y"
   omit_from_output="y"
   send_to="14"
   sequence="100"
  >
  <send>
   mplay ("misc/tradesmanSale", "notification")
   print_color ({"[Tradesman Market] ", "default"}, {"New Sale by %1: %2 %3 for %4 credits.", "market"})
   channel ("market", "[Tradesman Market] New Sale by %1: %2 %3 for %4 credits.", {"market"})
  </send>
  </trigger>

  <trigger
   enabled="y"
   group="market"
   match="^\[Tradesman Market\] ([A-Z][a-z]+ [A-Z][a-z]+?) has (lowered|raised) the price of ([ehisr]{3}) sale from ([0-9,]+[.0-9]{3}) credits to ([0-9,]+[.0-9]{3}) credits per certificate\.$"
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
   match="^\[Tradesman Market\] [A-Z][a-z]+ [A-Z][a-z]+'?s? (?:has canceled \w+ sale|sale has completed)\.$"
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
   match="^\[Tradesman Market\] [A-Z][a-z]+ [A-Z][a-z]+ has bought .+? tradesman certificates? from [A-Z][a-z]+ [A-Z][a-z]+\.$"
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