-- Defines shared constants across Miriani plugins.

local constants = {}

constants.VERSION = "4.0.02"
constants.EXTENSION = ".ogg"
constants.ALT_EXTENSION = ".ogg"
constants.SOUNDPATH = "miriani/"
constants.ALTPATH = "alternate/"
constants.TOASTUSH_ID = "843d2f53cb3685465bda7d4a"
constants.UPDATE_ID = "508bd88f4d441f81466bf471"
constants.INDEX = "index-v5.manifest"

constants.PROXIANI = "https://github.com/PsudoDeSudo/proxiani"
constants.UPDATE_URL = "https://codeberg.org/miriani-next/miriani-next/raw/branch/main"
constants.IDLE_CUTOFF = 1200







-- sound groups to disable:

constants.minimal_groups = {"ship", "combat", "sounds", "sounds", "misc", "market", "hauling", "asteroid", "archaeology", "planetary mining"}


-- room types:
constants.rooms = {
  starship = {
    cr = "cr",
    eng = "eng",
    storage = "storage",
    weapons = "weapon",
    repair = "eng",
    bay = "bay",
    corridor = "corridor",
    stateroom = "stateroom",
    medical = "starship_medical",
    airlock = "airlock",
    pool = "pool",
    observation = "observation",
    brig = "brig",
    unknown = "starship_unknown",
  }, -- starship

  planet = {
    garage = "garage",
    pool = "pool",
    hottub = "pool",
    observation = "observation",
    unknown = "planet_unknown",
    security = "security",
    lp = "landingpad",

  }, -- station

  station = {
    garage = "garage",
    pool = "pool",
    hottub = "pool",
    observation = "observation",
    unknown = "station_unknown",
    security = "security",
    lp = "landingpad",

  }, -- planet

  room = {

  } -- room
} -- rooms


-- Global table of walkstyle:
constants.walkStyle = {
  ["ambles"] = "amble",
  ["boogies"] = "boogie",
  ["bounces"] = "bounce",
  ["canters"] = "canter",
  ["clomps"] = "clomp",
  ["crawls"] = "crawl",
  ["creeps"] = "creep",
  ["dances"] = "dance",
  ["darts"] = "dart",
  ["dashes"] = "dash",
  ["drags"] = "drag",
  ["flies"] = "fly",
  ["floats"] = "float",
  ["glides"] = "glide",
  ["hastens"] = "hasten",
  ["hobble"] = "hobble",
  ["hops"] = "hop",
  ["hurries"] = "hurry",
  ["jogs"] = "jog",
  ["leeps"] = "leap",
  ["limps"] = "limp",
  ["lumbers"] = "lumber",
  ["marches"] = "march",
  ["meanders"] = "meander",
  ["moonwalks"] = "moonwalk",
  ["moseys"] = "mosey",
  ["plods"] = "plod",
  ["parades"] = "parade",
  ["perambulates"] = "perambulate",
  ["prances"] = "prance",
  ["races"] = "race",
  ["rides"] = "ride",
  ["runs"] = "run",
  ["rushes"] = "rush",
  ["sashays"] = "sashay",
  ["saunters"] = "saunter",
  ["scampers"] = "scamper",
  ["scrambles"] = "scramble",
  ["scurries"] = "scurry",
  ["scuttles"] = "scuttle",
  ["shuffles"] = "shuffle",
  ["skates"] = "skate",
  ["skips"] = "skip",
  ["slinks"] = "slink",
  ["slouches"] = "slouch",
  ["sprints"] = "sprint",
  ["staggers"] = "stagger",
  ["stalks"] = "stalk",
  ["stomps"] = "stomp",
  ["storms"] = "storm",
  ["strides"] = "stride",
  ["strolls"] = "stroll",
  ["struts"] = "strut",
  ["stumbles"] = "stumble",
  ["swaggers"] = "swagger",
  ["swims"] = "swim",
  ["tiptoes"] = "tiptoe",
  ["traipses"] = "traipse",
  ["tramps"] = "tramp",
  ["trots"] = "trot",
  ["trudges"] = "trudge",
  ["twirls"] = "twirl",
  ["waddles"] = "waddle",
  ["walks"] = "walk"
} -- table of walk-styles

return constants
