-- Unified Configuration Schema for Miriani/Toastush
-- This is the single source of truth for all configuration options, groups, and defaults
-- Version 2.0 introduces the unified miriani.conf format

local config_schema = {
  -- Configuration format version
  version = "2.0",

  -- Groups in display order (array position determines menu order)
  groups = {
    {key = "general", title = "General Settings"},
    {key = "auto_login", title = "Auto Login"},
    {key = "ship", title = "Starship Options"},
    {key = "room", title = "Room and Environment"},
    {key = "helpers", title = "Helpers and Extras"},
    {key = "screen reader", title = "Screen Reader Integration"},
    {key = "gags", title = "Spam and Gag Filters"},
    {key = "scan_formats", title = "Configure Scan Templates"},
    {key = "buffers", title = "Output Buffers"},
    {key = "colors", title = "Color Customization"},
    {key = "audio groups", title = "Toggle Sound Categories"},
    {key = "sound variants", title = "Sound Variants"},
    {key = "developer", title = "Developer Options"},
  },

  -- All option definitions
  options = {
    -- Auto Login
    auto_login = {
      type = "bool",
      default = "no",
      group = "auto_login",
      descr = "Enable automatic login when connecting to the game."
    },
    auto_login_username = {
      type = "string",
      default = "",
      group = "auto_login",
      descr = "Username for auto login (use underscores for spaces)."
    },
    auto_login_password = {
      type = "password",
      default = "",
      group = "auto_login",
      descr = "Password for auto login."
    },

    -- General Settings
    automatic_changelog = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Automatically open changelog after updates."
    },
    automatic_updates = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Automatically apply updates quietly at login."
    },
    beep_on_keepalive = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Play beep sound on keep-alive messages."
    },
    alternate_audio = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Access alternative audio files before soundpack files (requires sounds/alternate directory)."
    },
    foreground_sounds = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Restrict sounds to only when window has focus."
    },
    follow_direction_sounds = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Play direction sounds when following or being dragged."
    },
    roundtime = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Play a sound when roundtime is up."
    },
    escape_abort = {
      type = "bool",
      default = "yes",
      group = "general",
      descr = "Use Escape key to send @abort command."
    },
    tab_activates_notepad = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Use Tab to activate output window instead of tab completion."
    },
    update_idle = {
      type = "bool",
      default = "no",
      group = "general",
      descr = "Automatically apply updates while idle."
    },
    update_sound = {
      type = "bool",
      default = "yes",
      group = "general",
      descr = "Play a sound for pending updates."
    },

    -- Starship Options
    scan_formatting = {
      type = "bool",
      default = "no",
      group = "ship",
      descr = "Print formatted single-line scan output instead of raw multi-line output."
    },
    secondary_lock = {
      type = "bool",
      default = "no",
      group = "ship",
      descr = "Play a different sound for unfocus locks."
    },
    relativity_drive_freq = {
      type = "string",
      default = "44100",
      group = "ship",
      descr = "Relativity drive frequency."
    },
    unchange_coords = {
      type = "bool",
      default = "no",
      group = "ship",
      descr = "Print 'unchanged' before coordinates if the target has not moved since its last scan."
    },

    -- Room and Environment
    background_ambiance = {
      type = "bool",
      default = "yes",
      group = "room",
      descr = "Play background ambiances."
    },
    count_praelor = {
      type = "bool",
      default = "no",
      group = "room",
      descr = "Print the number of insectoids detected in a room."
    },
    digsite_detector = {
      type = "bool",
      default = "yes",
      group = "room",
      descr = "Play a sound when detecting a digsite."
    },
    store_detector = {
      type = "bool",
      default = "no",
      group = "room",
      descr = "Play a sound when detecting stores."
    },

    -- Helpers and Extras
    archaeology_helper_dig = {
      type = "bool",
      default = "yes",
      group = "helpers",
      descr = "Buried artifact depth tracker."
    },
    archaeology_calculate_direction = {
      type = "bool",
      default = "yes",
      group = "helpers",
      descr = "Calculate direction from scanner instead of showing coordinates."
    },
    fc_sector_numbers = {
      type = "bool",
      default = "no",
      group = "helpers",
      descr = "Show sector numbers instead of names in flight control messages."
    },
    show_point_calculations = {
      type = "bool",
      default = "yes",
      group = "helpers",
      descr = "Show point difference calculations when using your portable point unit."
    },
    count_cannon = {
      type = "bool",
      default = "yes",
      group = "helpers",
      descr = "Print remaining cannon shots (use WEAPON command in weapon room to initialize)."
    },

    -- Screen Reader Integration
    follow_interrupt = {
      type = "bool",
      default = "no",
      group = "screen reader",
      descr = "Interrupt speech when following."
    },
    pa_interrupt = {
      type = "bool",
      default = "no",
      group = "screen reader",
      descr = "Interrupt speech for public address (PA) messages."
    },
    praelor_interrupt = {
      type = "bool",
      default = "no",
      group = "screen reader",
      descr = "Interrupt speech when detecting insectoid activity."
    },
    scan_interrupt = {
      type = "enum",
      default = "starships",
      group = "screen reader",
      descr = "Interrupt speech for scan coordinates.",
      options = {"starships", "everything", "off"}
    },

    -- Spam and Gag Filters
    external_camera = {
      type = "bool",
      default = "no",
      group = "gags",
      descr = "Gag external camera output."
    },
    internal_camera = {
      type = "bool",
      default = "no",
      group = "gags",
      descr = "Gag internal camera output."
    },
    friendly_combat = {
      type = "bool",
      default = "no",
      group = "gags",
      descr = "Gag friendly (non-praelor) sector combat messages."
    },
    spam = {
      type = "bool",
      default = "yes",
      group = "gags",
      descr = "Reduce spam by gagging flavored text."
    },

    -- Scan Format Templates
    scan_format_starship = {
      type = "string",
      default = "{newbie}{name} ({ship_type}) is {distance} units away, at {coordinates}. Hull {hull_damage}, Avg dmg {average_component_damage}. Power {power}, Weapons {weapons}. {number_of_occupants}{occupancy}. Alliance {alliance}. {organization}{cargo}",
      group = "scan_formats",
      descr = "Starships"
    },
    scan_format_planet = {
      type = "string",
      default = "{object_name}, {classification} planet {distance} units away, at {coordinates}. {natural_resources}{atmospheric_composition}{surface_conditions}{hostile_military_occupation}",
      group = "scan_formats",
      descr = "Planets"
    },
    scan_format_moon = {
      type = "string",
      default = "{object_name}, moon {distance} units away, at {coordinates}, orbiting {orbiting}. {natural_resources}{atmospheric_composition}",
      group = "scan_formats",
      descr = "Moons"
    },
    scan_format_station = {
      type = "string",
      default = "{object_name}: Station {distance} units away, at {coordinates}. {integrity}{occupancy}{identifiable_power_sources}",
      group = "scan_formats",
      descr = "Stations"
    },
    scan_format_asteroid = {
      type = "string",
      default = "{object_name}: {size} asteroid {distance} units away, at {coordinates}. {composition}{starships}{landing_beacons}",
      group = "scan_formats",
      descr = "Asteroids"
    },
    scan_format_star = {
      type = "string",
      default = "{object_name}: Class {classification} star {distance} units away, at {coordinates}",
      group = "scan_formats",
      descr = "Stars"
    },
    scan_format_debris = {
      type = "string",
      default = "{object_name}: {type} {distance} units away, at {coordinates}",
      group = "scan_formats",
      descr = "Debris"
    },
    scan_format_weapon = {
      type = "string",
      default = "{object_name}: {distance} units away, at {coordinates}. {damage}{available_charge}{launched_by}",
      group = "scan_formats",
      descr = "Proximity Weapons"
    },
    scan_format_probe = {
      type = "string",
      default = "{object_name}: {distance} units away, at {coordinates}. {launched_by}",
      group = "scan_formats",
      descr = "Video Probes"
    },
    scan_format_interdictor = {
      type = "string",
      default = "{object_name}: {distance} units away, at {coordinates}. {launched_by}",
      group = "scan_formats",
      descr = "Interdictors"
    },
    scan_format_blockade = {
      type = "string",
      default = "{object_name}: {distance} units away, at {coordinates}. {launched_by}",
      group = "scan_formats",
      descr = "Blockades"
    },
    scan_format_unknown = {
      type = "string",
      default = "{object_name}: {distance} units away, at {coordinates}",
      group = "scan_formats",
      descr = "Unknown objects"
    },

    -- Output Buffers
    communication_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Communication (all channels)."
    },
    private_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Private communication."
    },
    combat_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Combat."
    },
    general_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "General communication."
    },
    url_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "URLs (http, mailto, gofer, etc)."
    },
    camera_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Camera feeds (droids, internal turrets, external camera)."
    },
    market_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Tradesman market."
    },
    metaf_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Metafrequency."
    },
    metaf_separate_buffers = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Separate metafrequency buffers by frequency/label."
    },
    flight_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Flight control."
    },
    say_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Say communication."
    },
    whisper_buffer = {
      type = "bool",
      default = "no",
      group = "buffers",
      descr = "Whispers."
    },
    ooc_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "OOC communication (ROOC, SOOC, OOC channel)."
    },
    ship_buffer = {
      type = "bool",
      default = "no",
      group = "buffers",
      descr = "Ship-to-ship communication."
    },
    pa_buffer = {
      type = "bool",
      default = "no",
      group = "buffers",
      descr = "Public address speaker (PA)."
    },
    alliance_buffer = {
      type = "bool",
      default = "no",
      group = "buffers",
      descr = "Alliance communication."
    },
    board_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Message boards."
    },
    chatter_buffer = {
      type = "bool",
      default = "no",
      group = "buffers",
      descr = "Chatter communication."
    },
    computer_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Starship computer messages."
    },
    design_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Architectural design channel."
    },
    contributions_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Credit contributions."
    },
    auction_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Auctions."
    },
    organization_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Organization channel."
    },
    courier_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Courier company channel."
    },
    scan_buffer = {
      type = "bool",
      default = "yes",
      group = "buffers",
      descr = "Starship Scans"
    },

    -- Color Customization
    -- Note: These will be refactored in Phase 3 to use type="color" instead of "function"
    -- For now, keeping backward compatibility with action/read fields
    background_color = {
      type = "function",
      default = 16777215,
      group = "colors",
      descr = "Default Background:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    board_color = {
      type = "function",
      default = 7346457,
      group = "colors",
      descr = "Message Board:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    camera_color = {
      type = "function",
      default = 16119285,
      group = "colors",
      descr = "Camera Feed:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    combat_color = {
      type = "function",
      default = 255,
      group = "colors",
      descr = "Combat:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    computer_color = {
      type = "function",
      default = 12632256,
      group = "colors",
      descr = "Computer:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    default_color = {
      type = "function",
      default = 0,
      group = "colors",
      descr = "Default Foreground:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    flight_color = {
      type = "function",
      default = 14772545,
      group = "colors",
      descr = "Flight Control:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    market_color = {
      type = "function",
      default = 65535,
      group = "colors",
      descr = "Tradesman Market:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    priv_comm_color = {
      type = "function",
      default = 32768,
      group = "colors",
      descr = "Private Communication:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    pub_comm_color = {
      type = "function",
      default = 13688896,
      group = "colors",
      descr = "Public Communication:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    info_background_color = {
      type = "function",
      default = 8421504,
      group = "colors",
      descr = "Info-bar background:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    info_foreground_color = {
      type = "function",
      default = 8388608,
      group = "colors",
      descr = "Info-bar foreground:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    hyperlink_foreground_color = {
      type = "function",
      default = 8388736,
      group = "colors",
      descr = "Hyperlink foreground:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },
    hyperlink_background_color = {
      type = "function",
      default = 16777215,
      group = "colors",
      descr = "Hyperlink background:",
      action = "return PickColour(-1)",
      read = "return(RGBColourToName)"
    },

    -- Developer Options
    debug_mode = {
      type = "bool",
      default = "no",
      group = "developer",
      descr = "Debug notifications (missing audio files, etc)."
    },
    sounds_buffer = {
      type = "bool",
      default = "no",
      group = "developer",
      descr = "Sound Playback History"
    },
    hooks_buffer = {
      type = "bool",
      default = "no",
      group = "developer",
      descr = "Soundpack hooks buffer."
    },
  },

  -- Audio configuration
  audio = {
    -- Master volume controls
    master_volume = 50,
    master_mute = false,

    -- Audio categories
    categories = {
      sounds = {volume = 60, pan = 0},
      environment = {volume = 50, pan = 0},
    },

    -- Fixed volume offsets (applied as: master * (category + offset))
    offsets = {
      notification = -15,    -- Quieter beeps/alerts
      communication = 0,     -- Same as sounds
      computer = -10,        -- Ship computer slightly quieter
      ship = 0,              -- Ship sounds same as sounds
      melee = -5,            -- Combat slightly quieter
      socials = 0,           -- Socials same as sounds
      vehicle = 0,           -- Vehicle sounds same as sounds
      other = 0,             -- Other sounds same as sounds
    },

    -- Map groups to their base category (defaults to "sounds" if not listed)
    category_map = {
      ambiance = "environment",
      loop = "environment",
    },
  },

  -- Sound variants configuration
  -- These sounds have multiple variants that users can choose from
  sound_variants = {
    ["miriani/ship/move/accelerate.ogg"] = {
      name = "Ship Accelerate",
      default = 3
    },
    ["miriani/ship/move/decelerate.ogg"] = {
      name = "Ship Decelerate",
      default = 3
    },
    ["miriani/vehicle/accelerate.ogg"] = {
      name = "Vehicle Accelerate (Salvagers and ACVs)",
      default = 1
    },
    ["miriani/vehicle/decelerate.ogg"] = {
      name = "Vehicle Decelerate (Salvagers and ACVs)",
      default = 1
    },
    ["miriani/activity/archaeology/artifactHere.ogg"] = {
      name = "Archaeology Artifact Detected",
      default = 1
    },
  },

  -- Predefined sound groups
  -- These are known groups that can be toggled on/off
  -- Additional groups may be discovered at runtime
  sound_groups = {
    -- Common groups (typically enabled by default)
    notification = true,
    communication = true,
    computer = true,
    ship = true,
    melee = true,
    socials = true,
    vehicle = true,
    other = true,

    -- Less common groups (may be discovered later)
    babies = false,
    praelor = true,
    archaeology = true,

    -- Note: ambiance and environment are excluded from toggle
    -- as they use their own volume controls
  },

  -- Excluded sound groups (cannot be toggled, use volume controls instead)
  excluded_sound_groups = {
    ambiance = true,
    environment = true,
  },
}

-- Helper function to get group by key
function config_schema.get_group(key)
  for _, group in ipairs(config_schema.groups) do
    if group.key == key then
      return group
    end
  end
  return nil
end

-- Helper function to get group index (for ordering)
function config_schema.get_group_order(key)
  for i, group in ipairs(config_schema.groups) do
    if group.key == key then
      return i
    end
  end
  return 999 -- Unknown groups go to the end
end

return config_schema