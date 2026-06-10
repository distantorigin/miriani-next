-- @module stellar_surge
-- Stellar Surge game

local START_SPEED = 2.3
local MIN_SPEED = 0.62
local SPEED_DECAY = 0.04
local BASE_POINTS = 10
local COMBO_BONUS = 5
local BASE_ROUND_DELAY = 0.4
local FRENZY_THRESHOLD = 8
local FRENZY_SLOW_REACTION = 0.6
local HIT_DAMAGE = 25
local MAX_ABLATIVE = 4
local REPAIR_ACTION_AMOUNT = 14
local SCORE_VARIABLE = "stellar_surge_high_score"
local LEVEL_VARIABLE = "stellar_surge_level"
local XP_VARIABLE = "stellar_surge_xp"
local RUNS_VARIABLE = "stellar_surge_runs"
local LEVEL_CAP = 30
local socket_ok, socket = pcall(require, "socket")

local game_active = false
local score = 0
local hull = 0
local ablative = 0
local combo = 0
local best_combo = 0
local round = 0
local current_action = nil
local awaiting_input = false
local round_id = 0
local round_start_time = nil
local current_speed_level = nil
local frenzy_active = false
local active_event = nil
local next_event_round = nil
local last_event_name = nil
local last_action_key = nil
local repeated_action_count = 0
local game_token = 0

local actions = {
  {
    key = "s",
    label = "S",
    name = "Shield!",
    role = "defense",
    command_sounds = {
      "ship/alarm/redStart1", "ship/alarm/redStart2",
      "ship/combat/reflector1", "ship/combat/reflector2",
      "ship/combat/reflector3", "ship/combat/deflected",
    },
    hit_sounds = {
      {"ship/combat/deflected", "ship/combat/reflector1"},
      {"ship/combat/reflector2", "ship/combat/deflected"},
      {"ship/combat/reflector3", "ship/combat/reflector1"},
      {"ship/combat/deflected", "ship/misc/repair1"},
    },
  },
  {
    key = "d",
    label = "D",
    name = "Dodge!",
    role = "evasion",
    command_sounds = {
      "ship/combat/hit/sectorHit1", "ship/combat/hit/sectorHit3",
      "ship/combat/hit/sectorHit5", "ship/combat/prox/proxLaunch1",
      "ship/combat/prox/proxLaunch2", "ship/combat/prox/proxLaunch3",
    },
    hit_sounds = {
      {"ship/move/accelerate1", "ship/move/slip"},
      {"ship/move/accelerate2", "ship/move/flash"},
      {"ship/move/accelerate3", "ship/move/wavewarp"},
      {"ship/move/slip", "ship/combat/reflector2"},
    },
  },
  {
    key = "f",
    label = "F",
    name = "Fire!",
    role = "attack",
    command_sounds = {
      "ship/combat/laser1", "ship/combat/laser5", "ship/combat/laser12",
      "ship/combat/laser20", "ship/combat/laser25", "ship/combat/laser31",
      "ship/combat/cannon1", "ship/combat/cannon3", "ship/combat/cannon5",
    },
    hit_sounds = {
      {"ship/combat/hit/otherHit1", "ship/combat/destroy/targetDestroyed1"},
      {"ship/combat/hit/otherHit2", "ship/combat/destroy/targetDestroyed3"},
      {"ship/combat/hit/otherHit3", "ship/combat/destroy/targetDestroyed5"},
      {"ship/combat/hit/otherHit5", "ship/combat/destroy/targetDestroyed7"},
      {"ship/combat/cannon7", "ship/combat/destroy/targetDestroyed10"},
    },
  },
  {
    key = "Space",
    label = "Space",
    name = "Nuke!",
    role = "attack",
    command_sounds = {
      "ship/combat/aim", "ship/combat/pulse/lock1",
      "ship/combat/pulse/lock2", "ship/combat/targetLocked",
      "ship/combat/secondaryLock",
    },
    hit_sounds = {
      {"ship/combat/cannon9", "ship/combat/destroy/targetDestroyed10", "ship/combat/destroy/youDestroy1"},
      {"ship/combat/cannon7", "ship/combat/destroy/targetDestroyed9", "ship/combat/destroy/blockadeDestroyed"},
      {"ship/combat/cannon5", "ship/combat/destroy/targetDestroyed7", "ship/combat/destroy/youDestroy2"},
      {"ship/combat/laser31", "ship/combat/destroy/targetDestroyed5", "ship/combat/destroy/targetDestroyed1"},
    },
  },
  {
    key = "r",
    label = "R",
    name = "Repair!",
    role = "repair",
    repairs_hull = true,
    command_sounds = {
      "ship/combat/componentCritical", "ship/computer/warning1",
      "ship/misc/lowCharge", "ship/computer/noDamage",
      "ship/misc/repair1",
    },
    hit_sounds = {
      {"ship/misc/repair1", "ship/misc/repair4"},
      {"ship/misc/repair2", "ship/misc/repair5"},
      {"ship/misc/repair3", "ship/misc/repair6"},
      {"ship/misc/repair8", "ship/misc/repair7"},
    },
  },
}

local action_by_key = {}
for _, a in ipairs(actions) do
  action_by_key[a.key] = a
end

local wrong_sounds = {
  {"ship/combat/hit/youHit1", "ship/combat/internal"},
  {"ship/combat/hit/youHit2", "ship/combat/componentCritical"},
  {"ship/combat/hit/youHit3", "ship/alarm/criticalHull"},
  {"ship/combat/hit/youHit5", "ship/combat/hullCritical"},
  {"ship/combat/hit/youHit6", "ship/alarm/hullCompromise"},
  {"ship/combat/hit/youHit7", "ship/combat/internal"},
}

local timeout_sounds = {
  {"ship/combat/componentCritical", "ship/alarm/redStart1"},
  {"ship/combat/internal", "ship/alarm/redStart2"},
  {"ship/alarm/criticalHull", "ship/combat/hit/youHit4"},
}

local chaos_sounds = {
  "ship/alarm/blue1", "ship/alarm/blue2",
  "ship/alarm/purple1", "ship/alarm/purple2",
  "ship/alarm/green1", "ship/alarm/green2",
  "combat/praelor/shriekHere1", "combat/praelor/shriekHere2",
  "ship/misc/creak1", "ship/misc/creak3", "ship/misc/creak5",
  "ship/computer/warning1", "ship/computer/warning2", "ship/computer/warning3",
  "ship/computer/error", "ship/misc/clang",
  "combat/praelor/wallCry",
  "ship/combat/laser12", "ship/combat/laser20",
  "ship/combat/hit/sectorHit2", "ship/combat/hit/sectorHit4",
}

local speed_levels = {
  {min_round = 1,  name = "Sublight"},
  {min_round = 8,  name = "Impulse"},
  {min_round = 16, name = "Warp"},
  {min_round = 26, name = "Transwarp"},
  {min_round = 38, name = "Ludicrous"},
  {min_round = 52, name = "Overdrive"},
  {min_round = 70, name = "Singularity"},
}

local surge_events = {
  {
    name = "Clear vector",
    voice = "Clear vector.",
    sound = "ship/computer/inRange",
    time_bonus = 0.35,
    score_multiplier = 1.10,
    favored_keys = {"d", "f"},
    action_bias = 65,
  },
  {
    name = "Engineering window",
    voice = "Engineering window.",
    sound = "ship/misc/repair4",
    time_bonus = 0.15,
    repair_bonus = 8,
    favored_keys = {"r", "s"},
    action_bias = 70,
  },
  {
    name = "Shield harmonic",
    voice = "Shield harmonic.",
    sound = "ship/combat/reflector2",
    armor_bonus = 1,
    favored_keys = {"s"},
    action_bias = 80,
  },
  {
    name = "Solar flare",
    voice = "Solar flare.",
    sound = "ship/computer/warning2",
    time_bonus = -0.14,
    score_multiplier = 1.25,
    favored_keys = {"s", "d"},
    action_bias = 70,
    chaos = true,
    silent_command = true,
  },
  {
    name = "Target lock",
    voice = "Target lock.",
    sound = "ship/combat/targetLocked",
    time_bonus = -0.05,
    score_multiplier = 1.20,
    favored_keys = {"f", "Space"},
    action_bias = 72,
    miss_costs_armor = true,
  },
  {
    name = "Missile swarm",
    voice = "Missile swarm.",
    sound = "ship/combat/prox/proxLaunch2",
    time_bonus = -0.16,
    score_multiplier = 1.30,
    favored_keys = {"d", "s"},
    action_bias = 75,
    chaos = true,
    double_prompt = true,
  },
  {
    name = "Coolant leak",
    voice = "Coolant leak.",
    sound = "ship/misc/lowCharge",
    time_bonus = 0.05,
    repair_bonus = 5,
    favored_keys = {"r", "s"},
    action_bias = 68,
  },
}

local function say(text)
  speech_interrupt(text)
end

local function random_pick(tbl)
  return tbl[math.random(#tbl)]
end

local function weighted_pick(candidates)
  local total = 0
  for _, candidate in ipairs(candidates) do
    total = total + candidate.weight
  end

  local roll = math.random() * total
  for _, candidate in ipairs(candidates) do
    roll = roll - candidate.weight
    if roll <= 0 then return candidate.value end
  end

  return candidates[#candidates].value
end

local function now()
  if socket_ok and socket and socket.gettime then
    return socket.gettime()
  end
  return os.time()
end

local MUSIC_GROUP = "stellar_surge_music"

local function schedule_token(delay, code)
  DoAfterSpecial(delay, string.format("stellar_surge_run_if_token(%d, %q)", game_token, code), sendto.script)
end

function stellar_surge_run_if_token(expected_token, code)
  if expected_token ~= game_token then return end
  local fn = loadstring(code)
  if fn then fn() end
end

local function music_start()
  mplay("misc/Games/stellar_surge/music", MUSIC_GROUP, true, 0, true, nil, nil, nil, nil, -100)
  fade_group(MUSIC_GROUP, 20, 3000)
end

local function music_stop()
  fade_group(MUSIC_GROUP, 0, 2000)
  schedule_token(2, "stop('" .. MUSIC_GROUP .. "')")
end

local function gsound(name)
  mplay(name, "games", true)
end

local function gsound_layer(name)
  mplay(name, "games", false)
end

local function play_combo(sound_set)
  if type(sound_set) == "string" then
    gsound(sound_set)
    return
  end
  for i, snd in ipairs(sound_set) do
    if i == 1 then
      gsound(snd)
    else
      schedule_token((i - 1) * 0.15, string.format("mplay('%s', 'games', false)", snd))
    end
  end
end

local function get_speed()
  local early_rounds = math.min(round, 60)
  local late_rounds = math.max(0, round - 60)
  return math.max(MIN_SPEED, START_SPEED - early_rounds * SPEED_DECAY - late_rounds * 0.018)
end

local function get_prompt_speed()
  local speed = get_speed()
  if active_event and active_event.time_bonus then
    speed = speed + active_event.time_bonus
  end
  return math.max(MIN_SPEED, speed)
end

local function get_round_delay()
  local base = math.max(0.22, BASE_ROUND_DELAY * (get_speed() / START_SPEED))
  if frenzy_active then base = math.max(0.18, base * 0.75) end
  if active_event and active_event.chaos then base = math.max(0.18, base * 0.85) end
  return base
end

local function get_action_count()
  if round < 8 then return 3 end
  if round < 20 then return 4 end
  return 5
end

local function get_speed_level()
  local level = speed_levels[1]
  for _, l in ipairs(speed_levels) do
    if round >= l.min_round then level = l end
  end
  return level
end

local function show_status()
  -- Combo and frenzy only. Hull is announced explicitly when damage is taken;
  -- ablative is announced when gained/spent. Neither needs round-by-round TTS.
  local parts = {}
  if combo > 1 then table.insert(parts, "Combo: x" .. combo) end
  if frenzy_active then table.insert(parts, "FRENZY") end
  if #parts > 0 then Note(table.concat(parts, " | ")) end
end

local function repair_hull(amount)
  if hull <= 0 then return 0 end
  local before = hull
  hull = math.max(0, hull - amount)
  return before - hull
end

local function fire_chaos_sound()
  if game_active then gsound_layer(random_pick(chaos_sounds)) end
end

local function check_frenzy()
  -- Gain-only: combo-drop / slow-reaction / miss handlers explicitly clear frenzy_active.
  if not frenzy_active and combo >= FRENZY_THRESHOLD then
    frenzy_active = true
    say("Frenzy!")
    gsound_layer("ship/alarm/redStart1")
    schedule_token(0.2, "mplay('ship/alarm/redStart2', 'games', false)")
    schedule_token(0.5, "stellar_surge_chaos_pulse()")
  end
end

local hooked_keys = {}

local function bind_game_keys()
  for i = 1, get_action_count() do
    local a = actions[i]
    if not hooked_keys[a.key] then
      AcceleratorTo(a.key,
        string.format("stellar_surge_key_pressed('%s')", a.key),
        sendto.script)
      hooked_keys[a.key] = true
    end
  end
end

local function unbind_game_keys()
  for key in pairs(hooked_keys) do
    Accelerator(key, "")
  end
  hooked_keys = {}
end

local ablative_combos = {[18] = true, [30] = true, [45] = true, [60] = true}

local function maybe_award_ablative()
  if ablative >= MAX_ABLATIVE then return nil end
  if ablative_combos[combo] then
    ablative = ablative + 1
    gsound_layer("ship/misc/repair5")
    return "Ablative armor. " .. ablative .. " layer" .. (ablative > 1 and "s" or "") .. "."
  end
  if round > 35 and math.random(25) == 1 then
    ablative = ablative + 1
    gsound_layer("ship/misc/repair3")
    return "Ablative pickup."
  end
  return nil
end

local function schedule_next_event()
  if round < 10 then
    next_event_round = math.random(12, 16)
    return
  end

  local gap = math.random(5, 9)
  if frenzy_active then gap = math.random(4, 7) end
  next_event_round = round + gap
end

local function apply_event_rewards()
  if not active_event then return nil end

  local messages = {}
  if active_event.repair_bonus then
    repair_hull(active_event.repair_bonus)
  end

  if active_event.armor_bonus and ablative < MAX_ABLATIVE then
    ablative = math.min(MAX_ABLATIVE, ablative + active_event.armor_bonus)
    table.insert(messages, "Ablative " .. ablative)
  end

  if #messages == 0 then return nil end
  return table.concat(messages, ". ") .. "."
end

local function maybe_start_event()
  active_event = nil
  if not next_event_round then schedule_next_event() end
  if round < next_event_round then return false end

  for _ = 1, 6 do
    active_event = random_pick(surge_events)
    if active_event.name ~= last_event_name then break end
  end
  last_event_name = active_event.name
  schedule_next_event()
  Note(">> " .. active_event.name .. " <<")
  say(active_event.voice)
  if active_event.sound then gsound_layer(active_event.sound) end
  if active_event.chaos then schedule_token(0.25, "stellar_surge_chaos_layer()") end
  return true
end

local function choose_action()
  local action_count = get_action_count()
  local action = nil

  if active_event and active_event.favored_keys and math.random(100) <= (active_event.action_bias or 60) then
    local candidates = {}
    for _, key in ipairs(active_event.favored_keys) do
      local favored = action_by_key[key]
      for i = 1, action_count do
        if actions[i] == favored then
          table.insert(candidates, {value = favored, weight = repeated_action_count >= 2 and favored.key == last_action_key and 1 or 5})
          break
        end
      end
    end
    if #candidates > 0 then action = weighted_pick(candidates) end
  end

  for _ = 1, 8 do
    if not action then action = actions[math.random(action_count)] end
    if repeated_action_count < 2 or action.key ~= last_action_key then break end
    action = nil
  end

  if not action then action = actions[math.random(action_count)] end

  if action.key == last_action_key then
    repeated_action_count = repeated_action_count + 1
  else
    last_action_key = action.key
    repeated_action_count = 1
  end

  return action
end

local function take_damage()
  if ablative > 0 then
    ablative = ablative - 1
    gsound("ship/combat/deflected")
    schedule_token(0.15, "mplay('ship/combat/reflector1', 'games', false)")
    say("Ablative hit.")
    return false, true
  end
  hull = math.min(100, hull + HIT_DAMAGE)
  return hull >= 100, false
end

local function handle_correct()
  awaiting_input = false
  combo = combo + 1
  if combo > best_combo then best_combo = combo end

  local reaction = round_start_time and (now() - round_start_time) or nil
  local speed_bonus = 0
  if reaction then
    if reaction < 0.25 then speed_bonus = 30
    elseif reaction < 0.5 then speed_bonus = 15
    elseif reaction < 0.8 then speed_bonus = 5
    end
  end

  local points = BASE_POINTS + (combo - 1) * COMBO_BONUS + speed_bonus
  if frenzy_active then points = math.floor(points * 1.5) end
  if active_event and active_event.score_multiplier then
    points = math.floor(points * active_event.score_multiplier)
  end
  score = score + points

  play_combo(random_pick(current_action.hit_sounds))

  local reward_messages = {}
  if current_action.repairs_hull then
    repair_hull(REPAIR_ACTION_AMOUNT)
  end

  local event_message = apply_event_rewards()
  if event_message then table.insert(reward_messages, event_message) end
  local was_double_prompt = active_event and active_event.double_prompt
  active_event = nil

  if frenzy_active and math.random(2) == 1 then
    schedule_token(0.3, "stellar_surge_chaos_layer()")
  end

  -- Frenzy is easy to enter but harder to maintain: a slow reaction breaks it.
  -- Skip check_frenzy on that round so we don't say "Frenzy!" right after "Frenzy broken."
  local frenzy_broken = frenzy_active and reaction and reaction > FRENZY_SLOW_REACTION
  if frenzy_broken then
    frenzy_active = false
    table.insert(reward_messages, "Frenzy broken.")
  else
    check_frenzy()
  end
  local armor_message = maybe_award_ablative()
  if armor_message then table.insert(reward_messages, armor_message) end

  show_status()
  if #reward_messages > 0 then say(table.concat(reward_messages, " "))
  elseif combo == 5 then say("Nice streak.")
  elseif combo == 20 then say("Unstoppable.")
  elseif combo == 30 then say("Inhuman.")
  elseif speed_bonus >= 25 then say("Fast. Plus " .. speed_bonus .. ".")
  end

  -- Missile swarm chains a second prompt with almost no gap
  local next_delay = was_double_prompt and 0.25 or get_round_delay()
  schedule_token(next_delay, "stellar_surge_next_round()")
end

local function handle_wrong()
  awaiting_input = false

  -- Target Lock event: a miss costs one ablative layer instead of breaking the combo
  if active_event and active_event.miss_costs_armor and ablative > 0 then
    ablative = ablative - 1
    gsound("ship/combat/deflected")
    schedule_token(0.15, "mplay('ship/combat/reflector1', 'games', false)")
    active_event = nil
    show_status()
    say("Lock broken. Combo held.")
    schedule_token(0.7, "stellar_surge_next_round()")
    return
  end

  local had_frenzy = frenzy_active
  combo = 0
  frenzy_active = false
  active_event = nil

  local dead, absorbed = take_damage()

  if not dead then
    play_combo(random_pick(wrong_sounds))
  end

  if had_frenzy then
    schedule_token(0.3, "mplay('ship/computer/error', 'games', false)")
  end

  if dead then
    stellar_surge_game_over()
  else
    show_status()
    if not absorbed then say(string.format("Miss. Hull %d percent.", hull)) end
    schedule_token(0.55, "stellar_surge_next_round()")
  end
end

local function normalize_input(input)
  input = string.lower(input or "")
  input = string.gsub(input, "^%s+", "")
  input = string.gsub(input, "%s+$", "")

  if input == " " or input == "space" or input == "sp" then return "Space" end
  if input == "esc" or input == "escape" then return "Escape" end
  if input == "shield" then return "s" end
  if input == "dodge" then return "d" end
  if input == "fire" then return "f" end
  if input == "nuke" then return "Space" end
  if input == "repair" then return "r" end
  if action_by_key[input] then return input end
  return nil
end

local function xp_to_next_level(level)
  if level >= LEVEL_CAP then return nil end
  return 120 + (level - 1) * 70 + (level - 1) * (level - 1) * 15
end

local function get_saved_progress()
  local level = tonumber(GetVariable(LEVEL_VARIABLE)) or 1
  local xp = tonumber(GetVariable(XP_VARIABLE)) or 0

  level = math.max(1, math.min(LEVEL_CAP, math.floor(level)))
  xp = math.max(0, math.floor(xp))

  return level, xp
end

local function get_progress_title(level)
  if level >= 30 then return "Singularity pilot" end
  if level >= 25 then return "Nova ace" end
  if level >= 20 then return "Overdrive pilot" end
  if level >= 15 then return "Transwarp ace" end
  if level >= 10 then return "Warp runner" end
  if level >= 5 then return "Impulse trainee" end
  return "Cadet"
end

local function get_starting_ablative(level)
  return 0
end

local function get_xp_bonus_percent(level)
  return math.min(20, math.floor((level - 1) / 4) * 3)
end

local function calculate_run_xp(level)
  if score <= 0 or round <= 1 then return 0 end

  local xp = math.floor(score / 30 + round * 5 + best_combo * 8)
  if round >= 8 then xp = xp + 40 end
  if round >= 20 then xp = xp + 90 end
  if best_combo >= FRENZY_THRESHOLD then xp = xp + 35 end

  local bonus = get_xp_bonus_percent(level)
  if bonus > 0 then xp = math.floor(xp * (100 + bonus) / 100) end

  return math.max(20, xp)
end

local function apply_progress()
  local old_level, xp = get_saved_progress()
  local level = old_level
  local earned = calculate_run_xp(level)

  if earned <= 0 then
    return {
      old_level = old_level,
      level = level,
      xp = xp,
      earned = 0,
      gained = 0,
      next_xp = xp_to_next_level(level),
    }
  end

  xp = xp + earned
  local gained = 0
  local needed = xp_to_next_level(level)

  while needed and xp >= needed do
    xp = xp - needed
    level = level + 1
    gained = gained + 1
    needed = xp_to_next_level(level)
  end

  if level >= LEVEL_CAP then
    level = LEVEL_CAP
    xp = 0
  end

  SetVariable(LEVEL_VARIABLE, tostring(level))
  SetVariable(XP_VARIABLE, tostring(xp))
  SetVariable(RUNS_VARIABLE, tostring((tonumber(GetVariable(RUNS_VARIABLE)) or 0) + 1))
  SaveState()

  return {
    old_level = old_level,
    level = level,
    xp = xp,
    earned = earned,
    gained = gained,
    next_xp = xp_to_next_level(level),
  }
end

function stellar_surge_chaos_pulse()
  if not game_active or not frenzy_active then return end
  fire_chaos_sound()
  schedule_token(2.0 + math.random() * 3.0, "stellar_surge_chaos_pulse()")
end

function stellar_surge_chaos_layer()
  if game_active then fire_chaos_sound() end
end

function stellar_surge_game_over()
  game_token = game_token + 1
  game_active = false
  awaiting_input = false
  current_speed_level = nil
  frenzy_active = false
  active_event = nil
  next_event_round = nil
  last_event_name = nil
  ablative = 0
  unbind_game_keys()
  EnableAlias("stellar_surge_input_handler", false)

  music_stop()
  gsound(random_pick({
    "ship/combat/destroy/youDestroy1", "ship/combat/destroy/youDestroy2",
  }))
  schedule_token(0.3, "mplay('ship/alarm/criticalHull', 'games', false)")
  schedule_token(0.6, "mplay('ship/move/disablePower3', 'games', false)")

  local high = tonumber(GetVariable(SCORE_VARIABLE)) or 0
  local is_record = score > high and score > 0
  local progress = apply_progress()

  if is_record then
    SetVariable(SCORE_VARIABLE, tostring(score))
    SaveState()
  end

  Note("")
  Note("STELLAR SURGE OVER")
  Note(string.format("Score: %d | Rounds: %d | Best combo: x%d", score, round, best_combo))
  Note(string.format("High score: %d%s", math.max(high, score), is_record and " (new!)" or ""))
  if progress.earned > 0 then
    Note(string.format("XP earned: %d", progress.earned))
    if progress.gained > 0 then
      Note(string.format("Level: %d -> %d (%s)",
        progress.old_level, progress.level, get_progress_title(progress.level)))
    elseif progress.next_xp then
      Note(string.format("Level: %d (%d/%d XP)",
        progress.level, progress.xp, progress.next_xp))
    else
      Note(string.format("Level: %d (%s, max)",
        progress.level, get_progress_title(progress.level)))
    end
  end
  Note("")

  if progress.gained > 0 then
    say("Game over. " .. score .. " points. Level " .. progress.level .. ".")
    gsound_layer("ship/misc/chime1")
  else
    say("Game over. " .. score .. " points." .. (is_record and " New record." or ""))
  end
end

function stellar_surge_timeout(expected_id)
  if expected_id ~= round_id then return end
  if not game_active or not awaiting_input then return end
  awaiting_input = false
  local had_frenzy = frenzy_active
  combo = 0
  frenzy_active = false
  active_event = nil

  local dead, absorbed = take_damage()

  if not dead then
    play_combo(random_pick(timeout_sounds))
  end

  if had_frenzy then
    schedule_token(0.2, "mplay('ship/computer/error', 'games', false)")
  end

  if dead then
    stellar_surge_game_over()
  else
    show_status()
    if not absorbed then say(string.format("Too slow. Hull %d percent.", hull)) end
    schedule_token(0.55, "stellar_surge_next_round()")
  end
end

function stellar_surge_next_round()
  if not game_active then return end
  round = round + 1

  local new_level = get_speed_level()
  if new_level ~= current_speed_level then
    current_speed_level = new_level
    if round > 1 then
      say(new_level.name .. " speed.")
      gsound(random_pick({
        "ship/move/accelerate1", "ship/move/accelerate2", "ship/move/accelerate3",
      }))
      if new_level.min_round >= 24 then fire_chaos_sound() end
      schedule_token(1.15, "stellar_surge_next_round_continue()")
      return
    end
  end

  stellar_surge_next_round_continue()
end

function stellar_surge_next_round_continue()
  if not game_active then return end

  local unlocks = {[8] = 4, [20] = 5}
  if unlocks[round] then
    local a = actions[unlocks[round]]
    Note(string.format(">> %s unlocked [%s] <<", a.name, a.label))
    say(a.name .. " unlocked. " .. a.label .. ".")
    bind_game_keys()
    gsound("ship/computer/announce10")
    schedule_token(1.4, "stellar_surge_issue_command()")
    return
  end

  if maybe_start_event() then
    schedule_token(0.75, "stellar_surge_issue_command()")
    return
  end

  stellar_surge_issue_command()
end

function stellar_surge_issue_command()
  if not game_active then return end

  current_action = choose_action()
  awaiting_input = true
  round_start_time = now()
  round_id = round_id + 1

  gsound(random_pick(current_action.command_sounds))
  if frenzy_active then
    schedule_token(0.1, string.format("mplay('%s', 'games', false)",
      random_pick(current_action.command_sounds)))
  end
  -- Solar flare: sound only, no TTS callout (forces sound-only recognition)
  if not (active_event and active_event.silent_command) then
    say(current_action.name)
  end

  if frenzy_active and math.random(3) == 1 then
    schedule_token(0.15, "stellar_surge_chaos_layer()")
  end

  schedule_token(get_prompt_speed(), string.format("stellar_surge_timeout(%d)", round_id))
end

function stellar_surge_countdown_3()
  if not game_active then return end
  say("3")
  gsound(random_pick({"misc/beep/beep1", "misc/beep/beep3", "misc/beep/beep5"}))
  schedule_token(1.0, "stellar_surge_countdown_2()")
end

function stellar_surge_countdown_2()
  if not game_active then return end
  say("2")
  gsound(random_pick({"misc/beep/beep1", "misc/beep/beep3", "misc/beep/beep5"}))
  schedule_token(1.0, "stellar_surge_countdown_1()")
end

function stellar_surge_countdown_1()
  if not game_active then return end
  say("1")
  gsound(random_pick({"misc/beep/beep1", "misc/beep/beep3", "misc/beep/beep5"}))
  schedule_token(1.0, "stellar_surge_go()")
end

function stellar_surge_go()
  if not game_active then return end
  say("Go!")
  gsound(random_pick({"ship/move/enablePower1", "ship/move/enablePower2", "ship/move/enablePower3"}))
  gsound_layer("ship/combat/laser1")
  schedule_token(0.15, "mplay('ship/combat/cannon1', 'games', false)")
  schedule_token(0.8, "stellar_surge_next_round()")
end

function stellar_surge_key_pressed(key)
  if game_active and key == "Escape" then
    stellar_surge_game_over()
    return
  end
  if not game_active or not awaiting_input then return end
  if action_by_key[key] == current_action then
    handle_correct()
  else
    handle_wrong()
  end
end

function stellar_surge_handle_input(input)
  if not game_active then return false end
  local key = normalize_input(input)
  if key then
    stellar_surge_key_pressed(key)
    return true
  end
  if input and dialog and dialog.is_active() then
    dialog.handle_input(input)
  end
  return true
end

function stellar_surge_toggle()
  if game_active then
    stellar_surge_game_over()
  else
    stellar_surge_start()
  end
end

function stellar_surge_quit_or_pass()
  if game_active then
    stellar_surge_game_over()
  else
    Send("quit")
  end
end

function stellar_surge_show_progress()
  local level, xp = get_saved_progress()
  local next_xp = xp_to_next_level(level)
  local runs = tonumber(GetVariable(RUNS_VARIABLE)) or 0
  local high = tonumber(GetVariable(SCORE_VARIABLE)) or 0
  local starting_ablative = get_starting_ablative(level)
  local xp_bonus = get_xp_bonus_percent(level)

  Note("")
  Note("STELLAR SURGE PROGRESS")
  Note(string.format("Level: %d - %s", level, get_progress_title(level)))
  if next_xp then
    Note(string.format("XP: %d/%d", xp, next_xp))
  else
    Note("XP: max level")
  end
  Note("Runs: " .. runs)
  Note("High score: " .. high)
  Note("Starting ablative: " .. starting_ablative)
  Note("XP bonus: +" .. xp_bonus .. "%")
  Note("")
end

function stellar_surge_start()
  if game_active then return end

  if dialog and dialog.is_active() then
    Note("Finish the dialog first.")
    return
  end

  game_token = game_token + 1
  game_active = true
  score = 0
  hull = 0
  ablative = 0
  combo = 0
  best_combo = 0
  round = 0
  round_id = round_id + 1
  awaiting_input = false
  current_speed_level = nil
  frenzy_active = false
  active_event = nil
  next_event_round = nil
  last_event_name = nil
  last_action_key = nil
  repeated_action_count = 0

  local pilot_level, pilot_xp = get_saved_progress()
  local starting_ablative = get_starting_ablative(pilot_level)
  ablative = starting_ablative

  bind_game_keys()
  EnableAlias("stellar_surge_input_handler", true)

  local high = tonumber(GetVariable(SCORE_VARIABLE)) or 0

  Note("")
  Note("STELLAR SURGE")
  Note("Each round the game shouts an action; hit its key before the prompt times out.")
  Note("S = Shield | D = Dodge | F = Fire")
  Note("Space = Nuke (unlocks round 8) | R = Repair (unlocks round 20)")
  Note(string.format("Wrong key or timeout: +%d%% hull. 100%% = dead.", HIT_DAMAGE))
  Note(string.format("Hit 18, 30, 45, or 60 in a row to earn ablative armor (max %d layers, each absorbs one hit).", MAX_ABLATIVE))
  Note(string.format("Reach a %d-hit combo for Frenzy: faster pacing, 1.5x points. Breaks if you slow down.", FRENZY_THRESHOLD))
  Note("Surge events shift scoring and timing - some grant repairs or armor, others change the rules.")
  Note("'ssurge help' explains each event.")
  Note(string.format("Level: %d - %s", pilot_level, get_progress_title(pilot_level)))
  local next_xp = xp_to_next_level(pilot_level)
  if next_xp then
    Note(string.format("XP: %d/%d", pilot_xp, next_xp))
  else
    Note("XP: max level")
  end
  if starting_ablative > 0 then
    Note("Starting ablative: " .. starting_ablative)
  end
  local xp_bonus = get_xp_bonus_percent(pilot_level)
  if xp_bonus > 0 then
    Note("XP bonus: +" .. xp_bonus .. "%")
  end
  if high > 0 then
    Note(string.format("High score: %d", high))
  end
  Note("Press Escape or type 'quit' to stop.")
  Note("")

  gsound(random_pick({"ship/computer/announce1", "ship/computer/announce3",
    "ship/computer/announce5", "ship/computer/announce7"}))
  music_start()
  say("Hit the key for whatever action gets called. S shield, D dodge, F fire. Good luck.")
  schedule_token(3.5, "stellar_surge_countdown_3()")
end

function stellar_surge_is_active()
  return game_active
end

function stellar_surge_show_help()
  Note("")
  Note("STELLAR SURGE")
  Note("ssurge - start or stop the game")
  Note("ssurge progress - show level, XP, and high score")
  Note("ssurge help - show this help")
  Note("")
  Note("Controls during a game:")
  Note("S = Shield | D = Dodge | F = Fire")
  Note("Space = Nuke (unlocks round 8)")
  Note("R = Repair (unlocks round 20)")
  Note("Escape or 'quit' = end the game")
  Note("")
  Note("Scoring and survival:")
  Note(string.format("Wrong key or timeout: +%d%% hull. 100%% = dead.", HIT_DAMAGE))
  Note(string.format("Combo at 18, 30, 45, 60 earns ablative armor (max %d, each soaks one hit).", MAX_ABLATIVE))
  Note(string.format("Hit %d in a row for Frenzy: 1.5x points, faster pacing. Breaks if you slow down.", FRENZY_THRESHOLD))
  Note("")
  Note("Surge events:")
  Note("Clear vector / Engineering window / Coolant leak - more time, repairs or armor.")
  Note("Shield harmonic - free armor for hitting Shield.")
  Note("Target lock - a miss costs armor instead of breaking your combo.")
  Note("Solar flare - command sound only, no TTS callout. Listen, don't wait.")
  Note("Missile swarm - two prompts back to back, both must hit.")
  Note("")
end

function stellar_surge_command(arg)
  arg = string.lower(arg or "")
  arg = arg:gsub("^%s+", ""):gsub("%s+$", "")
  if arg == "" then
    stellar_surge_toggle()
  elseif arg == "progress" or arg == "stats" then
    stellar_surge_show_progress()
  elseif arg == "help" or arg == "?" then
    stellar_surge_show_help()
  else
    Note("Unknown ssurge command: " .. arg .. ". Try: ssurge help")
  end
end

ImportXML([=[
<aliases>
  <alias
    enabled="y"
    match="^ssurge(?:\s+(.+))?$"
    ignore_case="y"
    regexp="y"
    send_to="12"
    sequence="100"
  >
  <send>stellar_surge_command("%1")</send>
  </alias>

  <alias
    enabled="y"
    match="^quit$"
    ignore_case="y"
    regexp="y"
    send_to="12"
    sequence="8"
  >
  <send>stellar_surge_quit_or_pass()</send>
  </alias>

  <alias
    name="stellar_surge_input_handler"
    enabled="n"
    match="^(s|d|f|r|space|sp|shield|dodge|fire|nuke|repair|esc|escape)$"
    ignore_case="y"
    regexp="y"
    send_to="12"
    sequence="9"
  >
  <send>stellar_surge_handle_input("%1")</send>
  </alias>
</aliases>
]=])
