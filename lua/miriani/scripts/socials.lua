-- Social sound playback with gender-based sound selection.
local M = {}

-- State for targeted social validation
local pending_targeted_message = nil

-- Cache for O(1) gender lookup
local gender_sets_cache = {}

-- Constants
local PENDING_TARGET_TIMEOUT = 2.0  -- seconds to wait for targeted social confirmation

-- Social aliases - map action names to canonical sound file names
local social_aliases = {
  ["slug"] = "punch",
  ["sock"] = "punch",
  ["hit"] = "punch",
}

-- Socials database
--
-- To add a new social:
--   1. Place sound file(s) in sounds/miriani/social/<gender>/<name>.ogg
--   2. Add entry below in the appropriate category section (alphabetically)
--
-- Entry format:
--   name = {genders = {"male", "female", "neuter"}, category = "category_name"},
--
-- Examples:
--   -- Neuter only (no gendered variants):
--   clap = {genders = {"neuter"}, category = "physical"},
--
--   -- Male and female variants:
--   laugh = {genders = {"male", "female"}, category = "laughter"},
--
--   -- Override sound filename (when different from social name):
--   lmao = {genders = {"neuter"}, category = "laughter", sound = "rofl"},
--
--   -- Requires target (only plays when you're the target, e.g. "X pokes you"):
--   poke = {genders = {"neuter"}, category = "physical", requires_target = true},
--
-- Categories: laughter, distress, reflex, bodily, physical, novelty
-- (socials without a category will appear under "uncategorized")
--
local socials = {
  -- Laughter sounds
  cackle    = {genders = {"neuter"}, category = "laughter"},
  chortle   = {genders = {"male", "female"}, category = "laughter"},
  chuckle   = {genders = {"male", "female"}, category = "laughter"},
  giggle    = {genders = {"male", "female"}, category = "laughter"},
  laugh     = {genders = {"male", "female"}, category = "laughter"},
  lol       = {genders = {"male", "female"}, category = "laughter"},
  mlaugh    = {genders = {"neuter"}, category = "laughter"},
  rofl      = {genders = {"male", "female"}, category = "laughter"},
  snicker   = {genders = {"male", "female"}, category = "laughter"},

  -- Distress sounds
  cry       = {genders = {"male", "female"}, category = "distress"},
  gasp      = {genders = {"male", "female"}, category = "distress"},
  moan      = {genders = {"male", "female"}, category = "distress"},
  screech   = {genders = {"neuter"}, category = "distress"},
  shriek    = {genders = {"male", "female"}, category = "distress"},
  sniffle   = {genders = {"neuter"}, category = "distress"},
  sob       = {genders = {"male", "female"}, category = "distress"},
  yelp      = {genders = {"neuter"}, category = "distress"},
  yowl      = {genders = {"neuter"}, category = "distress"},

  -- Reflex sounds (involuntary body reflexes)
  cough     = {genders = {"male", "female"}, category = "reflex"},
  gulp      = {genders = {"neuter"}, category = "reflex"},
  sigh      = {genders = {"male", "female"}, category = "reflex"},
  sneeze    = {genders = {"male", "female"}, category = "reflex"},
  snore     = {genders = {"neuter"}, category = "reflex"},
  snort     = {genders = {"neuter"}, category = "reflex"},
  splutter  = {genders = {"male", "female"}, category = "reflex"},
  swallow   = {genders = {"neuter"}, category = "reflex"},
  throatfix = {genders = {"male"}, category = "reflex"},
  yawn      = {genders = {"male", "female"}, category = "reflex"},

  -- Bodily sounds (gross/bodily functions)
  belch     = {genders = {"neuter"}, category = "bodily"},
  bubble    = {genders = {"neuter"}, category = "bodily"},
  burp      = {genders = {"neuter"}, category = "bodily"},
  fart      = {genders = {"neuter"}, category = "bodily"},
  gag       = {genders = {"neuter"}, category = "bodily"},
  puke      = {genders = {"neuter"}, category = "bodily"},
  spit      = {genders = {"neuter"}, category = "bodily"},
  vomit     = {genders = {"neuter"}, category = "bodily"},

  -- Physical sounds (movement/contact)
  bop         = {genders = {"neuter"}, category = "physical"},
  bounce      = {genders = {"neuter"}, category = "physical"},
  clap        = {genders = {"neuter"}, category = "physical"},
  collapse    = {genders = {"neuter"}, category = "physical"},
  fall        = {genders = {"neuter"}, category = "physical"},
  flap        = {genders = {"neuter"}, category = "physical"},
  headdesk    = {genders = {"neuter"}, category = "physical"},
  hop         = {genders = {"male", "female"}, category = "physical"},
  kick        = {genders = {"neuter"}, category = "physical"},
  kiss        = {genders = {"neuter"}, category = "physical"},
  knucklecrack = {genders = {"neuter"}, category = "physical"},
  nudge       = {genders = {"neuter"}, category = "physical", requires_target = true},
  poke        = {genders = {"neuter"}, category = "physical", requires_target = true},
  punch       = {genders = {"neuter"}, category = "physical"},
  slap        = {genders = {"neuter"}, category = "physical"},
  snap        = {genders = {"neuter"}, category = "physical"},
  spank       = {genders = {"neuter"}, category = "physical"},
  stomp       = {genders = {"neuter"}, category = "physical"},
  tackle      = {genders = {"neuter"}, category = "physical"},
  twitch      = {genders = {"neuter"}, category = "physical"},

  -- Novelty sounds (animals, musical, memes, misc expressions)
  airguitar = {genders = {"neuter"}, category = "novelty"},
  applaud   = {genders = {"neuter"}, category = "novelty"},
  beep      = {genders = {"neuter"}, category = "novelty"},
  boggle    = {genders = {"female"}, category = "novelty"},
  bongo     = {genders = {"neuter"}, category = "novelty"},
  bonk      = {genders = {"neuter"}, category = "novelty"},
  boo       = {genders = {"neuter"}, category = "novelty"},
  cheer     = {genders = {"male", "female"}, category = "novelty"},
  frog      = {genders = {"neuter"}, category = "novelty"},
  golfclap  = {genders = {"neuter"}, category = "novelty"},
  growl     = {genders = {"male", "female"}, category = "novelty"},
  hiss      = {genders = {"neuter"}, category = "novelty"},
  hoot      = {genders = {"neuter"}, category = "novelty"},
  itsatrap  = {genders = {"neuter"}, category = "novelty"},
  khan      = {genders = {"neuter"}, category = "novelty"},
  mock      = {genders = {"neuter"}, category = "novelty"},
  moo       = {genders = {"neuter"}, category = "novelty"},
  noo       = {genders = {"neuter"}, category = "novelty"},
  oink      = {genders = {"neuter"}, category = "novelty"},
  pimp      = {genders = {"neuter"}, category = "novelty"},
  ponder    = {genders = {"male", "female"}, category = "novelty"},
  purr      = {genders = {"neuter"}, category = "novelty"},
  quack     = {genders = {"neuter"}, category = "novelty"},
  roar      = {genders = {"neuter"}, category = "novelty"},
  slowclap  = {genders = {"neuter"}, category = "novelty"},
  snarl     = {genders = {"neuter"}, category = "novelty"},
  spoon     = {genders = {"neuter"}, category = "novelty"},
  squeak    = {genders = {"neuter"}, category = "novelty"},
  whistle   = {genders = {"neuter"}, category = "novelty"},
  why       = {genders = {"neuter"}, category = "novelty"},
  yess      = {genders = {"neuter"}, category = "novelty"},
}

--- Check if social sounds are globally enabled in config
-- @return boolean
function M.is_enabled()
  if config and config.get_option then
    local option = config:get_option("social_sounds")
    if option then
      return option.value == "yes"
    end
  end
  return true -- default to enabled if config not available
end

--- Check if a specific category is enabled
-- @param category string The category name (laughter, distress, reflex, bodily, physical, novelty)
-- @return boolean
function M.is_category_enabled(category)
  if not config or not config.get_option then
    return true -- default to enabled
  end
  local option_key = "social_cat_" .. category
  local option = config:get_option(option_key)
  if option then
    return option.value == "yes"
  end
  return true -- default to enabled if option not found
end

--- Check if a specific social is individually enabled
-- @param social_name string The canonical social name
-- @return boolean
function M.is_social_enabled(social_name)
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
function M.should_play(social_name)
  -- Check master toggle
  if not M.is_enabled() then
    return false
  end

  -- Get social data to find its category
  local social_data = socials[social_name]
  if not social_data then
    return false
  end

  -- Check category toggle (default to uncategorized if no category)
  local category = social_data.category or "uncategorized"
  if not M.is_category_enabled(category) then
    return false
  end

  -- Check individual toggle
  if not M.is_social_enabled(social_name) then
    return false
  end

  return true
end

--- Resolve a social action to its canonical name (handle aliases)
-- @param action string The social action name
-- @return string The canonical social name
function M.resolve_alias(action)
  if not action then return nil end
  local lower_action = string.lower(action)
  return social_aliases[lower_action] or lower_action
end

--- Check if a social exists in the database
-- @param action string The social action name
-- @return boolean
function M.social_exists(action)
  if not action then return false end
  local canonical = M.resolve_alias(action)
  return socials[canonical] ~= nil
end

--- Get social metadata
-- @param action string The social action name
-- @return table or nil Social entry data
function M.get_social_info(action)
  if not action then return nil end
  local canonical = M.resolve_alias(action)
  return socials[canonical]
end

--- Get all socials in a category
-- @param category string The category name (use "uncategorized" for socials without a category)
-- @return table Array of social action names
function M.get_socials_by_category(category)
  local result = {}
  for action, data in pairs(socials) do
    local social_category = data.category or "uncategorized"
    if social_category == category then
      table.insert(result, action)
    end
  end
  return result
end

--- Get list of all available social names
-- @return table Array of social action names
function M.get_all_socials()
  local result = {}
  for action, _ in pairs(socials) do
    table.insert(result, action)
  end
  table.sort(result)
  return result
end

--- Get list of all categories in use
-- @return table Array of category names (includes "uncategorized" only if socials exist without category)
function M.get_all_categories()
  local category_set = {}
  local has_uncategorized = false
  for _, data in pairs(socials) do
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

--- Build a gender set for O(1) lookup (cached per social)
-- @param social_name string The social name for cache key
-- @param genders table Array of supported genders
-- @return table Set of genders
local function get_gender_set(social_name, genders)
  if not gender_sets_cache[social_name] then
    local set = {}
    for _, g in ipairs(genders) do
      set[g] = true
    end
    gender_sets_cache[social_name] = set
  end
  return gender_sets_cache[social_name]
end

--- Check if a gender is supported for a social (O(1) lookup)
-- @param social_name string The social name
-- @param social_data table The social entry
-- @param gender string The gender to check
-- @return boolean
local function gender_supported(social_name, social_data, gender)
  local gender_set = get_gender_set(social_name, social_data.genders)
  return gender_set[gender] == true
end

--- Find the appropriate sound file path for a social and gender
-- @param social_name string The canonical social name
-- @param gender string The gender (male, female, neuter)
-- @return string or nil The sound file path (without extension)
function M.find_sound_file(social_name, gender)
  local social_data = socials[social_name]
  if not social_data then
    return nil
  end

  -- Derive sound filename: use explicit sound or fall back to social_name
  local sound_file = social_data.sound or social_name

  -- Check if the specified gender is supported
  if gender_supported(social_name, social_data, gender) then
    return "social/" .. gender .. "/" .. sound_file
  end

  -- Fall back to neuter if gender not supported (neuter is gender-neutral)
  if gender ~= "neuter" and gender_supported(social_name, social_data, "neuter") then
    return "social/neuter/" .. sound_file
  end

  -- Don't fall back to opposite gender - return nil if no match
  return nil
end

--- Set pending targeted message (called from hooks when social hook received)
-- @param action string The social action
-- @param actor string The actor performing the social
function M.set_pending_target(action, actor)
  pending_targeted_message = {
    action = action,
    actor = actor,
    timestamp = utils.timer()  -- high-resolution timer
  }
end

--- Clear pending targeted message
function M.clear_pending_target()
  pending_targeted_message = nil
end

--- Check if we have a valid pending targeted message for this social
-- @param action string The social action to check
-- @return boolean
local function has_valid_pending_target(action)
  if not pending_targeted_message then
    return false
  end
  -- Check if the pending message matches and is recent
  local elapsed = utils.timer() - pending_targeted_message.timestamp
  if pending_targeted_message.action == action and elapsed <= PENDING_TARGET_TIMEOUT then
    return true
  end
  return false
end

--- Main entry point - play a social sound
-- @param action string The social action name (e.g., "laugh", "punch")
-- @param gender string Character gender ("male", "female", "nonbinary")
-- @param is_targeted_at_player boolean Whether player is the target (for edge cases)
-- @return boolean Whether sound was played successfully
function M.play_social(action, gender, is_targeted_at_player)
  -- Resolve any aliases
  local canonical = M.resolve_alias(action)
  local social_data = socials[canonical]

  if not social_data then
    -- Unknown social, nothing to play
    return false
  end

  -- Check if this social should play (master, category, and individual toggles)
  if not M.should_play(canonical) then
    return false
  end

  -- Determine effective gender (default to neuter if nil)
  local effective_gender = gender or "neuter"
  if effective_gender == "nonbinary" then
    effective_gender = math.random(2) == 1 and "male" or "female"
  end

  -- Handle targeted socials (poke, nudge)
  if social_data.requires_target then
    -- For targeted socials, only play if we have a valid pending target
    if is_targeted_at_player or has_valid_pending_target(canonical) then
      -- Clear the pending message
      M.clear_pending_target()
    else
      -- Don't play the sound - player is not the target
      return false
    end
  end

  -- Find the appropriate sound file
  local sound_path = M.find_sound_file(canonical, effective_gender)
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

return M
