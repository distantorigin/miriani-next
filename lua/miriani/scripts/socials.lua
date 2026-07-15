-- Social sound playback.
--
-- Resolution is filesystem-driven: for a given social + gender, we try
-- "social/<gender>/<name>" first, then fall back to "social/neuter/<name>".
-- A candidate stem "wins" only if it resolves to an actual file (main pack,
-- replace theme, or additive theme) via sound_stem_resolves. This means a
-- theme can add male/female variants for a social the main pack only had
-- neuter for, and a neuter-only social plays for every gender.
--
-- Themes may also extend the socials registry via their theme.json:
--   { "socials": { "slurp": { "category": "novelty" } },
--     "social_aliases": { "sip": "slurp" } }
-- The merged view (base + enabled themes) is cached and invalidated whenever
-- a theme is enabled/disabled.

-- Social aliases - map action names to canonical sound file names
local social_aliases = {
  ["slug"] = "punch",
  ["sock"] = "punch",
  ["hit"] = "punch",
  ["pop"] = "punch",
  ["puke"] = "vomit",
  ["barf"] = "vomit",
  ["hurl"] = "vomit",
  ["spew"] = "vomit",
  ["upchuck"] = "vomit",
  ["lurch"] = "vomit",
  ["yak"] = "vomit",
  ["ralph"] = "vomit",
  ["splutter"] = "vomit",
  ["yark"] = "vomit",
  ["splat"] = "vomit",
  ["retch"] = "vomit",
  ["hurf"] = "vomit",
  ["sickup"] = "vomit",
["gfas"] = "grabfriendandshrieklikegirls",
["gfaslg"] = "grabfriendandshrieklikegirls",
["gfs"] = "grabfriendandshrieklikegirls",
["gfslg"] = "grabfriendandshrieklikegirls",
["shiver"] = "cower",
["q"] = "quack",
["scratch"] = "headscratch",
["nosescratch"] = "headscratch",
-- Dance aliases
["boogiewoogie"] = "boogie",
["chwing"] = "chickenwing",
["fish"] = "fishdance",
["hootc"] = "hootchykootchy",
["lam"] = "lambada",
["lamb"] = "lambada",
["mashedpotato"] = "potato",
["square"] = "squaredance",
["timew"] = "timewarp",
}

-- Socials database
--
-- To add a new social:
--   1. Drop sound file(s) into sounds/miriani/social/<gender>/<name>.ogg
--      (gender folder is "male", "female", or "neuter"; pick whichever
--      variants you actually have)
--   2. Add entry below in the appropriate category section (alphabetically)
--
-- Entry format:
--   name = {category = "category_name"},
--
-- Optional fields:
--   sound = "filename"  -- use a different sound-file base than the social name
--                          (e.g. lmao plays rofl.ogg)
--
-- Categories: laughter, distress, reflex, bodily, physical, reaction, novelty, songs, dances
-- (socials without a category will appear under "uncategorized")
--
-- Dances are a special category: they play from sounds/miriani/dances/<name>.ogg
-- with no gender variants.
--
-- Gender is inferred from folder placement, not declared here. A social will
-- play if any of its gender-specific or neuter files exist in the main pack
-- OR any enabled theme.
--
local socials = {
  -- Laughter sounds
  cackle    = {category = "laughter"},
  chortle   = {category = "laughter"},
  chuckle   = {category = "laughter"},
  giggle    = {category = "laughter"},
  laugh     = {category = "laughter"},
  lol       = {category = "laughter"},
  mlaugh    = {category = "laughter"},
  rofl      = {category = "laughter"},
  snicker   = {category = "laughter"},

  -- Distress sounds
  bawl   = {category = "distress"},  
  blubber   = {category = "distress"},  
  cry       = {category = "distress"},
  gasp      = {category = "distress"},
  grunt      = {category = "distress"},
  moan      = {category = "distress"},
  panic   = {category = "distress"},
  screech   = {category = "distress"},
  shriek    = {category = "distress"},
  sniffle   = {category = "distress"},
  sob       = {category = "distress"},
wail      = {category = "distress"},
weep      = {category = "distress"},
whimper      = {category = "distress"},  
whine      = {category = "distress"},  
yelp      = {category = "distress"},
  yowl      = {category = "distress"},

  -- Reflex sounds (involuntary body reflexes)
  blink     = {category = "reflex"},
  choke     = {category = "reflex"},
  cough     = {category = "reflex"},
  eep     = {category = "reflex"},
  gulp      = {category = "reflex"},
  sigh      = {category = "reflex"},
    pant      = {category = "reflex"},
  sneeze    = {category = "reflex"},
  snore     = {category = "reflex"},
  snort     = {category = "reflex"},
  swallow   = {category = "reflex"},
  throatfix = {category = "reflex"},
  yawn      = {category = "reflex"},

  -- Bodily sounds (gross/bodily functions)
  belch     = {category = "bodily"},
  bubble    = {category = "bodily"},
  burp      = {category = "bodily"},
  drool      = {category = "bodily"},
  fart      = {category = "bodily"},
  gag       = {category = "bodily"},
  spit      = {category = "bodily"},
  squish    = {category = "bodily"},
  vomit     = {category = "bodily"},

  -- Physical sounds (movement/contact)
  bap       = {category = "physical"},
  bite      = {category = "physical"},
  bop       = {category = "physical"},
  bounce    = {category = "physical"},
  collapse  = {category = "physical"},
dust      = {category = "physical"},
  fall      = {category = "physical"},
  flap      = {category = "physical"},
  french = {category = "physical", sound = "kiss"},
handshake = {category = "physical"},  
  headscratch = {category = "physical"},  
hop       = {category = "physical"},
jazzhands    = {category = "physical"},  
jig    = {category = "physical"},
  kick      = {category = "physical"},
  kiss      = {category = "physical"},
  knucklecrack = {category = "physical"},
  lean      = {category = "physical"},
  lick      = {category = "physical"},
   makeout = {category = "physical", sound = "kiss"},
  noogie     = {category = "physical"},
   nudge     = {category = "physical"},
  poke      = {category = "physical"},
  pose      = {category = "physical"},
  punch     = {category = "physical"},
  slap      = {category = "physical"},
  smooch = {category = "physical", sound = "kiss"},
  snap      = {category = "physical"},
  snog = {category = "physical", sound = "kiss"},
  smack     = {category = "physical"},
  spank     = {category = "physical"},
  strangle     = {category = "physical"},
  stroke     = {category = "physical"},
  stomp     = {category = "physical"},
  tackle    = {category = "physical"},
  tap  = {category = "physical"},
  tapdance    = {category = "physical"},
  thump     = {category = "physical"},
  twirl    = {category = "physical"},
wink    = {category = "physical"},

  -- Reaction sounds (approval, disapproval, confusion)
  applaud   = {category = "reaction"},
  boggle    = {category = "reaction"},
  boo       = {category = "reaction"},
  bulge       = {category = "reaction"},
  clap      = {category = "reaction"},
  cower     = {category = "reaction"},
  golfclap  = {category = "reaction"},
  headdesk  = {category = "reaction"},
  headshake = {category = "reaction"},
  hi5       = {category = "reaction"},
  mock      = {category = "reaction"},
  oic       = {category = "reaction"},
  oicic     = {category = "reaction"},
  ponder    = {category = "reaction"},
  shrug    = {category = "reaction"},
  squeal    = {category = "reaction"},
  twitch    = {category = "reaction"},
  worship   = {category = "reaction"},

  -- Novelty sounds (animals, musical, memes, misc expressions)
  airguitar = {category = "novelty"},
  bears       = {category = "songs"},
  beep      = {category = "novelty"},
  bongo     = {category = "novelty"},
  bonk      = {category = "novelty"},
  bustamove       = {category = "novelty"},
  cake      = {category = "songs"},
  cheer     = {category = "novelty"},
  devil      = {category = "novelty"},
  duck      = {category = "novelty"},
  fire       = {category = "songs"},
flex  = {category = "novelty"},
flip  = {category = "novelty"},  
flirt  = {category = "novelty"},
  frog      = {category = "novelty"},
  goose      = {category = "novelty"},
  grabfriendandshrieklikegirls      = {category = "novelty"},
  growl     = {category = "novelty"},
  hiss      = {category = "novelty"},
  hoot      = {category = "novelty"},
  horses       = {category = "songs"},
  howl      = {category = "novelty"},
hum    = {category = "novelty"},
  insult  = {category = "novelty"},
  itsatrap  = {category = "novelty"},
  jiggle  = {category = "novelty"},
  khan      = {category = "novelty"},
  mash      = {category = "novelty"},
  moo       = {category = "novelty"},
  noo       = {category = "novelty"},
  oink      = {category = "novelty"},
  orgasm     = {category = "novelty"},
  pimp      = {category = "novelty"},
  pirate    = {category = "songs"},
  pizza       = {category = "songs"},
  please    = {category = "novelty"},
  prance       = {category = "novelty"},
  purr      = {category = "novelty"},
  q         = {category = "novelty"},
  quack     = {category = "novelty"},
  roar      = {category = "novelty"},
  roll      = {category = "novelty"},
  scream    = {category = "novelty"},
  shake      = {category = "novelty"},
  slowclap  = {category = "novelty"},
  snarl     = {category = "novelty"},
  spoon     = {category = "novelty"},
  squeak    = {category = "novelty"},
  whistle   = {category = "novelty"},
  what  = {category = "novelty"},
    why       = {category = "novelty"},
    yess      = {category = "novelty"},
yodel      = {category = "novelty"},

  -- Dances (no gender variants; sounds live in sounds/miriani/dances/)
  boogaloo       = {category = "dances"},
  boogie         = {category = "dances"},
  breakdance     = {category = "dances"},
  bunny          = {category = "dances"},
  chacha         = {category = "dances"},
  charleston     = {category = "dances"},
  chickenwing    = {category = "dances"},
  dip            = {category = "dances"},
  disco          = {category = "dances"},
  eslide         = {category = "dances"},
  fandango       = {category = "dances"},
  fishdance      = {category = "dances"},
  grind          = {category = "dances"},
  hootchykootchy = {category = "dances"},
  jitterbug      = {category = "dances"},
  lambada        = {category = "dances"},
  lindy          = {category = "dances"},
  macarena       = {category = "dances"},
  mambo          = {category = "dances"},
  monkey         = {category = "dances"},
  polka          = {category = "dances"},
  potato         = {category = "dances"},
  rhumba         = {category = "dances"},
  robot          = {category = "dances"},
  salsa          = {category = "dances"},
  squaredance    = {category = "dances"},
  tango          = {category = "dances"},
  timewarp       = {category = "dances"},
  twist          = {category = "dances"},
  waltz          = {category = "dances"},
  worm           = {category = "dances"},
}

-- Merged view over base + enabled themes. Rebuilt lazily on first read,
-- invalidated by refresh_social_registry() (called from themes.lua on
-- enable/disable).
local merged_socials_cache = nil
local merged_aliases_cache = nil

local function build_merged()
  local ms, ma = {}, {}
  for k, v in pairs(socials) do ms[k] = v end
  for k, v in pairs(social_aliases) do ma[k] = v end
  if get_enabled_theme_socials then
    local theme_socials, theme_aliases = get_enabled_theme_socials()
    for k, v in pairs(theme_socials) do ms[k] = v end
    for k, v in pairs(theme_aliases) do ma[k] = v end
  end
  merged_socials_cache = ms
  merged_aliases_cache = ma
end

local function all_socials()
  if not merged_socials_cache then build_merged() end
  return merged_socials_cache
end

local function all_aliases()
  if not merged_aliases_cache then build_merged() end
  return merged_aliases_cache
end

--- Invalidate the merged socials cache and re-sync dynamic config options.
-- Called by themes.lua whenever a theme is enabled or disabled, and once
-- at startup from init.lua after all modules are loaded.
function refresh_social_registry()
  merged_socials_cache = nil
  merged_aliases_cache = nil
  resync_social_options()
end

--- Check if social sounds are globally enabled in config
-- @return boolean
function is_socials_enabled()
  if config and config.get_option then
    local option = config:get_option("social_sounds")
    if option then
      return option.value == "yes"
    end
  end
  return true -- default to enabled if config not available
end

--- Check if a specific category is enabled
-- @param category string The category name (laughter, distress, reflex, bodily, physical, novelty, songs)
-- @return boolean
function is_social_category_enabled(category)
  -- songs category defaults to off
  local default_enabled = category ~= "songs"

  if not config or not config.get_option then
    return default_enabled
  end
  local option_key = "social_cat_" .. category
  local option = config:get_option(option_key)
  if option then
    return option.value == "yes"
  end
  return default_enabled
end

--- Check if a specific social is individually enabled
-- @param social_name string The canonical social name
-- @return boolean
function is_social_enabled(social_name)
  if not config or not config.get_option then
    return true -- default to enabled
  end
  local option_key = "social_" .. social_name
  local option = config:get_option(option_key)
  if option then
    return option.value == "yes"
  end
  return true -- default to enabled if option not found
end

--- Check if a social should play based on all toggle levels
-- @param social_name string The canonical social name
-- @return boolean
function should_play_social(social_name)
  -- Check master toggle
  if not is_socials_enabled() then
    return false
  end

  -- Get social data to find its category
  local social_data = all_socials()[social_name]
  if not social_data then
    return false
  end

  -- Check category toggle (default to uncategorized if no category)
  local category = social_data.category or "uncategorized"
  if not is_social_category_enabled(category) then
    return false
  end

  -- Check individual toggle
  if not is_social_enabled(social_name) then
    return false
  end

  return true
end

--- Resolve a social action to its canonical name (handle aliases and plurals)
-- @param action string The social action name
-- @return string The canonical social name
function resolve_social_alias(action)
  if not action then return nil end
  local lower_action = string.lower(action)
  local aliases = all_aliases()
  local socials_map = all_socials()

  -- Check explicit aliases first
  if aliases[lower_action] then
    return aliases[lower_action]
  end

  -- Check if action exists directly in socials
  if socials_map[lower_action] then
    return lower_action
  end

  -- Try converting trailing 'ies' to 'y' for irregular plurals (e.g., "cries" -> "cry")
  if string.sub(lower_action, -3) == "ies" then
    local singular = string.sub(lower_action, 1, -4) .. "y"
    if socials_map[singular] or aliases[singular] then
      return aliases[singular] or singular
    end
  end

  -- Try stripping trailing 'es' for pluralized forms (e.g., "belches" -> "belch")
  if string.sub(lower_action, -2) == "es" then
    local singular = string.sub(lower_action, 1, -3)
    if socials_map[singular] or aliases[singular] then
      return aliases[singular] or singular
    end
  end

  -- Try stripping trailing 's' for pluralized forms (e.g., "screams" -> "scream")
  if string.sub(lower_action, -1) == "s" then
    local singular = string.sub(lower_action, 1, -2)
    if socials_map[singular] or aliases[singular] then
      return aliases[singular] or singular
    end
  end

  -- Return as-is if no match found
  return lower_action
end

--- Check if a social exists in the database
-- @param action string The social action name
-- @return boolean
function social_exists(action)
  if not action then return false end
  local canonical = resolve_social_alias(action)
  return all_socials()[canonical] ~= nil
end

--- Get social metadata
-- @param action string The social action name
-- @return table|nil Social entry data
function get_social_info(action)
  if not action then return nil end
  local canonical = resolve_social_alias(action)
  return all_socials()[canonical]
end

--- Get all socials in a category
-- @param category string The category name (use "uncategorized" for socials without a category)
-- @return table Array of social action names
function get_socials_by_category(category)
  local result = {}
  for action, data in pairs(all_socials()) do
    local social_category = data.category or "uncategorized"
    if social_category == category then
      table.insert(result, action)
    end
  end
  return result
end

--- Get list of all available social names
-- @return table Array of social action names
function get_all_socials()
  local result = {}
  for action, _ in pairs(all_socials()) do
    table.insert(result, action)
  end
  table.sort(result)
  return result
end

--- Get list of all categories in use
-- @return table Array of category names (includes "uncategorized" only if socials exist without category)
function get_all_social_categories()
  local category_set = {}
  local has_uncategorized = false
  for _, data in pairs(all_socials()) do
    if data.category then
      category_set[data.category] = true
    else
      has_uncategorized = true
    end
  end
  local result = {}
  for cat, _ in pairs(category_set) do
    table.insert(result, cat)
  end
  table.sort(result)
  if has_uncategorized then
    table.insert(result, "uncategorized")
  end
  return result
end

--- Find the appropriate sound file path for a social and gender.
-- Tries the gender-specific stem first, then falls back to neuter. A stem
-- only wins if sound_stem_resolves reports actual files (main pack or any
-- enabled theme), so a theme's male/female variant plays for the matching
-- gender, and a neuter-only main-pack sound plays for everyone else.
-- @param social_name string The canonical social name
-- @param gender string The gender (male, female, neuter)
-- @return string|nil The sound file path (without extension)
function find_social_sound_file(social_name, gender)
  local social_data = all_socials()[social_name]
  if not social_data then
    return nil
  end

  local sound_file = social_data.sound or social_name

  -- Dances play from sounds/miriani/dances/ with no gender variants
  if social_data.category == "dances" then
    return "dances/" .. sound_file
  end

  local candidates = {}
  if gender and gender ~= "neuter" then
    table.insert(candidates, "social/" .. gender .. "/" .. sound_file)
  end
  table.insert(candidates, "social/neuter/" .. sound_file)

  for _, candidate in ipairs(candidates) do
    if sound_stem_resolves and sound_stem_resolves(candidate) then
      return candidate
    end
  end

  return nil
end

--- Main entry point - play a social sound
-- @param action string The social action name (e.g., "laugh", "punch")
-- @param gender string Character gender ("male", "female", "nonbinary")
-- @return boolean Whether sound was played successfully
function play_social(action, gender)
  -- Resolve any aliases
  local canonical = resolve_social_alias(action)
  local social_data = all_socials()[canonical]

  if not social_data then
    -- Unknown social, nothing to play
    return false
  end

  -- Check if this social should play (master, category, and individual toggles)
  if not should_play_social(canonical) then
    return false
  end

  -- Determine effective gender (default to neuter if nil)
  local effective_gender = gender or "neuter"
  if effective_gender == "nonbinary" then
    effective_gender = math.random(2) == 1 and "male" or "female"
  end

  -- Find the appropriate sound file
  local sound_path = find_social_sound_file(canonical, effective_gender)
  if not sound_path then
    return false
  end

  -- Play the sound using mplay
  if mplay then
    mplay(sound_path, "socials")
    return true
  end

  return false
end

--- Ensure config has an individual on/off toggle option for every currently
-- known social, including those contributed by themes after startup. Only
-- adds missing options; never removes (leftover options are harmless and
-- default to "yes" if their social later disappears). Idempotent.
function resync_social_options()
  if not config or not config.options then return end
  for _, social_name in ipairs(get_all_socials()) do
    local info = get_social_info(social_name)
    if info then
      local key = "social_" .. social_name
      if not config.options[key] then
        config.options[key] = {
          descr = social_name:gsub("^%l", string.upper),
          value = "yes",
          group = "socials_" .. (info.category or "uncategorized"),
          type = "bool",
        }
      end
    end
  end
end
