
local options = {
  automatic_changelog = {descr="Automatically open changelog after updates?", value="no", group="general", type="bool"},
  automatic_updates = {descr="Automatically apply updates quietly at login?", value="no", group="general", type="bool"},
  debug_mode = {descr="Enable debug notifications (missing audio files, etc).", value="no", group="general", type="bool"},
  archaeology_helper_dig = {descr="Buried artifact digging tracker.", value="yes", group="archaeology", type="bool"},
  alternate_audio = {descr="Access alternative audio files before soundpack files? Note you must create the sounds/alternate directory for this change to take affect.", value="no", group="general", type="bool"},
  background_ambiance = {descr="Play background ambiances.", value="yes", group="room", type="bool"},
  foreground_sounds = {descr="Restrict sounds to only when window has focus.", value="no", group="general", type="bool"},
  computer_voice = {descr="Use computerized voice files.", value="no", group="ship", type="bool"},
  count_cannon = {descr="Print remaining cannon shots: Use the command WEAPON in a weapon's room to initialize.", value="no", group="ship", type="bool"},
  count_praelor = {descr="Print the number of insectoids detected in a room.", value="no", group="room", type="bool"},
  digsite_detector = {descr="Play a sound when detecting a digsite.", value="no", group="room", type="bool"},
  external_camera = {descr="Gag external camera output.", value="no", group="gags", type="bool"},
  internal_camera = {descr="Gag internal camera output.", value="no", group="gags", type="bool"},
  focus_interrupt = {descr="Interrupt speech on focus.", value="no", group="screen reader", type="bool"},
  follow_interrupt = {descr="Interrupt speech when following.", value="no", group="screen reader", type="bool"},
  friendly_combat = {descr="Gag friendly (non praelor) sector combat messages.", value="no", group="gags", type="bool"},
  pa_interrupt = {descr="Interrupt speech for public address (PA) messages.", value="no", group="screen reader", type="bool"},
  praelor_interrupt = {descr="Interrupt speech when detecting insectoid activity.", value="no", group="screen reader", type="bool"},
  scan_interrupt = {descr="Interrupt speech for scan coordinates.", value="no", group="screen reader", type="bool"},
  roundtime = {descr="Play a sound when roundtime is up.", value="no", group="general", type="bool"},
  escape_abort = {descr="Use Escape key to send @abort command.", value="yes", group="general", type="bool"},
  secondary_lock = {descr="Play a different sound for unfocus locks.", value="no", group="ship", type="bool"},
  spam = {descr="Cutback on spam by gagging flavored text.", value="yes", group="gags", type="bool"},
  store_detector = {descr="Play a sound when detecting stores.", value="no", group="room", type="bool"},
  unchange_coords = {descr="Print 'unchanged' before coordinates if the target has not moved since its last scan.", value="no", group="ship", type="bool"},

  update_idle = {descr="Automatically apply updates while idle?", value="no", group="general", type="bool"},
  update_sound = {descr="Play a sound for pending updates.", value="yes", group="general", type="bool"},

  -- Channel buffers:

  -- default:
  communication_buffer = {descr="Communication: (all channels)", value="yes", group="buffers", type="bool"},
  private_buffer = {descr="Private Communication", value="yes", group="buffers", type="bool"},
  combat_buffer = {descr="Combat (Praelor, ship-locks)", value="yes", group="buffers", type="bool"},
  general_buffer = {descr="General Communication", value="yes", group="buffers", type="bool"},
  url_buffer = {descr="URLs (http, mailto, gofer, etc)", value="yes", group="buffers", type="bool"},

  -- extended:
  camera_buffer = {descr="Camera Feeds(droids, internals, external)", value="no", group="buffers", type="bool"},
  market_buffer = {descr="Tradesman Market", value="no", group="buffers", type="bool"},
  metaf_buffer = {descr="Metafrequency", value="no", group="buffers", type="bool"},
  metaf_separate_buffers = {descr="Separate metafrequency buffers by frequency/label", value="yes", group="buffers", type="bool"},
  flight_buffer = {descr="Flight Control", value="no", group="buffers", type="bool"},
  say_buffer = {descr="Say Communication", value="no", group="buffers", type="bool"},
  ooc_buffer = {descr="OOC Communication (ROOC, SOOC, OOC channel)", value="no", group="buffers", type="bool"},
  ship_buffer = {descr="Ship-to-ship Communication", value="no", group="buffers", type="bool"},
  pa_buffer = {descr="Public Address speaker (PA)", value="no", group="buffers", type="bool"},
  alliance_buffer = {descr="Alliance Communication", value="no", group="buffers", type="bool"},
  board_buffer = {descr="Message Board", value="no", group="buffers", type="bool"},
  chatter_buffer = {descr="Chatter Communication", value="no", group="buffers", type="bool"},
  computer_buffer = {descr="Starship Computer Messages", value="no", group="buffers", type="bool"},
  design_buffer = {descr="Architectural design channel.", value="no", group="buffers", type="bool"},
  hooks_buffer = {descr="Soundpack Hooks:", value="no", group="buffers", type="bool"},


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

return options