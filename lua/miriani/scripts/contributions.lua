-- @module contributions
-- Tracks credit contributions received on starships
-- Similar to VIP MUD's contribution system

-- Author: Claude Code
-- Reviewed by: Distantorigin

---------------------------------------------

-- Initialize contributions storage
if not contributions then
  contributions = {}
end

-- Helper function to format credits with proper decimal placement
local function format_credits(amount)
  return string.format("%.2f", amount)
end

-- Helper function to add large numbers (for credit amounts)
local function add_credits(a, b)
  local num_a = tonumber(a) or 0
  local num_b = tonumber(b) or 0
  return num_a + num_b
end

-- Function to handle receiving a contribution
function receive_contribution(name, line, wildcards, styles)
  local amount = wildcards[1]
  local contributor = wildcards[2]

  -- Strip commas from amount
  local clean_amount = amount:gsub(",", "")

  -- Initialize contributor data if new
  if not contributions[contributor] then
    contributions[contributor] = {
      times = 0,
      total = 0,
      history = {}
    }
  end

  -- Update contribution data
  local contrib = contributions[contributor]
  contrib.times = contrib.times + 1
  contrib.total = add_credits(contrib.total, clean_amount)
  table.insert(contrib.history, clean_amount)

  -- Play sound
  mplay("misc/cash")

  -- Also send to contributions buffer
  Execute("history_add Contributions=" .. line)
end

-- Function to display contributions
function show_contributions(name, line, wildcards, styles)
  local arg = wildcards[1] or ""

  -- Check if we should clear
  if arg:lower() == "clear" then
    contributions = {}
    Note("Contribution data cleared.")
    return
  end

  -- Check if we have any contributions
  local count = 0
  for _ in pairs(contributions) do
    count = count + 1
  end

  if count == 0 then
    Note("You have received no contributions since last reset.")
    return
  end

  -- Build sorted list of contributors
  local sorted = {}
  for name, data in pairs(contributions) do
    table.insert(sorted, {
      name = name,
      total = data.total,
      times = data.times
    })
  end

  -- Sort by total amount (highest first)
  table.sort(sorted, function(a, b)
    return a.total > b.total
  end)

  -- Display header
  Note("Contributions received:")
  Note(string.rep("-", 60))

  -- Display each contributor
  local grand_total = 0
  for _, contrib in ipairs(sorted) do
    local formatted_total = format_credits(contrib.total)
    local times_text = contrib.times == 1 and "time" or "times"
    Note(string.format("%s: %s credits (%d %s)",
      contrib.name,
      formatted_total,
      contrib.times,
      times_text))
    grand_total = add_credits(grand_total, contrib.total)
  end

  Note(string.rep("-", 60))
  Note(string.format("Total contributions: %s credits", format_credits(grand_total)))
  Note(string.rep("-", 60))
  Note("Use CONTRIBS CLEAR to reset.")
end


-- Import triggers and alias
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   script="receive_contribution"
   group="contributions"
   match="^You have received a contribution of ([0-9,.]+) credits? from (.+)\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   group="contributions"
   match="^You contribute ([0-9,.]+) credits? to the owner of the ship\.$"
   regexp="y"
   send_to="12"
   sequence="100"
  >
  <send>mplay("misc/discardCash")</send>
  </trigger>
</triggers>
]=])

ImportXML([=[
<aliases>
  <alias
   enabled="y"
   script="show_contributions"
   match="^contribs$"
   regexp="y"
   ignore_case="y"
   send_to="12"
  >
  </alias>
  <alias
   enabled="y"
   script="show_contributions"
   match="^contribs (.+)$"
   regexp="y"
   ignore_case="y"
   send_to="12"
  >
  </alias>
</aliases>
]=])
