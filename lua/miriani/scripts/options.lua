
local options = {
  automatic_changelog = {descr="Automatically open changelog after updates.", value="no", group="general", type="bool"},
  automatic_updates = {descr="Automatically apply updates quietly at login.", value="no", group="general", type="bool"},
  beep_on_keepalive = {descr="Play beep sound on keep-alive messages.", value="no", group="general", type="bool"},
  debug_mode = {descr="Debug notifications (missing audio files, etc).", value="no", group="developer", type="bool"},
  sounds_buffer = {descr="Sound playback log.", value="no", group="developer", type="bool"},
  archaeology_helper_dig = {descr="Buried artifact depth tracker.", value="yes", group="archaeology", type="bool"},
  archaeology_calculate_direction = {descr="Calculate direction from scanner instead of showing coordinates.", value="yes", group="archaeology", type="bool"},
  alternate_audio = {descr="Access alternative audio files before soundpack files (requires sounds/alternate directory).", value="no", group="general", type="bool"},
  background_ambiance = {descr="Play background ambiances.", value="yes", group="room", type="bool"},
  foreground_sounds = {descr="Restrict sounds to only when window has focus.", value="no", group="general", type="bool"},
  count_cannon = {descr="Print remaining cannon shots (use WEAPON command in weapon room to initialize).", value="yes", group="ship", type="bool"},
  count_praelor = {descr="Print the number of insectoids detected in a room.", value="no", group="room", type="bool"},
  digsite_detector = {descr="Play a sound when detecting a digsite.", value="yes", group="room", type="bool"},
  external_camera = {descr="Gag external camera output.", value="no", group="gags", type="bool"},
  internal_camera = {descr="Gag internal camera output.", value="no", group="gags", type="bool"},
  follow_interrupt = {descr="Interrupt speech when following.", value="no", group="screen reader", type="bool"},
  friendly_combat = {descr="Gag friendly (non-praelor) sector combat messages.", value="no", group="gags", type="bool"},
  pa_interrupt = {descr="Interrupt speech for public address (PA) messages.", value="no", group="screen reader", type="bool"},
  praelor_interrupt = {descr="Interrupt speech when detecting insectoid activity.", value="no", group="screen reader", type="bool"},
  scan_interrupt = {descr="Interrupt speech for scan coordinates.", value="starships", group="screen reader", type="enum", options={"starships", "everything", "off"}},
  scan_formatting = {descr="Use formatted single-line scan output instead of raw multi-line output.", value="no", group="ship", type="bool"},

  --ss
  -- Available variables for Starship: newbie, name, ship_type, alliance, organization, distance, hull_damage, average_component_damage, power, weapons, number_of_occupants, occupancy, cargo, coordinates
  scan_format_starship = {descr="Starships", value="{newbie}{name} ({ship_type}) is {distance} units away. Hull {hull_damage}, Avg dmg {average_component_damage}. Power {power}, Weapons {weapons}. {number_of_occupants}{occupancy}. Alliance {alliance}. {organization}{cargo}{coordinates}", group="scan_formats", type="string"},
  -- Available variables for Planet: object_name, classification, distance, coordinates, natural_resources, atmospheric_composition, surface_conditions, hostile_military_occupation
  scan_format_planet = {descr="Planets", value="{object_name}, {classification} planet {distance} units away at {coordinates}. {natural_resources}{atmospheric_composition}{surface_conditions}{hostile_military_occupation}", group="scan_formats", type="string"},
  -- Available variables for Moon: object_name, distance, orbiting, coordinates, natural_resources, atmospheric_composition
  scan_format_moon = {descr="Moons", value="{object_name}, moon {distance} units away, orbiting {orbiting}. {coordinates}. {natural_resources}{atmospheric_composition}", group="scan_formats", type="string"},
  -- Available variables for Station: object_name, distance, coordinates, integrity, identifiable_power_sources
  scan_format_station = {descr="Stations", value="{object_name}: Station {distance} units away, at {coordinates}. {integrity}{occupancy}{identifiable_power_sources}", group="scan_formats", type="string"},
  -- Available variables for Asteroid: object_name, size, distance, coordinates, composition, starships, landing_beacons
  scan_format_asteroid = {descr="Asteroids", value="{object_name}: {size} asteroid {distance} units away. {composition}{starships}{landing_beacons}{coordinates}", group="scan_formats", type="string"},
  -- Available variables for Star: object_name, classification, distance, coordinates
  scan_format_star = {descr="Stars", value="{object_name}: Class {classification} star {distance} units away, at {coordinates}", group="scan_formats", type="string"},
  -- Available variables for Debris: object_name, type, size, distance, coordinates
  scan_format_debris = {descr="Debriss", value="{object_name}: {type} {distance} units away, at {coordinates}", group="scan_formats", type="string"},
  -- Available variables for Proximity Weapon: object_name, distance, coordinates, damage, available_charge, launched_by
  scan_format_weapon = {descr="Proximity Weapons", value="{object_name}: {distance} units distant. {damage}{available_charge}{launched_by}{coordinates}", group="scan_formats", type="string"},
  -- Available variables for Probe: object_name, distance, coordinates, launched_by
  scan_format_probe = {descr="Video Probes", value="{object_name}: {distance} units distant. {launched_by}{coordinates}", group="scan_formats", type="string"},
  -- Available variables for Interdictor: object_name, distance, coordinates, launched_by
  scan_format_interdictor = {descr="Interdictors", value="{object_name}: {distance} units distant. {launched_by}{coordinates}", group="scan_formats", type="string"},
  -- Available variables for Blockade: object_name, distance, coordinates, launched_by
  scan_format_blockade = {descr="Blockades", value="{object_name}: {distance} units distant. {launched_by}{coordinates}", group="scan_formats", type="string"},
  -- Available variables for Unknown: object_name, distance, coordinates
  scan_format_unknown = {descr="Unknown objects", value="{object_name}: {distance} units away, at {coordinates}", group="scan_formats", type="string"},

  roundtime = {descr="Play a sound when roundtime is up.", value="no", group="general", type="bool"},
  escape_abort = {descr="Use Escape key to send @abort command.", value="yes", group="general", type="bool"},
  secondary_lock = {descr="Play a different sound for unfocus locks.", value="no", group="ship", type="bool"},
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
  camera_buffer = {descr="Camera feeds (droids, internals, external).", value="no", group="buffers", type="bool"},
  market_buffer = {descr="Tradesman market.", value="yes", group="buffers", type="bool"},
  metaf_buffer = {descr="Metafrequency.", value="yes", group="buffers", type="bool"},
  metaf_separate_buffers = {descr="Separate metafrequency buffers by frequency/label.", value="yes", group="buffers", type="bool"},
  flight_buffer = {descr="Flight control.", value="yes", group="buffers", type="bool"},
  say_buffer = {descr="Say communication.", value="yes", group="buffers", type="bool"},
  ooc_buffer = {descr="OOC communication (ROOC, SOOC, OOC channel).", value="yes", group="buffers", type="bool"},
  ship_buffer = {descr="Ship-to-ship communication.", value="no", group="buffers", type="bool"},
  pa_buffer = {descr="Public address speaker (PA).", value="no", group="buffers", type="bool"},
  alliance_buffer = {descr="Alliance communication.", value="no", group="buffers", type="bool"},
  board_buffer = {descr="Message boards.", value="yes", group="buffers", type="bool"},
  chatter_buffer = {descr="Chatter communication.", value="no", group="buffers", type="bool"},
  computer_buffer = {descr="Starship computer messages.", value="yes", group="buffers", type="bool"},
  design_buffer = {descr="Architectural design channel.", value="yes", group="buffers", type="bool"},
  contributions_buffer = {descr="Credit contributions.", value="yes", group="buffers", type="bool"},
  auction_buffer = {descr="Auctions.", value="yes", group="buffers", type="bool"},
  hooks_buffer = {descr="Soundpack hooks.", value="no", group="developer", type="bool"},


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
  {key = "ship", title = "Starship Options", order = 2},
  {key = "room", title = "Room and Environment", order = 3},
  {key = "archaeology", title = "Archaeology Helper", order = 4},
  {key = "screen reader", title = "Screen Reader Integration", order = 5},
  {key = "gags", title = "Spam and Gag Filters", order = 6},
  {key = "scan_formats", title = "Configure Scan Templates", order = 7},
  {key = "buffers", title = "Output Buffers", order = 8},
  {key = "colors", title = "Color Customization", order = 9},
  {key = "audio groups", title = "Toggle Sound Categories", order = 10},
  {key = "developer", title = "Developer Options", order = 11},
} -- group_metadata

return {
  options = options,
  group_metadata = group_metadata,
}