
local options = {
  auto_login = {descr="Enable automatic login when connecting to the game.", value="no", group="auto_login", type="bool"},
  auto_login_username = {descr="Username for auto login (use underscores for spaces).", value="", group="auto_login", type="string"},
  auto_login_password = {descr="Password for auto login.", value="", group="auto_login", type="password"},
  automatic_changelog = {descr="Automatically open changelog after updates.", value="no", group="general", type="bool"},
  automatic_updates = {descr="Automatically apply updates quietly at login.", value="no", group="general", type="bool"},
  beep_on_keepalive = {descr="Play beep sound on keep-alive messages.", value="no", group="general", type="bool"},
  debug_mode = {descr="Debug notifications (missing audio files, etc).", value="no", group="developer", type="bool"},
  sounds_buffer = {descr="Sound Playback History", value="no", group="developer", type="bool"},
  archaeology_helper_dig = {descr="Buried artifact depth tracker.", value="yes", group="helpers", type="bool"},
  archaeology_calculate_direction = {descr="Calculate direction from scanner instead of showing coordinates.", value="yes", group="helpers", type="bool"},
  show_counters = {descr="Display counter values when activities are completed.", value="no", group="helpers", type="bool"},
  reset_counters_on_startup = {descr="Reset activity counters at startup.", value="yes", group="helpers", type="bool"},
  fc_sector_numbers = {descr="Show sector numbers instead of names in flight control messages.", value="no", group="helpers", type="bool"},
  show_point_calculations = {descr="Show point difference calculations when using your portable point unit.", value="yes", group="helpers", type="bool"},
  background_ambiance = {descr="Play background ambiances.", value="yes", group="room", type="bool"},
  foreground_sounds = {descr="Restrict sounds to only when window has focus.", value="no", group="general", type="bool"},
  -- Social sound options (master toggle, categories, and individual socials)
  social_sounds = {descr="Enable all social sounds (master toggle).", value="yes", group="socials", type="bool"},

  -- Social category toggles
  social_cat_laughter = {descr="Laughter sounds (laugh, giggle, chuckle, etc).", value="yes", group="socials", type="bool"},
  social_cat_distress = {descr="Distress sounds (cry, sob, moan, etc).", value="yes", group="socials", type="bool"},
  social_cat_reflex = {descr="Reflex sounds (cough, sneeze, yawn, etc).", value="yes", group="socials", type="bool"},
  social_cat_bodily = {descr="Bodily sounds (fart, burp, belch, etc).", value="yes", group="socials", type="bool"},
  social_cat_physical = {descr="Physical sounds (punch, kick, clap, etc).", value="yes", group="socials", type="bool"},
  social_cat_novelty = {descr="Novelty sounds (animals, musical, memes, etc).", value="yes", group="socials", type="bool"},

  -- Individual social toggles - Laughter
  social_cackle = {descr="Cackle.", value="yes", group="socials_laughter", type="bool"},
  social_chortle = {descr="Chortle.", value="yes", group="socials_laughter", type="bool"},
  social_chuckle = {descr="Chuckle.", value="yes", group="socials_laughter", type="bool"},
  social_giggle = {descr="Giggle.", value="yes", group="socials_laughter", type="bool"},
  social_laugh = {descr="Laugh.", value="yes", group="socials_laughter", type="bool"},
  social_lol = {descr="LOL.", value="yes", group="socials_laughter", type="bool"},
  social_mlaugh = {descr="Maniacal laugh.", value="yes", group="socials_laughter", type="bool"},
  social_rofl = {descr="ROFL.", value="yes", group="socials_laughter", type="bool"},
  social_snicker = {descr="Snicker.", value="yes", group="socials_laughter", type="bool"},

  -- Individual social toggles - Distress
  social_cry = {descr="Cry.", value="yes", group="socials_distress", type="bool"},
  social_gasp = {descr="Gasp.", value="yes", group="socials_distress", type="bool"},
  social_moan = {descr="Moan.", value="yes", group="socials_distress", type="bool"},
  social_screech = {descr="Screech.", value="yes", group="socials_distress", type="bool"},
  social_shriek = {descr="Shriek.", value="yes", group="socials_distress", type="bool"},
  social_sniffle = {descr="Sniffle.", value="yes", group="socials_distress", type="bool"},
  social_sob = {descr="Sob.", value="yes", group="socials_distress", type="bool"},
  social_yelp = {descr="Yelp.", value="yes", group="socials_distress", type="bool"},
  social_yowl = {descr="Yowl.", value="yes", group="socials_distress", type="bool"},

  -- Individual social toggles - Reflex
  social_cough = {descr="Cough.", value="yes", group="socials_reflex", type="bool"},
  social_gulp = {descr="Gulp.", value="yes", group="socials_reflex", type="bool"},
  social_sigh = {descr="Sigh.", value="yes", group="socials_reflex", type="bool"},
  social_sneeze = {descr="Sneeze.", value="yes", group="socials_reflex", type="bool"},
  social_snore = {descr="Snore.", value="yes", group="socials_reflex", type="bool"},
  social_snort = {descr="Snort.", value="yes", group="socials_reflex", type="bool"},
  social_splutter = {descr="Splutter.", value="yes", group="socials_reflex", type="bool"},
  social_swallow = {descr="Swallow.", value="yes", group="socials_reflex", type="bool"},
  social_throatfix = {descr="Clear throat.", value="yes", group="socials_reflex", type="bool"},
  social_yawn = {descr="Yawn.", value="yes", group="socials_reflex", type="bool"},

  -- Individual social toggles - Bodily
  social_belch = {descr="Belch.", value="yes", group="socials_bodily", type="bool"},
  social_blow = {descr="Blow.", value="yes", group="socials_bodily", type="bool"},
  social_bubble = {descr="Bubble.", value="yes", group="socials_bodily", type="bool"},
  social_burp = {descr="Burp.", value="yes", group="socials_bodily", type="bool"},
  social_fart = {descr="Fart.", value="yes", group="socials_bodily", type="bool"},
  social_gag = {descr="Gag.", value="yes", group="socials_bodily", type="bool"},
  social_puke = {descr="Puke.", value="yes", group="socials_bodily", type="bool"},
  social_spit = {descr="Spit.", value="yes", group="socials_bodily", type="bool"},
  social_vomit = {descr="Vomit.", value="yes", group="socials_bodily", type="bool"},

  -- Individual social toggles - Physical
  social_bop = {descr="Bop.", value="yes", group="socials_physical", type="bool"},
  social_bounce = {descr="Bounce.", value="yes", group="socials_physical", type="bool"},
  social_clap = {descr="Clap.", value="yes", group="socials_physical", type="bool"},
  social_collapse = {descr="Collapse.", value="yes", group="socials_physical", type="bool"},
  social_fall = {descr="Fall.", value="yes", group="socials_physical", type="bool"},
  social_flap = {descr="Flap.", value="yes", group="socials_physical", type="bool"},
  social_headdesk = {descr="Headdesk.", value="yes", group="socials_physical", type="bool"},
  social_hop = {descr="Hop.", value="yes", group="socials_physical", type="bool"},
  social_kick = {descr="Kick.", value="yes", group="socials_physical", type="bool"},
  social_kiss = {descr="Kiss.", value="yes", group="socials_physical", type="bool"},
  social_knucklecrack = {descr="Knuckle crack.", value="yes", group="socials_physical", type="bool"},
  social_nudge = {descr="Nudge.", value="yes", group="socials_physical", type="bool"},
  social_poke = {descr="Poke.", value="yes", group="socials_physical", type="bool"},
  social_punch = {descr="Punch.", value="yes", group="socials_physical", type="bool"},
  social_slap = {descr="Slap.", value="yes", group="socials_physical", type="bool"},
  social_snap = {descr="Snap.", value="yes", group="socials_physical", type="bool"},
  social_spank = {descr="Spank.", value="yes", group="socials_physical", type="bool"},
  social_stomp = {descr="Stomp.", value="yes", group="socials_physical", type="bool"},
  social_tackle = {descr="Tackle.", value="yes", group="socials_physical", type="bool"},
  social_twitch = {descr="Twitch.", value="yes", group="socials_physical", type="bool"},

  -- Individual social toggles - Novelty (animals, musical, memes, misc)
  social_airguitar = {descr="Air guitar.", value="yes", group="socials_novelty", type="bool"},
  social_applaud = {descr="Applaud.", value="yes", group="socials_novelty", type="bool"},
  social_beep = {descr="Beep.", value="yes", group="socials_novelty", type="bool"},
  social_boggle = {descr="Boggle.", value="yes", group="socials_novelty", type="bool"},
  social_bongo = {descr="Bongo.", value="yes", group="socials_novelty", type="bool"},
  social_bonk = {descr="Bonk.", value="yes", group="socials_novelty", type="bool"},
  social_boo = {descr="Boo.", value="yes", group="socials_novelty", type="bool"},
  social_cheer = {descr="Cheer.", value="yes", group="socials_novelty", type="bool"},
  social_frog = {descr="Frog.", value="yes", group="socials_novelty", type="bool"},
  social_golfclap = {descr="Golf clap.", value="yes", group="socials_novelty", type="bool"},
  social_growl = {descr="Growl.", value="yes", group="socials_novelty", type="bool"},
  social_hiss = {descr="Hiss.", value="yes", group="socials_novelty", type="bool"},
  social_hoot = {descr="Hoot.", value="yes", group="socials_novelty", type="bool"},
  social_itsatrap = {descr="It's a trap.", value="yes", group="socials_novelty", type="bool"},
  social_khan = {descr="Khan.", value="yes", group="socials_novelty", type="bool"},
  social_mock = {descr="Mock.", value="yes", group="socials_novelty", type="bool"},
  social_moo = {descr="Moo.", value="yes", group="socials_novelty", type="bool"},
  social_noo = {descr="Noo.", value="yes", group="socials_novelty", type="bool"},
  social_oink = {descr="Oink.", value="yes", group="socials_novelty", type="bool"},
  social_pimp = {descr="Pimp.", value="yes", group="socials_novelty", type="bool"},
  social_ponder = {descr="Ponder.", value="yes", group="socials_novelty", type="bool"},
  social_purr = {descr="Purr.", value="yes", group="socials_novelty", type="bool"},
  social_quack = {descr="Quack.", value="yes", group="socials_novelty", type="bool"},
  social_roar = {descr="Roar.", value="yes", group="socials_novelty", type="bool"},
  social_slowclap = {descr="Slow clap.", value="yes", group="socials_novelty", type="bool"},
  social_snarl = {descr="Snarl.", value="yes", group="socials_novelty", type="bool"},
  social_spoon = {descr="Spoon.", value="yes", group="socials_novelty", type="bool"},
  social_squeak = {descr="Squeak.", value="yes", group="socials_novelty", type="bool"},
  social_whistle = {descr="Whistle.", value="yes", group="socials_novelty", type="bool"},
  social_why = {descr="Why.", value="yes", group="socials_novelty", type="bool"},
  social_yess = {descr="Yess.", value="yes", group="socials_novelty", type="bool"},

  dnd_mode = {descr="Do Not Disturb mode (stops all sounds and TTS).", value="no", group="general", type="bool"},
  dnd_wake_on_red = {descr="Disable DND mode when ship goes to red alert (Wake on Red).", value="no", group="general", type="bool"},
  service_comm_interrupt = {descr="Link Recipients (Auction Service, combat mission notification service, etc) bypass foreground sounds.", value="no", group="general", type="bool"},
  count_cannon = {descr="Print remaining cannon shots (use WEAPON command in weapon room to initialize).", value="yes", group="helpers", type="bool"},
  count_praelor = {descr="Print the number of insectoids detected in a room.", value="no", group="room", type="bool"},
  digsite_detector = {descr="Play a sound when detecting a digsite.", value="yes", group="room", type="bool"},
  external_camera = {descr="Gag external camera output.", value="no", group="gags", type="bool"},
  internal_camera = {descr="Gag internal camera output.", value="no", group="gags", type="bool"},
  follow_interrupt = {descr="Interrupt speech when following.", value="no", group="screen reader", type="bool"},
  follow_direction_sounds = {descr="Play direction sounds when following or being dragged.", value="no", group="general", type="bool"},
  friendly_combat = {descr="Gag friendly (non-praelor) sector combat messages.", value="no", group="gags", type="bool"},
  pa_interrupt = {descr="Interrupt speech for public address (PA) messages.", value="no", group="screen reader", type="bool"},
  praelor_interrupt = {descr="Interrupt speech when detecting insectoid activity.", value="no", group="screen reader", type="bool"},
  scan_interrupt = {descr="Interrupt speech for scan coordinates.", value="starships", group="screen reader", type="enum", options={"starships", "everything", "off"}},
  scan_formatting = {descr="Print formatted single-line scan output instead of raw multi-line output.", value="no", group="ship", type="bool"},

  -- Scan format templates (SINGLE SOURCE OF TRUTH)
  -- These templates are used by starmap_scan.lua's formatScanOutput() function
  -- Available variables for Starship: newbie, name, ship_type, alliance, organization, distance, hull_damage, average_component_damage, power, weapons, number_of_occupants, occupancy, cargo, coordinates
  scan_format_starship = {descr="Starships", value="{newbie}{name} ({ship_type}) is {distance} units away, at {coordinates}. Hull {hull_damage}, Avg dmg {average_component_damage}. Power {power}, Weapons {weapons}. {number_of_occupants}{occupancy}. Alliance {alliance}. {organization}{cargo}", group="scan_formats", type="string"},
  -- Available variables for Planet: object_name, classification, distance, coordinates, natural_resources, atmospheric_composition, surface_conditions, hostile_military_occupation
  scan_format_planet = {descr="Planets", value="{object_name}, {classification} planet {distance} units away, at {coordinates}. {natural_resources}{atmospheric_composition}{surface_conditions}{hostile_military_occupation}", group="scan_formats", type="string"},
  -- Available variables for Moon: object_name, distance, orbiting, coordinates, natural_resources, atmospheric_composition
  scan_format_moon = {descr="Moons", value="{object_name}, moon {distance} units away, at {coordinates}, orbiting {orbiting}. {natural_resources}{atmospheric_composition}", group="scan_formats", type="string"},
  -- Available variables for Station: object_name, distance, coordinates, integrity, identifiable_power_sources
  scan_format_station = {descr="Stations", value="{object_name}: Station {distance} units away, at {coordinates}. {integrity}{occupancy}{identifiable_power_sources}", group="scan_formats", type="string"},
  -- Available variables for Asteroid: object_name, size, distance, coordinates, composition, starships, landing_beacons
  scan_format_asteroid = {descr="Asteroids", value="{object_name}: {size} asteroid {distance} units away, at {coordinates}. {composition}{starships}{landing_beacons}", group="scan_formats", type="string"},
  -- Available variables for Star: object_name, classification, distance, coordinates
  scan_format_star = {descr="Stars", value="{object_name}: Class {classification} star {distance} units away, at {coordinates}", group="scan_formats", type="string"},
  -- Available variables for Debris: object_name, type, size, distance, coordinates
  scan_format_debris = {descr="Debris", value="{object_name}: {type} {distance} units away, at {coordinates}", group="scan_formats", type="string"},
  -- Available variables for Proximity Weapon: object_name, distance, coordinates, damage, available_charge, launched_by
  scan_format_weapon = {descr="Proximity Weapons", value="{object_name}: {distance} units away, at {coordinates}. {damage}{available_charge}{launched_by}", group="scan_formats", type="string"},
  -- Available variables for Probe: object_name, distance, coordinates, launched_by
  scan_format_probe = {descr="Video Probes", value="{object_name}: {distance} units away, at {coordinates}. {launched_by}", group="scan_formats", type="string"},
  -- Available variables for Interdictor: object_name, distance, coordinates, launched_by
  scan_format_interdictor = {descr="Interdictors", value="{object_name}: {distance} units away, at {coordinates}. {launched_by}", group="scan_formats", type="string"},
  -- Available variables for Blockade: object_name, distance, coordinates, launched_by
  scan_format_blockade = {descr="Blockades", value="{object_name}: {distance} units away, at {coordinates}. {launched_by}", group="scan_formats", type="string"},
  -- Available variables for Unknown: object_name, distance, coordinates
  scan_format_unknown = {descr="Unknown objects", value="{object_name}: {distance} units away, at {coordinates}", group="scan_formats", type="string"},

  roundtime = {descr="Play a sound when roundtime is up.", value="no", group="general", type="bool"},
  escape_abort = {descr="Use Escape key to send @abort command.", value="yes", group="general", type="bool"},
  tab_activates_notepad = {descr="Use Tab to activate output window instead of tab completion.", value="no", group="general", type="bool"},
  alt_space_shows_exits = {descr="Alt+Space shows exits instead of current history item.", value="yes", group="general", type="bool"},
  secondary_lock = {descr="Play a different sound for unfocus locks.", value="no", group="ship", type="bool"},
  relativity_drive_freq = {descr="Relativity drive frequency.", value="44100", group="ship", type="string"},
  spam = {descr="Reduce spam by gagging flavored text.", value="yes", group="gags", type="bool"},
  store_detector = {descr="Play a sound when detecting stores.", value="no", group="room", type="bool"},
  unchange_coords = {descr="Print 'unchanged' before coordinates if the target has not moved since its last scan.", value="no", group="ship", type="bool"},

  update_idle = {descr="Automatically apply updates while idle.", value="no", group="general", type="bool"},
  update_sound = {descr="Play a sound for pending updates.", value="yes", group="general", type="bool"},

  -- Channel buffers:

  -- default:
  communication_buffer = {descr="Communication (all channels).", value="yes", group="buffers", type="bool"},
  private_buffer = {descr="Private communication.", value="yes", group="buffers", type="bool"},
  combat_buffer = {descr="Combat.", value="yes", group="buffers", type="bool"},
  general_buffer = {descr="General communication.", value="yes", group="buffers", type="bool"},
  url_buffer = {descr="URLs (http, mailto, gofer, etc).", value="yes", group="buffers", type="bool"},

  -- extended:
  camera_buffer = {descr="Camera feeds (droids, internal turrets, external camera).", value="yes", group="buffers", type="bool"},
  market_buffer = {descr="Tradesman market.", value="yes", group="buffers", type="bool"},
  metaf_buffer = {descr="Metafrequency.", value="yes", group="buffers", type="bool"},
  metaf_separate_buffers = {descr="Separate metafrequency buffers by frequency/label.", value="yes", group="buffers", type="bool"},
  flight_buffer = {descr="Flight control.", value="yes", group="buffers", type="bool"},
  say_buffer = {descr="Say communication.", value="yes", group="buffers", type="bool"},
  whisper_buffer = {descr="Whispers.", value="no", group="buffers", type="bool"},
  ooc_buffer = {descr="OOC communication (ROOC, SOOC, OOC channel).", value="yes", group="buffers", type="bool"},
  ship_buffer = {descr="Ship-to-ship communication.", value="no", group="buffers", type="bool"},
  pa_buffer = {descr="Public address speaker (PA).", value="no", group="buffers", type="bool"},
  alliance_buffer = {descr="Alliance communication.", value="no", group="buffers", type="bool"},
  board_buffer = {descr="Message boards.", value="yes", group="buffers", type="bool"},
  chatter_buffer = {descr="Chatter communication.", value="yes", group="buffers", type="bool"},
  computer_buffer = {descr="Starship computer messages.", value="yes", group="buffers", type="bool"},
  design_buffer = {descr="Architectural design channel.", value="yes", group="buffers", type="bool"},
  contributions_buffer = {descr="Credit contributions.", value="yes", group="buffers", type="bool"},
  auction_buffer = {descr="Auctions.", value="yes", group="buffers", type="bool"},
  organization_buffer = {descr="Organization channel.", value="yes", group="buffers", type="bool"},
  courier_buffer = {descr="Courier company channel.", value="yes", group="buffers", type="bool"},
  newbie_buffer = {descr="Newbie Channel.", value="yes", group="buffers", type="bool"},
  hooks_buffer = {descr="Soundpack hooks buffer.", value="no", group="developer", type="bool"},
scan_buffer = {descr="Starship Scans", value="yes", group="buffers", type="bool"},
  rp_buffer = {descr="Roleplay.", value="yes", group="buffers", type="bool"},

  -- Colors --

  background_color = {descr="Default Background:", value=16777215, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  board_color = {descr="Message Board:", value=7346457, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  camera_color = {descr="Camera Feed:", value=16119285, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  combat_color = {descr="Combat:", value=255, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  computer_color = {descr="Computer:", value=12632256, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  default_color = {descr="Default Foreground:", value=0, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  flight_color = {descr="Flight Control:", value=14772545, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  market_color = {descr="Tradesman Market:", value=65535, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  priv_comm_color = {descr="Private Communication:", value=32768, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  pub_comm_color = {descr="Public Communication:", value=13688896, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  info_background_color = {descr="Info-bar background:", value=8421504, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  info_foreground_color = {descr="Info-bar foreground:", value=8388608, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  hyperlink_foreground_color = {descr="Hyperlink foreground:", value=8388736, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},
  hyperlink_background_color = {descr="Hyperlink background:", value=16777215, group="colors", type="function", action="return PickColour(-1)", read="return(RGBColourToName)"},




} -- options

-- Group metadata: defines display titles and sort order for option groups
-- Groups not listed here will appear at the bottom in alphabetical order
local group_metadata = {
  {key = "general", title = "General Settings", order = 1},
  {key = "auto_login", title = "Auto Login", order = 2},
  {key = "ship", title = "Starship Options", order = 3},
  {key = "room", title = "Room and Environment", order = 4},
  {key = "helpers", title = "Helpers and Extras", order = 5},
  {key = "screen reader", title = "Screen Reader Integration", order = 6},
  {key = "gags", title = "Spam and Gag Filters", order = 7},
  {key = "socials", title = "Social Sounds", order = 8},
  {key = "socials_laughter", title = "Socials: Laughter", order = 9},
  {key = "socials_distress", title = "Socials: Distress", order = 10},
  {key = "socials_reflex", title = "Socials: Reflex", order = 11},
  {key = "socials_bodily", title = "Socials: Bodily", order = 12},
  {key = "socials_physical", title = "Socials: Physical", order = 13},
  {key = "socials_novelty", title = "Socials: Novelty", order = 14},
  {key = "scan_formats", title = "Configure Scan Templates", order = 15},
  {key = "buffers", title = "Output Buffers", order = 16},
  {key = "colors", title = "Color Customization", order = 17},
  {key = "audio groups", title = "Toggle Sound Categories", order = 18},
  {key = "sound variants", title = "Sound Variants", order = 19},
  {key = "developer", title = "Developer Options", order = 20},
} -- group_metadata

return {
  options = options,
  group_metadata = group_metadata,
}