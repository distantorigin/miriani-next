-- @module socials
-- Handles all social sound playback for the Miriani soundpack.
-- Provides a complete database of socials with gender-based sound selection.

-- Author: Claude Code
-- Created: 2026.01.01

local M = {}

-- State for targeted social validation
local pending_targeted_message = nil

-- Social aliases - map action names to canonical sound file names
local social_aliases = {
  ["slug"] = "punch",
  ["sock"] = "punch",
  ["hit"] = "punch",
}

-- Complete socials database
-- Each entry: sound = base filename, genders = supported folders, category = grouping, requires_target = edge case flag
-- Categories: laughter, distress, reflex, bodily, physical, novelty
local socials = {
  -- Laughter sounds
  ["cackle"] = {sound = "cackle", genders = {"neuter"}, category = "laughter", requires_target = false},
  ["chortle"] = {sound = "chortle", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},
  ["chuckle"] = {sound = "chuckle", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},
  ["giggle"] = {sound = "giggle", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},
  ["laugh"] = {sound = "laugh", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},
  ["lol"] = {sound = "lol", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},
  ["mlaugh"] = {sound = "mlaugh", genders = {"neuter"}, category = "laughter", requires_target = false},
  ["rofl"] = {sound = "rofl", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},
  ["snicker"] = {sound = "snicker", genders = {"male", "female", "neuter"}, category = "laughter", requires_target = false},

  -- Distress sounds
  ["cry"] = {sound = "cry", genders = {"male", "female", "neuter"}, category = "distress", requires_target = false},
  ["gasp"] = {sound = "gasp", genders = {"male", "female", "neuter"}, category = "distress", requires_target = false},
  ["moan"] = {sound = "moan", genders = {"male", "female", "neuter"}, category = "distress", requires_target = false},
  ["screech"] = {sound = "screech", genders = {"neuter"}, category = "distress", requires_target = false},
  ["shriek"] = {sound = "shriek", genders = {"female", "neuter"}, category = "distress", requires_target = false},
  ["sniffle"] = {sound = "sniffle", genders = {"neuter"}, category = "distress", requires_target = false},
  ["sob"] = {sound = "sob", genders = {"male", "female", "neuter"}, category = "distress", requires_target = false},
  ["yelp"] = {sound = "yelp", genders = {"neuter"}, category = "distress", requires_target = false},
  ["yowl"] = {sound = "yowl", genders = {"neuter"}, category = "distress", requires_target = false},

  -- Reflex sounds (involuntary body reflexes)
  ["cough"] = {sound = "cough", genders = {"male", "female", "neuter"}, category = "reflex", requires_target = false},
  ["gulp"] = {sound = "gulp", genders = {"neuter"}, category = "reflex", requires_target = false},
  ["sigh"] = {sound = "sigh", genders = {"male", "female", "neuter"}, category = "reflex", requires_target = false},
  ["sneeze"] = {sound = "sneeze", genders = {"male", "female", "neuter"}, category = "reflex", requires_target = false},
  ["snore"] = {sound = "snore", genders = {"neuter"}, category = "reflex", requires_target = false},
  ["snort"] = {sound = "snort", genders = {"neuter"}, category = "reflex", requires_target = false},
  ["splutter"] = {sound = "splutter", genders = {"male", "female", "neuter"}, category = "reflex", requires_target = false},
  ["swallow"] = {sound = "swallow", genders = {"neuter"}, category = "reflex", requires_target = false},
  ["throatfix"] = {sound = "throatfix", genders = {"male", "neuter"}, category = "reflex", requires_target = false},
  ["yawn"] = {sound = "yawn", genders = {"male", "female", "neuter"}, category = "reflex", requires_target = false},

  -- Bodily sounds (gross/bodily functions)
  ["belch"] = {sound = "belch", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["blow"] = {sound = "blow", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["bubble"] = {sound = "bubble", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["burp"] = {sound = "burp", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["fart"] = {sound = "fart", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["gag"] = {sound = "gag", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["puke"] = {sound = "puke", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["spit"] = {sound = "spit", genders = {"neuter"}, category = "bodily", requires_target = false},
  ["vomit"] = {sound = "vomit", genders = {"neuter"}, category = "bodily", requires_target = false},

  -- Physical sounds (movement/contact)
  ["bop"] = {sound = "bop", genders = {"neuter"}, category = "physical", requires_target = false},
  ["bounce"] = {sound = "bounce", genders = {"neuter"}, category = "physical", requires_target = false},
  ["clap"] = {sound = "clap", genders = {"neuter"}, category = "physical", requires_target = false},
  ["collapse"] = {sound = "collapse", genders = {"neuter"}, category = "physical", requires_target = false},
  ["fall"] = {sound = "fall", genders = {"neuter"}, category = "physical", requires_target = false},
  ["flap"] = {sound = "flap", genders = {"neuter"}, category = "physical", requires_target = false},
  ["headdesk"] = {sound = "headdesk", genders = {"neuter"}, category = "physical", requires_target = false},
  ["hop"] = {sound = "hop", genders = {"male", "female", "neuter"}, category = "physical", requires_target = false},
  ["kick"] = {sound = "kick", genders = {"neuter"}, category = "physical", requires_target = false},
  ["kiss"] = {sound = "kiss", genders = {"neuter"}, category = "physical", requires_target = false},
  ["knucklecrack"] = {sound = "knucklecrack", genders = {"neuter"}, category = "physical", requires_target = false},
  ["nudge"] = {sound = "nudge", genders = {"neuter"}, category = "physical", requires_target = true},
  ["poke"] = {sound = "poke", genders = {"neuter"}, category = "physical", requires_target = true},
  ["punch"] = {sound = "punch", genders = {"neuter"}, category = "physical", requires_target = false},
  ["slap"] = {sound = "slap", genders = {"neuter"}, category = "physical", requires_target = false},
  ["snap"] = {sound = "snap", genders = {"neuter"}, category = "physical", requires_target = false},
  ["spank"] = {sound = "spank", genders = {"neuter"}, category = "physical", requires_target = false},
  ["stomp"] = {sound = "stomp", genders = {"neuter"}, category = "physical", requires_target = false},
  ["tackle"] = {sound = "tackle", genders = {"neuter"}, category = "physical", requires_target = false},
  ["twitch"] = {sound = "twitch", genders = {"neuter"}, category = "physical", requires_target = false},

  -- Novelty sounds (animals, musical, memes, misc expressions)
  ["airguitar"] = {sound = "airguitar", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["applaud"] = {sound = "applaud", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["beep"] = {sound = "beep", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["boggle"] = {sound = "boggle", genders = {"female", "neuter"}, category = "novelty", requires_target = false},
  ["bongo"] = {sound = "bongo", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["bonk"] = {sound = "bonk", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["boo"] = {sound = "boo", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["cheer"] = {sound = "cheer", genders = {"male", "female", "neuter"}, category = "novelty", requires_target = false},
  ["frog"] = {sound = "frog", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["golfclap"] = {sound = "golfclap", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["growl"] = {sound = "growl", genders = {"male", "female", "neuter"}, category = "novelty", requires_target = false},
  ["hiss"] = {sound = "hiss", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["hoot"] = {sound = "hoot", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["itsatrap"] = {sound = "itsatrap", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["khan"] = {sound = "khan", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["mock"] = {sound = "mock", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["moo"] = {sound = "moo", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["noo"] = {sound = "noo", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["oink"] = {sound = "oink", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["pimp"] = {sound = "pimp", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["ponder"] = {sound = "ponder", genders = {"male", "female", "neuter"}, category = "novelty", requires_target = false},
  ["purr"] = {sound = "purr", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["quack"] = {sound = "quack", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["roar"] = {sound = "roar", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["slowclap"] = {sound = "slowclap", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["snarl"] = {sound = "snarl", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["spoon"] = {sound = "spoon", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["squeak"] = {sound = "squeak", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["whistle"] = {sound = "whistle", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["why"] = {sound = "why", genders = {"neuter"}, category = "novelty", requires_target = false},
  ["yess"] = {sound = "yess", genders = {"neuter"}, category = "novelty", requires_target = false},
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
-- @param category string The category name (vocal, physical, expressive, silly, animal, musical)
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

  -- Check category toggle
  if not M.is_category_enabled(social_data.category) then
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
-- @param category string The category name
-- @return table Array of social action names
function M.get_socials_by_category(category)
  local result = {}
  for action, data in pairs(socials) do
    if data.category == category then
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

--- Check if a gender is supported for a social
-- @param social_data table The social entry
-- @param gender string The gender to check
-- @return boolean
local function gender_supported(social_data, gender)
  for _, g in ipairs(social_data.genders) do
    if g == gender then
      return true
    end
  end
  return false
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

  -- Check if the specified gender is supported
  if gender_supported(social_data, gender) then
    return "social/" .. gender .. "/" .. social_data.sound
  end

  -- Fall back to neuter if gender not supported
  if gender ~= "neuter" and gender_supported(social_data, "neuter") then
    return "social/neuter/" .. social_data.sound
  end

  -- Last resort: try first available gender
  if #social_data.genders > 0 then
    return "social/" .. social_data.genders[1] .. "/" .. social_data.sound
  end

  return nil
end

--- Set pending targeted message (called from hooks when social hook received)
-- @param action string The social action
-- @param actor string The actor performing the social
function M.set_pending_target(action, actor)
  pending_targeted_message = {
    action = action,
    actor = actor,
    timestamp = os.time()
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
  -- Check if the pending message matches and is recent (within 2 seconds)
  if pending_targeted_message.action == action and
     (os.time() - pending_targeted_message.timestamp) <= 2 then
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

  -- Handle nonbinary: randomly pick male or female
  local effective_gender = gender
  if gender == "nonbinary" then
    local genders = {"male", "female"}
    effective_gender = genders[math.random(2)]
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
