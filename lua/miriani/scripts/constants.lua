-- Defines shared constants across Miriani plugins.

local version = require("miriani.scripts.version")
local constants = {}

constants.VERSION = version.version_string()
constants.EXTENSION = ".ogg"
constants.ALT_EXTENSION = ".ogg"
constants.SOUNDPATH = "miriani/"
constants.ALTPATH = "alternate/"
constants.TOASTUSH_ID = "843d2f53cb3685465bda7d4a"
constants.UPDATE_ID = "706cd88f4d441a81439bd421"

constants.PROXIANI = "https://github.com/PsudoDeSudo/proxiani"
constants.UPDATE_URL = "https://codeberg.org/miriani-next/miriani-next/raw/branch/main"
constants.IDLE_CUTOFF = 1200







-- sound groups to disable:

constants.minimal_groups = {"ship", "combat", "sounds", "misc", "market", "hauling", "asteroid", "archaeology", "planetary mining"}


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
  ["leaps"] = "leap",
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
